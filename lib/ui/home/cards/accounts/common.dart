import 'package:tor/tor.dart';
import 'package:envoy/business/settings.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

void broadcast(
    Psbt psbt, BuildContext context, Wallet wallet, CardNavigator navigator) {
  wallet
      .broadcastTx(
          Settings().electrumAddress(wallet.network), Tor().port, psbt.rawTx)
      .then((_) {
    navigator.pop(depth: 3);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S().envoy_psbt_transaction_sent),
    ));
  }, onError: (_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S().envoy_psbt_transaction_not_sent),
    ));
  });
}
