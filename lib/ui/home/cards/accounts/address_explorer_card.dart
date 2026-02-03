// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

/// Represents address information with usage and balance data
class AddressInfo {
  final int index;
  final String address;
  final int balanceSats;
  final bool isUsed;
  final bool isCurrentReceiveAddress;

  AddressInfo({
    required this.index,
    required this.address,
    required this.balanceSats,
    required this.isUsed,
    required this.isCurrentReceiveAddress,
  });
}

/// Filter options for the address explorer
enum AddressFilter { used, unused, zeroBalance }

/// Sort options for the address explorer
enum AddressSort { none, highestValue, lowestValue }

class AddressExplorerCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  AddressExplorerCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<AddressExplorerCard> createState() =>
      _AddressExplorerCardState();
}

class _AddressExplorerCardState extends ConsumerState<AddressExplorerCard> {
  List<AddressInfo> _addresses = [];
  List<AddressInfo> _filteredAddresses = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  Set<AddressFilter> _activeFilters = {};
  AddressSort _sortOption = AddressSort.none;

  // Address type toggle: true = Receive (external), false = Change (internal)
  bool _isReceiveAddresses = true;

  // Pagination
  static const int _loadCount = 50;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state =
          S().exploreAdresses_activityOptions_exploreAddresses.toUpperCase();
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });

    _loadAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    final handler = widget.account.handler;
    if (handler == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final account = ref.read(accountStateProvider(widget.account.id));
      if (account == null) return;

      // Get the preferred address type
      final addressType = account.preferredAddressType;

      // Get current receive address
      final currentAddress = account.nextAddress
          .firstWhere(
            (record) => record.$2 == addressType,
            orElse: () => ('', addressType),
          )
          .$1;

      // Peek addresses from wallet
      final peekedAddresses = await handler.peekAddresses(
        addressType: addressType,
        fromIndex: 0,
        toIndex: _loadCount,
        isChange: !_isReceiveAddresses,
      );

      // Build address usage and balance map from transactions and UTXOs
      final addressBalances = <String, int>{};
      final usedAddresses = <String>{};

      // Get balances from UTXOs
      for (final utxo in account.utxo) {
        final addr = utxo.address;
        addressBalances[addr] =
            (addressBalances[addr] ?? 0) + utxo.amount.toInt();
      }

      // Get used addresses from transaction outputs
      for (final tx in account.transactions) {
        for (final output in tx.outputs) {
          if (output.keychain == KeyChain.external_) {
            usedAddresses.add(output.address);
          }
        }
      }

      // Build AddressInfo list
      final addresses = peekedAddresses.map((tuple) {
        final (index, address) = tuple;
        final balance = addressBalances[address] ?? 0;
        final isUsed = usedAddresses.contains(address) || balance > 0;

        return AddressInfo(
          index: index,
          address: address,
          balanceSats: balance,
          isUsed: isUsed,
          isCurrentReceiveAddress: address == currentAddress,
        );
      }).toList();

      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<AddressInfo>.from(_addresses);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((addr) =>
              addr.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              addr.index.toString().contains(_searchQuery))
          .toList();
    }

    // Apply receive only filter (External addresses only - which is what we get from peekAddresses)
    // This is already the case since we only peek External keychain

    // Apply active filters
    if (_activeFilters.isNotEmpty) {
      filtered = filtered.where((addr) {
        if (_activeFilters.contains(AddressFilter.used) && !addr.isUsed) {
          return false;
        }
        if (_activeFilters.contains(AddressFilter.unused) && addr.isUsed) {
          return false;
        }
        if (_activeFilters.contains(AddressFilter.zeroBalance) &&
            addr.balanceSats > 0) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case AddressSort.highestValue:
        filtered.sort((a, b) => b.balanceSats.compareTo(a.balanceSats));
        break;
      case AddressSort.lowestValue:
        filtered.sort((a, b) => a.balanceSats.compareTo(b.balanceSats));
        break;
      case AddressSort.none:
        // Keep original order (by index)
        break;
    }

    setState(() {
      _filteredAddresses = filtered;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterModal(
        activeFilters: _activeFilters,
        sortOption: _sortOption,
        onApply: (filters, sort) {
          setState(() {
            _activeFilters = filters;
            _sortOption = sort;
          });
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onAddressTap(AddressInfo addressInfo) {
    if (addressInfo.isUsed && !addressInfo.isCurrentReceiveAddress) {
      _showUsedAddressWarning(addressInfo);
    } else {
      _copyAddress(addressInfo.address);
    }
  }

  Future<void> _showUsedAddressWarning(AddressInfo addressInfo) async {
    final dismissed = await EnvoyStorage()
        .checkPromptDismissed(DismissiblePrompt.usedAddressWarning);

    if (dismissed) {
      _copyAddress(addressInfo.address);
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _UsedAddressWarningDialog(
        onBackToList: () => Navigator.pop(context),
        onShowAddress: () {
          Navigator.pop(context);
          _copyAddress(addressInfo.address);
        },
        onDontShowAgain: (value) {
          if (value) {
            EnvoyStorage().addPromptState(DismissiblePrompt.usedAddressWarning);
          }
        },
      ),
    );
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    EnvoyToast(
      backgroundColor: EnvoyColors.accentPrimary,
      replaceExisting: true,
      duration: const Duration(seconds: 2),
      message: "Address copied to clipboard", // TODO: Add to l10n
      icon: const EnvoyIcon(
        EnvoyIcons.check,
        color: EnvoyColors.textPrimaryInverse,
      ),
    ).show(context, rootNavigator: true);
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountStateProvider(widget.account.id));

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.medium1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: EnvoySpacing.medium1),
                  child: EnvoyIcon(
                    EnvoyIcons.search,
                    color: EnvoyColors.textTertiary,
                    size: EnvoyIconSize.small,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Enter address", // TODO: Add to l10n
                      hintStyle: EnvoyTypography.body
                          .copyWith(color: EnvoyColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.small,
                        vertical: EnvoySpacing.medium1,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final currentAddress = account?.nextAddress
                        .firstWhere(
                          (record) => record.$2 == account.preferredAddressType,
                          orElse: () => ('', account.preferredAddressType),
                        )
                        .$1;
                    if (currentAddress != null && currentAddress.isNotEmpty) {
                      _copyAddress(currentAddress);
                    }
                  },
                  icon: const EnvoyIcon(
                    EnvoyIcons.copy,
                    color: EnvoyColors.textTertiary,
                    size: EnvoyIconSize.small,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: QR scanner
                  },
                  icon: EnvoyIcon(
                    EnvoyIcons.qr_scan,
                    color: EnvoyColors.textTertiary,
                    size: EnvoyIconSize.small,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Row(
            children: [
              // Receive/Change toggle
              _AddressTypeToggle(
                isReceive: _isReceiveAddresses,
                onToggle: (isReceive) {
                  setState(() {
                    _isReceiveAddresses = isReceive;
                  });
                  _loadAddresses();
                },
              ),
              const SizedBox(width: EnvoySpacing.small),
              GestureDetector(
                onTap: _loadAddresses,
                child: Container(
                  padding: const EdgeInsets.all(EnvoySpacing.small),
                  decoration: BoxDecoration(
                    color: EnvoyColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const EnvoyIcon(
                    EnvoyIcons.refresh,
                    color: EnvoyColors.textSecondary,
                    size: EnvoyIconSize.small,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.all(EnvoySpacing.small),
                  decoration: BoxDecoration(
                    color: _activeFilters.isNotEmpty ||
                            _sortOption != AddressSort.none
                        ? EnvoyColors.accentPrimary.withValues(alpha: 0.1)
                        : EnvoyColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: EnvoyIcon(
                    EnvoyIcons.filter,
                    color: _activeFilters.isNotEmpty ||
                            _sortOption != AddressSort.none
                        ? EnvoyColors.accentPrimary
                        : EnvoyColors.textSecondary,
                    size: EnvoyIconSize.small,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: EnvoySpacing.medium1),

        // Address list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAddresses.isEmpty
                  ? Center(
                      child: Text(
                        "No addresses found", // TODO: Add to l10n
                        style: EnvoyTypography.body
                            .copyWith(color: EnvoyColors.textTertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1,
                      ),
                      itemCount: _filteredAddresses.length,
                      itemBuilder: (context, index) {
                        final addressInfo = _filteredAddresses[index];
                        return _AddressListItem(
                          addressInfo: addressInfo,
                          account: account!,
                          onTap: () => _onAddressTap(addressInfo),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _AddressTypeToggle extends StatelessWidget {
  final bool isReceive;
  final Function(bool) onToggle;

  const _AddressTypeToggle({
    required this.isReceive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EnvoyColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Receive button
          GestureDetector(
            onTap: () => onToggle(true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.small,
              ),
              decoration: BoxDecoration(
                color:
                    isReceive ? EnvoyColors.accentPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EnvoyIcon(
                    EnvoyIcons.receive,
                    color: isReceive
                        ? EnvoyColors.textPrimaryInverse
                        : EnvoyColors.textSecondary,
                    size: EnvoyIconSize.extraSmall,
                  ),
                  const SizedBox(width: EnvoySpacing.xs),
                  Text(
                    "Receive", // TODO: Add to l10n
                    style: EnvoyTypography.label.copyWith(
                      color: isReceive
                          ? EnvoyColors.textPrimaryInverse
                          : EnvoyColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Change button
          GestureDetector(
            onTap: () => onToggle(false),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.small,
              ),
              decoration: BoxDecoration(
                color:
                    !isReceive ? EnvoyColors.accentPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EnvoyIcon(
                    EnvoyIcons.send,
                    color: !isReceive
                        ? EnvoyColors.textPrimaryInverse
                        : EnvoyColors.textSecondary,
                    size: EnvoyIconSize.extraSmall,
                  ),
                  const SizedBox(width: EnvoySpacing.xs),
                  Text(
                    "Change", // TODO: Add to l10n
                    style: EnvoyTypography.label.copyWith(
                      color: !isReceive
                          ? EnvoyColors.textPrimaryInverse
                          : EnvoyColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressListItem extends StatelessWidget {
  final AddressInfo addressInfo;
  final EnvoyAccount account;
  final VoidCallback onTap;

  const _AddressListItem({
    required this.addressInfo,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlighted =
        addressInfo.isUsed && !addressInfo.isCurrentReceiveAddress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium1,
          vertical: EnvoySpacing.small,
        ),
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: EnvoyColors.border1,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Index
            SizedBox(
              width: 24,
              child: Text(
                "${addressInfo.index}:",
                style: EnvoyTypography.body.copyWith(
                  color: isHighlighted
                      ? EnvoyColors.accentPrimary
                      : EnvoyColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: EnvoySpacing.small),

            // Address (truncated)
            Expanded(
              child: Text(
                _formatAddress(addressInfo.address),
                style: EnvoyTypography.body.copyWith(
                  color: isHighlighted
                      ? EnvoyColors.accentPrimary
                      : EnvoyColors.textPrimary,
                ),
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                EnvoyAmount(
                  account: account,
                  amountSats: addressInfo.balanceSats,
                  amountWidgetStyle: AmountWidgetStyle.singleLine,
                ),
                if (Settings().selectedFiat != null)
                  Text(
                    _formatFiatAmount(addressInfo.balanceSats),
                    style: EnvoyTypography.label.copyWith(
                      color: EnvoyColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 20) return address;
    return "${address.substring(0, 8)} ... ${address.substring(address.length - 8)}";
  }

  String _formatFiatAmount(int sats) {
    final fiatValue = ExchangeRate().getUsdValue(sats);
    return "\$${fiatValue.toStringAsFixed(2)}";
  }
}

class _FilterModal extends StatefulWidget {
  final Set<AddressFilter> activeFilters;
  final AddressSort sortOption;
  final Function(Set<AddressFilter>, AddressSort) onApply;

  const _FilterModal({
    required this.activeFilters,
    required this.sortOption,
    required this.onApply,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late Set<AddressFilter> _filters;
  late AddressSort _sort;

  @override
  void initState() {
    super.initState();
    _filters = Set.from(widget.activeFilters);
    _sort = widget.sortOption;
  }

  void _toggleFilter(AddressFilter filter) {
    setState(() {
      if (_filters.contains(filter)) {
        _filters.remove(filter);
      } else {
        // Used and Unused are mutually exclusive
        if (filter == AddressFilter.used) {
          _filters.remove(AddressFilter.unused);
        } else if (filter == AddressFilter.unused) {
          _filters.remove(AddressFilter.used);
        }
        _filters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: EnvoySpacing.medium2,
        right: EnvoySpacing.medium2,
        top: EnvoySpacing.medium2,
        bottom: MediaQuery.of(context).viewInsets.bottom + EnvoySpacing.medium2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EnvoyColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: EnvoySpacing.medium2),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter", // TODO: Add to l10n
                style: EnvoyTypography.subheading,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _filters.clear();
                  });
                },
                child: Text(
                  "Reset filter", // TODO: Add to l10n
                  style: EnvoyTypography.body.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnvoySpacing.medium1),

          // Filter chips
          Wrap(
            spacing: EnvoySpacing.small,
            runSpacing: EnvoySpacing.small,
            children: [
              _ModalFilterChip(
                label: S().exploreAddresses_listFilter_used,
                icon: EnvoyIcons.alert,
                isSelected: _filters.contains(AddressFilter.used),
                onTap: () => _toggleFilter(AddressFilter.used),
              ),
              _ModalFilterChip(
                label: S().exploreAddresses_listFilter_unused,
                icon: EnvoyIcons.check,
                isSelected: _filters.contains(AddressFilter.unused),
                onTap: () => _toggleFilter(AddressFilter.unused),
              ),
              _ModalFilterChip(
                label: S().exploreAddresses_listFilter_zeroBalance,
                icon: EnvoyIcons.btc,
                isSelected: _filters.contains(AddressFilter.zeroBalance),
                onTap: () => _toggleFilter(AddressFilter.zeroBalance),
              ),
            ],
          ),

          const SizedBox(height: EnvoySpacing.medium2),

          // Sort header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sort by", // TODO: Add to l10n
                style: EnvoyTypography.subheading,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sort = AddressSort.none;
                  });
                },
                child: Text(
                  "Reset sorting", // TODO: Add to l10n
                  style: EnvoyTypography.body.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnvoySpacing.medium1),

          // Sort options
          _SortOption(
            label: S().filter_sortBy_highest,
            isSelected: _sort == AddressSort.highestValue,
            onTap: () {
              setState(() {
                _sort = AddressSort.highestValue;
              });
            },
          ),
          _SortOption(
            label: S().filter_sortBy_lowest,
            isSelected: _sort == AddressSort.lowestValue,
            onTap: () {
              setState(() {
                _sort = AddressSort.lowestValue;
              });
            },
          ),

          const SizedBox(height: EnvoySpacing.medium2),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: EnvoyButton(
              "Apply", // TODO: Add to l10n
              onTap: () => widget.onApply(_filters, _sort),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalFilterChip extends StatelessWidget {
  final String label;
  final EnvoyIcons icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModalFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium1,
          vertical: EnvoySpacing.small,
        ),
        decoration: BoxDecoration(
          color: isSelected ? EnvoyColors.accentPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? EnvoyColors.accentPrimary : EnvoyColors.border1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EnvoyIcon(
              icon,
              color: isSelected
                  ? EnvoyColors.textPrimaryInverse
                  : EnvoyColors.textSecondary,
              size: EnvoyIconSize.extraSmall,
            ),
            const SizedBox(width: EnvoySpacing.xs),
            Text(
              label,
              style: EnvoyTypography.label.copyWith(
                color: isSelected
                    ? EnvoyColors.textPrimaryInverse
                    : EnvoyColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? EnvoyColors.accentPrimary
                      : EnvoyColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: EnvoyColors.accentPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: EnvoySpacing.medium1),
            Text(
              label,
              style: EnvoyTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsedAddressWarningDialog extends StatefulWidget {
  final VoidCallback onBackToList;
  final VoidCallback onShowAddress;
  final Function(bool) onDontShowAgain;

  const _UsedAddressWarningDialog({
    required this.onBackToList,
    required this.onShowAddress,
    required this.onDontShowAgain,
  });

  @override
  State<_UsedAddressWarningDialog> createState() =>
      _UsedAddressWarningDialogState();
}

class _UsedAddressWarningDialogState extends State<_UsedAddressWarningDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EnvoyIcon(
              EnvoyIcons.alert,
              color: EnvoyColors.accentSecondary,
              size: EnvoyIconSize.big,
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Text(
              "Warning", // TODO: Add to l10n
              style: EnvoyTypography.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Text(
              "This address has been used at least once. When receiving Bitcoin it is a privacy best practice to use a new address.", // TODO: Add to l10n
              style: EnvoyTypography.info.copyWith(
                color: EnvoyColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: EnvoySpacing.small),
            GestureDetector(
              onTap: () {
                // TODO: Open learn more link
              },
              child: Text(
                "Learn more", // TODO: Add to l10n
                style: EnvoyTypography.body.copyWith(
                  color: EnvoyColors.accentPrimary,
                ),
              ),
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontShowAgain = value ?? false;
                    });
                    widget.onDontShowAgain(_dontShowAgain);
                  },
                  activeColor: EnvoyColors.accentPrimary,
                ),
                Text(
                  "Don't show again", // TODO: Add to l10n
                  style: EnvoyTypography.body,
                ),
              ],
            ),
            const SizedBox(height: EnvoySpacing.medium1),
            SizedBox(
              width: double.infinity,
              child: EnvoyButton(
                "Back to List", // TODO: Add to l10n
                type: EnvoyButtonTypes.secondary,
                onTap: widget.onBackToList,
              ),
            ),
            const SizedBox(height: EnvoySpacing.small),
            SizedBox(
              width: double.infinity,
              child: EnvoyButton(
                "Show Address", // TODO: Add to l10n
                onTap: widget.onShowAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
