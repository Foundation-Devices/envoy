// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';
import 'package:envoy/ui/components/account_selector.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_loader.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/components/ramp_widget.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';

GlobalKey<ChooseAccountState> chooseAccountKey =
    GlobalKey<ChooseAccountState>();

class SelectAccount extends ConsumerStatefulWidget {
  const SelectAccount({super.key});

  @override
  ConsumerState<SelectAccount> createState() => _SelectAccountState();
}

class _SelectAccountState extends ConsumerState<SelectAccount> {
  Account? selectedAccount;
  GestureTapCallback? onTap;
  String? address;
  bool _canPop = true;
  final Map<String, String?> accountAddressCache = {};

  GlobalKey<StackedAccountChooserState> accountChooserKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        selectedAccount = ref.read(mainnetAccountsProvider(null)).first;
      });
      selectedAccount?.wallet.getAddress().then((value) {
        setState(() {
          address = value;
          if (selectedAccount != null && selectedAccount?.id != null) {
            accountAddressCache[selectedAccount!.id!] = address;
          }
        });
      }).catchError((error) {});
    });
  }

  @override
  void dispose() {
    accountAddressCache.clear();
    super.dispose();
  }

  void updateSelectedAccount(Account account) async {
    setState(() {
      selectedAccount = account;
      address = null;
    });
    if (accountAddressCache.containsKey(selectedAccount?.id!) &&
        accountAddressCache[selectedAccount?.id!] != null) {
      setState(() {
        address = accountAddressCache[selectedAccount?.id!];
      });
    } else {
      String? address = await account.wallet.getAddress();
      // Separate setState call to avoid UI lag during the async operation
      setState(() {
        this.address = address;
        accountAddressCache[selectedAccount!.id!] = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Account> filteredAccounts = [];
    if (selectedAccount != null) {
      filteredAccounts = ref.watch(mainnetAccountsProvider(selectedAccount));
    }
    if ((selectedAccount == null)) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return PopScope(
        canPop: _canPop,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            accountChooserKey.currentState?.dismiss();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: EnvoySpacing.medium2, horizontal: EnvoySpacing.medium2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S().buy_bitcoin_accountSelection_heading,
                        style: EnvoyTypography.subheading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: EnvoySpacing.medium2,
                      ),
                      StackedAccountChooser(
                        key: accountChooserKey,
                        account: selectedAccount ?? filteredAccounts.first,
                        accounts: filteredAccounts,
                        onOverlayChanges: (bool visible) {
                          setState(() {
                            _canPop = !visible;
                          });
                        },
                        onAccountSelected: (Account account) {
                          updateSelectedAccount(account);
                        },
                      ),
                      const SizedBox(
                        height: EnvoySpacing.small,
                      ),
                      Builder(builder: (context) {
                        return GestureDetector(
                          child: Text(
                            S().buy_bitcoin_accountSelection_chooseAccount,
                            style: EnvoyTypography.info
                                .copyWith(color: EnvoyColors.accentPrimary),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            accountChooserKey.currentState
                                ?.openChooserOverlay(context);
                          },
                        );
                      }),
                      const SizedBox(
                        height: EnvoySpacing.medium2,
                      ),
                      Text(
                        S().buy_bitcoin_accountSelection_subheading,
                        style: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: EnvoySpacing.medium1,
                      ),
                      getAddressWidget(address),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!selectedAccount!.wallet.hot)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: EnvoySpacing.small),
                      child: EnvoyButton(
                        label: S().buy_bitcoin_accountSelection_verify,
                        icon: EnvoyIcons.verifyAddress,
                        type: ButtonType.secondary,
                        state: ButtonState.defaultState,
                        onTap: () {
                          if (mounted) {
                            showEnvoyDialog(
                              context: context,
                              blurColor: Colors.black,
                              useRootNavigator: true,
                              linearGradient: true,
                              dialog: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: VerifyAddressDialog(
                                  address: address!,
                                  accountName: selectedAccount!.name,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: EnvoySpacing.large1),
                    child: EnvoyButton(
                      label: S().component_continue,
                      type: ButtonType.primary,
                      state: ButtonState.defaultState,
                      onTap: () async {
                        bool dismissed = await EnvoyStorage()
                            .checkPromptDismissed(
                                DismissiblePrompt.leavingEnvoy);
                        if (!dismissed && context.mounted) {
                          showEnvoyPopUp(
                              context,
                              title: S()
                                  .buy_bitcoin_accountSelection_modal_heading,
                              S().buy_bitcoin_accountSelection_modal_subheading,
                              S().send_keyboard_address_confirm,
                              (BuildContext context) {
                                Navigator.pop(context);
                                RampWidget.showRamp(
                                    context, selectedAccount!, address!);
                              },
                              icon: EnvoyIcons.info,
                              checkBoxText: S().component_dontShowAgain,
                              checkedValue: dismissed,
                              onCheckBoxChanged: (checkedValue) {
                                if (!checkedValue) {
                                  EnvoyStorage().addPromptState(
                                      DismissiblePrompt.leavingEnvoy);
                                } else if (checkedValue) {
                                  EnvoyStorage().removePromptState(
                                      DismissiblePrompt.leavingEnvoy);
                                }
                              });
                        } else {
                          if (context.mounted) {
                            RampWidget.showRamp(
                                context, selectedAccount!, address!);
                          }
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  Widget getAddressWidget(String? address) {
    return address != null
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.medium2,
            ),
            child: AddressWidget(
              address: address,
              align: TextAlign.center,
            ),
          )
        : const EnvoyLoader();
  }
}

class ChooseAccount extends StatefulWidget {
  const ChooseAccount({
    super.key,
    required this.accounts,
    required this.onSelectAccount,
    required this.selectedAccount,
    this.chooseAccountKey,
  });

  final List<Account> accounts;
  final Function(Account) onSelectAccount;
  final Account selectedAccount;
  final GlobalKey<ChooseAccountState>? chooseAccountKey;

  @override
  State<ChooseAccount> createState() => ChooseAccountState();
}

class ChooseAccountState extends State<ChooseAccount> {
  late List<Account> accounts;
  late Account _currentSelectedAccount;

  //to improve shadow animation, bool
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    accounts = List<Account>.from(widget.accounts);
    _currentSelectedAccount = widget.selectedAccount;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTapUp: (_) {
          moveAccountToEnd(widget.selectedAccount);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: TweenAnimationBuilder(
          duration: Duration(milliseconds: _exiting ? 100 : 300),
          builder: (context, value, child) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                value ?? Colors.transparent,
                const Color(0x00000000),
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: child,
            );
          },
          tween: _exiting
              ? ColorTween(begin: Colors.black, end: Colors.transparent)
              : ColorTween(begin: Colors.transparent, end: Colors.black),
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: _exiting ? 100 : 300),
            tween: _exiting
                ? Tween<double>(begin: 5, end: 0)
                : Tween<double>(begin: 0, end: 5),
            builder: (context, value, child) {
              return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                  child: child);
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: AnimatedOpacity(
                  duration: Duration(milliseconds: _exiting ? 100 : 300),
                  opacity: _exiting ? 0 : 1,
                  child: Text(
                    S().header_chooseAccount,
                    style: EnvoyTypography.subheading
                        .copyWith(color: Colors.white),
                  ),
                ),
                leading: AnimatedOpacity(
                  duration: Duration(milliseconds: _exiting ? 100 : 300),
                  opacity: _exiting ? 0 : 1,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.medium1,
                    horizontal: EnvoySpacing.medium1),
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        EnvoyColors.solidWhite,
                        Colors.transparent,
                        Colors.transparent,
                        EnvoyColors.solidWhite,
                      ],
                      stops: [0.0, 0.05, 0.95, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    itemCount: accounts.length,
                    onReorder: (oldIndex, newIndex) {},
                    itemBuilder: (context, index) {
                      return _buildAccountItem(context, accounts[index]);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  int _getAccountIndexById(String? id) {
    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i].id == id) {
        return i;
      }
    }
    return 0;
  }

  Widget _buildAccountItem(
    BuildContext context,
    Account account,
  ) {
    return Padding(
      key: ValueKey(account.id),
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.small, horizontal: EnvoySpacing.medium1),
      child: Hero(
        transitionOnUserGestures: true,
        tag: account.id!,
        child: Consumer(builder: (context, ref, child) {
          return AccountListTile(
            account,
            onTap: () async {
              final navigator = Navigator.of(context);
              setState(() {
                _exiting = true;
              });
              await Future.delayed(const Duration(milliseconds: 100));

              _currentSelectedAccount = account;
              widget.onSelectAccount(account);
              // moveAccountToEnd(account);
              await Future.delayed(const Duration(milliseconds: 100));
              navigator.pop();
            },
            draggable: false,
          );
        }),
      ),
    );
  }

  void moveAccountToEnd(Account accountToMove) {
    // Ensure moving the correct account to prevent lag when navigating back on Android.
    if (_currentSelectedAccount == accountToMove) {
      int index = _getAccountIndexById(accountToMove.id);
      setState(() {
        final Account account = accounts.removeAt(index);
        accounts.insert(accounts.length, account);
      });
    }
  }
}

class VerifyAddressDialog extends StatelessWidget {
  const VerifyAddressDialog({
    super.key,
    required this.address,
    required this.accountName,
  });

  final String address;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: EnvoySpacing.medium2),
              child: EnvoyIcon(
                EnvoyIcons.verifyAddress,
                size: EnvoyIconSize.big,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
              child: Text(
                S().buy_bitcoin_accountSelection_verify,
                style: EnvoyTypography.subheading,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
              child: Text(
                S().buy_bitcoin_accountSelection_verify_modal_heading(
                    accountName),
                style: EnvoyTypography.info,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
              child: AddressWidget(
                address: address,
                align: TextAlign.center,
              ),
            ),
            Flexible(
                child: Padding(
              padding: const EdgeInsets.all(EnvoySpacing.small),
              child: EnvoyQR(data: address),
            )),
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
              child: EnvoyButton(
                label: S().component_done,
                type: ButtonType.primary,
                state: ButtonState.defaultState,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
