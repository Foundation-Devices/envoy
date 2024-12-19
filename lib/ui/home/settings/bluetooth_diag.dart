import 'package:flutter/material.dart';
import 'package:bluart/bluart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/util/console.dart';

class ScanNotifier extends StateNotifier<List<BleDevice>> {
  ScanNotifier() : super([]);

  void start() {
    // addLogger(name: "DIAG", level: LogLevel.debug);
    // enableLogging().listen((msg) => kPrint(msg));
    final scannedDevices = scan(filter: []);
    scannedDevices.listen((d) {
      state = d;
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  onPressed: () {
                    kPrint('Scanning...');
                    ref.read(scanProvider.notifier).start();
                  },
                  child: const Text('Scan')),
              ListView(
                shrinkWrap: true,
                children: [
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
                              : 'Connect to ${d.name}'),
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
            ]),
      ),
    );
  }
}
