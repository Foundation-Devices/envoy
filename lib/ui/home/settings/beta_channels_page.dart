// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/beta_channels.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetaChannelsPage extends ConsumerStatefulWidget {
  const BetaChannelsPage({super.key});

  @override
  ConsumerState<BetaChannelsPage> createState() => _BetaChannelsPageState();
}

class _BetaChannelsPageState extends ConsumerState<BetaChannelsPage> {
  static const _noneSentinel = '__none__';

  @override
  void initState() {
    super.initState();
    // Synchronous prefix of refresh() sets loading=true before first build,
    // so the page opens directly into the loading state.
    ref.read(betaChannelsProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Colors.black;
    const dividerColor = Color(0xFF3A3C40);
    const titleColor = Colors.white;
    const subtitleColor = Color(0xFFB9BBC1);

    final manager = ref.watch(betaChannelsProvider);
    final selected = ref.watch(settingsProvider).selectedBetaChannel;
    final channels = manager.channels;
    final loading = manager.loading;

    // Fall back to None if the selection has disappeared from the server
    // (e.g. channel was deleted or renamed) — otherwise DropdownButton's
    // "exactly one item with value" assert blows up. Only clear the stale
    // setting when a *successful* refresh confirms the channel is gone;
    // a failed fetch (offline, pre-Tor) leaves the selection intact.
    final selectionPresent =
        selected != null && channels.any((c) => c.name == selected);
    if (selected != null &&
        !loading &&
        manager.error == null &&
        !selectionPresent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Settings().setSelectedBetaChannel(null);
      });
    }
    final dropdownValue = selectionPresent ? selected : _noneSentinel;

    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: surfaceColor,
        primaryColor: Colors.white70,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            "Beta channels",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              tooltip: "Refresh",
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
              onPressed: loading ? null : () => manager.refresh(),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Passport Prime firmware beta channel",
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16, right: 4),
              child: Text(
                "Select a channel to include its beta firmware updates in Passport Prime update checks. Choose \"None\" to disable.",
                style: TextStyle(color: subtitleColor, fontSize: 13),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              color: surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1B1F),
                    iconEnabledColor: Colors.white,
                    value: dropdownValue,
                    style: const TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem<String>(
                        value: _noneSentinel,
                        child: Text("None (stable only)"),
                      ),
                      ...channels.map(
                        (c) => DropdownMenuItem<String>(
                          value: c.name,
                          child: _ChannelRow(channel: c),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      final newChannel =
                          value == _noneSentinel ? null : value;
                      Settings().setSelectedBetaChannel(newChannel);
                      EnvoyToast.dismissPreviousToasts(context);
                      EnvoyToast(
                        replaceExisting: true,
                        duration: const Duration(seconds: 2),
                        message: newChannel == null
                            ? "Beta channel disabled"
                            : "Beta channel set to '$newChannel'",
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                      ).show(context);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (manager.error != null)
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  "Failed to load channels: ${manager.error}",
                  style: const TextStyle(
                    color: Color(0xFFE16060),
                    fontSize: 13,
                  ),
                ),
              )
            else if (loading)
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  "Loading channels…",
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              )
            else if (channels.isEmpty)
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  "No beta channels available.",
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({required this.channel});

  final BetaChannel channel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            channel.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          "${channel.latestVersion} · ${channel.patchCount}",
          style: const TextStyle(
            color: Color(0xFFB9BBC1),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
