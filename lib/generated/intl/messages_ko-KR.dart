// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko_KR locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ko_KR';

  static String m0(period) =>
      "This voucher expired on ${period}.\n\n\nPlease contact the issuer with any voucher-related questions.";

  static String m1(AccountName) =>
      "Navigate to ${AccountName} on Passport, choose ‘Verify Address’, then scan the QR code.";

  static String m2(tagName) =>
      "Your ${tagName} tag is now empty. Would you like to delete it?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage("30,493.93"),
        "about_appVersion": MessageLookupByLibrary.simpleMessage("App Version"),
        "about_openSourceLicences":
            MessageLookupByLibrary.simpleMessage("Open Source Licences"),
        "about_privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "about_show": MessageLookupByLibrary.simpleMessage("Show"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Terms of Use"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage("Sort by"),
        "account_details_untagged_card":
            MessageLookupByLibrary.simpleMessage("Untagged"),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
                "Applied filters are hiding all transactions.\nUpdate or reset filters to view transactions."),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "There are no transactions in this account.\nReceive your first transaction below."),
        "account_type_label_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "account_type_sublabel_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Create a mobile wallet with Magic Backups."),
        "accounts_empty_text_learn_more":
            MessageLookupByLibrary.simpleMessage("Get Started"),
        "accounts_forceUpdate_cta":
            MessageLookupByLibrary.simpleMessage("Update Envoy"),
        "accounts_forceUpdate_heading":
            MessageLookupByLibrary.simpleMessage("Envoy Update Required"),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
            "A new Envoy update is available that contains important upgrades and fixes. \n\nTo continue using Envoy, please update to the latest version. Thank you."),
        "accounts_screen_walletType_Envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "accounts_screen_walletType_Passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "accounts_screen_walletType_defaultName":
            MessageLookupByLibrary.simpleMessage("Mobile Wallet"),
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Boosted"),
        "activity_canceling": MessageLookupByLibrary.simpleMessage("Canceling"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
            "There is no activity to display."),
        "activity_envoyUpdate":
            MessageLookupByLibrary.simpleMessage("Envoy App Updated"),
        "activity_envoyUpdateAvailable":
            MessageLookupByLibrary.simpleMessage("Envoy update available"),
        "activity_firmwareUpdate":
            MessageLookupByLibrary.simpleMessage("Firmware update available"),
        "activity_incomingPurchase":
            MessageLookupByLibrary.simpleMessage("Incoming Purchase"),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Today"),
        "activity_passportUpdate":
            MessageLookupByLibrary.simpleMessage("Passport update available"),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pending"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Received"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Sent"),
        "activity_sent_boosted":
            MessageLookupByLibrary.simpleMessage("Sent (Boosted)"),
        "activity_sent_canceled":
            MessageLookupByLibrary.simpleMessage("Canceled"),
        "add_note_modal_heading":
            MessageLookupByLibrary.simpleMessage("Add a Note"),
        "add_note_modal_ie_text_field": MessageLookupByLibrary.simpleMessage(
            "Purchased a Passport hardware wallet"),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Record some details about this transaction."),
        "android_backup_info_heading":
            MessageLookupByLibrary.simpleMessage("Android Backs Up Every 24h"),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
            "Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Magic Backup is complete, we recommend performing a manual backup in your device [[Settings]]."),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
            "Envoy is a simple Bitcoin wallet with powerful account management and privacy features.\n\nUse Envoy alongside your Passport hardware wallet for setup, firmware updates, and more.\n\nEnvoy offers the following features:\n\n1. Magic Backups. Get up and running with self-custody in only 60 seconds with automatic encrypted backups. Seed words optional.\n\n2. Manage your mobile wallet and Passport hardware wallet accounts in the same app.\n\n3. Send and receive Bitcoin in a zen-like interface.\n\n4. Connect your Passport hardware wallet for setup, firmware updates, and support videos. Use Envoy as your software wallet connected to your Passport.\n\n5. Fully open source and privacy preserving. Envoy optionally connects to the Internet with Tor for maximum privacy.\n\n6. Optionally connect your own Bitcoin node."),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Pending Azteco voucher"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Unable to Connect"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to connect with Azteco.\n\nPlease contact support@azte.co or try again later."),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage("VOUCHER CODE"),
        "azteco_redeem_modal_amount":
            MessageLookupByLibrary.simpleMessage("Amount"),
        "azteco_redeem_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Redeem"),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Unable to Redeem"),
        "azteco_redeem_modal_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Please confirm that your voucher is still valid.\n\nContact support@azte.co with any voucher related questions."),
        "azteco_redeem_modal_heading":
            MessageLookupByLibrary.simpleMessage("Redeem Voucher?"),
        "azteco_redeem_modal_saleDate":
            MessageLookupByLibrary.simpleMessage("Sale Date"),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage("Voucher Redeemed"),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "An incoming transaction will appear in your account shortly."),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage("Erase Wallets and Backups"),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "You’re about to permanently delete your Envoy Wallet. \n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from Android Auto Backup. "),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "You’re about to permanently delete your Envoy Wallet.\n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from iCloud Keychain. "),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Any connected Passport accounts will not be removed as part of this process.\n\nBefore deleting your Envoy Wallet, let’s ensure your Seed and Backup File are saved.\n"),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Show Seed"),
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Activity"),
        "bottomNav_devices": MessageLookupByLibrary.simpleMessage("Devices"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Learn"),
        "bottomNav_privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "btcpay_connection_modal_expired_subheading": m0,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Voucher Expired"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to connect with the issuer\'s BTCPay store.\n\nPlease contact the issuer or try again later."),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
                "The scanned voucher was not created with onchain support.\n\nPlease contact the voucher creator."),
        "btcpay_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Pending BTCPay Voucher"),
        "btcpay_redeem_modal_description":
            MessageLookupByLibrary.simpleMessage("Description:"),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Name:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Wrong Network"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This is an on-chain voucher. It cannot be redeemed to a Testnet or Signet account."),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage("Choose different account"),
        "buy_bitcoin_accountSelection_heading":
            MessageLookupByLibrary.simpleMessage(
                "Where should the Bitcoin be sent?"),
        "buy_bitcoin_accountSelection_modal_heading":
            MessageLookupByLibrary.simpleMessage("Leaving Envoy"),
        "buy_bitcoin_accountSelection_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "You are about to leave Envoy for our partner service to purchase Bitcoin. Foundation never learns any purchase information."),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Your Bitcoin will be sent to this address:"),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
                "Verify Address with Passport"),
        "buy_bitcoin_accountSelection_verify_modal_heading": m1,
        "buy_bitcoin_buyOptions_atms_heading":
            MessageLookupByLibrary.simpleMessage("How would you like to buy?"),
        "buy_bitcoin_buyOptions_atms_map_modal_openingHours":
            MessageLookupByLibrary.simpleMessage("Opening Hours:"),
        "buy_bitcoin_buyOptions_atms_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Different ATM providers require varying amounts of personal information. This info is never shared with Foundation."),
        "buy_bitcoin_buyOptions_atms_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Find a Bitcoin ATM in your local area to purchase Bitcoin with cash."),
        "buy_bitcoin_buyOptions_card_atms":
            MessageLookupByLibrary.simpleMessage("ATMs"),
        "buy_bitcoin_buyOptions_card_commingSoon":
            MessageLookupByLibrary.simpleMessage("Coming soon in your area."),
        "buy_bitcoin_buyOptions_card_disabledInSettings":
            MessageLookupByLibrary.simpleMessage("Disabled in settings."),
        "buy_bitcoin_buyOptions_card_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("Buy in Envoy"),
        "buy_bitcoin_buyOptions_card_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Buy Bitcoin in seconds, directly to your Passport accounts or mobile wallet."),
        "buy_bitcoin_buyOptions_card_peerToPeer":
            MessageLookupByLibrary.simpleMessage("Peer to Peer"),
        "buy_bitcoin_buyOptions_card_vouchers":
            MessageLookupByLibrary.simpleMessage("Vouchers"),
        "buy_bitcoin_buyOptions_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("How would you like to buy?"),
        "buy_bitcoin_buyOptions_inEnvoy_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Info shared with Ramp when you purchase Bitcoin using this method. This info is never shared with Foundation."),
        "buy_bitcoin_buyOptions_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Buy with credit card, Apple Pay, Google Pay or bank transfer, directly into your Passport accounts or mobile wallet."),
        "buy_bitcoin_buyOptions_modal_address":
            MessageLookupByLibrary.simpleMessage("Address"),
        "buy_bitcoin_buyOptions_modal_bankingInfo":
            MessageLookupByLibrary.simpleMessage("Banking Info"),
        "buy_bitcoin_buyOptions_modal_email":
            MessageLookupByLibrary.simpleMessage("Email"),
        "buy_bitcoin_buyOptions_modal_identification":
            MessageLookupByLibrary.simpleMessage("Identification"),
        "buy_bitcoin_buyOptions_modal_poweredBy":
            MessageLookupByLibrary.simpleMessage("Powered by "),
        "buy_bitcoin_buyOptions_notSupported_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Check out these other ways to purchase Bitcoin."),
        "buy_bitcoin_buyOptions_peerToPeer_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Most trades require no info sharing, but your trade partner may learn your banking info. This info is never shared with Foundation."),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk":
            MessageLookupByLibrary.simpleMessage("AgoraDesk"),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Non-custodial, peer-to-peer Bitcoin purchases."),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq":
            MessageLookupByLibrary.simpleMessage("Bisq"),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Non-custodial, peer-to-peer Bitcoin purchases."),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl":
            MessageLookupByLibrary.simpleMessage("Hodl Hodl"),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Non-custodial, peer-to-peer Bitcoin purchases."),
        "buy_bitcoin_buyOptions_peerToPeer_options_heading":
            MessageLookupByLibrary.simpleMessage("Select an option"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach":
            MessageLookupByLibrary.simpleMessage("Peach"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Non-custodial, peer-to-peer Bitcoin purchases."),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats":
            MessageLookupByLibrary.simpleMessage("Robosats"),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Non-custodial, Lightning native, peer-to-peer Bitcoin purchases."),
        "buy_bitcoin_buyOptions_peerToPeer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Buy Bitcoin outside of Envoy, without middlemen. Requires more steps, but can be more private."),
        "buy_bitcoin_buyOptions_vouchers_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Different vendors will require varying amounts of personal information. This info is never shared with Foundation."),
        "buy_bitcoin_buyOptions_vouchers_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Purchase Bitcoin vouchers online or in person. Redeem using the scanner inside any account."),
        "buy_bitcoin_defineLocation_heading":
            MessageLookupByLibrary.simpleMessage("Your Region"),
        "buy_bitcoin_defineLocation_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Select your region so Envoy can display the purchase options available to you.  This info will never leave Envoy."),
        "buy_bitcoin_details_menu_editRegion":
            MessageLookupByLibrary.simpleMessage("EDIT REGION"),
        "buy_bitcoin_exit_modal_heading":
            MessageLookupByLibrary.simpleMessage("Cancel Buying Process"),
        "buy_bitcoin_exit_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "You are about to cancel the buying process. Are you sure?"),
        "buy_bitcoin_mapLoadingError_header":
            MessageLookupByLibrary.simpleMessage("Couldn\'t load map"),
        "buy_bitcoin_mapLoadingError_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is currently unable to load map data. Check your connection or try again later."),
        "buy_bitcoin_purchaseComplete_heading":
            MessageLookupByLibrary.simpleMessage("Purchase Complete"),
        "buy_bitcoin_purchaseComplete_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Finalization may take some time depending on\npayment method and network congestion."),
        "buy_bitcoin_purchaseError_contactRamp":
            MessageLookupByLibrary.simpleMessage(
                "Please contact Ramp for support."),
        "buy_bitcoin_purchaseError_heading":
            MessageLookupByLibrary.simpleMessage("Something Went Wrong"),
        "buy_bitcoin_purchaseError_purchaseID":
            MessageLookupByLibrary.simpleMessage("Purchase ID:"),
        "card_coin_locked": MessageLookupByLibrary.simpleMessage("Coin Locked"),
        "card_coin_selected":
            MessageLookupByLibrary.simpleMessage("Coin Selected"),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Coin"),
        "card_coins_locked":
            MessageLookupByLibrary.simpleMessage("Coins Locked"),
        "card_coins_selected":
            MessageLookupByLibrary.simpleMessage("Coins Selected"),
        "card_coins_unselected": MessageLookupByLibrary.simpleMessage("Coins"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("of"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Choose a Tag"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
                "This transaction spends coins from multiple tags. How would you like to tag your change?"),
        "coinDetails_tagDetails":
            MessageLookupByLibrary.simpleMessage("TAG DETAILS"),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone."),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Available balance"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Required Amount"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Selected Amount"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Lock"),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Locking coins will prevent them from being used in transactions"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Review Transaction"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage("Sign with Passport"),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction is ready \nto be signed"),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Confirm the transaction details are correct before signing with Passport."),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Save some details about your transaction."),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Show details"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Amount to send"),
        "coincontrol_tx_detail_change":
            MessageLookupByLibrary.simpleMessage("Change received"),
        "coincontrol_tx_detail_cta1":
            MessageLookupByLibrary.simpleMessage("Send Transaction"),
        "coincontrol_tx_detail_cta2":
            MessageLookupByLibrary.simpleMessage("Edit Transaction"),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Confirm Fee"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_cta":
            MessageLookupByLibrary.simpleMessage("Over 25%"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Over 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage("Destination"),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Show address"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Change received"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage("coin"),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage("coins"),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("TRANSACTION DETAILS"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Spent from"),
        "coincontrol_tx_detail_fee":
            MessageLookupByLibrary.simpleMessage("Fee"),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
                " Updating your fee may have changed\nyour coin selection. Please review."),
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage("Custom"),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage("Faster"),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage("Standard"),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
            "Your transaction is ready \nto be sent"),
        "coincontrol_tx_detail_high_fee_info_overlay_learnMore":
            MessageLookupByLibrary.simpleMessage("[[Learn more]]"),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Some smaller coins have been excluded from this transaction. At the chosen fee rate, they cost more to include than they are worth."),
        "coincontrol_tx_detail_newFee":
            MessageLookupByLibrary.simpleMessage("New Fee"),
        "coincontrol_tx_detail_no_change":
            MessageLookupByLibrary.simpleMessage("No change"),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage("Cancel Transaction"),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
                "By canceling you will lose all transaction progress."),
        "coincontrol_tx_detail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Confirm the transaction details are correct before sending."),
        "coincontrol_tx_detail_total":
            MessageLookupByLibrary.simpleMessage("Total"),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Note"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Unlock"),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Unlocking coins will make them available for use in transactions."),
        "coindetails_overlay_address":
            MessageLookupByLibrary.simpleMessage("Address"),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("at"),
        "coindetails_overlay_boostedFees":
            MessageLookupByLibrary.simpleMessage("Boosted Fee"),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage("Confirmation in"),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage("Confirms in"),
        "coindetails_overlay_confirmationIn_day":
            MessageLookupByLibrary.simpleMessage("day"),
        "coindetails_overlay_confirmationIn_days":
            MessageLookupByLibrary.simpleMessage("days"),
        "coindetails_overlay_confirmationIn_month":
            MessageLookupByLibrary.simpleMessage("month"),
        "coindetails_overlay_confirmationIn_week":
            MessageLookupByLibrary.simpleMessage("week"),
        "coindetails_overlay_confirmationIn_weeks":
            MessageLookupByLibrary.simpleMessage("weeks"),
        "coindetails_overlay_confirmation_boost":
            MessageLookupByLibrary.simpleMessage("Boost"),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Date"),
        "coindetails_overlay_heading":
            MessageLookupByLibrary.simpleMessage("COIN DETAILS"),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage("Cannot Boost Transaction"),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This is because there are not enough confirmed or unlocked coins to choose from. \n\nWhere possible, allow pending coins to confirm or unlock some coins and try again."),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Note"),
        "coindetails_overlay_paymentID":
            MessageLookupByLibrary.simpleMessage("Payment ID"),
        "coindetails_overlay_rampFee":
            MessageLookupByLibrary.simpleMessage("Ramp Fees"),
        "coindetails_overlay_rampID":
            MessageLookupByLibrary.simpleMessage("Ramp ID"),
        "coindetails_overlay_status":
            MessageLookupByLibrary.simpleMessage("Status"),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmed"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "coindetails_overlay_tag": MessageLookupByLibrary.simpleMessage("Tag"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage("Transaction ID"),
        "component_Apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "component_back": MessageLookupByLibrary.simpleMessage("Back"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "component_content": MessageLookupByLibrary.simpleMessage("Content"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continue"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "component_device": MessageLookupByLibrary.simpleMessage("Device"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
        "component_done": MessageLookupByLibrary.simpleMessage("Done"),
        "component_dontShowAgain":
            MessageLookupByLibrary.simpleMessage("Don’t show again"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "component_filter_button_all":
            MessageLookupByLibrary.simpleMessage("All"),
        "component_goToSettings":
            MessageLookupByLibrary.simpleMessage("Go to Settings"),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Learn more"),
        "component_minishield_buy": MessageLookupByLibrary.simpleMessage("Buy"),
        "component_next": MessageLookupByLibrary.simpleMessage("Next"),
        "component_no": MessageLookupByLibrary.simpleMessage("No"),
        "component_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Redeem"),
        "component_reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "component_retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "component_save": MessageLookupByLibrary.simpleMessage("Save"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Skip"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
        "component_tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
        "component_update": MessageLookupByLibrary.simpleMessage("Update"),
        "component_warning": MessageLookupByLibrary.simpleMessage("WARNING"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Yes"),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
            "Your address will be copied to the clipboard and may be visible to other apps on your phone."),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
            "Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone."),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tags are a useful way to organize your coins."),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage("Suggestions"),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Most used"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to delete this tag?"),
        "delete_tag_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Delete Tag"),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Deleting this tag will automatically mark these coins as untagged."),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Android automatically backs up your Envoy data every 24 hours.\n\nTo immediately remove your Envoy Seed from Android Auto Backups, you can perform a manual backup in your device [[Settings.]]"),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage("Deleting your Envoy Wallet"),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Delete Wallet"),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Are you sure you want to DELETE your Envoy Wallet?"),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your wallet was successfully deleted"),
        "devices_empty_modal_video_cta1":
            MessageLookupByLibrary.simpleMessage("Buy Passport"),
        "devices_empty_modal_video_cta2":
            MessageLookupByLibrary.simpleMessage("Watch Later"),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Secure your Bitcoin with Passport."),
        "empty_tag_modal_subheading": m2,
        "envoy_account_tos_cta":
            MessageLookupByLibrary.simpleMessage("I Accept"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
            "Please review and accept the Passport Terms of Use"),
        "envoy_account_tos_subheading": MessageLookupByLibrary.simpleMessage(
            "Last updated: May 16, 2021.\r\n\r\nBy purchasing, using or continuing to use a Passport hardware wallet (“Passport“), you, the purchaser of Passport, agree to be bound by these terms of and use (the “Passport Terms of Use” or “Terms”).\r\n\r\n1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\r\n\r\n2. Security\n\r\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\r\n\r\n3. BACKUPS\r\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss.\r\n\r\n4. MODIFICATIONS\r\nYou acknowledge and agree that any modifications to Passport, the installation of any additional software or firmware on a Passport or the use of Passport in connection with any other software or equipment are at your sole risk, and that we have no obligation or liability in respect thereof or in respect of any resulting loss of Bitcoin, damage to Passport, failure of the Passport or errors in storing Bitcoin or processing Transactions;\r\n\r\n5. OPEN SOURCE LICENSES\r\nPassport includes software licensed under the GNU General Public License v3 and other open source licenses, as identified in documentation provided with Passport. Your use of such software is subject to the applicable open source licenses and, to the extent such open source licenses conflicts with this Agreement, the terms of such licenses will prevail.\r\n\r\n6. ACKNOWLEDGEMENT AND ASSUMPTION OF RISK\r\nYou understand and agree that:\r\n\r\n(a) there are risks associated with the use and holding of Bitcoin and you represent and warrant that you are knowledgeable and/or experienced in matters relating to the use of Bitcoin and are capable of evaluating the benefits and risks of using and holding Bitcoin and fully understand the nature of Bitcoin, the limitations and restrictions on its liquidity and transferability and are capable of bearing the economic risk of holding and transacting using Bitcoin;\r\n\r\n(b) the continued ability to use Bitcoin is dependent on many elements beyond our control, including without limitation the publication of blocks, network connectivity, hacking or changes in the technical and other standards, policies and procedures applicable to Bitcoin;\r\n\r\n(c) no regulatory authority has reviewed or passed on the merits, legality or fungibility of Bitcoin;\r\n\r\n(d) there is no government or other insurance covering Bitcoin, the loss or theft of Bitcoin, or any loss in the value of Bitcoin;\r\n\r\n(e) the use of Bitcoin or the Products may become subject to regulatory controls that limit, restrict, prohibit or otherwise impose conditions on your use of same;\r\n\r\n(f) Bitcoin do not constitute a currency, asset, security, negotiable instrument, or other form of property and do not have any intrinsic or inherent value;\r\n\r\n(g) the value of and/or exchange rates for Bitcoin may fluctuate significantly and may result in you incurring significant losses;\r\n\r\n(h) Transactions may have tax consequences (including obligations to report, collect or remit taxes) and you are solely responsible for understanding and complying with all applicable tax laws and regulations; and\r\n\r\n(i) the use of Bitcoin or Products may be illegal or subject to regulation in certain jurisdictions, and it is your responsibility to ensure that you comply with the laws of any jurisdiction in which you use Bitcoin or Products.\r\n\r\n7. TRANSFER OF PASSPORT\r\nYou may transfer or sell Passport to others on the condition that you ensure that the transferee or purchaser agrees to be bound by the then-current form of these Terms available on our website at the time of transfer.\r\n\r\n8. RESTRICTIONS\r\nYou shall not:\r\n\r\n(a) use Passport in a manner or for a purpose that: (i) is illegal or otherwise contravenes applicable law (including the facilitation or furtherance of any criminal or fraudulent activity or the violation of any anti-money laundering legislation); or (ii) infringes upon the lawful rights of others;\r\n\r\n(b) interfere with the security or integrity of Passport;\r\n\r\n(c) remove, destroy, cover, obfuscate or alter in any manner any notices, legends, trademarks, branding or logos appearing on or contained in Passport; or\r\n\r\n(d) attempt, or cause, permit or encourage any other person, to do any of the foregoing.\r\n\r\nNotwithstanding the foregoing, you may investigate security and other vulnerabilities, provided you do so in a reasonable and responsible manner in compliance with applicable law and our responsible disclosure policy and otherwise use good faith efforts to minimize or avoid contravention of any of the foregoing.\r\n\r\n9. REPRESENTATIONS AND WARRANTIES\r\nYou represent, warrant and covenant that:\r\n\r\n(a) you have the capacity to, and are and will be free to, enter into and to fully perform your obligations under these Terms and that no agreement or understanding with any other person exists or will exist which would interfere with such obligations; and\r\n\r\n(b) these Terms constitute a legal, valid and binding obligation upon you.\r\n\r\n10. OWNERSHIP\r\nExcept for the limited rights of use expressly granted to you under these Terms, all right, title and interest (including all copyrights, trademarks, service marks, patents, inventions, trade secrets, intellectual property rights and other proprietary rights) in and to Passport are and shall remain exclusively owned by us and our licensors. All trade names, company names, trademarks, service marks and other names and logos are the proprietary marks of us or our licensors, and are protected by law and may not be copied, imitated or used, in whole or in part, without the consent of their respective owners. These Terms do not grant you any rights in respect of any such marks. You understand and agree that any feedback, input, suggestions, recommendations, improvements, changes, specifications, test results, or other data or information that you provide or make available to us arising from or related to your use of the Products or Software shall become our exclusive property and may be used by us to modify, enhance, maintain and improve Passport without any obligation or payment to you whatsoever.\r\n\r\n11. THIRD PARTY PRODUCTS\r\nYou acknowledge and agree that you will require certain third party equipment, products, software and services in order to use the Products and may also use optional third party equipment, products, software and services that enhance or complement such use (collectively, “Third Party Products”). You acknowledge and agree that failure to use or procure Third Party Products that meet the minimum requirements for Products, or failure to properly configure or setup Third Party Products may result in the inability to use the Products and/or processing failures or errors. Third Party Products include, without limitation, computers, mobile devices, networking equipment, operating system software, web browsers and internet connectivity. We may also identify, recommend, reference or link to optional Third Party Products on our website. You acknowledge and agree that: (a) Third Party Products are be governed by separate licenses, agreements or terms and conditions and we have no obligation or liability to you in respect thereof; and (b) you are solely responsible for procuring any Third Party Products at your cost and expense, and are solely responsible for compliance with any applicable licenses, agreements or terms and conditions governing same. \r\n\r\n12. INDEMNITY\r\nYou agree to indemnify and hold Foundation Devices (and our officers, employees, and agents) harmless, including costs and attorneys’ fees, from any claim or demand due to or arising out of (a) your use of Passport, (b) your violation of this Agreement or (c) your violation of applicable laws or regulations. We reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us and you agree to cooperate with our defense of these claims. You agree not to settle any matter without our prior written consent. We will use reasonable efforts to notify you of any such claim, action or proceeding upon becoming aware of it.\r\n\r\n13. DISCLAIMERS\r\nPASSPORT IS PROVIDED “AS-IS” AND “AS AVAILABLE” AND WE (AND OUR SUPPLIERS) EXPRESSLY DISCLAIM ANY WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, QUIET ENJOYMENT, ACCURACY, OR NON-INFRINGEMENT. WE (AND OUR SUPPLIERS) MAKE NO WARRANTY THAT PASSPORT: (A) WILL MEET YOUR REQUIREMENTS; (B) WILL BE AVAILABLE ON AN UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE BASIS; OR (C) WILL BE ACCURATE, RELIABLE, FREE OF VIRUSES OR OTHER HARMFUL CODE, COMPLETE, LEGAL, OR SAFE.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n14. LIMITATION ON LIABILITY\r\nYOU AGREE THAT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, OUR AGGREGATE LIABILITY ARISING FROM OR RELATED TO THESE TERMS OR PASSPORT IN ANY MANNER WILL BE LIMITED TO DIRECT DAMAGES NOT TO EXCEED THE PURCHASE PRICE YOU HAVE PAID TO US FOR PASSPORT (EXCLUDING SHIPPING CHARGES AND TAXES). TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL WE (AND OUR SUPPLIERS) BE LIABLE FOR ANY CONSEQUENTIAL, INCIDENTAL, INDIRECT, SPECIAL, PUNITIVE, OR OTHER DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF REVENUE, PROFITS, OR EXPECTED SAVINGS, BUSINESS INTERRUPTION, PERSONAL INJURY, LOSS OF PRIVACY, LOSS OF DATA OR INFORMATION OR OTHER PECUNIARY OR INTANGIBLE LOSS) ARISING OUT OF THESE TERMS OR THE USE OF OR INABILITY TO USE PASSPORT, EVEN IF WE FORESEE OR HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OF CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n15. RELEASE\r\nYou hereby release and forever discharge us (and our officers, employees, agents, successors, and assigns) from, and hereby waive and relinquish, each and every past, present and future dispute, claim, controversy, demand, right, obligation, liability, action and cause of action of every kind and nature (including personal injuries, death, and property damage), that has arisen or arises directly or indirectly out of, or relates directly or indirectly to, use of Passport. IF YOU ARE A CALIFORNIA RESIDENT, YOU HEREBY WAIVE CALIFORNIA CIVIL CODE SECTION 1542 IN CONNECTION WITH THE FOREGOING, WHICH STATES: “A GENERAL RELEASE DOES NOT EXTEND TO CLAIMS WHICH THE CREDITOR DOES NOT KNOW OR SUSPECT TO EXIST IN HIS OR HER FAVOR AT THE TIME OF EXECUTING THE RELEASE, WHICH IF KNOWN BY HIM OR HER MUST HAVE MATERIALLY AFFECTED HIS OR HER SETTLEMENT WITH THE DEBTOR.”\r\n\r\n16. SURVIVAL\r\nNeither the expiration nor the earlier termination of your account will release you from any obligation or liability that accrued prior to such expiration or termination. The provisions of these Terms requiring performance or fulfilment after the expiration or earlier termination of your account and any other provisions hereof, the nature and intent of which is to survive termination or expiration, will survive.\r\n\r\n17. PRIVACY POLICY\r\nPlease review our Privacy Policy, located at https://foundationdevices.com/privacy, which governs the use of personal information.\r\n\r\n18. DISPUTE RESOLUTION\r\nPlease read the following arbitration agreement in this section (“Arbitration Agreement”) carefully. It requires U.S. users to arbitrate disputes with Foundation Devices and limits the manner in which you can seek relief from us.\r\n\r\n(a) Applicability of Arbitration Agreement. You agree that any dispute, claim, or request for relief relating in any way to your use of Passport will be resolved by binding arbitration, rather than in court, except that (a) you may assert claims or seek relief in small claims court if your claims qualify; and (b) you or we may seek equitable relief in court for infringement or other misuse of intellectual property rights (such as trademarks, trade dress, domain names, trade secrets, copyrights, and patents). This Arbitration Agreement shall apply, without limitation, to all disputes or claims and requests for relief that arose or were asserted before the effective date of this Agreement or any prior version of this Agreement.\r\n\r\n(b) Arbitration Rules and Forum. The Federal Arbitration Act governs the interpretation and enforcement of this Arbitration Agreement. To begin an arbitration proceeding, you must send a letter requesting arbitration and describing your dispute or claim or request for relief to our registered agent. The arbitration will be conducted by JAMS, an established alternative dispute resolution provider. Disputes involving claims, counterclaims, or request for relief under \$250,000, not inclusive of attorneys’ fees and interest, shall be subject to JAMS’s most current version of the Streamlined Arbitration Rules and procedures available at https://jamsadr.com/rules-streamlined-arbitration/; all other disputes shall be subject to JAMS’s most current version of the Comprehensive Arbitration Rules and Procedures, available at https://jamsadr.com/rules-comprehensive-arbitration/. JAMS’s rules are also available at https://jamsadr.com or by calling JAMS at 800-352-5267. If JAMS is not available to arbitrate, the parties will select an alternative arbitral forum. If the arbitrator finds that you cannot afford to pay JAMS’s filing, administrative, hearing and/or other fees and cannot obtain a waiver from JAMS, Company will pay them for you. In addition, Company will reimburse all such JAMS’s filing, administrative, hearing and/or other fees for disputes, claims, or requests for relief totaling less than \$10,000 unless the arbitrator determines the claims are frivolous.\r\n\r\nYou may choose to have the arbitration conducted by telephone, based on written submissions, or in person in the country where you live or at another mutually agreed location. Any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction.\r\n\r\n(c) Authority of Arbitrator. The arbitrator shall have exclusive authority to (a) determine the scope and enforceability of this Arbitration Agreement and (b) resolve any dispute related to the interpretation, applicability, enforceability or formation of this Arbitration Agreement including, but not limited to, any assertion that all or any part of this Arbitration Agreement is void or voidable. The arbitration will decide the rights and liabilities, if any, of you and Company. The arbitration proceeding will not be consolidated with any other matters or joined with any other cases or parties. The arbitrator shall have the authority to grant motions dispositive of all or part of any claim. The arbitrator shall have the authority to award monetary damages and to grant any non-monetary remedy or relief available to an individual under applicable law, the arbitral forum’s rules, and the Agreement (including the Arbitration Agreement). The arbitrator shall issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator has the same authority to award relief on an individual basis that a judge in a court of law would have. The award of the arbitrator is final and binding upon you and us.\r\n\r\n(d) Waiver of Jury Trial. YOU AND COMPANY HEREBY WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO SUE IN COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY. You and Company are instead electing that all disputes, claims, or requests for relief shall be resolved by arbitration under this Arbitration Agreement, except as specified in Section 10(a) (Application of Arbitration Agreement) above. An arbitrator can award on an individual basis the same damages and relief as a court and must follow this Agreement as a court would. However, there is no judge or jury in arbitration, and court review of an arbitration award is subject to very limited review.\r\n\r\n(e) Waiver of Class or Other Non-Individualized Relief. ALL DISPUTES, CLAIMS, AND REQUESTS FOR RELIEF WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS OR COLLECTIVE BASIS, ONLY INDIVIDUAL RELIEF IS AVAILABLE, AND CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If a decision is issued stating that applicable law precludes enforcement of any of this section’s limitations as to a given dispute, claim, or request for relief, then such aspect must be severed from the arbitration and brought into the State or Federal Courts located in the Commonwealth of Massachusetts. All other disputes, claims, or requests for relief shall be arbitrated.\r\n\r\n(f) 30-Day Right to Opt Out. You have the right to opt out of the provisions of this Arbitration Agreement by sending written notice of your decision to opt out to: hello@foundationdevices.com, within thirty (30) days after first becoming subject to this Arbitration Agreement. Your notice must include your name and address, your Company username (if any), the email address you used to set up your Company account (if you have one), and an unequivocal statement that you want to opt out of this Arbitration Agreement. If you opt out of this Arbitration Agreement, all other parts of this Agreement will continue to apply to you. Opting out of this Arbitration Agreement has no effect on any other arbitration agreements that you may currently have, or may enter in the future, with us.\r\n\r\n(g) Severability. Except as provided in Section 10(e)(Waiver of Class or Other Non-Individualized Relief), if any part or parts of this Arbitration Agreement are found under the law to be invalid or unenforceable, then such specific part or parts shall be of no force and effect and shall be severed and the remainder of the Arbitration Agreement shall continue in full force and effect.\r\n\r\n(h) Survival of Agreement. This Arbitration Agreement will survive the termination of your relationship with Company.\r\n\r\nModification. Notwithstanding any provision in this Agreement to the contrary, we agree that if Company makes any future material change to this Arbitration Agreement, you may reject that change within thirty (30) days of such change becoming effective by writing Company at the following address: Foundation Devices, Inc., 6 Liberty Square #6018, Boston, MA 02109, Attn: CEO.\r\n\r\n19. GENERAL\r\n(a) Changes to Terms of Use. This Agreement is subject to occasional revision, and if we make any substantial changes, we may notify you by sending you an e-mail to the last e-mail address you provided to us (if any) and/or by prominently posting notice of the changes on our website. Any changes to this agreement will be effective upon the earlier of thirty (30) calendar days following our dispatch of an e-mail notice to you (if applicable) or thirty (30) calendar days following our posting of notice of the changes on our website. These changes will be effective immediately for new users of our website. You are responsible for providing us with your most current e-mail address. In the event that the last e-mail address that you have provided us is not valid, or for any reason is not capable of delivering to you the notice described above, our dispatch of the e-mail containing such notice will nonetheless constitute effective notice of the changes described in the notice. Continued use of Passport following notice of such changes will indicate your acknowledgement of such changes and agreement to be bound by the terms and conditions of such changes.\r\n\r\nChoice Of Law. The Agreement is made under and will be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts, consistent with the Federal Arbitration Act, without giving effect to any principles that provide for the application of the law of another jurisdiction.\r\n\r\n(b) Entire Agreement. This Agreement constitutes the entire agreement between you and us regarding the use of Passport. Our failure to exercise or enforce any right or provision of this Agreement will not operate as a waiver of such right or provision. The section titles in this Agreement are for convenience only and have no legal or contractual effect. The word including means including without limitation. If any provision of this Agreement is, for any reason, held to be invalid or unenforceable, the other provisions of this Agreement will be unimpaired and the invalid or unenforceable provision will be deemed modified so that it is valid and enforceable to the maximum extent permitted by law. Your relationship to us is that of an independent contractor, and neither party is an agent or partner of the other. This Agreement, and your rights and obligations herein, may not be assigned, subcontracted, delegated, or otherwise transferred by you without our prior written consent, and any attempted assignment, subcontract, delegation, or transfer in violation of the foregoing will be null and void. The terms of this Agreement will be binding upon assignees.\r\n\r\n(c) Copyright/Trademark Information. Copyright © 2020, Foundation Devices, Inc. All rights reserved. All trademarks, logos and service marks displayed on the Site are our property or the property of other third parties. You are not permitted to use such trademarks, logos and service marks without our prior written consent or the consent of such third party which may own the Marks.\r\n\r\nContact Information:\r\n\r\nFoundation Devices, Inc.\r\n6 Liberty Square #6018\r\nBoston, MA 02109\r\nhello@foundationdevices.com"),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
            "Envoy requires camera access to scan QR codes. Please go to settings and grant camera permissions."),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Permission required"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
            "Envoy is a Bitcoin mobile wallet and Passport companion app, available on iOS and Android."),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
            "No, anyone is still free to manually download, verify and install new firmware. See [[here]] for more information."),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
            "Absolutely, there is no limit to the number of Passports you can manage and interact with using Envoy."),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
            "Yes, Envoy makes multi-account management simple."),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
            "Envoy communicates predominantly via QR codes, however firmware updates are passed from your phone via a microSD card. Passport includes microSD adapters for your phone."),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
            "Yes, just be aware that any wallet-specific information, such as address or UTXO labeling, will not be copied to or from Envoy."),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
            "This may be possible as most QR enabled hardware wallets communicate in very similar ways, however this is not explicitly supported. As Envoy is open source, we welcome other QR-based hardware wallets to add support!"),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
            "At this time Envoy only works with ‘on-chain’ Bitcoin. We plan to support Lightning in the future."),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
            "Anyone finding your phone would first need to get past your phones operating system PIN or biometric authentication to access Envoy. In the unlikely event they achieve this, the attacker could send funds from your Envoy Mobile Wallet and see the amount of Bitcoin stored within any connected Passport accounts. These Passport funds are not at risk because any transactions must be authorized by the paired Passport device."),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
            "If used with a Passport, Envoy acts as a ‘watch-only’ wallet connected to your hardware wallet. This means Envoy can construct transactions, but they are useless without the relevant authorization, which only Passport can provide. Passport is the \'cold storage\' and Envoy is simply the internet connected interface!If you use Envoy to create a mobile wallet, where the keys are stored securely on your phone, that mobile wallet would not be considered cold storage. This has zero effect on the security of any Passport connected accounts."),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
            "Yes, Envoy can connect to personal nodes via the Electrum or Esplora server protocols. To connect to your own server, scan the QR or enter the URL provided into the network settings on Envoy."),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
            "Envoy is designed to offer the easiest to use experience of any Bitcoin wallet, without compromising on your privacy. With Envoy Magic Backups, set up a self custodied Bitcoin mobile wallet in 60 seconds, without seed words! Passport users can connect their devices to Envoy for easy setup, firmware updates, and a simple Bitcoin wallet experience."),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
            "Downloading and installing Envoy requires zero personal information and Envoy can connect to the internet via Tor, a privacy preserving protocol. This means that Foundation has no way of knowing who you are. Envoy also allows more advanced users the ability to connect to their own Bitcoin node to remove any reliance on the Foundation servers completely."),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
            "Yes. From version 1.4.0, Envoy now support full coin selection as well as coin \'tagging\'."),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
            "At this time Envoy does not support batch spending."),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
            "Yes. From version 1.4.0, Envoy allows for fully customized miner fees as well as two quick select fee options of ‘Standard’ and ‘Faster’. \'Standard\' aims to get your transaction finalized within 60 minutes and \'Faster\' within 10 minutes. These are estimates based on the network congestion at the time the transaction is built and you will always be shown the cost of both options before finalizing the transaction."),
        "envoy_faq_answer_24": MessageLookupByLibrary.simpleMessage(
            "Yes! From v1.7 you can now purchase Bitcoin within Envoy and have it automatically deposited to your mobile account, or any connected Passport accounts. Just click on the buy button from the main Accounts screen."),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
            "Envoy is a simple Bitcoin wallet with powerful account management and privacy features, including Magic Backups.Use Envoy alongside your Passport hardware wallet for setup, firmware updates, and more."),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
            "Magic Backups is the easiest way to set up and back up a Bitcoin mobile wallet. Magic Backups stores your mobile wallet seed end-to-end encrypted in iCloud Keychain or Android Auto Backup. All app data is encrypted by your seed and stored on Foundation Servers. Set up your wallet in 60 seconds, and automatically restore if you lose your phone!"),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
            "Magic Backups are completely optional for users that want to leverage Envoy as a mobile wallet. If you prefer to manage your own mobile wallet seed words and backup file, choose \'Manually Configure Seed Words\' at the wallet set up stage."),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
            "The Envoy backup file contains app settings, account info and transaction labels. The file is encrypted with your mobile wallet seed words. For Magic Backup users, this is stored fully encrypted on the Foundation server. Manual backup Envoy users can download and store their backup file anywhere they like. This could be any combination of your phone, a personal cloud server, or on something physical like a microSD card or USB drive."),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
            "No, Envoy’s core features will always be free to use. In the future we may introduce optional paid services or subscriptions."),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
            "Yes, like everything we do at Foundation, Envoy is completely open source. Envoy is licensed under the same [[GPLv3]] license as our Passport Firmware. For those wanting to check our source code, click [[here]]."),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
            "No, we pride ourselves on ensuring Passport is compatible with as many different software wallets as possible. See our full list, including tutorials [[here]]."),
        "envoy_faq_question_1":
            MessageLookupByLibrary.simpleMessage("What is Envoy?"),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
            "Do I have to use Envoy to update the firmware on Passport?"),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
            "Can I manage more than one Passport with Envoy?"),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
            "Can I manage multiple accounts from the same Passport?"),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
            "How does Envoy communicate with Passport?"),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
            "Can I use Envoy in parallel to another piece of software like Sparrow Wallet?"),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
            "Can I manage other hardware wallets with Envoy?"),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
            "Is Envoy compatible with the Lightning Network?"),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
            "What happens if I lose my phone with Envoy installed?"),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
            "Is Envoy considered ‘Cold Storage’?"),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
            "Can I connect Envoy to my own Bitcoin node?"),
        "envoy_faq_question_2":
            MessageLookupByLibrary.simpleMessage("Why should I use Envoy?"),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
            "How does Envoy protect my privacy?"),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
            "Does Envoy offer coin control?"),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
            "Does Envoy support Batch spends?"),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
            "Does Envoy allow custom miner fee selection?"),
        "envoy_faq_question_24":
            MessageLookupByLibrary.simpleMessage("Can I buy Bitcoin in Envoy?"),
        "envoy_faq_question_3":
            MessageLookupByLibrary.simpleMessage("What can Envoy do?"),
        "envoy_faq_question_4":
            MessageLookupByLibrary.simpleMessage("What is Envoy Magic Backup?"),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
            "Do I have to use Envoy Magic Backups?"),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
            "What is the Envoy Backup File?"),
        "envoy_faq_question_7":
            MessageLookupByLibrary.simpleMessage("Do I need to pay for Envoy?"),
        "envoy_faq_question_8":
            MessageLookupByLibrary.simpleMessage("Is Envoy Open Source?"),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
            "Do I have to use Envoy to transact with Passport?"),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy failed to copy the firmware onto the microSD card."),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Ensure the microSD card is inserted into your phone correctly and try again. Alternatively the firmware can be downloaded from our [[GitHub]]."),
        "envoy_fw_intro_cta":
            MessageLookupByLibrary.simpleMessage("Download Firmware"),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Next, let’s update Passport\'s firmware"),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy allows you to update your Passport from your phone using the included microSD adapter.\n\nAdvanced users can [[tap here]] to download and verify their own firmware on a computer."),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
                "Allow Envoy to access the microSD card"),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Grant Envoy access to copy files to the microSD card. Tap Browse, then PASSPORT-SD, then Open."),
        "envoy_fw_microsd_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Download from Github"),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
            "Sorry, we can’t get the firmware update right now."),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
            "Insert the microSD card into your Phone"),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
            "Insert the provided microSD card adapter into your phone, then insert the microSD card into the adapter."),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
            "Remove the microSD card and insert it into Passport"),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Insert the microSD card into Passport and navigate to Settings -> Firmware -> Update Firmware.\n\nEnsure Passport has adequate battery charge before carrying out this operation."),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
            "Insert the microSD card into Passport then head follow the instructions. \n\nEnsure Passport has adequate battery charge before carrying out this operation."),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy is now copying the firmware onto the\nmicroSD card"),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
            "This might take few seconds. Please do not remove the microSD card."),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
            "Firmware was successfully copied onto the\nmicroSD card"),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Make sure to tap the Unmount SD Card button from your File Manager before removing your microSD card from your phone."),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
            "The latest firmware has been copied to the microSD card and is ready to be applied to Passport."),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Enter a 6-12 digit PIN on your Passport"),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport will always ask for the PIN when starting up. We recommend using a unique PIN and writing it down.\n\nIf you forget your PIN, there is no way to recover Passport, and the device will be permanently disabled."),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Now, create an encrypted backup of your seed"),
        "envoy_pp_new_seed_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport will back up your seed and device settings to an encrypted microSD card."),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
            "On Passport select \nCreate New Seed"),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport\'s Avalanche Noise Source, an open source true random number generator, helps create a strong seed."),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Congratulations, your new seed has been created"),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Next, we will connect Envoy and Passport."),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
            "On Passport, select \nRestore Backup"),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage("Decrypt your Backup"),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
                "To decrypt the backup file, enter the 20 digit backup code shown to you when creating the backup file.\n\nIf you have lost or forgotten this code, you can restore using the seed words instead."),
        "envoy_pp_restore_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the password to decrypt the backup."),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your Backup File has been successfully restored"),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
            "On Passport, select \nRestore Seed"),
        "envoy_pp_restore_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Use this feature to restore an existing 12 or 24 word seed."),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your seed has been successfully restored"),
        "envoy_pp_setup_intro_cta1":
            MessageLookupByLibrary.simpleMessage("Create New Seed"),
        "envoy_pp_setup_intro_cta2":
            MessageLookupByLibrary.simpleMessage("Restore Seed"),
        "envoy_pp_setup_intro_cta3":
            MessageLookupByLibrary.simpleMessage("Restore Backup"),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
            "How would you like to set up your Passport?"),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "As a new owner of a Passport you can create a new seed, restore a wallet using seed words, or restore a backup from an existing Passport."),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
            "First, let’s make sure your Passport is secure"),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "This security check will ensure your Passport has not been tampered with during shipping."),
        "envoy_scv_result_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Contact Us"),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
            "Your Passport may be insecure"),
        "envoy_scv_result_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy could not validate the security of your Passport. Please contact us for assistance."),
        "envoy_scv_result_ok_heading":
            MessageLookupByLibrary.simpleMessage("Your Passport is secure"),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
            "Next, create a PIN to secure your Passport"),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
            "Next, scan the QR code on Passport\'s screen"),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "This QR code completes the validation and shares some Passport information with Envoy."),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
            "On Passport, select Envoy App and scan this QR Code"),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "This QR code provides information for validation and setup."),
        "envoy_support_documentation":
            MessageLookupByLibrary.simpleMessage("Documentation"),
        "envoy_support_email": MessageLookupByLibrary.simpleMessage("Email"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1":
            MessageLookupByLibrary.simpleMessage("Enable Magic Backups"),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Manually Configure Seed Words"),
        "envoy_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Create New Wallet"),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "For a seamless setup, we recommend enabling [[Magic Backups]].\n\nAdvanced users can manually create or restore a wallet seed."),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage("Return to my Accounts"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage("Delete Accounts anyway"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Before deleting your Envoy Wallet, please empty your Accounts. \nGo to Backups > Erase Wallets and Backups once you’re done."),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "This encrypted file contains useful wallet data such as labels, accounts, and settings.\n\nThis file is encrypted with your Envoy Seed. Ensure your seed is backed up securely. "),
        "export_backup_send_CTA1":
            MessageLookupByLibrary.simpleMessage("Download Backup File"),
        "export_backup_send_CTA2":
            MessageLookupByLibrary.simpleMessage("Discard"),
        "export_seed_modal_12_words_CTA2":
            MessageLookupByLibrary.simpleMessage("View as QR Code"),
        "export_seed_modal_QR_code_CTA2":
            MessageLookupByLibrary.simpleMessage("View Seed"),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "To use this QR code in Envoy on a new phone, go to Set Up Envoy Wallet > Recover Magic Backup > Recover with QR code"),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
                "This seed is protected by a passphrase. You need these seed words and the passphrase to recover your funds."),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "The following screen displays highly sensitive information.\n\nAnyone with access to this data can steal your Bitcoin. Proceed with extreme caution."),
        "filter_sortBy_aToZ": MessageLookupByLibrary.simpleMessage("A to Z"),
        "filter_sortBy_highest":
            MessageLookupByLibrary.simpleMessage("Highest value"),
        "filter_sortBy_lowest":
            MessageLookupByLibrary.simpleMessage("Lowest value"),
        "filter_sortBy_newest":
            MessageLookupByLibrary.simpleMessage("Newest first"),
        "filter_sortBy_oldest":
            MessageLookupByLibrary.simpleMessage("Oldest first"),
        "filter_sortBy_zToA": MessageLookupByLibrary.simpleMessage("Z to A"),
        "header_buyBitcoin":
            MessageLookupByLibrary.simpleMessage("BUY BITCOIN"),
        "header_chooseAccount":
            MessageLookupByLibrary.simpleMessage("CHOOSE ACCOUNT"),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Swipe to show and hide your balance."),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Tap the above card to receive Bitcoin."),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
                "Tap any of the above cards to receive Bitcoin."),
        "launch_screen_faceID_fail_CTA":
            MessageLookupByLibrary.simpleMessage("Try Again"),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage("Authentication Failed"),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage("Please try again"),
        "launch_screen_lockedout_heading":
            MessageLookupByLibrary.simpleMessage("Locked Out"),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Biometric authentication is disabled. Please close the app, wait 30 seconds and try again."),
        "learning_center_device_defender":
            MessageLookupByLibrary.simpleMessage("Defender"),
        "learning_center_device_envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "learning_center_device_passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "learning_center_device_passportPrime":
            MessageLookupByLibrary.simpleMessage("Passport Prime"),
        "learning_center_filterEmpty_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Applied filters are hiding all search results.\nUpdate or reset filters to view more results."),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("All"),
        "learning_center_results_title":
            MessageLookupByLibrary.simpleMessage("Results"),
        "learning_center_search_input":
            MessageLookupByLibrary.simpleMessage("Search..."),
        "learning_center_title_blog":
            MessageLookupByLibrary.simpleMessage("Blog"),
        "learning_center_title_faq":
            MessageLookupByLibrary.simpleMessage("FAQs"),
        "learning_center_title_video":
            MessageLookupByLibrary.simpleMessage("Videos"),
        "learningcenter_status_read":
            MessageLookupByLibrary.simpleMessage("Read"),
        "learningcenter_status_watched":
            MessageLookupByLibrary.simpleMessage("Watched"),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage("Encrypting Your Backup"),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as tags, notes, accounts, and settings."),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your Android backup."),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage("Creating Your Envoy Seed"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain."),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage("Recover with QR Code"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Google account and that you’ve restored your latest device backup."),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage("Magic Backup Not Found"),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to locate a Magic Backup file on the Foundation server.\n\nPlease check you’re recovering a wallet that previously used Magic Backups."),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Connection Error"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to connect to the Foundation server to retrieve your Magic Backup data.\n\nYou can retry, import your own Envoy Backup File, or continue without one.\n"),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage("Recovery Unsuccessful"),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup."),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
                "Recovering your Envoy wallet"),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage("Uploading Your Backup"),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents."),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically backs up your wallet and settings with Android Auto Backup, 100% end-to-end encrypted. \n\n[[Learn more]]."),
        "magic_setup_tutorial_heading":
            MessageLookupByLibrary.simpleMessage("Magic Backups"),
        "magic_setup_tutorial_ios_CTA1":
            MessageLookupByLibrary.simpleMessage("Create Magic Backup"),
        "magic_setup_tutorial_ios_CTA2":
            MessageLookupByLibrary.simpleMessage("Recover Magic Backup"),
        "magic_setup_tutorial_ios_subheading": MessageLookupByLibrary.simpleMessage(
            "The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically back up your wallet and settings with iCloud Keychain, 100% end-to-end encrypted. \n\n[[Learn more]]."),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
                "For privacy, we create a new address each time you visit this screen."),
        "manage_account_address_heading":
            MessageLookupByLibrary.simpleMessage("ACCOUNT DETAILS"),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Make sure not to share this descriptor unless you are comfortable with your transactions being public."),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage("EDIT ACCOUNT NAME"),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage("SHOW DESCRIPTOR"),
        "manage_account_remove_heading":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This only removes the account from Envoy."),
        "manage_account_rename_heading":
            MessageLookupByLibrary.simpleMessage("Rename Account"),
        "manage_device_deletePassportWarning": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to disconnect Passport?\nThis will remove the device from Envoy alongside any connected accounts."),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage("Paired"),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage("Serial"),
        "manage_device_details_heading":
            MessageLookupByLibrary.simpleMessage("DEVICE DETAILS"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage("EDIT DEVICE NAME"),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage("Rename your Passport"),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
                "Unable to backup. Please try again later."),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
                "This will discard any coin selection changes. Do you want to proceed?"),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Choose Destination"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage("Save Envoy Backup File"),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("I understand"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy Backup File is encrypted by your seed words. \n\nIf you lose access to your seed words, you will be unable to recover your backup."),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy has generated your encrypted backup. This backup contains useful wallet data such as Tags, Notes, accounts and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card."),
        "manual_setup_generate_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Generate Seed"),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage("Keep Your Seed Private"),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Remember to always keep your seed words private. Anyone with access to this seed can spend your Bitcoin!"),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage("Choose a word to continue"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage("Let’s Verify Your Seed"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage("Verify Your Seed"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Invalid Entry"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is unable to verify your seed. Please confirm that you correctly recorded your seed and try again."),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage(
                "What’s your seed word number"),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correct"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy will ask you some questions to verify you correctly recorded your seed."),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Write Down These 24 Words"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Write Down These 12 Words"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Generating Seed"),
        "manual_setup_import_backup_CTA1":
            MessageLookupByLibrary.simpleMessage("Create Envoy Backup File"),
        "manual_setup_import_backup_CTA2":
            MessageLookupByLibrary.simpleMessage("Import Envoy Backup File"),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage("We can’t read Envoy Backup"),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Make sure you have selected the right file."),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Would you like to restore an existing Envoy Backup file?\n\nIf not, Envoy will create a new encrypted backup file."),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "That seed appears to be invalid. Please check the words entered, including the order they are in and try again."),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Enter Your Seed"),
        "manual_setup_import_seed_CTA1":
            MessageLookupByLibrary.simpleMessage("Import with QR code"),
        "manual_setup_import_seed_CTA2":
            MessageLookupByLibrary.simpleMessage("24 Word Seed"),
        "manual_setup_import_seed_CTA3":
            MessageLookupByLibrary.simpleMessage("12 Word Seed"),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage("My seed has a passphrase"),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage("Import Your Seed"),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
                "Never import your Passport seed into the following screens."),
        "manual_setup_import_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Continue below to import an existing seed.\n\nYou’ll have the option to import an Envoy Backup File later."),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Importing Seed"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage("Magic Backup Detected"),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignore"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restore"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Magic Backup was found on the server.  \nRestore your backup?"),
        "manual_setup_recovery_fail_cta2":
            MessageLookupByLibrary.simpleMessage("Import Seed Words"),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage("Unable to scan QR Code"),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Try scanning again or manually import your seed words instead."),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "If you continue without a backup file, your wallet settings, additional accounts, Tags and Notes will not be restored."),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Re-type Passphrase"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage("Choose other Backup File"),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy can’t open this Envoy Backup File"),
        "manual_setup_recovery_import_backup_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This could be because you imported a backup file from a different Envoy Wallet, or because your passphrase was entered incorrectly."),
        "manual_setup_recovery_import_backup_re_enter_passphrase_heading":
            MessageLookupByLibrary.simpleMessage("Re-type Your \nPassphrase"),
        "manual_setup_recovery_import_backup_re_enter_passphrase_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Carefully re-type your passphrase so Envoy can open your Envoy Backup File."),
        "manual_setup_recovery_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Enter Your Passphrase"),
        "manual_setup_recovery_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This seed is protected by a passphrase. Enter it below to import your Envoy Wallet."),
        "manual_setup_recovery_success_heading":
            MessageLookupByLibrary.simpleMessage("Importing your Seed"),
        "manual_setup_tutorial_CTA1":
            MessageLookupByLibrary.simpleMessage("Generate New Seed"),
        "manual_setup_tutorial_CTA2":
            MessageLookupByLibrary.simpleMessage("Import Seed"),
        "manual_setup_tutorial_heading":
            MessageLookupByLibrary.simpleMessage("Manual Seed Setup"),
        "manual_setup_tutorial_subheading": MessageLookupByLibrary.simpleMessage(
            "If you prefer to manage your own seed words, continue below to import or create a new seed.\n\nPlease note that you alone will be responsible for managing backups. No cloud services will be used."),
        "manual_setup_verify_enterYourPassphrase":
            MessageLookupByLibrary.simpleMessage("Enter Your Passphrase"),
        "manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Passphrases are case and space sensitive. Enter with care."),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2":
            MessageLookupByLibrary.simpleMessage(
                "[[Passphrases]] are an advanced feature."),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "If you do not understand the implications of using one, close this box and continue without one.\n\nFoundation has no way to recover a lost or incorrect passphrase."),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Verify Your Passphrase"),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Please carefully re-enter your passphrase."),
        "manual_toggle_off_disabled_for_manual_seed_configuration":
            MessageLookupByLibrary.simpleMessage(
                "Disabled for Manual Seed Configuration "),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage("Download Envoy Backup File"),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage("View Envoy Seed"),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
                "Stored in Android Auto Backup"),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Envoy Backup File"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Envoy Seed"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Back Up Now"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage("Stored in iCloud Keychain"),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage("to Foundation Servers"),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage("Backup in Progress"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy backup is complete."),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage("Uploading Envoy Backup"),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This backup contains connected devices and accounts, labels and app settings. It contains no private key information.\n\nEnvoy backups are end-to-end encrypted, Foundation has no access or knowledge of their contents. \n\nEnvoy will notify you when the upload is complete."),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Open Android Settings"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Pending Android Auto Backup (once daily)"),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Pending backup to iCloud Keychain"),
        "menu_about": MessageLookupByLibrary.simpleMessage("ABOUT"),
        "menu_backups": MessageLookupByLibrary.simpleMessage("BACKUPS"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("SETTINGS"),
        "menu_support": MessageLookupByLibrary.simpleMessage("SUPPORT"),
        "pair_existing_device_intro_heading":
            MessageLookupByLibrary.simpleMessage(
                "Connect Passport\nwith Envoy"),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
                "On Passport, select Manage Account > Connect Wallet > Envoy."),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
            "Scan this QR code with Passport to validate"),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This is a Bitcoin address belonging to your Passport."),
        "pair_new_device_address_cta2":
            MessageLookupByLibrary.simpleMessage("Contact Support"),
        "pair_new_device_address_heading":
            MessageLookupByLibrary.simpleMessage("Address validated?"),
        "pair_new_device_address_subheading": MessageLookupByLibrary.simpleMessage(
            "If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support."),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This step allows Envoy to generate receive addresses for Passport and propose spend transactions that Passport must authorize. "),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
            "Scan the QR code that Passport generates"),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
            "The QR code contains the information required for Envoy to interact securely with Passport."),
        "pair_new_device_success_cta1":
            MessageLookupByLibrary.simpleMessage("Validate receive address"),
        "pair_new_device_success_cta2":
            MessageLookupByLibrary.simpleMessage("Continue to home screen"),
        "pair_new_device_success_heading":
            MessageLookupByLibrary.simpleMessage("Connection successful"),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is now connected to your Passport."),
        "passport_welcome_screen_cta1":
            MessageLookupByLibrary.simpleMessage("Set up a new Passport"),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Connect an existing Passport"),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
            "I don’t have a Passport. [[Learn more.]]"),
        "passport_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Welcome to Passport"),
        "passport_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience."),
        "privacySetting_nodeConnected":
            MessageLookupByLibrary.simpleMessage("Node Connected"),
        "privacy_applicationLock_title":
            MessageLookupByLibrary.simpleMessage("Application lock"),
        "privacy_applicationLock_unlock": MessageLookupByLibrary.simpleMessage(
            "Unlock with biometrics or PIN"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
            "Improve your privacy by running your own node. Tap learn more above. "),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage("Block height:"),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage("Connected to Esplora server"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
                "Could not connect to Esplora server."),
        "privacy_node_connectedTo":
            MessageLookupByLibrary.simpleMessage("Connected to"),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage("Couldn\'t reach node."),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
                "Even with ‘Improved Privacy’ active, Envoy cannot prevent interference by compromised devices on your local network."),
        "privacy_node_nodeAddress":
            MessageLookupByLibrary.simpleMessage("Enter your node address"),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage("Foundation (Default)"),
        "privacy_node_nodeType_personal":
            MessageLookupByLibrary.simpleMessage("Personal Node"),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Node"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Better \nPerformance"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage("Improved Privacy"),
        "privacy_privacyMode_title":
            MessageLookupByLibrary.simpleMessage("Privacy mode"),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
                "Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users."),
        "privacy_privacyMode_torSuggestionOn": MessageLookupByLibrary.simpleMessage(
            "Tor will be turned [[ON]] for improved privacy. Envoy’s connection may be unreliable."),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Add Node"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Edit Node"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Your Node is connected via Clearnet."),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
                "We couldn’t connect your node"),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Connect"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("Connecting Your Node"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
                "Your Node is connected via Tor."),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage("Choose Your Privacy"),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
                "How would you like Envoy to connect to the Internet?"),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage("Use Taproot Address"),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("RECEIVE"),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("Awaiting confirmation"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Receive"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Send"),
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Sign into Google and restore your backup data"),
        "recovery_scenario_heading":
            MessageLookupByLibrary.simpleMessage("How to Recover?"),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
            "Install Envoy and tap “Set Up Envoy Wallet”"),
        "recovery_scenario_ios_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Sign into iCloud and restore your iCloud backup"),
        "recovery_scenario_ios_instruction3":
            MessageLookupByLibrary.simpleMessage(
                "Envoy will then automatically restore your Magic Backup"),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
            "To recover your Envoy wallet, follow these simple instructions."),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
                "The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. "),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage("Boosting transaction"),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
            "Your transaction could not be boosted"),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage("Review Coin Selection"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction has been boosted"),
        "replaceByFee_boost_tx_boostFee":
            MessageLookupByLibrary.simpleMessage("Boost Fee"),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
            "Your transaction is ready \nto be boosted"),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage("None"),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "The network fee for cancelling this transaction means no funds will be sent back to your wallet.\n\nAre you sure you want to cancel?"),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage("Canceling transaction"),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction could not be canceled"),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Cancellation Fee"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage("Proceed with Cancellation"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Receiving Amount"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Replace the unconfirmed transaction with one that contains a higher fee and sends the funds back to your wallet."),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction has been canceled"),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This is a cancellation attempt. There is a slight chance your original transaction is confirmed before this cancellation attempt."),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Boost"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Boost Transaction"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Increase the fee attached to your transaction to speed up confirmation time."),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Required to Boost"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transactions Removed"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Incomplete purchases with the following Ramp IDs were removed from activity after 5 days."),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage("New Transaction Fee "),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "To boost your original transaction, you are about to pay a new fee of:"),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
                "This will replace the original fee of:"),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
                "Incomplete purchases will be automatically removed after 5 days"),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. \n\nThis selection can be reviewed or edited in the following screen."),
        "scv_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage("Checking Device Security"),
        "send_keyboard_address_confirm":
            MessageLookupByLibrary.simpleMessage("Confirm"),
        "send_keyboard_address_loading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage("Enter valid address"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Insufficient funds"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage("Amount too low"),
        "send_keyboard_send_max":
            MessageLookupByLibrary.simpleMessage("Send Max"),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("To:"),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
            "Scan the QR with your Passport"),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
            "It contains the transaction for your Passport to sign."),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
            "You can now scan the QR code displayed on your Passport with your phone camera."),
        "send_reviewScreen_sendMaxWarning":
            MessageLookupByLibrary.simpleMessage(
                "Sending Max: \nFees are deducted from amount being sent."),
        "settings_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "settings_advanced_enableBuyRamp":
            MessageLookupByLibrary.simpleMessage("Buy in Envoy"),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Learn more about Signet [[here]]."),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Enabling Signet adds a Signet version of your Envoy Wallet. This feature is primarily used by developers or testers and has zero value."),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Learn how to do that [[here]]."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Enabling Testnet adds a Testnet version of your Envoy Wallet, and allows you to connect Testnet accounts from your Passport."),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activate"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Taproot is an advanced feature and wallet support is still limited.\n\nProceed with caution."),
        "settings_advanced_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "settings_amount":
            MessageLookupByLibrary.simpleMessage("View Amount in Sats"),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Currency"),
        "settings_show_fiat":
            MessageLookupByLibrary.simpleMessage("Display Fiat Values"),
        "settings_viewEnvoyLogs":
            MessageLookupByLibrary.simpleMessage("View Envoy Logs"),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("No thanks"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Transaction notes can be useful when making future spends."),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction couldn’t be sent"),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Please check your connection and try again"),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Your transaction was successfully sent"),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Review the details by tapping on the transaction from the account details screen."),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("Sending transaction"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
                "This might take a few seconds"),
        "tagDetails_EditTagName":
            MessageLookupByLibrary.simpleMessage("Edit Tag Name"),
        "tagSelection_example1":
            MessageLookupByLibrary.simpleMessage("Expenses"),
        "tagSelection_example2":
            MessageLookupByLibrary.simpleMessage("Personal"),
        "tagSelection_example3":
            MessageLookupByLibrary.simpleMessage("Savings"),
        "tagSelection_example4":
            MessageLookupByLibrary.simpleMessage("Donations"),
        "tagSelection_example5": MessageLookupByLibrary.simpleMessage("Travel"),
        "tagged_coin_details_inputs_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Discard Changes"),
        "tagged_coin_details_menu_cta1":
            MessageLookupByLibrary.simpleMessage("EDIT TAG NAME"),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
                "There are no coins assigned to this tag."),
        "tagged_tagDetails_sheet_cta1":
            MessageLookupByLibrary.simpleMessage("Send Selected"),
        "tagged_tagDetails_sheet_cta2":
            MessageLookupByLibrary.simpleMessage("Tag Selected"),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage("Retag Selected"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Hold to drag and reorder your accounts."),
        "taproot_passport_dialog_heading":
            MessageLookupByLibrary.simpleMessage("Taproot on Passport"),
        "taproot_passport_dialog_later":
            MessageLookupByLibrary.simpleMessage("Do It Later"),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage("Reconnect Passport"),
        "taproot_passport_dialog_subheading": MessageLookupByLibrary.simpleMessage(
            "To enable a Passport Taproot account, ensure you are running firmware 2.3.0 or later and reconnect your Passport."),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
            "Foundation servers are not reachable"),
        "toast_newEnvoyUpdateAvailable":
            MessageLookupByLibrary.simpleMessage("New Envoy update available"),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage("Retry Tor Connection"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage("Temporarily Disable Tor"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
            "You may experience degraded app performance until Envoy can re-establish a connection to Tor.\n\nDisabling Tor will establish a direct connection with the Envoy server, but comes with privacy [[tradeoffs]]."),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
            "Issue establishing Tor connectivity"),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy securely and automatically backs up your wallet seed with [[Android Auto Backup]].\n\nYour seed is always end-to-end encrypted and is never visible to Google."),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy securely and automatically backs up your wallet seed to [[iCloud Keychain.]]\n\nYour seed is always end-to-end encrypted and is never visible to Apple."),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Your wallet data – including tags, notes, accounts and settings – is automatically backed up to Foundation servers.\n\nThis backup is first encrypted with your wallet seed, ensuring that Foundation can never access your data."),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "To recover your wallet, simply log into your Google account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your Google account with a strong password and 2FA."),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "To recover your wallet, simply log into your iCloud account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your iCloud account with a strong password and 2FA."),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage("How Your Data is Secured"),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "If you prefer to opt out of Magic Backups and instead manually secure your wallet seed and data, no problem!\n\nSimply head back to the setup screen and choose Manually Configure Seed Words."),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage("How Your Wallet is Secured"),
        "wallet_security_modal__heading":
            MessageLookupByLibrary.simpleMessage("Security Tip"),
        "wallet_security_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy is storing more than the recommended amount of Bitcoin for a mobile, internet connected wallet.\n\nFor ultra-secure, offline storage, Foundation suggests Passport hardware wallet."),
        "wallet_setup_success_heading":
            MessageLookupByLibrary.simpleMessage("Your Wallet Is Ready"),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy is set up and ready for your Bitcoin!"),
        "welcome_screen_ctA1":
            MessageLookupByLibrary.simpleMessage("Set Up Envoy Wallet"),
        "welcome_screen_cta2":
            MessageLookupByLibrary.simpleMessage("Manage Passport"),
        "welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Welcome to Envoy"),
        "welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Reclaim your sovereignty with Envoy, a simple Bitcoin wallet with powerful account management and privacy features.")
      };
}
