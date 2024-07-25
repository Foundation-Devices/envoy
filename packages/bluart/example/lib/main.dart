import 'package:bluart/src/rust/frb_generated.dart';
import 'package:bluart/src/rust/api/bluart.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DeviceListScreen(),
    );
  }
}

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  BtleplugPlatformAdapter? adapter;
  List<BluartPeripheral> peripherals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device List'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Call the search function and update the list of devices
              searchForDevices();
            },
            child: const Text('Search Devices'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: peripherals.length,
              itemBuilder: (context, index) {
                return FutureBuilder<String>(
                  future: getNameFromPerihperal(peripheral: peripherals[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the data is being fetched
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    } else if (snapshot.hasError) {
                      // If there is an error
                      return ListTile(
                        title: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      // Data is available
                      String name = snapshot.data ?? 'Unknown';
                      return ListTile(
                        title: Text(name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PeripheralDetailsScreen(
                                peripheral: peripherals[index],
                                connectFunction: connectToDevice,
                                writeFunction: writeTo,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void searchForDevices() async {
    try {
      // Ensure adapter is initialized
      adapter ??= await firstAdapter();
      List<BluartPeripheral> result = await getPeripherals(
          adapter: adapter!,
          tcpPorts: [
            "127.0.0.1:5237"
          ]); // need permission if port is under 1000
      setState(() {
        peripherals = result;
      });
    } catch (e) {
      print('Error searching for devices: $e');
    }
  }

  void connectToDevice(BluartPeripheral peripheral) async {
    try {
      // Ensure adapter is initialized
      adapter ??= await firstAdapter();
      await connectPeripheral(peripheral: peripheral);
    } catch (e) {
      print('Error connecting: $e');
    }
  }
}

class PeripheralDetailsScreen extends StatefulWidget {
  final BluartPeripheral peripheral;
  final Function connectFunction;
  final Function writeFunction;

  const PeripheralDetailsScreen({
    Key? key,
    required this.peripheral,
    required this.connectFunction,
    required this.writeFunction,
  }) : super(key: key);

  @override
  State<PeripheralDetailsScreen> createState() =>
      _PeripheralDetailsScreenState();
}

class _PeripheralDetailsScreenState extends State<PeripheralDetailsScreen> {
  String readMessage = '';
  bool showConnectButton = false;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    showConnectButton = !await isConnected(peripheral: widget.peripheral);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripheral Details'),
      ),
      body: Center(
        child: Column(
          children: [
            // Display peripheral details here
            // You can customize this section based on your requirements
            if (showConnectButton)
              ElevatedButton(
                onPressed: () {
                  // Call the connect function with the selected device
                  widget.connectFunction(widget.peripheral);
                },
                child: const Text('Connect'),
              ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                String str = "test";
                List<int> intListTest = str.codeUnits;
                var rxCharacteristic =
                    UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");
                await widget.writeFunction(
                    peripheral: widget.peripheral,
                    data: intListTest,
                    rxCharacteristic: rxCharacteristic);
              },
              child: const Text('Write To'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                var txCharacteristic =
                    UuidValue.fromString("6E400003B5A3F393E0A9E50E24DCCA9E");
                var message = await readFrom(
                    peripheral: widget.peripheral,
                    characteristic: txCharacteristic);
                setState(() {
                  readMessage = String.fromCharCodes(message);
                });
              },
              child: const Text('read from'),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Read Message: $readMessage',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
