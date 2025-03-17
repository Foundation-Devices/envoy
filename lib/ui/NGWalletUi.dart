import 'package:envoy/business/AccountNg.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/src/rust/api/simple.dart' as NgWallet;

final nextAddressProvider =
    FutureProvider.family<String, NgWallet.Wallet>((ref, wallet) async {
  return await wallet.nextAddress();
});

final balanceProvider = FutureProvider.family<String, NgWallet.Wallet>((ref, wallet) async {
  return (await wallet.balance()).toString();
});

class NGWalletUi extends ConsumerStatefulWidget {
  const NGWalletUi({super.key});

  @override
  ConsumerState<NGWalletUi> createState() => _NGWalletUiState();
}

class _NGWalletUiState extends ConsumerState<NGWalletUi> {
  @override
  Widget build(BuildContext context) {
    final ngAccount = AccountNg();
    if (ngAccount.wallet == null) {
      return const Center(child: Text('Loading...'));
    }
    final nextAddressFuture = ref.watch(nextAddressProvider(ngAccount.wallet!));
    final balanceFuture = ref.watch(balanceProvider(ngAccount.wallet!));

    return Scaffold(
      appBar: AppBar(title: const Text('NG Wallet')),
      backgroundColor: EnvoyColors.white95,
      body:  ListView(
        children: <Widget>[
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
        ],
      ),
    );
  }
}
