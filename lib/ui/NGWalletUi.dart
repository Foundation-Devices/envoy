import 'dart:math' as math;

import 'package:envoy/business/AccountNg.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/text_field.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';

final nextAddressProvider =
    FutureProvider.family<String, EnvoyAccount>((ref, wallet) async {
  return await wallet.nextAddress();
});

final transactionsProvider =
    FutureProvider.family<List<BitcoinTransaction>, EnvoyAccount>(
        (ref, wallet) async {
  return await wallet.transactions();
});

final utoxosProvider =
    FutureProvider.family<List<Output>, EnvoyAccount>((ref, wallet) async {
  return await wallet.utxo();
});

final balanceProvider =
    FutureProvider.family<String, EnvoyAccount>((ref, wallet) async {
  return (await wallet.balance()).toString();
});

class NGWalletUi extends ConsumerStatefulWidget {
  const NGWalletUi({super.key});

  @override
  ConsumerState<NGWalletUi> createState() => _NGWalletUiState();
}

class _NGWalletUiState extends ConsumerState<NGWalletUi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: 800))
        ..repeat();

  bool spend = true;
  String serializedPSBT = "";
  String signedPSBT = "";
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onInit();
    });
  }

  onInit()async {
    setState(() {
    });
    //TODO: listen for ql messages and call onReceiveSignedPSBT
  }

  onReceiveSignedPSBT(String signed){
    setState(() {
      signedPSBT = signed;
    });
  }


  @override
  Widget build(BuildContext context) {
    final ngAccount = AccountNg();
    if (ngAccount.envoyAccount == null) {
      return const Scaffold(
        body: Center(child: Text('Loading...')),
      );
    }
    final envoyAccount = ngAccount.envoyAccount;
    final nextAddressFuture = ref.watch(nextAddressProvider(envoyAccount!));
    final transactionsFuture = ref.watch(transactionsProvider(envoyAccount));
    final utoxosFuture = ref.watch(utoxosProvider(envoyAccount));
    final balanceFuture = ref.watch(balanceProvider(envoyAccount));
    final hasBalance = balanceFuture.value != "0";
    return Scaffold(
      appBar: AppBar(
        title: const Text('NG Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              print("Getting query ${await envoyAccount?.balance()}");
              print(
                  "Getting query address ${await envoyAccount.nextAddress()}");
            },
          ),
          IconButton(
            icon: loading
                ? SizedBox.square(
                    dimension: 12,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                loading = true;
              });
              try {
                final scanRq = await ngAccount.scanRequest();
                if (scanRq != null) {
                  //final scanRes = await ngAccount.scan(scanRq);
                  // if (scanRes != null) {
                  //   await ngAccount.apply_update(scanRes);
                  // }
                }
                ref.refresh(transactionsProvider(envoyAccount));
                ref.refresh(balanceProvider(envoyAccount));
                ref.refresh(utoxosProvider(envoyAccount));
                setState(() {});
              } catch (e) {
                print(e);
              } finally {
                setState(() {
                  loading = false;
                });
              }
            },
          )
        ],
      ),
      backgroundColor: EnvoyColors.white95,
      body: ListView(
        children: <Widget>[
          Container(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: FlutterLogo(size: 120),
            ),
          ),
          ListTile(
            title: Text('Descriptor'),
            subtitle: Text('${ngAccount.descriptor}'),
          ),
          Divider(
            color: Colors.black,
            height: 12,
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
          ListTile(
            title: Text('Balance'),
            subtitle: balanceFuture.map(
              data: (data) {
                return Text(data.value);
              },
              loading: (loading) {
                return const Text('Loading...');
              },
              error: (error) {
                return Text('Error');
              },
            ),
          ),
          Divider(
            color: Colors.black,
            height: 12,
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
          ListTile(
            title: Text('Next Address'),
            subtitle: nextAddressFuture.map(
              data: (data) {
                return SelectableText(data.value);
              },
              loading: (loading) {
                return const Text('Loading...');
              },
              error: (error) {
                return Text('Error');
              },
            ),
          ),
          Divider(
            color: Colors.black,
            height: 12,
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (var tx in transactionsFuture.value ?? []) ...[
            ListTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('${tx.txId}'),
              ),
              subtitle: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Amount  : ${tx.amount}, Fee : ${tx.fee}, Block : ${tx.blockHeight}, Confirm : ${tx.confirmations}'),
                    Text('Note    : ${tx.note}'),
                    TextButton(
                        onPressed: () async {
                          await envoyAccount.setNote(
                              txId:
                                  "0547f25edf05afea281257ec688146222ff85104ee847200b6ae261e3ec40f89",
                              note: "Team BeefCake");
                          ref.refresh(transactionsProvider(envoyAccount));
                          ref.refresh(balanceProvider(envoyAccount));
                          ref.refresh(utoxosProvider(envoyAccount));
                        },
                        child: const Text('Set Note : "Team BeefCake"')),
                  ]),
            )
          ],
          Divider(
            color: Colors.black,
            height: 12,
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Utxo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (var utxo in utoxosFuture.value ?? []) ...[
            ListTile(
              title: Text('${utxo.txId}:${utxo.vout}'),
              subtitle: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount : ${utxo.amount}'),
                  Text('Tag          : ${utxo.tag}'),
                  Text('Do not spend : ${utxo.doNotSpend}'),
                  Wrap(
                    children: [
                      TextButton(
                          onPressed: () {
                            envoyAccount.setTag(
                                utxo: Output(
                                    txId:
                                        "0547f25edf05afea281257ec688146222ff85104ee847200b6ae261e3ec40f89",
                                    vout: 0,
                                    amount: BigInt.from(0)),
                                tag: "BeefStash");
                            ref.refresh(transactionsProvider(envoyAccount));
                            ref.refresh(balanceProvider(envoyAccount));
                            ref.refresh(utoxosProvider(envoyAccount));
                          },
                          child: const Text('Set Tag  : "BeefStash"')),
                      TextButton(
                          onPressed: () {
                            envoyAccount.setDoNotSpend(
                                utxo: Output(
                                    txId:
                                        "0547f25edf05afea281257ec688146222ff85104ee847200b6ae261e3ec40f89",
                                    vout: 0,
                                    amount: BigInt.from(0)),
                                doNotSpend: !spend);
                            spend = !spend;
                            ref.refresh(transactionsProvider(envoyAccount));
                            ref.refresh(balanceProvider(envoyAccount));
                            ref.refresh(utoxosProvider(envoyAccount));
                          },
                          child: const Text('Toggle spend status')),
                    ],
                  )
                ],
              ),
            )
          ],
          Divider(
            color: Colors.black,
            height: 12,
            thickness: 1,
            indent: 12,
            endIndent: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Send',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (hasBalance)
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    EnvoyTextField(
                      defaultText: "Unsigned PSBT",
                      controller: TextEditingController(text: serializedPSBT),
                      onChanged: (String) {},
                    ),
                    Padding(padding: const EdgeInsets.all(8.0)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: EnvoyButton(
                          label: "Compose PSBT",
                          state: ButtonState.defaultState,
                          type: ButtonType.copper,
                          onTap: () async {
                            try {
                              serializedPSBT = await envoyAccount.send(
                                  address:
                                      "tb1pkar3gerekw8f9gef9vn9xz0qypytgacp9wa5saelpksdgct33qdqs257jl",
                                  amount: BigInt.from(2344));
                              setState(() {
                                print(serializedPSBT);
                              });
                            } catch (e) {}
                          },
                        )),
                        Padding(padding: const EdgeInsets.all(8.0)),
                        Expanded(
                          child: EnvoyButton(
                            label: "Clear PSBT",
                            state: ButtonState.defaultState,
                            type: ButtonType.danger,
                            onTap: () async {
                              setState(() {
                                serializedPSBT = "";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(8.0)),
                    EnvoyButton(
                      label: "Send PSBT to Prime",
                      state: ButtonState.defaultState,
                      type: ButtonType.primary,
                      onTap: () async {
                        await BluetoothManager().sendPsbt(AccountNg().descriptor!, serializedPSBT);
                      },
                    ),
                  ],
                )),
          if (hasBalance)
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    EnvoyTextField(
                      defaultText: "Signed PSBT",
                      controller: TextEditingController(text: signedPSBT),
                      onChanged: (String) {},
                    ),
                    Padding(padding: const EdgeInsets.all(8.0)),
                    EnvoyButton(
                      label: "broadcast PSBT",
                      state: ButtonState.defaultState,
                      type: ButtonType.primary,
                      onTap: signedPSBT.isEmpty
                          ? null
                          : () async {
                              try {
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                //await envoyAccount.broadcast(psbt: signedPSBT);
                                const snackBar = SnackBar(content: Text('Broadcasting successful'));
                                scaffoldMessenger.showSnackBar(snackBar);
                              } catch (e,stack) {
                                kPrint("Error broadcasting: $e",stackTrace: stack);
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                const snackBar = SnackBar(content: Text('Error broadcasting...'));
                                scaffoldMessenger.showSnackBar(snackBar);
                              }
                            },
                    ),
                  ],
                )),
          Padding(
            padding: const EdgeInsets.all(54),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
