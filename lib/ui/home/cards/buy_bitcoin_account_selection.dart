// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_loader.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/material_transparent_router.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/components/account_selector.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/components/ramp_widget.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';

class SelectAccount extends ConsumerStatefulWidget {
  const SelectAccount({super.key});

  @override
  ConsumerState<SelectAccount> createState() => _SelectAccountState();
}

class _SelectAccountState extends ConsumerState<SelectAccount> {
  Account? selectedAccount;
  GestureTapCallback? onTap;
  String? address;
  final Map<String, String?> accountAddressCache = {};
  bool isChooseAccountOpen = false;

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
      isChooseAccountOpen = false;
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
        canPop: !isChooseAccountOpen,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.of(context).pop();
            setState(() {
              isChooseAccountOpen = false;
            });
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
                      StackedAccountTile(
                        selectedAccount!,
                        filteredAccounts: filteredAccounts,
                        onTap: (Account account) {
                          updateSelectedAccount(account);
                          chooseAccount(context, filteredAccounts);
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
                            chooseAccount(context, filteredAccounts);
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

  void chooseAccount(BuildContext context, List<Account> filteredAccounts) {
    setState(() {
      isChooseAccountOpen = true;
    });
    Navigator.of(rootNavigator: true, context).push(MaterialTransparentRoute(
      builder: (context) {
        return PopScope(
          onPopInvoked: (_) {
            setState(() {
              isChooseAccountOpen = false;
            });
          },
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ChooseAccount(
                accounts: filteredAccounts,
                onSelectAccount: updateSelectedAccount,
              )),
        );
      },
    ));
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
  });

  final List<Account> accounts;
  final Function(Account) onSelectAccount;

  @override
  State<ChooseAccount> createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {
  late List<GlobalKey> keys = widget.accounts.map((e) => GlobalKey()).toList();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return GestureDetector(
        onTapDown: (details) {
          for (var element in keys) {
            final RenderBox box =
                element.currentContext?.findRenderObject() as RenderBox;
            final Offset localOffset =
                box.globalToLocal(details.globalPosition);

            if (!box.paintBounds.contains(localOffset)) {
              Navigator.of(context).pop();
              break;
            }
          }
        },
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
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
          tween: ColorTween(begin: Colors.transparent, end: Colors.black),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                S().header_chooseAccount,
                style: EnvoyTypography.subheading.copyWith(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
                child: ListView.builder(
                  itemCount: widget.accounts.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: EnvoySpacing.medium2, bottom: EnvoySpacing.medium2),
                  itemBuilder: (context, index) {
                    return Container(
                      key: keys[index],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: EnvoySpacing.small,
                            horizontal: EnvoySpacing.medium1),
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: widget.accounts[index].id!,
                          key: ValueKey(widget.accounts[index].id!),
                          child: AccountListTile(
                            widget.accounts[index],
                            onTap: () async {
                              final navigator = Navigator.of(context);
                              widget.onSelectAccount(widget.accounts[index]);
                              navigator.pop();
                            },
                            draggable: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
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
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: const EnvoyIcon(EnvoyIcons.close),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium2),
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
            Flexible(child: EnvoyQR(data: address)),
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
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
