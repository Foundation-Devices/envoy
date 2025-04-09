import 'package:envoy/business/account.dart';
import 'package:envoy/util/console.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountNg {
  Account? account;
  String? descriptor;
  EnvoyAccountHandler? envoyAccount;
  static final AccountNg _instance = AccountNg._internal();

  factory AccountNg() {
    return _instance;
  }

  restore(String descriptor) async {
    //makes an in memory wallet
    try {
      print("Restoring account $descriptor");

      /**
       *   "Passport Prime".to_string(),
          "red".to_string(),
          None,
          EXTERNAL_DESCRIPTOR.to_string(),
          0,
          None
       */
      // envoyAccount = await EnvoyAccount.newFromDescriptor(
      //     name: "Passport Prime",
      //     color: "red",
      //     deviceSerial: null,
      //     descriptor: descriptor,
      //     index: 0,
      //     dbPath: null);
      this.descriptor = descriptor;
    } catch (e) {
      print(e);
    }
  }

  nextAddress() async {
    return await envoyAccount?.nextAddress() ?? "";
  }

  Future<FullScanRequest?> scanRequest() async {
    return await envoyAccount?.requestFullScan();
  }

  Future<bool?>? apply_update(WalletUpdate scanResponse) async {
    return await envoyAccount?.applyUpdate(update: scanResponse);
  }

  init() async {
    await RustLib.init();
  }

  AccountNg._internal() {
    kPrint("Instance of AccountNg created!");
  }
}
