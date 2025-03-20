import 'dart:math' as math;

import 'package:envoy/business/AccountNg.dart';
import 'package:envoy/ui/envoy_colors.dart';
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
  @override
  Widget build(BuildContext context) {
    final ngAccount = AccountNg();
    if (ngAccount.envoyAccount == null) {
      return const Center(child: Text('Loading...'));
    }
    final envoyAccount = ngAccount.envoyAccount;
    final nextAddressFuture = ref.watch(nextAddressProvider(envoyAccount!));
    final transactionsFuture = ref.watch(transactionsProvider(envoyAccount));
    final utoxosFuture = ref.watch(utoxosProvider(envoyAccount));
    final balanceFuture = ref.watch(balanceProvider(envoyAccount));

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
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final scanRq = await ngAccount.scanRequest();
              if (scanRq != null) {
                final scanRes = await ngAccount.scan(scanRq);
                if (scanRes != null) {
                  await ngAccount.apply_update(scanRes);
                }
                print("Scan ready");
              }
              ref.refresh(transactionsProvider(envoyAccount));
              ref.refresh(balanceProvider(envoyAccount));
              ref.refresh(utoxosProvider(envoyAccount));
              setState(() {});
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
          ListTile(
            title: Text('Next Address'),
            subtitle: nextAddressFuture.map(
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
          ListTile(
            title: Text('Transactions'),
            subtitle: transactionsFuture.map(
              data: (data) {
                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                      itemCount: data.value.length,
                      itemBuilder: (context, index) {
                        final element = data.value[index];
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('${element.txId}'),
                          ),
                          subtitle: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Amount  : ${element.amount}'),
                                Text('Fee     : ${element.fee}'),
                                Text('Block   : ${element.blockHeight}'),
                                Text('Confirm : ${element.confirmations}'),
                                Text('Note    : ${element.note}'),
                              ]),
                        );
                      }),
                );
              },
              loading: (loading) {
                return const Text('Loading...');
              },
              error: (error) {
                return Text('Error');
              },
            ),
          ),
          ListTile(
            title: Text('Utxos'),
            subtitle: utoxosFuture.map(
              data: (data) {
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                      itemCount: data.value.length,
                      itemBuilder: (context, index) {
                        final element = data.value[index];
                        return ListTile(
                          title: Text('${element.txId}:${element.vout}'),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount : ${element.amount}'),
                              Text('Tag          : ${element.tag}'),
                              Text('Do not spend : ${element.doNotSpend}'),
                            ],
                          )
                        );
                      }),
                );
              },
              loading: (loading) {
                return const Text('Loading...');
              },
              error: (error) {
                return Text('Error');
              },
            ),
          ),
          const Divider(),
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
