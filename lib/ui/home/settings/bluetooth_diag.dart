// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/bluetooth_manager.dart';
import 'package:flutter/material.dart';
import 'package:bluart/bluart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/util/console.dart';

class ScanNotifier extends StateNotifier<List<BleDevice>> {
  ScanNotifier() : super([]);

  void start() {
    BluetoothManager().scan();
    BluetoothManager().events?.listen((Event event) {
      if (event is Event_ScanResult) {
        state = event.field0;
      }
    });
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, List<BleDevice>>(
    (ref) => ScanNotifier());

class BluetoothDiagnosticsPage extends ConsumerStatefulWidget {
  const BluetoothDiagnosticsPage({super.key});

  @override
  BluetoothDiagnosticsPageState createState() =>
      BluetoothDiagnosticsPageState();
}

class BluetoothDiagnosticsPageState
    extends ConsumerState<BluetoothDiagnosticsPage> {
  Stream<BigInt>? benchmarkStream;

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(scanProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE diagnostics'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ElevatedButton(
              onPressed: () {
                kPrint('Scanning...');
                ref.read(scanProvider.notifier).start();
              },
              child: const Text('Scan')),
          for (final d in devices)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (!d.connected) {
                      kPrint('Connecting to ${d.id}');
                      connect(id: d.id);
                    } else {
                      kPrint('Disconnecting from ${d.id}');
                      disconnect(id: d.id);
                    }
                  },
                  child: Text(d.connected
                      ? 'Disconnect from ${d.name}'
                      : 'Connect to ${d.name} ${d.id}'),
                ),
                if (d.connected)
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          benchmarkStream = benchmark(id: d.id);
                        });
                      },
                      child: StreamBuilder(
                          stream: benchmarkStream,
                          builder: (context, snapshot) {
                            return Text(snapshot.hasData
                                ? snapshot.data.toString()
                                : "Benchmark");
                          })),
              ],
            )
        ],
      ),
    );
  }
}
