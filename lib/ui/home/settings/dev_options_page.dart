// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/keys_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';

class DevOptionsPage extends StatefulWidget {
  const DevOptionsPage({super.key});

  @override
  State<DevOptionsPage> createState() => _DevOptionsPageState();
}

class _DevOptionsPageState extends State<DevOptionsPage> {
  bool _wipingWallet = false;

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    EnvoyToast.dismissPreviousToasts(context);
    EnvoyToast(
      replaceExisting: true,
      duration: const Duration(seconds: 2),
      message: message,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    ).show(context);
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
    String failureMessage = "Action failed",
  }) async {
    try {
      await action();
      _showToast(successMessage);
    } catch (e) {
      kPrint(e);
      _showToast(failureMessage, isError: true);
    }
  }

  Future<void> _wipeWallet() async {
    setState(() {
      _wipingWallet = true;
    });

    try {
      await EnvoySeed().delete();
      _showToast("Envoy wallet wiped");
    } catch (e) {
      kPrint(e);
      _showToast("Failed to wipe wallet", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _wipingWallet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Colors.black;
    const dividerColor = Color(0xFF3A3C40);
    const titleColor = Colors.white;
    const subtitleColor = Color(0xFFB9BBC1);
    const dangerColor = Color(0xFFE16060);

    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: surfaceColor,
          primaryColor: Colors.white70,
          appBarTheme: AppBarTheme(
            backgroundColor: surfaceColor,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          )),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "Developer options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Development",
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? surfaceColor
                    : const Color(0xFF8E9198);
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.white
                    : const Color(0xFF53555A);
              }),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              title: const Text(
                "Skip Prime security check",
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Enable the skip flag for Prime security checks for this session.",
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              ),
              value: Settings().skipPrimeSecurityCheck,
              onChanged: (enabled) {
                setState(() {
                  Settings().skipPrimeSecurityCheck = enabled;
                });
              },
            ),
            SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? surfaceColor
                    : const Color(0xFF8E9198);
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.white
                    : const Color(0xFF53555A);
              }),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              title: const Text(
                "Use dev Envoy server",
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Route Envoy requests through the dev server. Intended for internal team testing only.",
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              ),
              value: Settings().useEnvoyDevServer,
              onChanged: (enabled) async {
                setState(() {
                  Settings().setUseEnvoyDevServer(enabled);
                });
                await KeysManager().fetchKeysFromServer();
              },
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Envoy",
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _DevOptionTile(
                    title: "Clear prompt states",
                    subtitle: "Reset dismissed prompt state in local storage.",
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    iconColor: subtitleColor,
                    onTap: () {
                      return _runAction(() async {
                        await EnvoyStorage().clearDismissedStatesStore();
                      }, successMessage: "Prompt states cleared");
                    },
                  ),
                  const Divider(height: 1, color: dividerColor),
                  _DevOptionTile(
                    title: "Clear Azteco states",
                    subtitle: "Remove pending Azteco state from local storage.",
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    iconColor: subtitleColor,
                    onTap: () {
                      return _runAction(() async {
                        await EnvoyStorage().clearPendingStore();
                      }, successMessage: "Azteco states cleared");
                    },
                  ),
                  const Divider(height: 1, color: dividerColor),
                  _DevOptionTile(
                    title: "Clear Envoy logs",
                    subtitle: "Delete stored bug reports and local logs.",
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    iconColor: subtitleColor,
                    onTap: () {
                      return _runAction(() async {
                        await EnvoyReport().clearAll();
                      }, successMessage: "Envoy logs cleared");
                    },
                  ),
                  const Divider(height: 1, color: dividerColor),
                  _DevOptionTile(
                    title: "Clear Envoy preferences",
                    subtitle: "Remove saved Envoy preferences from storage.",
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    iconColor: subtitleColor,
                    onTap: () {
                      return _runAction(() async {
                        await EnvoyStorage().clear();
                      }, successMessage: "Envoy preferences cleared");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Danger zone",
                style: TextStyle(
                  color: dangerColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: _DevOptionTile(
                title: "Wipe Envoy wallet",
                subtitle: "Delete the local Envoy wallet data on this device.",
                titleColor: dangerColor,
                subtitleColor: subtitleColor,
                iconColor: dangerColor,
                isLoading: _wipingWallet,
                onTap: _wipingWallet ? null : _wipeWallet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevOptionTile extends StatelessWidget {
  const _DevOptionTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.titleColor,
    required this.subtitleColor,
    required this.iconColor,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final Future<void> Function()? onTap;
  final Color titleColor;
  final Color subtitleColor;
  final Color iconColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      enabled: onTap != null && !isLoading,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 13),
        ),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: iconColor),
      onTap: onTap == null
          ? null
          : () async {
              await onTap!();
            },
    );
  }
}
