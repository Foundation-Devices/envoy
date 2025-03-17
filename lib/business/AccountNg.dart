import 'package:envoy/business/account.dart';
import 'package:envoy/util/console.dart';
import 'package:ngwallet/src/rust/api/simple.dart' as NgWallet;
import 'package:ngwallet/src/rust/frb_generated.dart' as api;

class AccountNg {

  Account? account;
  String? descriptor;
  NgWallet.Wallet? wallet;
  static final AccountNg _instance = AccountNg._internal();


  factory AccountNg() {
    return _instance;
  }

  restore(String descriptor) async {
    //makes an in memory wallet
    wallet = await NgWallet.Wallet.newFromDescriptor(descriptor: descriptor);
    this.descriptor = descriptor;
  }

  nextAddress() async {
    return await wallet?.nextAddress() ?? "";
  }

  init() async {
    await api.RustLib.init();
  }

  AccountNg._internal() {
    kPrint("Instance of AccountNg created!");
  }
}
