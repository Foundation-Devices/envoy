// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/filter_chip.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/new_envoy_color.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/components/pop_up.dart';

import '../../../components/envoy_loaders.dart';

/// Represents address information with usage and balance data
class AddressInfo {
  final int index;
  final String address;
  final int balanceSats;
  final bool isUsed;
  final bool isCurrentReceiveAddress;
  final bool isChange;

  AddressInfo({
    required this.index,
    required this.address,
    required this.balanceSats,
    required this.isUsed,
    required this.isCurrentReceiveAddress,
    required this.isChange,
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

  // Filter state - all filters selected by default (show all)
  Set<AddressFilter> _activeFilters = {
    AddressFilter.used,
    AddressFilter.unused,
    AddressFilter.zeroBalance,
  };
  AddressSort _sortOption = AddressSort.none;

  // Address type toggle: true = Receive (external), false = Change (internal)
  bool _isReceiveAddresses = true;

  // Pagination and search
  static const int _loadCount = 50;
  int _searchedAddressCount = _loadCount;
  bool _isContinueSearching = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });

    _loadAddresses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses({bool resetSearchCount = true}) async {
    setState(() {
      _isLoading = true;
      if (resetSearchCount) {
        _searchedAddressCount = _loadCount;
      }
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
        toIndex: _searchedAddressCount,
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
      final isChange = !_isReceiveAddresses;
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
          isChange: isChange,
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

  Future<void> _continueSearching() async {
    setState(() {
      _isContinueSearching = true;
      _searchedAddressCount += _loadCount;
    });

    await _loadAddresses(resetSearchCount: false);

    setState(() {
      _isContinueSearching = false;
    });
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

    // Apply active filters (selected = show, unselected = hide)
    filtered = filtered.where((addr) {
      // If "used" is not selected, hide used addresses
      if (!_activeFilters.contains(AddressFilter.used) && addr.isUsed) {
        return false;
      }
      // If "unused" is not selected, hide unused addresses
      if (!_activeFilters.contains(AddressFilter.unused) && !addr.isUsed) {
        return false;
      }
      // If "zeroBalance" is not selected, hide zero balance addresses
      if (!_activeFilters.contains(AddressFilter.zeroBalance) &&
          addr.balanceSats == 0) {
        return false;
      }
      return true;
    }).toList();

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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.large1),
      child: Text(
        S().exploreAddresses_searchError_notFound,
        // TODO: fix localazy
        // "Address not found in the first $_searchedAddressCount addresses.",
        style: EnvoyTypography.info.copyWith(
          color: EnvoyColors.contentSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
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
      _navigateToAddressDetail(addressInfo);
    }
  }

  void _navigateToAddressDetail(AddressInfo addressInfo) {
    context.push(
      ROUTE_ACCOUNT_ADDRESS_DETAIL,
      extra: {
        'account': widget.account,
        'addressInfo': addressInfo,
      },
    );
  }

  Future<void> _showUsedAddressWarning(AddressInfo addressInfo) async {
    final dismissed = await EnvoyStorage()
        .checkPromptDismissed(DismissiblePrompt.usedAddressWarning);

    if (dismissed) {
      _navigateToAddressDetail(addressInfo);
      return;
    }

    if (!mounted) return;

    showEnvoyPopUp(
      context,
      S().exploreAddresses_listModal_content,
      S().exploreAddresses_listModal_showAddress,
      (context) {
        Navigator.of(context).pop();
        _navigateToAddressDetail(addressInfo);
      },
      icon: EnvoyIcons.alert,
      title: S().component_warning,
      typeOfMessage: PopUpState.warning,
      secondaryButtonLabel: S().exploreAddresses_listModal_backToList,
      onSecondaryButtonTap: (context) => Navigator.of(context).pop(),
      checkBoxText: S().component_dontShowAgain,
      checkedValue: false,
      showCloseButton: false,
      onCheckBoxChanged: (checked) {
        if (checked) {
          EnvoyStorage().addPromptState(DismissiblePrompt.usedAddressWarning);
        }
      },
      onLearnMore: () {
        // TODO: Open learn more link
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountStateProvider(widget.account.id));

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.medium1),
          child: _AddressSearchEntry(
            controller: _searchController,
            onChanged: (value) {
              final queryChanged = _searchQuery != value;
              setState(() {
                _searchQuery = value;
                // Reset search count when query changes
                if (queryChanged && _searchedAddressCount > _loadCount) {
                  _searchedAddressCount = _loadCount;
                }
              });
              // Reload addresses if we had expanded the search before
              if (queryChanged && _addresses.length > _loadCount) {
                _loadAddresses();
              } else {
                _applyFilters();
              }
            },
          ),
        ),

        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Row(
            children: [
              // Receive/Change toggle
              SlidingToggle(
                value: _isReceiveAddresses ? "Receive" : "Change",
                firstValue: "Receive",
                secondValue: "Change",
                firstLabel: S().receive_tx_list_receive,
                secondLabel: S().receive_tx_list_change,
                firstIcon: EnvoyIcons.receive,
                secondIcon: EnvoyIcons.change,
                backgroundColor: EnvoyColors.surface3,
                onChange: (value) {
                  setState(() {
                    _isReceiveAddresses = value == "Receive";
                  });
                  _loadAddresses();
                },
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showFilterModal,
                child: Container(
                  padding: const EdgeInsets.all(EnvoySpacing.small),
                  decoration: BoxDecoration(
                    color: _activeFilters.length < 3 ||
                            _sortOption != AddressSort.none
                        ? EnvoyColors.accentPrimary
                        : EnvoyColors.surface3,
                    borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
                  ),
                  child: EnvoyIcon(
                    EnvoyIcons.filter,
                    color: _activeFilters.length < 3 ||
                            _sortOption != AddressSort.none
                        ? EnvoyColors.solidWhite
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
                  ? _buildEmptyState()
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
        // Continue Searching button (shown when search has no results)
        if (_searchQuery.isNotEmpty &&
            _filteredAddresses.isEmpty &&
            !_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.medium1,
              vertical: EnvoySpacing.large2,
            ),
            child: SizedBox(
              width: double.infinity,
              child: EnvoyButton(
                _isContinueSearching
                    ? S().component_searching
                    : S().exploreAddresses_searchError_continueSearching,
                onTap: _isContinueSearching ? null : _continueSearching,
                leading: _isContinueSearching
                    ? EnvoyActivityIndicator(
                        color: EnvoyColors.solidWhite,
                        radius: EnvoySpacing.small,
                      )
                    : null,
              ),
            ),
          ),
        if (!(_searchQuery.isNotEmpty &&
            _filteredAddresses.isEmpty &&
            !_isLoading))
          const SizedBox(height: EnvoySpacing.large1),
      ],
    );
  }
}

class _AddressSearchEntry extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const _AddressSearchEntry({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_AddressSearchEntry> createState() => _AddressSearchEntryState();
}

class _AddressSearchEntryState extends State<_AddressSearchEntry> {
  final double _verticalPadding = EnvoySpacing.medium1;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
      child: Container(
        decoration: BoxDecoration(
          color: EnvoyColors.surface3,
          borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search icon
                Padding(
                  padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                  child: const EnvoyIcon(
                    EnvoyIcons.search,
                    size: EnvoyIconSize.extraSmall,
                    color: EnvoyColors.textTertiary,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small),
                  child: Container(
                    width: 1,
                    color: EnvoyColors.textTertiary.withValues(alpha: 0.3),
                  ),
                ),

                // Text field
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: _verticalPadding, bottom: _verticalPadding),
                    child: TextField(
                      controller: widget.controller,
                      style: EnvoyTypography.body,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        widget.onChanged(value);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: S().send_keyboard_enterAddress,
                        hintStyle: EnvoyTypography.body.copyWith(
                          color: EnvoyColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                // Clear button
                if (widget.controller.text.isNotEmpty)
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: EnvoyColors.textTertiary,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        widget.controller.text = "";
                      });
                      widget.onChanged("");
                    },
                  ),

                // Paste button
                if (widget.controller.text.isEmpty)
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                      child: const EnvoyIcon(
                        EnvoyIcons.clipboard,
                        size: EnvoyIconSize.extraSmall,
                        color: EnvoyColors.accentPrimary,
                      ),
                    ),
                    onTap: () async {
                      ClipboardData? cdata =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      String? text = cdata?.text;
                      if (text != null) {
                        setState(() {
                          widget.controller.text = text;
                        });
                        widget.onChanged(text);
                      }
                    },
                  ),

                // Separator before QR
                if (widget.controller.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.small),
                    child: Container(
                      width: 1,
                      color: EnvoyColors.textTertiary.withValues(alpha: 0.3),
                    ),
                  ),

                // QR scanner button
                if (widget.controller.text.isEmpty)
                  InkWell(
                    borderRadius: BorderRadius.circular(EnvoySpacing.large3),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                      child: const EnvoyIcon(
                        EnvoyIcons.scan,
                        color: EnvoyColors.accentPrimary,
                        size: EnvoyIconSize.extraSmall,
                      ),
                    ),
                    onTap: () {
                      showScannerDialog(
                        context: context,
                        onBackPressed: (context) {
                          Navigator.pop(context);
                        },
                        decoder: GenericQrDecoder(
                          onScan: (code) {
                            Navigator.of(context, rootNavigator: true).pop();
                            setState(() {
                              widget.controller.text = code;
                            });
                            widget.onChanged(code);
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
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
          horizontal: EnvoySpacing.small,
          vertical: EnvoySpacing.small,
        ),
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: NewEnvoyColor.borderTertiary,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index
            Text(
              "${addressInfo.index}:",
              style: EnvoyTypography.body.copyWith(
                color: isHighlighted
                    ? NewEnvoyColor.contentNotice
                    : EnvoyColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: EnvoySpacing.small),

            // Address (truncated)
            Expanded(
              child: Text(
                _formatAddress(addressInfo.address),
                style: EnvoyTypography.body.copyWith(
                  color: isHighlighted
                      ? NewEnvoyColor.contentNotice
                      : EnvoyColors.textPrimary,
                ),
              ),
            ),

            // Balance
            EnvoyAmount(
              account: account,
              amountSats: addressInfo.balanceSats,
              amountWidgetStyle: AmountWidgetStyle.normal,
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S().component_filter,
                style: EnvoyTypography.subheading.setWeight(FontWeight.w500),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Reset to all filters selected (show all)
                    _filters = {
                      AddressFilter.used,
                      AddressFilter.unused,
                      AddressFilter.zeroBalance,
                    };
                  });
                },
                child: Text(
                  S().component_resetFilter,
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
              EnvoyFilterChip(
                text: S().exploreAddresses_listFilter_used,
                icon: EnvoyIcons.alert,
                selected: _filters.contains(AddressFilter.used),
                onTap: () => _toggleFilter(AddressFilter.used),
              ),
              EnvoyFilterChip(
                text: S().exploreAddresses_listFilter_unused,
                icon: EnvoyIcons.checked_circle,
                selected: _filters.contains(AddressFilter.unused),
                onTap: () => _toggleFilter(AddressFilter.unused),
              ),
              EnvoyFilterChip(
                text: S().exploreAddresses_listFilter_zeroBalance,
                icon: EnvoyIcons.coins,
                selected: _filters.contains(AddressFilter.zeroBalance),
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
                S().component_sortBy,
                style: EnvoyTypography.subheading.setWeight(FontWeight.w500),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sort = AddressSort.none;
                  });
                },
                child: Text(
                  S().component_resetSorting,
                  style: EnvoyTypography.body.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnvoySpacing.medium1),

          // Sort options
          CheckBoxFilterItem(
            text: S().filter_sortBy_highest,
            checked: _sort == AddressSort.highestValue,
            onTap: () {
              setState(() {
                _sort = AddressSort.highestValue;
              });
            },
          ),
          CheckBoxFilterItem(
            text: S().filter_sortBy_lowest,
            checked: _sort == AddressSort.lowestValue,
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
              S().component_apply,
              onTap: () => widget.onApply(_filters, _sort),
            ),
          ),
          const SizedBox(height: EnvoySpacing.medium3),
        ],
      ),
    );
  }
}
