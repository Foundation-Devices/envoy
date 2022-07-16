import 'package:envoy/ui/amount.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/exceptions.dart';
import 'package:envoy/ui/home/cards/accounts/confirmation_card.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';

//ignore: must_be_immutable
class SendCard extends StatefulWidget with NavigationCard {
  final Account account;
  final String? address;

  SendCard(this.account, {this.address, CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = "Accounts".toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<SendCard> createState() => _SendCardState();
}

class _SendCardState extends State<SendCard>
    with AutomaticKeepAliveClientMixin {
  bool _addressValid = false;
  bool _amountSufficient = true;

  int _amount = 0;

  var _address = AddressEntry();
  var _amountEntry = AmountEntry();

  @override
  void initState() {
    super.initState();

    _address = AddressEntry(
        initalAddress: widget.address,
        onAddressChanged: (valid) {
          Future.delayed(Duration.zero, () async {
            setState(() {
              _addressValid = valid;
            });
          });
        });

    // Addresses from the scanner are already validated
    if (widget.address != null) {
      _addressValid = true;
    }

    _amountEntry = AmountEntry(
      onAmountChanged: _updateAmount,
    );
  }

  _updateAmount(amount) {
    setState(() {
      _amount = amount;
      _amountSufficient = !(amount > widget.account.wallet.balance);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable
    final loc = AppLocalizations.of(context)!;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: _address,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: _amountEntry,
      ),
      Padding(
          padding: const EdgeInsets.all(50.0),
          child: EnvoyTextButton(
              onTap: () async {
                if (_amount == 0) {
                  setState(() {
                    _amount = widget.account.wallet.balance;
                    _amountEntry = AmountEntry(
                      onAmountChanged: _updateAmount,
                      initalSatAmount: _amount,
                      key: UniqueKey(),
                    );
                  });
                  return;
                }

                if (_addressValid && _amountSufficient && (_amount > 0)) {
                  // Only check amount if we are not sending max
                  if (_amount != widget.account.wallet.balance) {
                    try {
                      await widget.account.wallet
                          .createPsbt(_address.text, _amount, Fees().fastRate);
                    } on InsufficientFunds {
                      // If amount is equal to balance user wants to send max
                      if (_amount != widget.account.wallet.balance) {
                        setState(() {
                          _amountSufficient = false;
                        });
                      }
                      return;
                    }
                  }

                  widget.navigator!.push(ConfirmationCard(
                    widget.account,
                    _amount,
                    _address.text,
                    pushCallback: widget.navigator,
                  ));
                }
              },
              error: !_addressValid || !_amountSufficient || (_amount == 0),
              label: _amount == 0
                  ? "Send Max"
                  : _amountSufficient
                      ? _addressValid
                          ? "Continue"
                          : "Enter Valid Address"
                      : "Insufficient Funds"))
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
