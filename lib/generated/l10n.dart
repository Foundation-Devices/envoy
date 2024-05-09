// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // skipped getter for the ':' key

  /// `Informational text`
  String get _ {
    return Intl.message(
      'Informational text',
      name: '_',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get about_appVersion {
    return Intl.message(
      'App Version',
      name: 'about_appVersion',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licences`
  String get about_openSourceLicences {
    return Intl.message(
      'Open Source Licences',
      name: 'about_openSourceLicences',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get about_privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'about_privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get about_show {
    return Intl.message(
      'Show',
      name: 'about_show',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get about_termsOfUse {
    return Intl.message(
      'Terms of Use',
      name: 'about_termsOfUse',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get account_details_filter_tags_sortBy {
    return Intl.message(
      'Sort by',
      name: 'account_details_filter_tags_sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Untagged`
  String get account_details_untagged_card {
    return Intl.message(
      'Untagged',
      name: 'account_details_untagged_card',
      desc: '',
      args: [],
    );
  }

  /// `Applied filters are hiding all transactions.\nUpdate or reset filters to view transactions.`
  String get account_emptyTxHistoryTextExplainer_FilteredView {
    return Intl.message(
      'Applied filters are hiding all transactions.\nUpdate or reset filters to view transactions.',
      name: 'account_emptyTxHistoryTextExplainer_FilteredView',
      desc: '',
      args: [],
    );
  }

  /// `There are no transactions in this account.\nReceive your first transaction below.`
  String get account_empty_tx_history_text_explainer {
    return Intl.message(
      'There are no transactions in this account.\nReceive your first transaction below.',
      name: 'account_empty_tx_history_text_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Taproot`
  String get account_type_label_taproot {
    return Intl.message(
      'Taproot',
      name: 'account_type_label_taproot',
      desc: '',
      args: [],
    );
  }

  /// `Testnet`
  String get account_type_sublabel_testnet {
    return Intl.message(
      'Testnet',
      name: 'account_type_sublabel_testnet',
      desc: '',
      args: [],
    );
  }

  /// `Create a mobile wallet with Magic Backups.`
  String get accounts_empty_text_explainer {
    return Intl.message(
      'Create a mobile wallet with Magic Backups.',
      name: 'accounts_empty_text_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get accounts_empty_text_learn_more {
    return Intl.message(
      'Get Started',
      name: 'accounts_empty_text_learn_more',
      desc: '',
      args: [],
    );
  }

  /// `Update Envoy`
  String get accounts_forceUpdate_cta {
    return Intl.message(
      'Update Envoy',
      name: 'accounts_forceUpdate_cta',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Update Required`
  String get accounts_forceUpdate_heading {
    return Intl.message(
      'Envoy Update Required',
      name: 'accounts_forceUpdate_heading',
      desc: '',
      args: [],
    );
  }

  /// `A new Envoy update is available that contains important upgrades and fixes. \n\nTo continue using Envoy, please update to the latest version. Thank you.`
  String get accounts_forceUpdate_subheading {
    return Intl.message(
      'A new Envoy update is available that contains important upgrades and fixes. \n\nTo continue using Envoy, please update to the latest version. Thank you.',
      name: 'accounts_forceUpdate_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy`
  String get accounts_screen_walletType_Envoy {
    return Intl.message(
      'Envoy',
      name: 'accounts_screen_walletType_Envoy',
      desc: '',
      args: [],
    );
  }

  /// `Passport`
  String get accounts_screen_walletType_Passport {
    return Intl.message(
      'Passport',
      name: 'accounts_screen_walletType_Passport',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Wallet`
  String get accounts_screen_walletType_defaultName {
    return Intl.message(
      'Mobile Wallet',
      name: 'accounts_screen_walletType_defaultName',
      desc: '',
      args: [],
    );
  }

  /// `Boosted`
  String get activity_boosted {
    return Intl.message(
      'Boosted',
      name: 'activity_boosted',
      desc: '',
      args: [],
    );
  }

  /// `Canceling`
  String get activity_canceling {
    return Intl.message(
      'Canceling',
      name: 'activity_canceling',
      desc: '',
      args: [],
    );
  }

  /// `There is no activity to display.`
  String get activity_emptyState_label {
    return Intl.message(
      'There is no activity to display.',
      name: 'activity_emptyState_label',
      desc: '',
      args: [],
    );
  }

  /// `Envoy App Updated`
  String get activity_envoyUpdate {
    return Intl.message(
      'Envoy App Updated',
      name: 'activity_envoyUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Envoy update available`
  String get activity_envoyUpdateAvailable {
    return Intl.message(
      'Envoy update available',
      name: 'activity_envoyUpdateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Firmware update available`
  String get activity_firmwareUpdate {
    return Intl.message(
      'Firmware update available',
      name: 'activity_firmwareUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Incoming Purchase`
  String get activity_incomingPurchase {
    return Intl.message(
      'Incoming Purchase',
      name: 'activity_incomingPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get activity_listHeader_Today {
    return Intl.message(
      'Today',
      name: 'activity_listHeader_Today',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get activity_pending {
    return Intl.message(
      'Pending',
      name: 'activity_pending',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get activity_received {
    return Intl.message(
      'Received',
      name: 'activity_received',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get activity_sent {
    return Intl.message(
      'Sent',
      name: 'activity_sent',
      desc: '',
      args: [],
    );
  }

  /// `Sent (Boosted)`
  String get activity_sent_boosted {
    return Intl.message(
      'Sent (Boosted)',
      name: 'activity_sent_boosted',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get activity_sent_canceled {
    return Intl.message(
      'Canceled',
      name: 'activity_sent_canceled',
      desc: '',
      args: [],
    );
  }

  /// `Add a Note`
  String get add_note_modal_heading {
    return Intl.message(
      'Add a Note',
      name: 'add_note_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Purchased a Passport hardware wallet`
  String get add_note_modal_ie_text_field {
    return Intl.message(
      'Purchased a Passport hardware wallet',
      name: 'add_note_modal_ie_text_field',
      desc: '',
      args: [],
    );
  }

  /// `Record some details about this transaction.`
  String get add_note_modal_subheading {
    return Intl.message(
      'Record some details about this transaction.',
      name: 'add_note_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Android Backs Up Every 24h`
  String get android_backup_info_heading {
    return Intl.message(
      'Android Backs Up Every 24h',
      name: 'android_backup_info_heading',
      desc: '',
      args: [],
    );
  }

  /// `Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Magic Backup is complete, we recommend performing a manual backup in your device [[Settings]].`
  String get android_backup_info_subheading {
    return Intl.message(
      'Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Magic Backup is complete, we recommend performing a manual backup in your device [[Settings]].',
      name: 'android_backup_info_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is a simple Bitcoin wallet with powerful account management and privacy features.\n\nUse Envoy alongside your Passport hardware wallet for setup, firmware updates, and more.\n\nEnvoy offers the following features:\n\n1. Magic Backups. Get up and running with self-custody in only 60 seconds with automatic encrypted backups. Seed words optional.\n\n2. Manage your mobile wallet and Passport hardware wallet accounts in the same app.\n\n3. Send and receive Bitcoin in a zen-like interface.\n\n4. Connect your Passport hardware wallet for setup, firmware updates, and support videos. Use Envoy as your software wallet connected to your Passport.\n\n5. Fully open source and privacy preserving. Envoy optionally connects to the Internet with Tor for maximum privacy.\n\n6. Optionally connect your own Bitcoin node.`
  String get appstore_description {
    return Intl.message(
      'Envoy is a simple Bitcoin wallet with powerful account management and privacy features.\n\nUse Envoy alongside your Passport hardware wallet for setup, firmware updates, and more.\n\nEnvoy offers the following features:\n\n1. Magic Backups. Get up and running with self-custody in only 60 seconds with automatic encrypted backups. Seed words optional.\n\n2. Manage your mobile wallet and Passport hardware wallet accounts in the same app.\n\n3. Send and receive Bitcoin in a zen-like interface.\n\n4. Connect your Passport hardware wallet for setup, firmware updates, and support videos. Use Envoy as your software wallet connected to your Passport.\n\n5. Fully open source and privacy preserving. Envoy optionally connects to the Internet with Tor for maximum privacy.\n\n6. Optionally connect your own Bitcoin node.',
      name: 'appstore_description',
      desc: '',
      args: [],
    );
  }

  /// `Pending Azteco voucher`
  String get azteco_account_tx_history_pending_voucher {
    return Intl.message(
      'Pending Azteco voucher',
      name: 'azteco_account_tx_history_pending_voucher',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Connect`
  String get azteco_connection_modal_fail_heading {
    return Intl.message(
      'Unable to Connect',
      name: 'azteco_connection_modal_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to connect with Azteco.\n\nPlease contact support@azte.co or try again later.`
  String get azteco_connection_modal_fail_subheading {
    return Intl.message(
      'Envoy is unable to connect with Azteco.\n\nPlease contact support@azte.co or try again later.',
      name: 'azteco_connection_modal_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `VOUCHER CODE`
  String get azteco_redeem_modal__voucher_code {
    return Intl.message(
      'VOUCHER CODE',
      name: 'azteco_redeem_modal__voucher_code',
      desc: '',
      args: [],
    );
  }

  /// `Redeem`
  String get azteco_redeem_modal_cta1 {
    return Intl.message(
      'Redeem',
      name: 'azteco_redeem_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Unable to Redeem`
  String get azteco_redeem_modal_fail_heading {
    return Intl.message(
      'Unable to Redeem',
      name: 'azteco_redeem_modal_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm that your voucher is still valid.\n\nContact support@azte.co with any voucher related questions.`
  String get azteco_redeem_modal_fail_subheading {
    return Intl.message(
      'Please confirm that your voucher is still valid.\n\nContact support@azte.co with any voucher related questions.',
      name: 'azteco_redeem_modal_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Redeem Voucher?`
  String get azteco_redeem_modal_heading {
    return Intl.message(
      'Redeem Voucher?',
      name: 'azteco_redeem_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Voucher Redeemed`
  String get azteco_redeem_modal_success_heading {
    return Intl.message(
      'Voucher Redeemed',
      name: 'azteco_redeem_modal_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `An incoming transaction will appear in your account shortly.`
  String get azteco_redeem_modal_success_subheading {
    return Intl.message(
      'An incoming transaction will appear in your account shortly.',
      name: 'azteco_redeem_modal_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Erase Wallets and Backups`
  String get backups_erase_wallets_and_backups {
    return Intl.message(
      'Erase Wallets and Backups',
      name: 'backups_erase_wallets_and_backups',
      desc: '',
      args: [],
    );
  }

  /// `You’re about to permanently delete your Envoy Wallet. \n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from Android Auto Backup. `
  String get backups_erase_wallets_and_backups_modal_1_2_android_subheading {
    return Intl.message(
      'You’re about to permanently delete your Envoy Wallet. \n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from Android Auto Backup. ',
      name: 'backups_erase_wallets_and_backups_modal_1_2_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `You’re about to permanently delete your Envoy Wallet.\n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from iCloud Keychain. `
  String get backups_erase_wallets_and_backups_modal_1_2_ios_subheading {
    return Intl.message(
      'You’re about to permanently delete your Envoy Wallet.\n\nIf you are using Magic Backups, your Envoy Seed will also be deleted from iCloud Keychain. ',
      name: 'backups_erase_wallets_and_backups_modal_1_2_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Any connected Passport accounts will not be removed as part of this process.\n\nBefore deleting your Envoy Wallet, let’s ensure your Seed and Backup File are saved.\n`
  String get backups_erase_wallets_and_backups_modal_2_2_subheading {
    return Intl.message(
      'Any connected Passport accounts will not be removed as part of this process.\n\nBefore deleting your Envoy Wallet, let’s ensure your Seed and Backup File are saved.\n',
      name: 'backups_erase_wallets_and_backups_modal_2_2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Show Seed`
  String get backups_erase_wallets_and_backups_show_seed_CTA {
    return Intl.message(
      'Show Seed',
      name: 'backups_erase_wallets_and_backups_show_seed_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get bottomNav_accounts {
    return Intl.message(
      'Accounts',
      name: 'bottomNav_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get bottomNav_activity {
    return Intl.message(
      'Activity',
      name: 'bottomNav_activity',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get bottomNav_devices {
    return Intl.message(
      'Devices',
      name: 'bottomNav_devices',
      desc: '',
      args: [],
    );
  }

  /// `Learn`
  String get bottomNav_learn {
    return Intl.message(
      'Learn',
      name: 'bottomNav_learn',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get bottomNav_privacy {
    return Intl.message(
      'Privacy',
      name: 'bottomNav_privacy',
      desc: '',
      args: [],
    );
  }

  /// `This voucher expired on {period}.\n\n\nPlease contact the issuer with any voucher-related questions.`
  String btcpay_connection_modal_expired_subheading(Object period) {
    return Intl.message(
      'This voucher expired on $period.\n\n\nPlease contact the issuer with any voucher-related questions.',
      name: 'btcpay_connection_modal_expired_subheading',
      desc: '',
      args: [period],
    );
  }

  /// `Voucher Expired`
  String get btcpay_connection_modal_fail_heading {
    return Intl.message(
      'Voucher Expired',
      name: 'btcpay_connection_modal_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to connect with the issuer's BTCPay store.\n\nPlease contact the issuer or try again later.`
  String get btcpay_connection_modal_fail_subheading {
    return Intl.message(
      'Envoy is unable to connect with the issuer\'s BTCPay store.\n\nPlease contact the issuer or try again later.',
      name: 'btcpay_connection_modal_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `The scanned voucher was not created with onchain support.\n\nPlease contact the voucher creator.`
  String get btcpay_connection_modal_onchainOnly_subheading {
    return Intl.message(
      'The scanned voucher was not created with onchain support.\n\nPlease contact the voucher creator.',
      name: 'btcpay_connection_modal_onchainOnly_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Description:`
  String get btcpay_redeem_modal_description {
    return Intl.message(
      'Description:',
      name: 'btcpay_redeem_modal_description',
      desc: '',
      args: [],
    );
  }

  /// `Name:`
  String get btcpay_redeem_modal_name {
    return Intl.message(
      'Name:',
      name: 'btcpay_redeem_modal_name',
      desc: '',
      args: [],
    );
  }

  /// `Choose different account`
  String get buy_bitcoin_accountSelection_chooseAccount {
    return Intl.message(
      'Choose different account',
      name: 'buy_bitcoin_accountSelection_chooseAccount',
      desc: '',
      args: [],
    );
  }

  /// `Where should the Bitcoin be sent?`
  String get buy_bitcoin_accountSelection_heading {
    return Intl.message(
      'Where should the Bitcoin be sent?',
      name: 'buy_bitcoin_accountSelection_heading',
      desc: '',
      args: [],
    );
  }

  /// `Leaving Envoy`
  String get buy_bitcoin_accountSelection_modal_heading {
    return Intl.message(
      'Leaving Envoy',
      name: 'buy_bitcoin_accountSelection_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `You are about to leave Envoy for our partner service to purchase Bitcoin. Foundation never learns any purchase information.`
  String get buy_bitcoin_accountSelection_modal_subheading {
    return Intl.message(
      'You are about to leave Envoy for our partner service to purchase Bitcoin. Foundation never learns any purchase information.',
      name: 'buy_bitcoin_accountSelection_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Bitcoin will be sent to this address:`
  String get buy_bitcoin_accountSelection_subheading {
    return Intl.message(
      'Your Bitcoin will be sent to this address:',
      name: 'buy_bitcoin_accountSelection_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Address with Passport`
  String get buy_bitcoin_accountSelection_verify {
    return Intl.message(
      'Verify Address with Passport',
      name: 'buy_bitcoin_accountSelection_verify',
      desc: '',
      args: [],
    );
  }

  /// `Navigate to {AccountName} on Passport, choose ‘Verify Address’, then scan the QR code.`
  String buy_bitcoin_accountSelection_verify_modal_heading(Object AccountName) {
    return Intl.message(
      'Navigate to $AccountName on Passport, choose ‘Verify Address’, then scan the QR code.',
      name: 'buy_bitcoin_accountSelection_verify_modal_heading',
      desc: '',
      args: [AccountName],
    );
  }

  /// `How would you like to buy?`
  String get buy_bitcoin_buyOptions_atms_heading {
    return Intl.message(
      'How would you like to buy?',
      name: 'buy_bitcoin_buyOptions_atms_heading',
      desc: '',
      args: [],
    );
  }

  /// `Opening Hours:`
  String get buy_bitcoin_buyOptions_atms_map_modal_openingHours {
    return Intl.message(
      'Opening Hours:',
      name: 'buy_bitcoin_buyOptions_atms_map_modal_openingHours',
      desc: '',
      args: [],
    );
  }

  /// `Different ATM providers require varying amounts of personal information. This info is never shared with Foundation.`
  String get buy_bitcoin_buyOptions_atms_modal_subheading {
    return Intl.message(
      'Different ATM providers require varying amounts of personal information. This info is never shared with Foundation.',
      name: 'buy_bitcoin_buyOptions_atms_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Find a Bitcoin ATM in your local area to purchase Bitcoin with cash.`
  String get buy_bitcoin_buyOptions_atms_subheading {
    return Intl.message(
      'Find a Bitcoin ATM in your local area to purchase Bitcoin with cash.',
      name: 'buy_bitcoin_buyOptions_atms_subheading',
      desc: '',
      args: [],
    );
  }

  /// `ATMs`
  String get buy_bitcoin_buyOptions_card_atms {
    return Intl.message(
      'ATMs',
      name: 'buy_bitcoin_buyOptions_card_atms',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon in your area.`
  String get buy_bitcoin_buyOptions_card_commingSoon {
    return Intl.message(
      'Coming soon in your area.',
      name: 'buy_bitcoin_buyOptions_card_commingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Buy in Envoy`
  String get buy_bitcoin_buyOptions_card_inEnvoy_heading {
    return Intl.message(
      'Buy in Envoy',
      name: 'buy_bitcoin_buyOptions_card_inEnvoy_heading',
      desc: '',
      args: [],
    );
  }

  /// `Buy Bitcoin in seconds, directly to your Passport accounts or mobile wallet.`
  String get buy_bitcoin_buyOptions_card_inEnvoy_subheading {
    return Intl.message(
      'Buy Bitcoin in seconds, directly to your Passport accounts or mobile wallet.',
      name: 'buy_bitcoin_buyOptions_card_inEnvoy_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Peer to Peer`
  String get buy_bitcoin_buyOptions_card_peerToPeer {
    return Intl.message(
      'Peer to Peer',
      name: 'buy_bitcoin_buyOptions_card_peerToPeer',
      desc: '',
      args: [],
    );
  }

  /// `Vouchers`
  String get buy_bitcoin_buyOptions_card_vouchers {
    return Intl.message(
      'Vouchers',
      name: 'buy_bitcoin_buyOptions_card_vouchers',
      desc: '',
      args: [],
    );
  }

  /// `How would you like to buy?`
  String get buy_bitcoin_buyOptions_inEnvoy_heading {
    return Intl.message(
      'How would you like to buy?',
      name: 'buy_bitcoin_buyOptions_inEnvoy_heading',
      desc: '',
      args: [],
    );
  }

  /// `Info shared with Ramp when you purchase Bitcoin using this method. This info is never shared with Foundation.`
  String get buy_bitcoin_buyOptions_inEnvoy_modal_subheading {
    return Intl.message(
      'Info shared with Ramp when you purchase Bitcoin using this method. This info is never shared with Foundation.',
      name: 'buy_bitcoin_buyOptions_inEnvoy_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Buy with credit card, Apple Pay, Google Pay or bank transfer, directly into your Passport accounts or mobile wallet.`
  String get buy_bitcoin_buyOptions_inEnvoy_subheading {
    return Intl.message(
      'Buy with credit card, Apple Pay, Google Pay or bank transfer, directly into your Passport accounts or mobile wallet.',
      name: 'buy_bitcoin_buyOptions_inEnvoy_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get buy_bitcoin_buyOptions_modal_address {
    return Intl.message(
      'Address',
      name: 'buy_bitcoin_buyOptions_modal_address',
      desc: '',
      args: [],
    );
  }

  /// `Banking Info`
  String get buy_bitcoin_buyOptions_modal_bankingInfo {
    return Intl.message(
      'Banking Info',
      name: 'buy_bitcoin_buyOptions_modal_bankingInfo',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get buy_bitcoin_buyOptions_modal_email {
    return Intl.message(
      'Email',
      name: 'buy_bitcoin_buyOptions_modal_email',
      desc: '',
      args: [],
    );
  }

  /// `Identification`
  String get buy_bitcoin_buyOptions_modal_identification {
    return Intl.message(
      'Identification',
      name: 'buy_bitcoin_buyOptions_modal_identification',
      desc: '',
      args: [],
    );
  }

  /// `Powered by `
  String get buy_bitcoin_buyOptions_modal_poweredBy {
    return Intl.message(
      'Powered by ',
      name: 'buy_bitcoin_buyOptions_modal_poweredBy',
      desc: '',
      args: [],
    );
  }

  /// `Check out these other ways to purchase Bitcoin.`
  String get buy_bitcoin_buyOptions_notSupported_subheading {
    return Intl.message(
      'Check out these other ways to purchase Bitcoin.',
      name: 'buy_bitcoin_buyOptions_notSupported_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Most trades require no info sharing, but your trade partner may learn your banking info. This info is never shared with Foundation.`
  String get buy_bitcoin_buyOptions_peerToPeer_modal_subheading {
    return Intl.message(
      'Most trades require no info sharing, but your trade partner may learn your banking info. This info is never shared with Foundation.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `AgoraDesk`
  String get buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk {
    return Intl.message(
      'AgoraDesk',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk',
      desc: '',
      args: [],
    );
  }

  /// `Non-custodial, peer-to-peer Bitcoin purchases.`
  String get buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading {
    return Intl.message(
      'Non-custodial, peer-to-peer Bitcoin purchases.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Bisq`
  String get buy_bitcoin_buyOptions_peerToPeer_options_bisq {
    return Intl.message(
      'Bisq',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_bisq',
      desc: '',
      args: [],
    );
  }

  /// `Non-custodial, peer-to-peer Bitcoin purchases.`
  String get buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading {
    return Intl.message(
      'Non-custodial, peer-to-peer Bitcoin purchases.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Hodl Hodl`
  String get buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl {
    return Intl.message(
      'Hodl Hodl',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl',
      desc: '',
      args: [],
    );
  }

  /// `Non-custodial, peer-to-peer Bitcoin purchases.`
  String
      get buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading {
    return Intl.message(
      'Non-custodial, peer-to-peer Bitcoin purchases.',
      name:
          'buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Select an option`
  String get buy_bitcoin_buyOptions_peerToPeer_options_heading {
    return Intl.message(
      'Select an option',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_heading',
      desc: '',
      args: [],
    );
  }

  /// `Peach`
  String get buy_bitcoin_buyOptions_peerToPeer_options_peach {
    return Intl.message(
      'Peach',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_peach',
      desc: '',
      args: [],
    );
  }

  /// `Non-custodial, peer-to-peer Bitcoin purchases.`
  String get buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading {
    return Intl.message(
      'Non-custodial, peer-to-peer Bitcoin purchases.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Robosats`
  String get buy_bitcoin_buyOptions_peerToPeer_options_robosats {
    return Intl.message(
      'Robosats',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_robosats',
      desc: '',
      args: [],
    );
  }

  /// `Non-custodial, Lightning native, peer-to-peer Bitcoin purchases.`
  String get buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading {
    return Intl.message(
      'Non-custodial, Lightning native, peer-to-peer Bitcoin purchases.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Buy Bitcoin outside of Envoy, without middlemen. Requires more steps, but can be more private.`
  String get buy_bitcoin_buyOptions_peerToPeer_subheading {
    return Intl.message(
      'Buy Bitcoin outside of Envoy, without middlemen. Requires more steps, but can be more private.',
      name: 'buy_bitcoin_buyOptions_peerToPeer_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Different vendors will require varying amounts of personal information. This info is never shared with Foundation.`
  String get buy_bitcoin_buyOptions_vouchers_modal_subheading {
    return Intl.message(
      'Different vendors will require varying amounts of personal information. This info is never shared with Foundation.',
      name: 'buy_bitcoin_buyOptions_vouchers_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Bitcoin vouchers online or in person. Redeem using the scanner inside any account.`
  String get buy_bitcoin_buyOptions_vouchers_subheading {
    return Intl.message(
      'Purchase Bitcoin vouchers online or in person. Redeem using the scanner inside any account.',
      name: 'buy_bitcoin_buyOptions_vouchers_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Region`
  String get buy_bitcoin_defineLocation_heading {
    return Intl.message(
      'Your Region',
      name: 'buy_bitcoin_defineLocation_heading',
      desc: '',
      args: [],
    );
  }

  /// `Select your region so Envoy can display the purchase options available to you.  This info will never leave Envoy.`
  String get buy_bitcoin_defineLocation_subheading {
    return Intl.message(
      'Select your region so Envoy can display the purchase options available to you.  This info will never leave Envoy.',
      name: 'buy_bitcoin_defineLocation_subheading',
      desc: '',
      args: [],
    );
  }

  /// `EDIT REGION`
  String get buy_bitcoin_details_menu_editRegion {
    return Intl.message(
      'EDIT REGION',
      name: 'buy_bitcoin_details_menu_editRegion',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Buying Process`
  String get buy_bitcoin_exit_modal_heading {
    return Intl.message(
      'Cancel Buying Process',
      name: 'buy_bitcoin_exit_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `You are about to cancel the buying process. Are you sure?`
  String get buy_bitcoin_exit_modal_subheading {
    return Intl.message(
      'You are about to cancel the buying process. Are you sure?',
      name: 'buy_bitcoin_exit_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Complete`
  String get buy_bitcoin_purchaseComplete_heading {
    return Intl.message(
      'Purchase Complete',
      name: 'buy_bitcoin_purchaseComplete_heading',
      desc: '',
      args: [],
    );
  }

  /// `Finalization may take some time depending on\npayment method and network congestion.`
  String get buy_bitcoin_purchaseComplete_subheading {
    return Intl.message(
      'Finalization may take some time depending on\npayment method and network congestion.',
      name: 'buy_bitcoin_purchaseComplete_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Please contact Ramp for support.`
  String get buy_bitcoin_purchaseError_contactRamp {
    return Intl.message(
      'Please contact Ramp for support.',
      name: 'buy_bitcoin_purchaseError_contactRamp',
      desc: '',
      args: [],
    );
  }

  /// `Something Went Wrong`
  String get buy_bitcoin_purchaseError_heading {
    return Intl.message(
      'Something Went Wrong',
      name: 'buy_bitcoin_purchaseError_heading',
      desc: '',
      args: [],
    );
  }

  /// `Coin Locked`
  String get card_coin_locked {
    return Intl.message(
      'Coin Locked',
      name: 'card_coin_locked',
      desc: '',
      args: [],
    );
  }

  /// `Coin Selected`
  String get card_coin_selected {
    return Intl.message(
      'Coin Selected',
      name: 'card_coin_selected',
      desc: '',
      args: [],
    );
  }

  /// `Coin`
  String get card_coin_unselected {
    return Intl.message(
      'Coin',
      name: 'card_coin_unselected',
      desc: '',
      args: [],
    );
  }

  /// `Coins Locked`
  String get card_coins_locked {
    return Intl.message(
      'Coins Locked',
      name: 'card_coins_locked',
      desc: '',
      args: [],
    );
  }

  /// `Coins Selected`
  String get card_coins_selected {
    return Intl.message(
      'Coins Selected',
      name: 'card_coins_selected',
      desc: '',
      args: [],
    );
  }

  /// `Coins`
  String get card_coins_unselected {
    return Intl.message(
      'Coins',
      name: 'card_coins_unselected',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get card_label_of {
    return Intl.message(
      'of',
      name: 'card_label_of',
      desc: '',
      args: [],
    );
  }

  /// `Choose a Tag`
  String get change_output_from_multiple_tags_modal_heading {
    return Intl.message(
      'Choose a Tag',
      name: 'change_output_from_multiple_tags_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `This transaction spends coins from multiple tags. How would you like to tag your change?`
  String get change_output_from_multiple_tags_modal_subehading {
    return Intl.message(
      'This transaction spends coins from multiple tags. How would you like to tag your change?',
      name: 'change_output_from_multiple_tags_modal_subehading',
      desc: '',
      args: [],
    );
  }

  /// `TAG DETAILS`
  String get coinDetails_tagDetails {
    return Intl.message(
      'TAG DETAILS',
      name: 'coinDetails_tagDetails',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone.`
  String get coincontrol_coin_change_spendable_tate_modal_subheading {
    return Intl.message(
      'Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone.',
      name: 'coincontrol_coin_change_spendable_tate_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Available balance`
  String get coincontrol_edit_transaction_available_balance {
    return Intl.message(
      'Available balance',
      name: 'coincontrol_edit_transaction_available_balance',
      desc: '',
      args: [],
    );
  }

  /// `Required Amount`
  String get coincontrol_edit_transaction_requiredAmount {
    return Intl.message(
      'Required Amount',
      name: 'coincontrol_edit_transaction_requiredAmount',
      desc: '',
      args: [],
    );
  }

  /// `Selected Amount`
  String get coincontrol_edit_transaction_selectedAmount {
    return Intl.message(
      'Selected Amount',
      name: 'coincontrol_edit_transaction_selectedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Lock`
  String get coincontrol_lock_coin_modal_cta1 {
    return Intl.message(
      'Lock',
      name: 'coincontrol_lock_coin_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Locking coins will prevent them from being used in transactions`
  String get coincontrol_lock_coin_modal_subheading {
    return Intl.message(
      'Locking coins will prevent them from being used in transactions',
      name: 'coincontrol_lock_coin_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Review Transaction`
  String get coincontrol_txDetail_ReviewTransaction {
    return Intl.message(
      'Review Transaction',
      name: 'coincontrol_txDetail_ReviewTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Sign with Passport`
  String get coincontrol_txDetail_cta1_passport {
    return Intl.message(
      'Sign with Passport',
      name: 'coincontrol_txDetail_cta1_passport',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction is ready \nto be signed`
  String get coincontrol_txDetail_heading_passport {
    return Intl.message(
      'Your transaction is ready \nto be signed',
      name: 'coincontrol_txDetail_heading_passport',
      desc: '',
      args: [],
    );
  }

  /// `Confirm the transaction details are correct before signing with Passport.`
  String get coincontrol_txDetail_subheading_passport {
    return Intl.message(
      'Confirm the transaction details are correct before signing with Passport.',
      name: 'coincontrol_txDetail_subheading_passport',
      desc: '',
      args: [],
    );
  }

  /// `Save some details about your transaction.`
  String get coincontrol_tx_add_note_subheading {
    return Intl.message(
      'Save some details about your transaction.',
      name: 'coincontrol_tx_add_note_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Show details`
  String get coincontrol_tx_detail_amount_details {
    return Intl.message(
      'Show details',
      name: 'coincontrol_tx_detail_amount_details',
      desc: '',
      args: [],
    );
  }

  /// `Amount to send`
  String get coincontrol_tx_detail_amount_to_sent {
    return Intl.message(
      'Amount to send',
      name: 'coincontrol_tx_detail_amount_to_sent',
      desc: '',
      args: [],
    );
  }

  /// `Change received`
  String get coincontrol_tx_detail_change {
    return Intl.message(
      'Change received',
      name: 'coincontrol_tx_detail_change',
      desc: '',
      args: [],
    );
  }

  /// `Send Transaction`
  String get coincontrol_tx_detail_cta1 {
    return Intl.message(
      'Send Transaction',
      name: 'coincontrol_tx_detail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Edit Transaction`
  String get coincontrol_tx_detail_cta2 {
    return Intl.message(
      'Edit Transaction',
      name: 'coincontrol_tx_detail_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Fee`
  String get coincontrol_tx_detail_custom_fee_cta {
    return Intl.message(
      'Confirm Fee',
      name: 'coincontrol_tx_detail_custom_fee_cta',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'coincontrol_tx_detail_custom_fee_insufficients_funds_-_25_prompt' key

  /// `Over 25%`
  String get coincontrol_tx_detail_custom_fee_insufficients_funds_25_cta {
    return Intl.message(
      'Over 25%',
      name: 'coincontrol_tx_detail_custom_fee_insufficients_funds_25_cta',
      desc: '',
      args: [],
    );
  }

  /// `Over 25%`
  String get coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt {
    return Intl.message(
      'Over 25%',
      name: 'coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get coincontrol_tx_detail_destination {
    return Intl.message(
      'Destination',
      name: 'coincontrol_tx_detail_destination',
      desc: '',
      args: [],
    );
  }

  /// `Show address`
  String get coincontrol_tx_detail_destination_details {
    return Intl.message(
      'Show address',
      name: 'coincontrol_tx_detail_destination_details',
      desc: '',
      args: [],
    );
  }

  /// `Change received`
  String get coincontrol_tx_detail_expand_changeReceived {
    return Intl.message(
      'Change received',
      name: 'coincontrol_tx_detail_expand_changeReceived',
      desc: '',
      args: [],
    );
  }

  /// `coin`
  String get coincontrol_tx_detail_expand_coin {
    return Intl.message(
      'coin',
      name: 'coincontrol_tx_detail_expand_coin',
      desc: '',
      args: [],
    );
  }

  /// `coins`
  String get coincontrol_tx_detail_expand_coins {
    return Intl.message(
      'coins',
      name: 'coincontrol_tx_detail_expand_coins',
      desc: '',
      args: [],
    );
  }

  /// `TRANSACTION DETAILS`
  String get coincontrol_tx_detail_expand_heading {
    return Intl.message(
      'TRANSACTION DETAILS',
      name: 'coincontrol_tx_detail_expand_heading',
      desc: '',
      args: [],
    );
  }

  /// `Spent from`
  String get coincontrol_tx_detail_expand_spentFrom {
    return Intl.message(
      'Spent from',
      name: 'coincontrol_tx_detail_expand_spentFrom',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get coincontrol_tx_detail_fee {
    return Intl.message(
      'Fee',
      name: 'coincontrol_tx_detail_fee',
      desc: '',
      args: [],
    );
  }

  /// ` Updating your fee may have changed\nyour coin selection. Please review.`
  String get coincontrol_tx_detail_feeChange_information {
    return Intl.message(
      ' Updating your fee may have changed\nyour coin selection. Please review.',
      name: 'coincontrol_tx_detail_feeChange_information',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get coincontrol_tx_detail_fee_custom {
    return Intl.message(
      'Custom',
      name: 'coincontrol_tx_detail_fee_custom',
      desc: '',
      args: [],
    );
  }

  /// `Faster`
  String get coincontrol_tx_detail_fee_faster {
    return Intl.message(
      'Faster',
      name: 'coincontrol_tx_detail_fee_faster',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get coincontrol_tx_detail_fee_standard {
    return Intl.message(
      'Standard',
      name: 'coincontrol_tx_detail_fee_standard',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction is ready \nto be sent`
  String get coincontrol_tx_detail_heading {
    return Intl.message(
      'Your transaction is ready \nto be sent',
      name: 'coincontrol_tx_detail_heading',
      desc: '',
      args: [],
    );
  }

  /// `[[Learn more]]`
  String get coincontrol_tx_detail_high_fee_info_overlay_learnMore {
    return Intl.message(
      '[[Learn more]]',
      name: 'coincontrol_tx_detail_high_fee_info_overlay_learnMore',
      desc: '',
      args: [],
    );
  }

  /// `Some smaller coins have been excluded from this transaction. At the chosen fee rate, they cost more to include than they are worth.`
  String get coincontrol_tx_detail_high_fee_info_overlay_subheading {
    return Intl.message(
      'Some smaller coins have been excluded from this transaction. At the chosen fee rate, they cost more to include than they are worth.',
      name: 'coincontrol_tx_detail_high_fee_info_overlay_subheading',
      desc: '',
      args: [],
    );
  }

  /// `No change`
  String get coincontrol_tx_detail_no_change {
    return Intl.message(
      'No change',
      name: 'coincontrol_tx_detail_no_change',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Transaction`
  String get coincontrol_tx_detail_passport_cta2 {
    return Intl.message(
      'Cancel Transaction',
      name: 'coincontrol_tx_detail_passport_cta2',
      desc: '',
      args: [],
    );
  }

  /// `By canceling you will lose all transaction progress.`
  String get coincontrol_tx_detail_passport_subheading {
    return Intl.message(
      'By canceling you will lose all transaction progress.',
      name: 'coincontrol_tx_detail_passport_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Confirm the transaction details are correct before sending.`
  String get coincontrol_tx_detail_subheading {
    return Intl.message(
      'Confirm the transaction details are correct before sending.',
      name: 'coincontrol_tx_detail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get coincontrol_tx_detail_total {
    return Intl.message(
      'Total',
      name: 'coincontrol_tx_detail_total',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get coincontrol_tx_history_tx_detail_note {
    return Intl.message(
      'Note',
      name: 'coincontrol_tx_history_tx_detail_note',
      desc: '',
      args: [],
    );
  }

  /// `Unlock`
  String get coincontrol_unlock_coin_modal_cta1 {
    return Intl.message(
      'Unlock',
      name: 'coincontrol_unlock_coin_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Unlocking coins will make them available for use in transactions.`
  String get coincontrol_unlock_coin_modal_subheading {
    return Intl.message(
      'Unlocking coins will make them available for use in transactions.',
      name: 'coincontrol_unlock_coin_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get coindetails_overlay_address {
    return Intl.message(
      'Address',
      name: 'coindetails_overlay_address',
      desc: '',
      args: [],
    );
  }

  /// `at`
  String get coindetails_overlay_at {
    return Intl.message(
      'at',
      name: 'coindetails_overlay_at',
      desc: '',
      args: [],
    );
  }

  /// `Boosted Fee`
  String get coindetails_overlay_boostedFees {
    return Intl.message(
      'Boosted Fee',
      name: 'coindetails_overlay_boostedFees',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation in`
  String get coindetails_overlay_confirmation {
    return Intl.message(
      'Confirmation in',
      name: 'coindetails_overlay_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Confirms in`
  String get coindetails_overlay_confirmationIn {
    return Intl.message(
      'Confirms in',
      name: 'coindetails_overlay_confirmationIn',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get coindetails_overlay_confirmationIn_day {
    return Intl.message(
      'day',
      name: 'coindetails_overlay_confirmationIn_day',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get coindetails_overlay_confirmationIn_days {
    return Intl.message(
      'days',
      name: 'coindetails_overlay_confirmationIn_days',
      desc: '',
      args: [],
    );
  }

  /// `month`
  String get coindetails_overlay_confirmationIn_month {
    return Intl.message(
      'month',
      name: 'coindetails_overlay_confirmationIn_month',
      desc: '',
      args: [],
    );
  }

  /// `week`
  String get coindetails_overlay_confirmationIn_week {
    return Intl.message(
      'week',
      name: 'coindetails_overlay_confirmationIn_week',
      desc: '',
      args: [],
    );
  }

  /// `weeks`
  String get coindetails_overlay_confirmationIn_weeks {
    return Intl.message(
      'weeks',
      name: 'coindetails_overlay_confirmationIn_weeks',
      desc: '',
      args: [],
    );
  }

  /// `Boost`
  String get coindetails_overlay_confirmation_boost {
    return Intl.message(
      'Boost',
      name: 'coindetails_overlay_confirmation_boost',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get coindetails_overlay_date {
    return Intl.message(
      'Date',
      name: 'coindetails_overlay_date',
      desc: '',
      args: [],
    );
  }

  /// `COIN DETAILS`
  String get coindetails_overlay_heading {
    return Intl.message(
      'COIN DETAILS',
      name: 'coindetails_overlay_heading',
      desc: '',
      args: [],
    );
  }

  /// `Cannot Boost Transaction`
  String get coindetails_overlay_noBoostNoFunds_heading {
    return Intl.message(
      'Cannot Boost Transaction',
      name: 'coindetails_overlay_noBoostNoFunds_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is because there are not enough confirmed or unlocked coins to choose from. \n\nAllow pending coins to confirm or unlock some coins and try again.`
  String get coindetails_overlay_noBoostNoFunds_subheading {
    return Intl.message(
      'This is because there are not enough confirmed or unlocked coins to choose from. \n\nAllow pending coins to confirm or unlock some coins and try again.',
      name: 'coindetails_overlay_noBoostNoFunds_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get coindetails_overlay_notes {
    return Intl.message(
      'Note',
      name: 'coindetails_overlay_notes',
      desc: '',
      args: [],
    );
  }

  /// `Payment ID`
  String get coindetails_overlay_paymentID {
    return Intl.message(
      'Payment ID',
      name: 'coindetails_overlay_paymentID',
      desc: '',
      args: [],
    );
  }

  /// `Ramp ID`
  String get coindetails_overlay_rampID {
    return Intl.message(
      'Ramp ID',
      name: 'coindetails_overlay_rampID',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get coindetails_overlay_status {
    return Intl.message(
      'Status',
      name: 'coindetails_overlay_status',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get coindetails_overlay_status_confirmed {
    return Intl.message(
      'Confirmed',
      name: 'coindetails_overlay_status_confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get coindetails_overlay_status_pending {
    return Intl.message(
      'Pending',
      name: 'coindetails_overlay_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get coindetails_overlay_tag {
    return Intl.message(
      'Tag',
      name: 'coindetails_overlay_tag',
      desc: '',
      args: [],
    );
  }

  /// `Transaction ID`
  String get coindetails_overlay_transactionID {
    return Intl.message(
      'Transaction ID',
      name: 'coindetails_overlay_transactionID',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get component_Apply {
    return Intl.message(
      'Apply',
      name: 'component_Apply',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get component_back {
    return Intl.message(
      'Back',
      name: 'component_back',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get component_cancel {
    return Intl.message(
      'Cancel',
      name: 'component_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get component_content {
    return Intl.message(
      'Content',
      name: 'component_content',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get component_continue {
    return Intl.message(
      'Continue',
      name: 'component_continue',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get component_delete {
    return Intl.message(
      'Delete',
      name: 'component_delete',
      desc: '',
      args: [],
    );
  }

  /// `Device`
  String get component_device {
    return Intl.message(
      'Device',
      name: 'component_device',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get component_dismiss {
    return Intl.message(
      'Dismiss',
      name: 'component_dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get component_done {
    return Intl.message(
      'Done',
      name: 'component_done',
      desc: '',
      args: [],
    );
  }

  /// `Don’t show again`
  String get component_dontShowAgain {
    return Intl.message(
      'Don’t show again',
      name: 'component_dontShowAgain',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get component_filter {
    return Intl.message(
      'Filter',
      name: 'component_filter',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get component_filter_button_all {
    return Intl.message(
      'All',
      name: 'component_filter_button_all',
      desc: '',
      args: [],
    );
  }

  /// `Go To Settings`
  String get component_goToSettings {
    return Intl.message(
      'Go To Settings',
      name: 'component_goToSettings',
      desc: '',
      args: [],
    );
  }

  /// `Learn more`
  String get component_learnMore {
    return Intl.message(
      'Learn more',
      name: 'component_learnMore',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get component_minishield_buy {
    return Intl.message(
      'Buy',
      name: 'component_minishield_buy',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get component_next {
    return Intl.message(
      'Next',
      name: 'component_next',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get component_no {
    return Intl.message(
      'No',
      name: 'component_no',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get component_ok {
    return Intl.message(
      'OK',
      name: 'component_ok',
      desc: '',
      args: [],
    );
  }

  /// `Redeem`
  String get component_redeem {
    return Intl.message(
      'Redeem',
      name: 'component_redeem',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get component_reset {
    return Intl.message(
      'Reset',
      name: 'component_reset',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get component_retry {
    return Intl.message(
      'Retry',
      name: 'component_retry',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get component_save {
    return Intl.message(
      'Save',
      name: 'component_save',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get component_skip {
    return Intl.message(
      'Skip',
      name: 'component_skip',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get component_sortBy {
    return Intl.message(
      'Sort by',
      name: 'component_sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get component_tryAgain {
    return Intl.message(
      'Try Again',
      name: 'component_tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get component_update {
    return Intl.message(
      'Update',
      name: 'component_update',
      desc: '',
      args: [],
    );
  }

  /// `WARNING`
  String get component_warning {
    return Intl.message(
      'WARNING',
      name: 'component_warning',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get component_yes {
    return Intl.message(
      'Yes',
      name: 'component_yes',
      desc: '',
      args: [],
    );
  }

  /// `Your address will be copied to the clipboard and may be visible to other apps on your phone.`
  String get copyToClipboard_address {
    return Intl.message(
      'Your address will be copied to the clipboard and may be visible to other apps on your phone.',
      name: 'copyToClipboard_address',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone.`
  String get copyToClipboard_txid {
    return Intl.message(
      'Your transaction ID will be copied to the clipboard and may be visible to other apps on your phone.',
      name: 'copyToClipboard_txid',
      desc: '',
      args: [],
    );
  }

  /// `Tags are a useful way to organize your coins.`
  String get create_first_tag_modal_1_2_subheading {
    return Intl.message(
      'Tags are a useful way to organize your coins.',
      name: 'create_first_tag_modal_1_2_subheading',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'create_first_tag_modal_2_2_ie_text-field' key

  /// `Suggestions`
  String get create_first_tag_modal_2_2_suggest {
    return Intl.message(
      'Suggestions',
      name: 'create_first_tag_modal_2_2_suggest',
      desc: '',
      args: [],
    );
  }

  /// `Most used`
  String get create_second_tag_modal_2_2_mostUsed {
    return Intl.message(
      'Most used',
      name: 'create_second_tag_modal_2_2_mostUsed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this tag?`
  String get delete_emptyTag_modal_subheading {
    return Intl.message(
      'Are you sure you want to delete this tag?',
      name: 'delete_emptyTag_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Delete Tag`
  String get delete_tag_modal_cta2 {
    return Intl.message(
      'Delete Tag',
      name: 'delete_tag_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Deleting this tag will automatically mark these coins as untagged.`
  String get delete_tag_modal_subheading {
    return Intl.message(
      'Deleting this tag will automatically mark these coins as untagged.',
      name: 'delete_tag_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Go to Settings`
  String get delete_wallet_for_good_instant_android_cta1 {
    return Intl.message(
      'Go to Settings',
      name: 'delete_wallet_for_good_instant_android_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Android automatically backs up your Envoy data every 24 hours.\n\nTo immediately remove your Envoy Seed from Android Auto Backups, you can perform a manual backup in your device [[Settings.]]`
  String get delete_wallet_for_good_instant_android_subheading {
    return Intl.message(
      'Android automatically backs up your Envoy data every 24 hours.\n\nTo immediately remove your Envoy Seed from Android Auto Backups, you can perform a manual backup in your device [[Settings.]]',
      name: 'delete_wallet_for_good_instant_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Deleting your Envoy Wallet`
  String get delete_wallet_for_good_loading_heading {
    return Intl.message(
      'Deleting your Envoy Wallet',
      name: 'delete_wallet_for_good_loading_heading',
      desc: '',
      args: [],
    );
  }

  /// `Delete Wallet`
  String get delete_wallet_for_good_modal_cta2 {
    return Intl.message(
      'Delete Wallet',
      name: 'delete_wallet_for_good_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to DELETE your Envoy Wallet?`
  String get delete_wallet_for_good_modal_subheading {
    return Intl.message(
      'Are you sure you want to DELETE your Envoy Wallet?',
      name: 'delete_wallet_for_good_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet was successfully deleted`
  String get delete_wallet_for_good_success_heading {
    return Intl.message(
      'Your wallet was successfully deleted',
      name: 'delete_wallet_for_good_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Buy Passport`
  String get devices_empty_modal_video_cta1 {
    return Intl.message(
      'Buy Passport',
      name: 'devices_empty_modal_video_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Watch Later`
  String get devices_empty_modal_video_cta2 {
    return Intl.message(
      'Watch Later',
      name: 'devices_empty_modal_video_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Secure your Bitcoin with Passport.`
  String get devices_empty_text_explainer {
    return Intl.message(
      'Secure your Bitcoin with Passport.',
      name: 'devices_empty_text_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Your {tagName} tag is now empty. Would you like to delete it?`
  String empty_tag_modal_subheading(Object tagName) {
    return Intl.message(
      'Your $tagName tag is now empty. Would you like to delete it?',
      name: 'empty_tag_modal_subheading',
      desc: '',
      args: [tagName],
    );
  }

  /// `I Accept`
  String get envoy_account_tos_cta {
    return Intl.message(
      'I Accept',
      name: 'envoy_account_tos_cta',
      desc: '',
      args: [],
    );
  }

  /// `Please review and accept the Passport Terms of Use`
  String get envoy_account_tos_heading {
    return Intl.message(
      'Please review and accept the Passport Terms of Use',
      name: 'envoy_account_tos_heading',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: May 16, 2021.\r\n\r\nBy purchasing, using or continuing to use a Passport hardware wallet (“Passport“), you, the purchaser of Passport, agree to be bound by these terms of and use (the “Passport Terms of Use” or “Terms”).\r\n\r\n1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\r\n\r\n2. Security\n\r\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\r\n\r\n3. BACKUPS\r\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss.\r\n\r\n4. MODIFICATIONS\r\nYou acknowledge and agree that any modifications to Passport, the installation of any additional software or firmware on a Passport or the use of Passport in connection with any other software or equipment are at your sole risk, and that we have no obligation or liability in respect thereof or in respect of any resulting loss of Bitcoin, damage to Passport, failure of the Passport or errors in storing Bitcoin or processing Transactions;\r\n\r\n5. OPEN SOURCE LICENSES\r\nPassport includes software licensed under the GNU General Public License v3 and other open source licenses, as identified in documentation provided with Passport. Your use of such software is subject to the applicable open source licenses and, to the extent such open source licenses conflicts with this Agreement, the terms of such licenses will prevail.\r\n\r\n6. ACKNOWLEDGEMENT AND ASSUMPTION OF RISK\r\nYou understand and agree that:\r\n\r\n(a) there are risks associated with the use and holding of Bitcoin and you represent and warrant that you are knowledgeable and/or experienced in matters relating to the use of Bitcoin and are capable of evaluating the benefits and risks of using and holding Bitcoin and fully understand the nature of Bitcoin, the limitations and restrictions on its liquidity and transferability and are capable of bearing the economic risk of holding and transacting using Bitcoin;\r\n\r\n(b) the continued ability to use Bitcoin is dependent on many elements beyond our control, including without limitation the publication of blocks, network connectivity, hacking or changes in the technical and other standards, policies and procedures applicable to Bitcoin;\r\n\r\n(c) no regulatory authority has reviewed or passed on the merits, legality or fungibility of Bitcoin;\r\n\r\n(d) there is no government or other insurance covering Bitcoin, the loss or theft of Bitcoin, or any loss in the value of Bitcoin;\r\n\r\n(e) the use of Bitcoin or the Products may become subject to regulatory controls that limit, restrict, prohibit or otherwise impose conditions on your use of same;\r\n\r\n(f) Bitcoin do not constitute a currency, asset, security, negotiable instrument, or other form of property and do not have any intrinsic or inherent value;\r\n\r\n(g) the value of and/or exchange rates for Bitcoin may fluctuate significantly and may result in you incurring significant losses;\r\n\r\n(h) Transactions may have tax consequences (including obligations to report, collect or remit taxes) and you are solely responsible for understanding and complying with all applicable tax laws and regulations; and\r\n\r\n(i) the use of Bitcoin or Products may be illegal or subject to regulation in certain jurisdictions, and it is your responsibility to ensure that you comply with the laws of any jurisdiction in which you use Bitcoin or Products.\r\n\r\n7. TRANSFER OF PASSPORT\r\nYou may transfer or sell Passport to others on the condition that you ensure that the transferee or purchaser agrees to be bound by the then-current form of these Terms available on our website at the time of transfer.\r\n\r\n8. RESTRICTIONS\r\nYou shall not:\r\n\r\n(a) use Passport in a manner or for a purpose that: (i) is illegal or otherwise contravenes applicable law (including the facilitation or furtherance of any criminal or fraudulent activity or the violation of any anti-money laundering legislation); or (ii) infringes upon the lawful rights of others;\r\n\r\n(b) interfere with the security or integrity of Passport;\r\n\r\n(c) remove, destroy, cover, obfuscate or alter in any manner any notices, legends, trademarks, branding or logos appearing on or contained in Passport; or\r\n\r\n(d) attempt, or cause, permit or encourage any other person, to do any of the foregoing.\r\n\r\nNotwithstanding the foregoing, you may investigate security and other vulnerabilities, provided you do so in a reasonable and responsible manner in compliance with applicable law and our responsible disclosure policy and otherwise use good faith efforts to minimize or avoid contravention of any of the foregoing.\r\n\r\n9. REPRESENTATIONS AND WARRANTIES\r\nYou represent, warrant and covenant that:\r\n\r\n(a) you have the capacity to, and are and will be free to, enter into and to fully perform your obligations under these Terms and that no agreement or understanding with any other person exists or will exist which would interfere with such obligations; and\r\n\r\n(b) these Terms constitute a legal, valid and binding obligation upon you.\r\n\r\n10. OWNERSHIP\r\nExcept for the limited rights of use expressly granted to you under these Terms, all right, title and interest (including all copyrights, trademarks, service marks, patents, inventions, trade secrets, intellectual property rights and other proprietary rights) in and to Passport are and shall remain exclusively owned by us and our licensors. All trade names, company names, trademarks, service marks and other names and logos are the proprietary marks of us or our licensors, and are protected by law and may not be copied, imitated or used, in whole or in part, without the consent of their respective owners. These Terms do not grant you any rights in respect of any such marks. You understand and agree that any feedback, input, suggestions, recommendations, improvements, changes, specifications, test results, or other data or information that you provide or make available to us arising from or related to your use of the Products or Software shall become our exclusive property and may be used by us to modify, enhance, maintain and improve Passport without any obligation or payment to you whatsoever.\r\n\r\n11. THIRD PARTY PRODUCTS\r\nYou acknowledge and agree that you will require certain third party equipment, products, software and services in order to use the Products and may also use optional third party equipment, products, software and services that enhance or complement such use (collectively, “Third Party Products”). You acknowledge and agree that failure to use or procure Third Party Products that meet the minimum requirements for Products, or failure to properly configure or setup Third Party Products may result in the inability to use the Products and/or processing failures or errors. Third Party Products include, without limitation, computers, mobile devices, networking equipment, operating system software, web browsers and internet connectivity. We may also identify, recommend, reference or link to optional Third Party Products on our website. You acknowledge and agree that: (a) Third Party Products are be governed by separate licenses, agreements or terms and conditions and we have no obligation or liability to you in respect thereof; and (b) you are solely responsible for procuring any Third Party Products at your cost and expense, and are solely responsible for compliance with any applicable licenses, agreements or terms and conditions governing same. \r\n\r\n12. INDEMNITY\r\nYou agree to indemnify and hold Foundation Devices (and our officers, employees, and agents) harmless, including costs and attorneys’ fees, from any claim or demand due to or arising out of (a) your use of Passport, (b) your violation of this Agreement or (c) your violation of applicable laws or regulations. We reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us and you agree to cooperate with our defense of these claims. You agree not to settle any matter without our prior written consent. We will use reasonable efforts to notify you of any such claim, action or proceeding upon becoming aware of it.\r\n\r\n13. DISCLAIMERS\r\nPASSPORT IS PROVIDED “AS-IS” AND “AS AVAILABLE” AND WE (AND OUR SUPPLIERS) EXPRESSLY DISCLAIM ANY WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, QUIET ENJOYMENT, ACCURACY, OR NON-INFRINGEMENT. WE (AND OUR SUPPLIERS) MAKE NO WARRANTY THAT PASSPORT: (A) WILL MEET YOUR REQUIREMENTS; (B) WILL BE AVAILABLE ON AN UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE BASIS; OR (C) WILL BE ACCURATE, RELIABLE, FREE OF VIRUSES OR OTHER HARMFUL CODE, COMPLETE, LEGAL, OR SAFE.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n14. LIMITATION ON LIABILITY\r\nYOU AGREE THAT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, OUR AGGREGATE LIABILITY ARISING FROM OR RELATED TO THESE TERMS OR PASSPORT IN ANY MANNER WILL BE LIMITED TO DIRECT DAMAGES NOT TO EXCEED THE PURCHASE PRICE YOU HAVE PAID TO US FOR PASSPORT (EXCLUDING SHIPPING CHARGES AND TAXES). TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL WE (AND OUR SUPPLIERS) BE LIABLE FOR ANY CONSEQUENTIAL, INCIDENTAL, INDIRECT, SPECIAL, PUNITIVE, OR OTHER DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF REVENUE, PROFITS, OR EXPECTED SAVINGS, BUSINESS INTERRUPTION, PERSONAL INJURY, LOSS OF PRIVACY, LOSS OF DATA OR INFORMATION OR OTHER PECUNIARY OR INTANGIBLE LOSS) ARISING OUT OF THESE TERMS OR THE USE OF OR INABILITY TO USE PASSPORT, EVEN IF WE FORESEE OR HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OF CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n15. RELEASE\r\nYou hereby release and forever discharge us (and our officers, employees, agents, successors, and assigns) from, and hereby waive and relinquish, each and every past, present and future dispute, claim, controversy, demand, right, obligation, liability, action and cause of action of every kind and nature (including personal injuries, death, and property damage), that has arisen or arises directly or indirectly out of, or relates directly or indirectly to, use of Passport. IF YOU ARE A CALIFORNIA RESIDENT, YOU HEREBY WAIVE CALIFORNIA CIVIL CODE SECTION 1542 IN CONNECTION WITH THE FOREGOING, WHICH STATES: “A GENERAL RELEASE DOES NOT EXTEND TO CLAIMS WHICH THE CREDITOR DOES NOT KNOW OR SUSPECT TO EXIST IN HIS OR HER FAVOR AT THE TIME OF EXECUTING THE RELEASE, WHICH IF KNOWN BY HIM OR HER MUST HAVE MATERIALLY AFFECTED HIS OR HER SETTLEMENT WITH THE DEBTOR.”\r\n\r\n16. SURVIVAL\r\nNeither the expiration nor the earlier termination of your account will release you from any obligation or liability that accrued prior to such expiration or termination. The provisions of these Terms requiring performance or fulfilment after the expiration or earlier termination of your account and any other provisions hereof, the nature and intent of which is to survive termination or expiration, will survive.\r\n\r\n17. PRIVACY POLICY\r\nPlease review our Privacy Policy, located at https://foundationdevices.com/privacy, which governs the use of personal information.\r\n\r\n18. DISPUTE RESOLUTION\r\nPlease read the following arbitration agreement in this section (“Arbitration Agreement”) carefully. It requires U.S. users to arbitrate disputes with Foundation Devices and limits the manner in which you can seek relief from us.\r\n\r\n(a) Applicability of Arbitration Agreement. You agree that any dispute, claim, or request for relief relating in any way to your use of Passport will be resolved by binding arbitration, rather than in court, except that (a) you may assert claims or seek relief in small claims court if your claims qualify; and (b) you or we may seek equitable relief in court for infringement or other misuse of intellectual property rights (such as trademarks, trade dress, domain names, trade secrets, copyrights, and patents). This Arbitration Agreement shall apply, without limitation, to all disputes or claims and requests for relief that arose or were asserted before the effective date of this Agreement or any prior version of this Agreement.\r\n\r\n(b) Arbitration Rules and Forum. The Federal Arbitration Act governs the interpretation and enforcement of this Arbitration Agreement. To begin an arbitration proceeding, you must send a letter requesting arbitration and describing your dispute or claim or request for relief to our registered agent. The arbitration will be conducted by JAMS, an established alternative dispute resolution provider. Disputes involving claims, counterclaims, or request for relief under $250,000, not inclusive of attorneys’ fees and interest, shall be subject to JAMS’s most current version of the Streamlined Arbitration Rules and procedures available at https://jamsadr.com/rules-streamlined-arbitration/; all other disputes shall be subject to JAMS’s most current version of the Comprehensive Arbitration Rules and Procedures, available at https://jamsadr.com/rules-comprehensive-arbitration/. JAMS’s rules are also available at https://jamsadr.com or by calling JAMS at 800-352-5267. If JAMS is not available to arbitrate, the parties will select an alternative arbitral forum. If the arbitrator finds that you cannot afford to pay JAMS’s filing, administrative, hearing and/or other fees and cannot obtain a waiver from JAMS, Company will pay them for you. In addition, Company will reimburse all such JAMS’s filing, administrative, hearing and/or other fees for disputes, claims, or requests for relief totaling less than $10,000 unless the arbitrator determines the claims are frivolous.\r\n\r\nYou may choose to have the arbitration conducted by telephone, based on written submissions, or in person in the country where you live or at another mutually agreed location. Any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction.\r\n\r\n(c) Authority of Arbitrator. The arbitrator shall have exclusive authority to (a) determine the scope and enforceability of this Arbitration Agreement and (b) resolve any dispute related to the interpretation, applicability, enforceability or formation of this Arbitration Agreement including, but not limited to, any assertion that all or any part of this Arbitration Agreement is void or voidable. The arbitration will decide the rights and liabilities, if any, of you and Company. The arbitration proceeding will not be consolidated with any other matters or joined with any other cases or parties. The arbitrator shall have the authority to grant motions dispositive of all or part of any claim. The arbitrator shall have the authority to award monetary damages and to grant any non-monetary remedy or relief available to an individual under applicable law, the arbitral forum’s rules, and the Agreement (including the Arbitration Agreement). The arbitrator shall issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator has the same authority to award relief on an individual basis that a judge in a court of law would have. The award of the arbitrator is final and binding upon you and us.\r\n\r\n(d) Waiver of Jury Trial. YOU AND COMPANY HEREBY WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO SUE IN COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY. You and Company are instead electing that all disputes, claims, or requests for relief shall be resolved by arbitration under this Arbitration Agreement, except as specified in Section 10(a) (Application of Arbitration Agreement) above. An arbitrator can award on an individual basis the same damages and relief as a court and must follow this Agreement as a court would. However, there is no judge or jury in arbitration, and court review of an arbitration award is subject to very limited review.\r\n\r\n(e) Waiver of Class or Other Non-Individualized Relief. ALL DISPUTES, CLAIMS, AND REQUESTS FOR RELIEF WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS OR COLLECTIVE BASIS, ONLY INDIVIDUAL RELIEF IS AVAILABLE, AND CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If a decision is issued stating that applicable law precludes enforcement of any of this section’s limitations as to a given dispute, claim, or request for relief, then such aspect must be severed from the arbitration and brought into the State or Federal Courts located in the Commonwealth of Massachusetts. All other disputes, claims, or requests for relief shall be arbitrated.\r\n\r\n(f) 30-Day Right to Opt Out. You have the right to opt out of the provisions of this Arbitration Agreement by sending written notice of your decision to opt out to: hello@foundationdevices.com, within thirty (30) days after first becoming subject to this Arbitration Agreement. Your notice must include your name and address, your Company username (if any), the email address you used to set up your Company account (if you have one), and an unequivocal statement that you want to opt out of this Arbitration Agreement. If you opt out of this Arbitration Agreement, all other parts of this Agreement will continue to apply to you. Opting out of this Arbitration Agreement has no effect on any other arbitration agreements that you may currently have, or may enter in the future, with us.\r\n\r\n(g) Severability. Except as provided in Section 10(e)(Waiver of Class or Other Non-Individualized Relief), if any part or parts of this Arbitration Agreement are found under the law to be invalid or unenforceable, then such specific part or parts shall be of no force and effect and shall be severed and the remainder of the Arbitration Agreement shall continue in full force and effect.\r\n\r\n(h) Survival of Agreement. This Arbitration Agreement will survive the termination of your relationship with Company.\r\n\r\nModification. Notwithstanding any provision in this Agreement to the contrary, we agree that if Company makes any future material change to this Arbitration Agreement, you may reject that change within thirty (30) days of such change becoming effective by writing Company at the following address: Foundation Devices, Inc., 6 Liberty Square #6018, Boston, MA 02109, Attn: CEO.\r\n\r\n19. GENERAL\r\n(a) Changes to Terms of Use. This Agreement is subject to occasional revision, and if we make any substantial changes, we may notify you by sending you an e-mail to the last e-mail address you provided to us (if any) and/or by prominently posting notice of the changes on our website. Any changes to this agreement will be effective upon the earlier of thirty (30) calendar days following our dispatch of an e-mail notice to you (if applicable) or thirty (30) calendar days following our posting of notice of the changes on our website. These changes will be effective immediately for new users of our website. You are responsible for providing us with your most current e-mail address. In the event that the last e-mail address that you have provided us is not valid, or for any reason is not capable of delivering to you the notice described above, our dispatch of the e-mail containing such notice will nonetheless constitute effective notice of the changes described in the notice. Continued use of Passport following notice of such changes will indicate your acknowledgement of such changes and agreement to be bound by the terms and conditions of such changes.\r\n\r\nChoice Of Law. The Agreement is made under and will be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts, consistent with the Federal Arbitration Act, without giving effect to any principles that provide for the application of the law of another jurisdiction.\r\n\r\n(b) Entire Agreement. This Agreement constitutes the entire agreement between you and us regarding the use of Passport. Our failure to exercise or enforce any right or provision of this Agreement will not operate as a waiver of such right or provision. The section titles in this Agreement are for convenience only and have no legal or contractual effect. The word including means including without limitation. If any provision of this Agreement is, for any reason, held to be invalid or unenforceable, the other provisions of this Agreement will be unimpaired and the invalid or unenforceable provision will be deemed modified so that it is valid and enforceable to the maximum extent permitted by law. Your relationship to us is that of an independent contractor, and neither party is an agent or partner of the other. This Agreement, and your rights and obligations herein, may not be assigned, subcontracted, delegated, or otherwise transferred by you without our prior written consent, and any attempted assignment, subcontract, delegation, or transfer in violation of the foregoing will be null and void. The terms of this Agreement will be binding upon assignees.\r\n\r\n(c) Copyright/Trademark Information. Copyright © 2020, Foundation Devices, Inc. All rights reserved. All trademarks, logos and service marks displayed on the Site are our property or the property of other third parties. You are not permitted to use such trademarks, logos and service marks without our prior written consent or the consent of such third party which may own the Marks.\r\n\r\nContact Information:\r\n\r\nFoundation Devices, Inc.\r\n6 Liberty Square #6018\r\nBoston, MA 02109\r\nhello@foundationdevices.com`
  String get envoy_account_tos_subheading {
    return Intl.message(
      'Last updated: May 16, 2021.\r\n\r\nBy purchasing, using or continuing to use a Passport hardware wallet (“Passport“), you, the purchaser of Passport, agree to be bound by these terms of and use (the “Passport Terms of Use” or “Terms”).\r\n\r\n1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\r\n\r\n2. Security\n\r\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\r\n\r\n3. BACKUPS\r\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss.\r\n\r\n4. MODIFICATIONS\r\nYou acknowledge and agree that any modifications to Passport, the installation of any additional software or firmware on a Passport or the use of Passport in connection with any other software or equipment are at your sole risk, and that we have no obligation or liability in respect thereof or in respect of any resulting loss of Bitcoin, damage to Passport, failure of the Passport or errors in storing Bitcoin or processing Transactions;\r\n\r\n5. OPEN SOURCE LICENSES\r\nPassport includes software licensed under the GNU General Public License v3 and other open source licenses, as identified in documentation provided with Passport. Your use of such software is subject to the applicable open source licenses and, to the extent such open source licenses conflicts with this Agreement, the terms of such licenses will prevail.\r\n\r\n6. ACKNOWLEDGEMENT AND ASSUMPTION OF RISK\r\nYou understand and agree that:\r\n\r\n(a) there are risks associated with the use and holding of Bitcoin and you represent and warrant that you are knowledgeable and/or experienced in matters relating to the use of Bitcoin and are capable of evaluating the benefits and risks of using and holding Bitcoin and fully understand the nature of Bitcoin, the limitations and restrictions on its liquidity and transferability and are capable of bearing the economic risk of holding and transacting using Bitcoin;\r\n\r\n(b) the continued ability to use Bitcoin is dependent on many elements beyond our control, including without limitation the publication of blocks, network connectivity, hacking or changes in the technical and other standards, policies and procedures applicable to Bitcoin;\r\n\r\n(c) no regulatory authority has reviewed or passed on the merits, legality or fungibility of Bitcoin;\r\n\r\n(d) there is no government or other insurance covering Bitcoin, the loss or theft of Bitcoin, or any loss in the value of Bitcoin;\r\n\r\n(e) the use of Bitcoin or the Products may become subject to regulatory controls that limit, restrict, prohibit or otherwise impose conditions on your use of same;\r\n\r\n(f) Bitcoin do not constitute a currency, asset, security, negotiable instrument, or other form of property and do not have any intrinsic or inherent value;\r\n\r\n(g) the value of and/or exchange rates for Bitcoin may fluctuate significantly and may result in you incurring significant losses;\r\n\r\n(h) Transactions may have tax consequences (including obligations to report, collect or remit taxes) and you are solely responsible for understanding and complying with all applicable tax laws and regulations; and\r\n\r\n(i) the use of Bitcoin or Products may be illegal or subject to regulation in certain jurisdictions, and it is your responsibility to ensure that you comply with the laws of any jurisdiction in which you use Bitcoin or Products.\r\n\r\n7. TRANSFER OF PASSPORT\r\nYou may transfer or sell Passport to others on the condition that you ensure that the transferee or purchaser agrees to be bound by the then-current form of these Terms available on our website at the time of transfer.\r\n\r\n8. RESTRICTIONS\r\nYou shall not:\r\n\r\n(a) use Passport in a manner or for a purpose that: (i) is illegal or otherwise contravenes applicable law (including the facilitation or furtherance of any criminal or fraudulent activity or the violation of any anti-money laundering legislation); or (ii) infringes upon the lawful rights of others;\r\n\r\n(b) interfere with the security or integrity of Passport;\r\n\r\n(c) remove, destroy, cover, obfuscate or alter in any manner any notices, legends, trademarks, branding or logos appearing on or contained in Passport; or\r\n\r\n(d) attempt, or cause, permit or encourage any other person, to do any of the foregoing.\r\n\r\nNotwithstanding the foregoing, you may investigate security and other vulnerabilities, provided you do so in a reasonable and responsible manner in compliance with applicable law and our responsible disclosure policy and otherwise use good faith efforts to minimize or avoid contravention of any of the foregoing.\r\n\r\n9. REPRESENTATIONS AND WARRANTIES\r\nYou represent, warrant and covenant that:\r\n\r\n(a) you have the capacity to, and are and will be free to, enter into and to fully perform your obligations under these Terms and that no agreement or understanding with any other person exists or will exist which would interfere with such obligations; and\r\n\r\n(b) these Terms constitute a legal, valid and binding obligation upon you.\r\n\r\n10. OWNERSHIP\r\nExcept for the limited rights of use expressly granted to you under these Terms, all right, title and interest (including all copyrights, trademarks, service marks, patents, inventions, trade secrets, intellectual property rights and other proprietary rights) in and to Passport are and shall remain exclusively owned by us and our licensors. All trade names, company names, trademarks, service marks and other names and logos are the proprietary marks of us or our licensors, and are protected by law and may not be copied, imitated or used, in whole or in part, without the consent of their respective owners. These Terms do not grant you any rights in respect of any such marks. You understand and agree that any feedback, input, suggestions, recommendations, improvements, changes, specifications, test results, or other data or information that you provide or make available to us arising from or related to your use of the Products or Software shall become our exclusive property and may be used by us to modify, enhance, maintain and improve Passport without any obligation or payment to you whatsoever.\r\n\r\n11. THIRD PARTY PRODUCTS\r\nYou acknowledge and agree that you will require certain third party equipment, products, software and services in order to use the Products and may also use optional third party equipment, products, software and services that enhance or complement such use (collectively, “Third Party Products”). You acknowledge and agree that failure to use or procure Third Party Products that meet the minimum requirements for Products, or failure to properly configure or setup Third Party Products may result in the inability to use the Products and/or processing failures or errors. Third Party Products include, without limitation, computers, mobile devices, networking equipment, operating system software, web browsers and internet connectivity. We may also identify, recommend, reference or link to optional Third Party Products on our website. You acknowledge and agree that: (a) Third Party Products are be governed by separate licenses, agreements or terms and conditions and we have no obligation or liability to you in respect thereof; and (b) you are solely responsible for procuring any Third Party Products at your cost and expense, and are solely responsible for compliance with any applicable licenses, agreements or terms and conditions governing same. \r\n\r\n12. INDEMNITY\r\nYou agree to indemnify and hold Foundation Devices (and our officers, employees, and agents) harmless, including costs and attorneys’ fees, from any claim or demand due to or arising out of (a) your use of Passport, (b) your violation of this Agreement or (c) your violation of applicable laws or regulations. We reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us and you agree to cooperate with our defense of these claims. You agree not to settle any matter without our prior written consent. We will use reasonable efforts to notify you of any such claim, action or proceeding upon becoming aware of it.\r\n\r\n13. DISCLAIMERS\r\nPASSPORT IS PROVIDED “AS-IS” AND “AS AVAILABLE” AND WE (AND OUR SUPPLIERS) EXPRESSLY DISCLAIM ANY WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, QUIET ENJOYMENT, ACCURACY, OR NON-INFRINGEMENT. WE (AND OUR SUPPLIERS) MAKE NO WARRANTY THAT PASSPORT: (A) WILL MEET YOUR REQUIREMENTS; (B) WILL BE AVAILABLE ON AN UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE BASIS; OR (C) WILL BE ACCURATE, RELIABLE, FREE OF VIRUSES OR OTHER HARMFUL CODE, COMPLETE, LEGAL, OR SAFE.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n14. LIMITATION ON LIABILITY\r\nYOU AGREE THAT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, OUR AGGREGATE LIABILITY ARISING FROM OR RELATED TO THESE TERMS OR PASSPORT IN ANY MANNER WILL BE LIMITED TO DIRECT DAMAGES NOT TO EXCEED THE PURCHASE PRICE YOU HAVE PAID TO US FOR PASSPORT (EXCLUDING SHIPPING CHARGES AND TAXES). TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL WE (AND OUR SUPPLIERS) BE LIABLE FOR ANY CONSEQUENTIAL, INCIDENTAL, INDIRECT, SPECIAL, PUNITIVE, OR OTHER DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF REVENUE, PROFITS, OR EXPECTED SAVINGS, BUSINESS INTERRUPTION, PERSONAL INJURY, LOSS OF PRIVACY, LOSS OF DATA OR INFORMATION OR OTHER PECUNIARY OR INTANGIBLE LOSS) ARISING OUT OF THESE TERMS OR THE USE OF OR INABILITY TO USE PASSPORT, EVEN IF WE FORESEE OR HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OF CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n15. RELEASE\r\nYou hereby release and forever discharge us (and our officers, employees, agents, successors, and assigns) from, and hereby waive and relinquish, each and every past, present and future dispute, claim, controversy, demand, right, obligation, liability, action and cause of action of every kind and nature (including personal injuries, death, and property damage), that has arisen or arises directly or indirectly out of, or relates directly or indirectly to, use of Passport. IF YOU ARE A CALIFORNIA RESIDENT, YOU HEREBY WAIVE CALIFORNIA CIVIL CODE SECTION 1542 IN CONNECTION WITH THE FOREGOING, WHICH STATES: “A GENERAL RELEASE DOES NOT EXTEND TO CLAIMS WHICH THE CREDITOR DOES NOT KNOW OR SUSPECT TO EXIST IN HIS OR HER FAVOR AT THE TIME OF EXECUTING THE RELEASE, WHICH IF KNOWN BY HIM OR HER MUST HAVE MATERIALLY AFFECTED HIS OR HER SETTLEMENT WITH THE DEBTOR.”\r\n\r\n16. SURVIVAL\r\nNeither the expiration nor the earlier termination of your account will release you from any obligation or liability that accrued prior to such expiration or termination. The provisions of these Terms requiring performance or fulfilment after the expiration or earlier termination of your account and any other provisions hereof, the nature and intent of which is to survive termination or expiration, will survive.\r\n\r\n17. PRIVACY POLICY\r\nPlease review our Privacy Policy, located at https://foundationdevices.com/privacy, which governs the use of personal information.\r\n\r\n18. DISPUTE RESOLUTION\r\nPlease read the following arbitration agreement in this section (“Arbitration Agreement”) carefully. It requires U.S. users to arbitrate disputes with Foundation Devices and limits the manner in which you can seek relief from us.\r\n\r\n(a) Applicability of Arbitration Agreement. You agree that any dispute, claim, or request for relief relating in any way to your use of Passport will be resolved by binding arbitration, rather than in court, except that (a) you may assert claims or seek relief in small claims court if your claims qualify; and (b) you or we may seek equitable relief in court for infringement or other misuse of intellectual property rights (such as trademarks, trade dress, domain names, trade secrets, copyrights, and patents). This Arbitration Agreement shall apply, without limitation, to all disputes or claims and requests for relief that arose or were asserted before the effective date of this Agreement or any prior version of this Agreement.\r\n\r\n(b) Arbitration Rules and Forum. The Federal Arbitration Act governs the interpretation and enforcement of this Arbitration Agreement. To begin an arbitration proceeding, you must send a letter requesting arbitration and describing your dispute or claim or request for relief to our registered agent. The arbitration will be conducted by JAMS, an established alternative dispute resolution provider. Disputes involving claims, counterclaims, or request for relief under \$250,000, not inclusive of attorneys’ fees and interest, shall be subject to JAMS’s most current version of the Streamlined Arbitration Rules and procedures available at https://jamsadr.com/rules-streamlined-arbitration/; all other disputes shall be subject to JAMS’s most current version of the Comprehensive Arbitration Rules and Procedures, available at https://jamsadr.com/rules-comprehensive-arbitration/. JAMS’s rules are also available at https://jamsadr.com or by calling JAMS at 800-352-5267. If JAMS is not available to arbitrate, the parties will select an alternative arbitral forum. If the arbitrator finds that you cannot afford to pay JAMS’s filing, administrative, hearing and/or other fees and cannot obtain a waiver from JAMS, Company will pay them for you. In addition, Company will reimburse all such JAMS’s filing, administrative, hearing and/or other fees for disputes, claims, or requests for relief totaling less than \$10,000 unless the arbitrator determines the claims are frivolous.\r\n\r\nYou may choose to have the arbitration conducted by telephone, based on written submissions, or in person in the country where you live or at another mutually agreed location. Any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction.\r\n\r\n(c) Authority of Arbitrator. The arbitrator shall have exclusive authority to (a) determine the scope and enforceability of this Arbitration Agreement and (b) resolve any dispute related to the interpretation, applicability, enforceability or formation of this Arbitration Agreement including, but not limited to, any assertion that all or any part of this Arbitration Agreement is void or voidable. The arbitration will decide the rights and liabilities, if any, of you and Company. The arbitration proceeding will not be consolidated with any other matters or joined with any other cases or parties. The arbitrator shall have the authority to grant motions dispositive of all or part of any claim. The arbitrator shall have the authority to award monetary damages and to grant any non-monetary remedy or relief available to an individual under applicable law, the arbitral forum’s rules, and the Agreement (including the Arbitration Agreement). The arbitrator shall issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator has the same authority to award relief on an individual basis that a judge in a court of law would have. The award of the arbitrator is final and binding upon you and us.\r\n\r\n(d) Waiver of Jury Trial. YOU AND COMPANY HEREBY WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO SUE IN COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY. You and Company are instead electing that all disputes, claims, or requests for relief shall be resolved by arbitration under this Arbitration Agreement, except as specified in Section 10(a) (Application of Arbitration Agreement) above. An arbitrator can award on an individual basis the same damages and relief as a court and must follow this Agreement as a court would. However, there is no judge or jury in arbitration, and court review of an arbitration award is subject to very limited review.\r\n\r\n(e) Waiver of Class or Other Non-Individualized Relief. ALL DISPUTES, CLAIMS, AND REQUESTS FOR RELIEF WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS OR COLLECTIVE BASIS, ONLY INDIVIDUAL RELIEF IS AVAILABLE, AND CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If a decision is issued stating that applicable law precludes enforcement of any of this section’s limitations as to a given dispute, claim, or request for relief, then such aspect must be severed from the arbitration and brought into the State or Federal Courts located in the Commonwealth of Massachusetts. All other disputes, claims, or requests for relief shall be arbitrated.\r\n\r\n(f) 30-Day Right to Opt Out. You have the right to opt out of the provisions of this Arbitration Agreement by sending written notice of your decision to opt out to: hello@foundationdevices.com, within thirty (30) days after first becoming subject to this Arbitration Agreement. Your notice must include your name and address, your Company username (if any), the email address you used to set up your Company account (if you have one), and an unequivocal statement that you want to opt out of this Arbitration Agreement. If you opt out of this Arbitration Agreement, all other parts of this Agreement will continue to apply to you. Opting out of this Arbitration Agreement has no effect on any other arbitration agreements that you may currently have, or may enter in the future, with us.\r\n\r\n(g) Severability. Except as provided in Section 10(e)(Waiver of Class or Other Non-Individualized Relief), if any part or parts of this Arbitration Agreement are found under the law to be invalid or unenforceable, then such specific part or parts shall be of no force and effect and shall be severed and the remainder of the Arbitration Agreement shall continue in full force and effect.\r\n\r\n(h) Survival of Agreement. This Arbitration Agreement will survive the termination of your relationship with Company.\r\n\r\nModification. Notwithstanding any provision in this Agreement to the contrary, we agree that if Company makes any future material change to this Arbitration Agreement, you may reject that change within thirty (30) days of such change becoming effective by writing Company at the following address: Foundation Devices, Inc., 6 Liberty Square #6018, Boston, MA 02109, Attn: CEO.\r\n\r\n19. GENERAL\r\n(a) Changes to Terms of Use. This Agreement is subject to occasional revision, and if we make any substantial changes, we may notify you by sending you an e-mail to the last e-mail address you provided to us (if any) and/or by prominently posting notice of the changes on our website. Any changes to this agreement will be effective upon the earlier of thirty (30) calendar days following our dispatch of an e-mail notice to you (if applicable) or thirty (30) calendar days following our posting of notice of the changes on our website. These changes will be effective immediately for new users of our website. You are responsible for providing us with your most current e-mail address. In the event that the last e-mail address that you have provided us is not valid, or for any reason is not capable of delivering to you the notice described above, our dispatch of the e-mail containing such notice will nonetheless constitute effective notice of the changes described in the notice. Continued use of Passport following notice of such changes will indicate your acknowledgement of such changes and agreement to be bound by the terms and conditions of such changes.\r\n\r\nChoice Of Law. The Agreement is made under and will be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts, consistent with the Federal Arbitration Act, without giving effect to any principles that provide for the application of the law of another jurisdiction.\r\n\r\n(b) Entire Agreement. This Agreement constitutes the entire agreement between you and us regarding the use of Passport. Our failure to exercise or enforce any right or provision of this Agreement will not operate as a waiver of such right or provision. The section titles in this Agreement are for convenience only and have no legal or contractual effect. The word including means including without limitation. If any provision of this Agreement is, for any reason, held to be invalid or unenforceable, the other provisions of this Agreement will be unimpaired and the invalid or unenforceable provision will be deemed modified so that it is valid and enforceable to the maximum extent permitted by law. Your relationship to us is that of an independent contractor, and neither party is an agent or partner of the other. This Agreement, and your rights and obligations herein, may not be assigned, subcontracted, delegated, or otherwise transferred by you without our prior written consent, and any attempted assignment, subcontract, delegation, or transfer in violation of the foregoing will be null and void. The terms of this Agreement will be binding upon assignees.\r\n\r\n(c) Copyright/Trademark Information. Copyright © 2020, Foundation Devices, Inc. All rights reserved. All trademarks, logos and service marks displayed on the Site are our property or the property of other third parties. You are not permitted to use such trademarks, logos and service marks without our prior written consent or the consent of such third party which may own the Marks.\r\n\r\nContact Information:\r\n\r\nFoundation Devices, Inc.\r\n6 Liberty Square #6018\r\nBoston, MA 02109\r\nhello@foundationdevices.com',
      name: 'envoy_account_tos_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy requires camera access to scan QR codes. Please go to settings and grant camera permissions.`
  String get envoy_cameraPermissionRequest {
    return Intl.message(
      'Envoy requires camera access to scan QR codes. Please go to settings and grant camera permissions.',
      name: 'envoy_cameraPermissionRequest',
      desc: '',
      args: [],
    );
  }

  /// `Permission required`
  String get envoy_cameraPermissionRequest_Header {
    return Intl.message(
      'Permission required',
      name: 'envoy_cameraPermissionRequest_Header',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is a Bitcoin mobile wallet and Passport companion app, available on iOS and Android.`
  String get envoy_faq_answer_1 {
    return Intl.message(
      'Envoy is a Bitcoin mobile wallet and Passport companion app, available on iOS and Android.',
      name: 'envoy_faq_answer_1',
      desc: '',
      args: [],
    );
  }

  /// `No, anyone is still free to manually download, verify and install new firmware. See [[here]] for more information.`
  String get envoy_faq_answer_10 {
    return Intl.message(
      'No, anyone is still free to manually download, verify and install new firmware. See [[here]] for more information.',
      name: 'envoy_faq_answer_10',
      desc: '',
      args: [],
    );
  }

  /// `Absolutely, there is no limit to the number of Passports you can manage and interact with using Envoy.`
  String get envoy_faq_answer_11 {
    return Intl.message(
      'Absolutely, there is no limit to the number of Passports you can manage and interact with using Envoy.',
      name: 'envoy_faq_answer_11',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Envoy makes multi-account management simple.`
  String get envoy_faq_answer_12 {
    return Intl.message(
      'Yes, Envoy makes multi-account management simple.',
      name: 'envoy_faq_answer_12',
      desc: '',
      args: [],
    );
  }

  /// `Envoy communicates predominantly via QR codes, however firmware updates are passed from your phone via a microSD card. Passport includes microSD adapters for your phone.`
  String get envoy_faq_answer_13 {
    return Intl.message(
      'Envoy communicates predominantly via QR codes, however firmware updates are passed from your phone via a microSD card. Passport includes microSD adapters for your phone.',
      name: 'envoy_faq_answer_13',
      desc: '',
      args: [],
    );
  }

  /// `Yes, just be aware that any wallet-specific information, such as address or UTXO labeling, will not be copied to or from Envoy.`
  String get envoy_faq_answer_14 {
    return Intl.message(
      'Yes, just be aware that any wallet-specific information, such as address or UTXO labeling, will not be copied to or from Envoy.',
      name: 'envoy_faq_answer_14',
      desc: '',
      args: [],
    );
  }

  /// `This may be possible as most QR enabled hardware wallets communicate in very similar ways, however this is not explicitly supported. As Envoy is open source, we welcome other QR-based hardware wallets to add support!`
  String get envoy_faq_answer_15 {
    return Intl.message(
      'This may be possible as most QR enabled hardware wallets communicate in very similar ways, however this is not explicitly supported. As Envoy is open source, we welcome other QR-based hardware wallets to add support!',
      name: 'envoy_faq_answer_15',
      desc: '',
      args: [],
    );
  }

  /// `At this time Envoy only works with ‘on-chain’ Bitcoin. We plan to support Lightning in the future.`
  String get envoy_faq_answer_16 {
    return Intl.message(
      'At this time Envoy only works with ‘on-chain’ Bitcoin. We plan to support Lightning in the future.',
      name: 'envoy_faq_answer_16',
      desc: '',
      args: [],
    );
  }

  /// `Anyone finding your phone would first need to get past your phones operating system PIN or biometric authentication to access Envoy. In the unlikely event they achieve this, the attacker could send funds from your Envoy Mobile Wallet and see the amount of Bitcoin stored within any connected Passport accounts. These Passport funds are not at risk because any transactions must be authorized by the paired Passport device.`
  String get envoy_faq_answer_17 {
    return Intl.message(
      'Anyone finding your phone would first need to get past your phones operating system PIN or biometric authentication to access Envoy. In the unlikely event they achieve this, the attacker could send funds from your Envoy Mobile Wallet and see the amount of Bitcoin stored within any connected Passport accounts. These Passport funds are not at risk because any transactions must be authorized by the paired Passport device.',
      name: 'envoy_faq_answer_17',
      desc: '',
      args: [],
    );
  }

  /// `If used with a Passport, Envoy acts as a ‘watch-only’ wallet connected to your hardware wallet. This means Envoy can construct transactions, but they are useless without the relevant authorization, which only Passport can provide. Passport is the 'cold storage' and Envoy is simply the internet connected interface!If you use Envoy to create a mobile wallet, where the keys are stored securely on your phone, that mobile wallet would not be considered cold storage. This has zero effect on the security of any Passport connected accounts.`
  String get envoy_faq_answer_18 {
    return Intl.message(
      'If used with a Passport, Envoy acts as a ‘watch-only’ wallet connected to your hardware wallet. This means Envoy can construct transactions, but they are useless without the relevant authorization, which only Passport can provide. Passport is the \'cold storage\' and Envoy is simply the internet connected interface!If you use Envoy to create a mobile wallet, where the keys are stored securely on your phone, that mobile wallet would not be considered cold storage. This has zero effect on the security of any Passport connected accounts.',
      name: 'envoy_faq_answer_18',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Envoy connects using the Electrum server protocol. To connect to your own Electrum Server, scan the QR or enter the URL provided into the network settings on Envoy.`
  String get envoy_faq_answer_19 {
    return Intl.message(
      'Yes, Envoy connects using the Electrum server protocol. To connect to your own Electrum Server, scan the QR or enter the URL provided into the network settings on Envoy.',
      name: 'envoy_faq_answer_19',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is designed to offer the easiest to use experience of any Bitcoin wallet, without compromising on your privacy. With Envoy Magic Backups, set up a self custodied Bitcoin mobile wallet in 60 seconds, without seed words! Passport users can connect their devices to Envoy for easy setup, firmware updates, and a simple Bitcoin wallet experience.`
  String get envoy_faq_answer_2 {
    return Intl.message(
      'Envoy is designed to offer the easiest to use experience of any Bitcoin wallet, without compromising on your privacy. With Envoy Magic Backups, set up a self custodied Bitcoin mobile wallet in 60 seconds, without seed words! Passport users can connect their devices to Envoy for easy setup, firmware updates, and a simple Bitcoin wallet experience.',
      name: 'envoy_faq_answer_2',
      desc: '',
      args: [],
    );
  }

  /// `Downloading and installing Envoy requires zero personal information and Envoy can connect to the internet via Tor, a privacy preserving protocol. This means that Foundation has no way of knowing who you are. Envoy also allows more advanced users the ability to connect to their own Bitcoin node to remove any reliance on the Foundation servers completely.`
  String get envoy_faq_answer_20 {
    return Intl.message(
      'Downloading and installing Envoy requires zero personal information and Envoy can connect to the internet via Tor, a privacy preserving protocol. This means that Foundation has no way of knowing who you are. Envoy also allows more advanced users the ability to connect to their own Bitcoin node to remove any reliance on the Foundation servers completely.',
      name: 'envoy_faq_answer_20',
      desc: '',
      args: [],
    );
  }

  /// `Yes. From version 1.4.0, Envoy now support full coin selection as well as coin 'tagging'.`
  String get envoy_faq_answer_21 {
    return Intl.message(
      'Yes. From version 1.4.0, Envoy now support full coin selection as well as coin \'tagging\'.',
      name: 'envoy_faq_answer_21',
      desc: '',
      args: [],
    );
  }

  /// `At this time Envoy does not support batch spending.`
  String get envoy_faq_answer_22 {
    return Intl.message(
      'At this time Envoy does not support batch spending.',
      name: 'envoy_faq_answer_22',
      desc: '',
      args: [],
    );
  }

  /// `Yes. From version 1.4.0, Envoy allows for fully customized miner fees as well as two quick select fee options of ‘Standard’ and ‘Faster’. 'Standard' aims to get your transaction finalized within 60 minutes and 'Faster' within 10 minutes. These are estimates based on the network congestion at the time the transaction is built and you will always be shown the cost of both options before finalizing the transaction.`
  String get envoy_faq_answer_23 {
    return Intl.message(
      'Yes. From version 1.4.0, Envoy allows for fully customized miner fees as well as two quick select fee options of ‘Standard’ and ‘Faster’. \'Standard\' aims to get your transaction finalized within 60 minutes and \'Faster\' within 10 minutes. These are estimates based on the network congestion at the time the transaction is built and you will always be shown the cost of both options before finalizing the transaction.',
      name: 'envoy_faq_answer_23',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is a simple Bitcoin wallet with powerful account management and privacy features, including Magic Backups.Use Envoy alongside your Passport hardware wallet for setup, firmware updates, and more.`
  String get envoy_faq_answer_3 {
    return Intl.message(
      'Envoy is a simple Bitcoin wallet with powerful account management and privacy features, including Magic Backups.Use Envoy alongside your Passport hardware wallet for setup, firmware updates, and more.',
      name: 'envoy_faq_answer_3',
      desc: '',
      args: [],
    );
  }

  /// `Magic Backups is the easiest way to set up and back up a Bitcoin mobile wallet. Magic Backups stores your mobile wallet seed end-to-end encrypted in iCloud Keychain or Android Auto Backup. All app data is encrypted by your seed and stored on Foundation Servers. Set up your wallet in 60 seconds, and automatically restore if you lose your phone!`
  String get envoy_faq_answer_4 {
    return Intl.message(
      'Magic Backups is the easiest way to set up and back up a Bitcoin mobile wallet. Magic Backups stores your mobile wallet seed end-to-end encrypted in iCloud Keychain or Android Auto Backup. All app data is encrypted by your seed and stored on Foundation Servers. Set up your wallet in 60 seconds, and automatically restore if you lose your phone!',
      name: 'envoy_faq_answer_4',
      desc: '',
      args: [],
    );
  }

  /// `Magic Backups are completely optional for users that want to leverage Envoy as a mobile wallet. If you prefer to manage your own mobile wallet seed words and backup file, choose 'Manually Configure Seed Words' at the wallet set up stage.`
  String get envoy_faq_answer_5 {
    return Intl.message(
      'Magic Backups are completely optional for users that want to leverage Envoy as a mobile wallet. If you prefer to manage your own mobile wallet seed words and backup file, choose \'Manually Configure Seed Words\' at the wallet set up stage.',
      name: 'envoy_faq_answer_5',
      desc: '',
      args: [],
    );
  }

  /// `The Envoy backup file contains app settings, account info and transaction labels. The file is encrypted with your mobile wallet seed words. For Magic Backup users, this is stored fully encrypted on the Foundation server. Manual backup Envoy users can download and store their backup file anywhere they like. This could be any combination of your phone, a personal cloud server, or on something physical like a microSD card or USB drive.`
  String get envoy_faq_answer_6 {
    return Intl.message(
      'The Envoy backup file contains app settings, account info and transaction labels. The file is encrypted with your mobile wallet seed words. For Magic Backup users, this is stored fully encrypted on the Foundation server. Manual backup Envoy users can download and store their backup file anywhere they like. This could be any combination of your phone, a personal cloud server, or on something physical like a microSD card or USB drive.',
      name: 'envoy_faq_answer_6',
      desc: '',
      args: [],
    );
  }

  /// `No, Envoy’s core features will always be free to use. In the future we may introduce optional paid services or subscriptions.`
  String get envoy_faq_answer_7 {
    return Intl.message(
      'No, Envoy’s core features will always be free to use. In the future we may introduce optional paid services or subscriptions.',
      name: 'envoy_faq_answer_7',
      desc: '',
      args: [],
    );
  }

  /// `Yes, like everything we do at Foundation, Envoy is completely open source. Envoy is licensed under the same [[GPLv3]] license as our Passport Firmware. For those wanting to check our source code, click [[here]].`
  String get envoy_faq_answer_8 {
    return Intl.message(
      'Yes, like everything we do at Foundation, Envoy is completely open source. Envoy is licensed under the same [[GPLv3]] license as our Passport Firmware. For those wanting to check our source code, click [[here]].',
      name: 'envoy_faq_answer_8',
      desc: '',
      args: [],
    );
  }

  /// `No, we pride ourselves on ensuring Passport is compatible with as many different software wallets as possible. See our full list, including tutorials [[here]].`
  String get envoy_faq_answer_9 {
    return Intl.message(
      'No, we pride ourselves on ensuring Passport is compatible with as many different software wallets as possible. See our full list, including tutorials [[here]].',
      name: 'envoy_faq_answer_9',
      desc: '',
      args: [],
    );
  }

  /// `What is Envoy?`
  String get envoy_faq_question_1 {
    return Intl.message(
      'What is Envoy?',
      name: 'envoy_faq_question_1',
      desc: '',
      args: [],
    );
  }

  /// `Do I have to use Envoy to update the firmware on Passport?`
  String get envoy_faq_question_10 {
    return Intl.message(
      'Do I have to use Envoy to update the firmware on Passport?',
      name: 'envoy_faq_question_10',
      desc: '',
      args: [],
    );
  }

  /// `Can I manage more than one Passport with Envoy?`
  String get envoy_faq_question_11 {
    return Intl.message(
      'Can I manage more than one Passport with Envoy?',
      name: 'envoy_faq_question_11',
      desc: '',
      args: [],
    );
  }

  /// `Can I manage multiple accounts from the same Passport?`
  String get envoy_faq_question_12 {
    return Intl.message(
      'Can I manage multiple accounts from the same Passport?',
      name: 'envoy_faq_question_12',
      desc: '',
      args: [],
    );
  }

  /// `How does Envoy communicate with Passport?`
  String get envoy_faq_question_13 {
    return Intl.message(
      'How does Envoy communicate with Passport?',
      name: 'envoy_faq_question_13',
      desc: '',
      args: [],
    );
  }

  /// `Can I use Envoy in parallel to another piece of software like Sparrow Wallet?`
  String get envoy_faq_question_14 {
    return Intl.message(
      'Can I use Envoy in parallel to another piece of software like Sparrow Wallet?',
      name: 'envoy_faq_question_14',
      desc: '',
      args: [],
    );
  }

  /// `Can I manage other hardware wallets with Envoy?`
  String get envoy_faq_question_15 {
    return Intl.message(
      'Can I manage other hardware wallets with Envoy?',
      name: 'envoy_faq_question_15',
      desc: '',
      args: [],
    );
  }

  /// `Is Envoy compatible with the Lightning Network?`
  String get envoy_faq_question_16 {
    return Intl.message(
      'Is Envoy compatible with the Lightning Network?',
      name: 'envoy_faq_question_16',
      desc: '',
      args: [],
    );
  }

  /// `What happens if I lose my phone with Envoy installed?`
  String get envoy_faq_question_17 {
    return Intl.message(
      'What happens if I lose my phone with Envoy installed?',
      name: 'envoy_faq_question_17',
      desc: '',
      args: [],
    );
  }

  /// `Is Envoy considered ‘Cold Storage’?`
  String get envoy_faq_question_18 {
    return Intl.message(
      'Is Envoy considered ‘Cold Storage’?',
      name: 'envoy_faq_question_18',
      desc: '',
      args: [],
    );
  }

  /// `Can I connect Envoy to my own Bitcoin node?`
  String get envoy_faq_question_19 {
    return Intl.message(
      'Can I connect Envoy to my own Bitcoin node?',
      name: 'envoy_faq_question_19',
      desc: '',
      args: [],
    );
  }

  /// `Why should I use Envoy?`
  String get envoy_faq_question_2 {
    return Intl.message(
      'Why should I use Envoy?',
      name: 'envoy_faq_question_2',
      desc: '',
      args: [],
    );
  }

  /// `How does Envoy protect my privacy?`
  String get envoy_faq_question_20 {
    return Intl.message(
      'How does Envoy protect my privacy?',
      name: 'envoy_faq_question_20',
      desc: '',
      args: [],
    );
  }

  /// `Does Envoy offer coin control?`
  String get envoy_faq_question_21 {
    return Intl.message(
      'Does Envoy offer coin control?',
      name: 'envoy_faq_question_21',
      desc: '',
      args: [],
    );
  }

  /// `Does Envoy support Batch spends?`
  String get envoy_faq_question_22 {
    return Intl.message(
      'Does Envoy support Batch spends?',
      name: 'envoy_faq_question_22',
      desc: '',
      args: [],
    );
  }

  /// `Does Envoy allow custom miner fee selection?`
  String get envoy_faq_question_23 {
    return Intl.message(
      'Does Envoy allow custom miner fee selection?',
      name: 'envoy_faq_question_23',
      desc: '',
      args: [],
    );
  }

  /// `What can Envoy do?`
  String get envoy_faq_question_3 {
    return Intl.message(
      'What can Envoy do?',
      name: 'envoy_faq_question_3',
      desc: '',
      args: [],
    );
  }

  /// `What is Envoy Magic Backup?`
  String get envoy_faq_question_4 {
    return Intl.message(
      'What is Envoy Magic Backup?',
      name: 'envoy_faq_question_4',
      desc: '',
      args: [],
    );
  }

  /// `Do I have to use Envoy Magic Backups?`
  String get envoy_faq_question_5 {
    return Intl.message(
      'Do I have to use Envoy Magic Backups?',
      name: 'envoy_faq_question_5',
      desc: '',
      args: [],
    );
  }

  /// `What is the Envoy Backup File?`
  String get envoy_faq_question_6 {
    return Intl.message(
      'What is the Envoy Backup File?',
      name: 'envoy_faq_question_6',
      desc: '',
      args: [],
    );
  }

  /// `Do I need to pay for Envoy?`
  String get envoy_faq_question_7 {
    return Intl.message(
      'Do I need to pay for Envoy?',
      name: 'envoy_faq_question_7',
      desc: '',
      args: [],
    );
  }

  /// `Is Envoy Open Source?`
  String get envoy_faq_question_8 {
    return Intl.message(
      'Is Envoy Open Source?',
      name: 'envoy_faq_question_8',
      desc: '',
      args: [],
    );
  }

  /// `Do I have to use Envoy to transact with Passport?`
  String get envoy_faq_question_9 {
    return Intl.message(
      'Do I have to use Envoy to transact with Passport?',
      name: 'envoy_faq_question_9',
      desc: '',
      args: [],
    );
  }

  /// `Envoy failed to copy the firmware onto the microSD card.`
  String get envoy_fw_fail_heading {
    return Intl.message(
      'Envoy failed to copy the firmware onto the microSD card.',
      name: 'envoy_fw_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Ensure the microSD card is inserted into your phone correctly and try again. Alternatively the firmware can be downloaded from our [[GitHub]].`
  String get envoy_fw_fail_subheading {
    return Intl.message(
      'Ensure the microSD card is inserted into your phone correctly and try again. Alternatively the firmware can be downloaded from our [[GitHub]].',
      name: 'envoy_fw_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Download Firmware`
  String get envoy_fw_intro_cta {
    return Intl.message(
      'Download Firmware',
      name: 'envoy_fw_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Next, let’s update Passport's firmware`
  String get envoy_fw_intro_heading {
    return Intl.message(
      'Next, let’s update Passport\'s firmware',
      name: 'envoy_fw_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy allows you to update your Passport from your phone using the included microSD adapter.\n\nAdvanced users can [[tap here]] to download and verify their own firmware on a computer.`
  String get envoy_fw_intro_subheading {
    return Intl.message(
      'Envoy allows you to update your Passport from your phone using the included microSD adapter.\n\nAdvanced users can [[tap here]] to download and verify their own firmware on a computer.',
      name: 'envoy_fw_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Allow Envoy to access the microSD card`
  String get envoy_fw_ios_instructions_heading {
    return Intl.message(
      'Allow Envoy to access the microSD card',
      name: 'envoy_fw_ios_instructions_heading',
      desc: '',
      args: [],
    );
  }

  /// `Grant Envoy access to copy files to the microSD card. Tap Browse, then PASSPORT-SD, then Open.`
  String get envoy_fw_ios_instructions_subheading {
    return Intl.message(
      'Grant Envoy access to copy files to the microSD card. Tap Browse, then PASSPORT-SD, then Open.',
      name: 'envoy_fw_ios_instructions_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Download from Github`
  String get envoy_fw_microsd_fails_cta2 {
    return Intl.message(
      'Download from Github',
      name: 'envoy_fw_microsd_fails_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, we can’t get the firmware update right now.`
  String get envoy_fw_microsd_fails_heading {
    return Intl.message(
      'Sorry, we can’t get the firmware update right now.',
      name: 'envoy_fw_microsd_fails_heading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into your Phone`
  String get envoy_fw_microsd_heading {
    return Intl.message(
      'Insert the microSD card into your Phone',
      name: 'envoy_fw_microsd_heading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the provided microSD card adapter into your phone, then insert the microSD card into the adapter.`
  String get envoy_fw_microsd_subheading {
    return Intl.message(
      'Insert the provided microSD card adapter into your phone, then insert the microSD card into the adapter.',
      name: 'envoy_fw_microsd_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Remove the microSD card and insert it into Passport`
  String get envoy_fw_passport_heading {
    return Intl.message(
      'Remove the microSD card and insert it into Passport',
      name: 'envoy_fw_passport_heading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into Passport and navigate to Settings -> Firmware -> Update Firmware.\n\nEnsure Passport has adequate battery charge before carrying out this operation.`
  String get envoy_fw_passport_onboarded_subheading {
    return Intl.message(
      'Insert the microSD card into Passport and navigate to Settings -> Firmware -> Update Firmware.\n\nEnsure Passport has adequate battery charge before carrying out this operation.',
      name: 'envoy_fw_passport_onboarded_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into Passport then head follow the instructions. \n\nEnsure Passport has adequate battery charge before carrying out this operation.`
  String get envoy_fw_passport_subheading {
    return Intl.message(
      'Insert the microSD card into Passport then head follow the instructions. \n\nEnsure Passport has adequate battery charge before carrying out this operation.',
      name: 'envoy_fw_passport_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is now copying the firmware onto the\nmicroSD card`
  String get envoy_fw_progress_heading {
    return Intl.message(
      'Envoy is now copying the firmware onto the\nmicroSD card',
      name: 'envoy_fw_progress_heading',
      desc: '',
      args: [],
    );
  }

  /// `This might take few seconds. Please do not remove the microSD card.`
  String get envoy_fw_progress_subheading {
    return Intl.message(
      'This might take few seconds. Please do not remove the microSD card.',
      name: 'envoy_fw_progress_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Firmware was successfully copied onto the\nmicroSD card`
  String get envoy_fw_success_heading {
    return Intl.message(
      'Firmware was successfully copied onto the\nmicroSD card',
      name: 'envoy_fw_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Make sure to tap the Unmount SD Card button from your File Manager before removing your microSD card from your phone.`
  String get envoy_fw_success_subheading {
    return Intl.message(
      'Make sure to tap the Unmount SD Card button from your File Manager before removing your microSD card from your phone.',
      name: 'envoy_fw_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `The latest firmware has been copied to the microSD card and is ready to be applied to Passport.`
  String get envoy_fw_success_subheading_ios {
    return Intl.message(
      'The latest firmware has been copied to the microSD card and is ready to be applied to Passport.',
      name: 'envoy_fw_success_subheading_ios',
      desc: '',
      args: [],
    );
  }

  /// `Enter a 6-12 digit PIN on your Passport`
  String get envoy_pin_intro_heading {
    return Intl.message(
      'Enter a 6-12 digit PIN on your Passport',
      name: 'envoy_pin_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passport will always ask for the PIN when starting up. We recommend using a unique PIN and writing it down.\n\nIf you forget your PIN, there is no way to recover Passport, and the device will be permanently disabled.`
  String get envoy_pin_intro_subheading {
    return Intl.message(
      'Passport will always ask for the PIN when starting up. We recommend using a unique PIN and writing it down.\n\nIf you forget your PIN, there is no way to recover Passport, and the device will be permanently disabled.',
      name: 'envoy_pin_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Now, create an encrypted backup of your seed`
  String get envoy_pp_new_seed_backup_heading {
    return Intl.message(
      'Now, create an encrypted backup of your seed',
      name: 'envoy_pp_new_seed_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passport will back up your seed and device settings to an encrypted microSD card.`
  String get envoy_pp_new_seed_backup_subheading {
    return Intl.message(
      'Passport will back up your seed and device settings to an encrypted microSD card.',
      name: 'envoy_pp_new_seed_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport select \nCreate New Seed`
  String get envoy_pp_new_seed_heading {
    return Intl.message(
      'On Passport select \nCreate New Seed',
      name: 'envoy_pp_new_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passport's Avalanche Noise Source, an open source true random number generator, helps create a strong seed.`
  String get envoy_pp_new_seed_subheading {
    return Intl.message(
      'Passport\'s Avalanche Noise Source, an open source true random number generator, helps create a strong seed.',
      name: 'envoy_pp_new_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations, your new seed has been created`
  String get envoy_pp_new_seed_success_heading {
    return Intl.message(
      'Congratulations, your new seed has been created',
      name: 'envoy_pp_new_seed_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Next, we will connect Envoy and Passport.`
  String get envoy_pp_new_seed_success_subheading {
    return Intl.message(
      'Next, we will connect Envoy and Passport.',
      name: 'envoy_pp_new_seed_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select \nRestore Backup`
  String get envoy_pp_restore_backup_heading {
    return Intl.message(
      'On Passport, select \nRestore Backup',
      name: 'envoy_pp_restore_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Decrypt your Backup`
  String get envoy_pp_restore_backup_password_heading {
    return Intl.message(
      'Decrypt your Backup',
      name: 'envoy_pp_restore_backup_password_heading',
      desc: '',
      args: [],
    );
  }

  /// `To decrypt the backup file, enter the 20 digit backup code shown to you when creating the backup file.\n\nIf you have lost or forgotten this code, you can restore using the seed words instead.`
  String get envoy_pp_restore_backup_password_subheading {
    return Intl.message(
      'To decrypt the backup file, enter the 20 digit backup code shown to you when creating the backup file.\n\nIf you have lost or forgotten this code, you can restore using the seed words instead.',
      name: 'envoy_pp_restore_backup_password_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the password to decrypt the backup.`
  String get envoy_pp_restore_backup_subheading {
    return Intl.message(
      'Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the password to decrypt the backup.',
      name: 'envoy_pp_restore_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Backup File has been successfully restored`
  String get envoy_pp_restore_backup_success_heading {
    return Intl.message(
      'Your Backup File has been successfully restored',
      name: 'envoy_pp_restore_backup_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select \nRestore Seed`
  String get envoy_pp_restore_seed_heading {
    return Intl.message(
      'On Passport, select \nRestore Seed',
      name: 'envoy_pp_restore_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Use this feature to restore an existing 12 or 24 word seed.`
  String get envoy_pp_restore_seed_subheading {
    return Intl.message(
      'Use this feature to restore an existing 12 or 24 word seed.',
      name: 'envoy_pp_restore_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your seed has been successfully restored`
  String get envoy_pp_restore_seed_success_heading {
    return Intl.message(
      'Your seed has been successfully restored',
      name: 'envoy_pp_restore_seed_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get envoy_pp_setup_intro_cta1 {
    return Intl.message(
      'Create New Seed',
      name: 'envoy_pp_setup_intro_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get envoy_pp_setup_intro_cta2 {
    return Intl.message(
      'Restore Seed',
      name: 'envoy_pp_setup_intro_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get envoy_pp_setup_intro_cta3 {
    return Intl.message(
      'Restore Backup',
      name: 'envoy_pp_setup_intro_cta3',
      desc: '',
      args: [],
    );
  }

  /// `How would you like to set up your Passport?`
  String get envoy_pp_setup_intro_heading {
    return Intl.message(
      'How would you like to set up your Passport?',
      name: 'envoy_pp_setup_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `As a new owner of a Passport you can create a new seed, restore a wallet using seed words, or restore a backup from an existing Passport.`
  String get envoy_pp_setup_intro_subheading {
    return Intl.message(
      'As a new owner of a Passport you can create a new seed, restore a wallet using seed words, or restore a backup from an existing Passport.',
      name: 'envoy_pp_setup_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `First, let’s make sure your Passport is secure`
  String get envoy_scv_intro_heading {
    return Intl.message(
      'First, let’s make sure your Passport is secure',
      name: 'envoy_scv_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `This security check will ensure your Passport has not been tampered with during shipping.`
  String get envoy_scv_intro_subheading {
    return Intl.message(
      'This security check will ensure your Passport has not been tampered with during shipping.',
      name: 'envoy_scv_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get envoy_scv_result_fail_cta1 {
    return Intl.message(
      'Contact Us',
      name: 'envoy_scv_result_fail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Your Passport may be insecure`
  String get envoy_scv_result_fail_heading {
    return Intl.message(
      'Your Passport may be insecure',
      name: 'envoy_scv_result_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy could not validate the security of your Passport. Please contact us for assistance.`
  String get envoy_scv_result_fail_subheading {
    return Intl.message(
      'Envoy could not validate the security of your Passport. Please contact us for assistance.',
      name: 'envoy_scv_result_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Passport is secure`
  String get envoy_scv_result_ok_heading {
    return Intl.message(
      'Your Passport is secure',
      name: 'envoy_scv_result_ok_heading',
      desc: '',
      args: [],
    );
  }

  /// `Next, create a PIN to secure your Passport`
  String get envoy_scv_result_ok_subheading {
    return Intl.message(
      'Next, create a PIN to secure your Passport',
      name: 'envoy_scv_result_ok_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Next, scan the QR code on Passport's screen`
  String get envoy_scv_scan_qr_heading {
    return Intl.message(
      'Next, scan the QR code on Passport\'s screen',
      name: 'envoy_scv_scan_qr_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR code completes the validation and shares some Passport information with Envoy.`
  String get envoy_scv_scan_qr_subheading {
    return Intl.message(
      'This QR code completes the validation and shares some Passport information with Envoy.',
      name: 'envoy_scv_scan_qr_subheading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Envoy App and scan this QR Code`
  String get envoy_scv_show_qr_heading {
    return Intl.message(
      'On Passport, select Envoy App and scan this QR Code',
      name: 'envoy_scv_show_qr_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR code provides information for validation and setup.`
  String get envoy_scv_show_qr_subheading {
    return Intl.message(
      'This QR code provides information for validation and setup.',
      name: 'envoy_scv_show_qr_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Documentation`
  String get envoy_support_documentation {
    return Intl.message(
      'Documentation',
      name: 'envoy_support_documentation',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get envoy_support_email {
    return Intl.message(
      'Email',
      name: 'envoy_support_email',
      desc: '',
      args: [],
    );
  }

  /// `Telegram`
  String get envoy_support_telegram {
    return Intl.message(
      'Telegram',
      name: 'envoy_support_telegram',
      desc: '',
      args: [],
    );
  }

  /// `Enable Magic Backups`
  String get envoy_welcome_screen_cta1 {
    return Intl.message(
      'Enable Magic Backups',
      name: 'envoy_welcome_screen_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Manually Configure Seed Words`
  String get envoy_welcome_screen_cta2 {
    return Intl.message(
      'Manually Configure Seed Words',
      name: 'envoy_welcome_screen_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Create New Wallet`
  String get envoy_welcome_screen_heading {
    return Intl.message(
      'Create New Wallet',
      name: 'envoy_welcome_screen_heading',
      desc: '',
      args: [],
    );
  }

  /// `For a seamless setup, we recommend enabling [[Magic Backups]].\n\nAdvanced users can manually create or restore a wallet seed.`
  String get envoy_welcome_screen_subheading {
    return Intl.message(
      'For a seamless setup, we recommend enabling [[Magic Backups]].\n\nAdvanced users can manually create or restore a wallet seed.',
      name: 'envoy_welcome_screen_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Return to my Accounts`
  String get erase_wallet_with_balance_modal_CTA1 {
    return Intl.message(
      'Return to my Accounts',
      name: 'erase_wallet_with_balance_modal_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Delete Accounts anyway`
  String get erase_wallet_with_balance_modal_CTA2 {
    return Intl.message(
      'Delete Accounts anyway',
      name: 'erase_wallet_with_balance_modal_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `Before deleting your Envoy Wallet, please empty your Accounts. \nGo to Backups > Erase Wallets and Backups once you’re done.`
  String get erase_wallet_with_balance_modal_subheading {
    return Intl.message(
      'Before deleting your Envoy Wallet, please empty your Accounts. \nGo to Backups > Erase Wallets and Backups once you’re done.',
      name: 'erase_wallet_with_balance_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `This encrypted file contains useful wallet data such as labels, accounts, and settings.\n\nThis file is encrypted with your Envoy Seed. Ensure your seed is backed up securely. `
  String get export_backup_modal_subheading {
    return Intl.message(
      'This encrypted file contains useful wallet data such as labels, accounts, and settings.\n\nThis file is encrypted with your Envoy Seed. Ensure your seed is backed up securely. ',
      name: 'export_backup_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Download Backup File`
  String get export_backup_send_CTA1 {
    return Intl.message(
      'Download Backup File',
      name: 'export_backup_send_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get export_backup_send_CTA2 {
    return Intl.message(
      'Discard',
      name: 'export_backup_send_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `View as QR Code`
  String get export_seed_modal_12_words_CTA2 {
    return Intl.message(
      'View as QR Code',
      name: 'export_seed_modal_12_words_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `View Seed`
  String get export_seed_modal_QR_code_CTA2 {
    return Intl.message(
      'View Seed',
      name: 'export_seed_modal_QR_code_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `To use this QR code in Envoy on a new phone, go to Set Up Envoy Wallet > Recover Magic Backup > Recover with QR code`
  String get export_seed_modal_QR_code_subheading {
    return Intl.message(
      'To use this QR code in Envoy on a new phone, go to Set Up Envoy Wallet > Recover Magic Backup > Recover with QR code',
      name: 'export_seed_modal_QR_code_subheading',
      desc: '',
      args: [],
    );
  }

  /// `This seed is protected by a passphrase. You need these seed words and the passphrase to recover your funds.`
  String get export_seed_modal_QR_code_subheading_passphrase {
    return Intl.message(
      'This seed is protected by a passphrase. You need these seed words and the passphrase to recover your funds.',
      name: 'export_seed_modal_QR_code_subheading_passphrase',
      desc: '',
      args: [],
    );
  }

  /// `The following screen displays highly sensitive information.\n\nAnyone with access to this data can steal your Bitcoin. Proceed with extreme caution.`
  String get export_seed_modal_subheading {
    return Intl.message(
      'The following screen displays highly sensitive information.\n\nAnyone with access to this data can steal your Bitcoin. Proceed with extreme caution.',
      name: 'export_seed_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `A to Z`
  String get filter_sortBy_aToZ {
    return Intl.message(
      'A to Z',
      name: 'filter_sortBy_aToZ',
      desc: '',
      args: [],
    );
  }

  /// `Highest value`
  String get filter_sortBy_highest {
    return Intl.message(
      'Highest value',
      name: 'filter_sortBy_highest',
      desc: '',
      args: [],
    );
  }

  /// `Lowest value`
  String get filter_sortBy_lowest {
    return Intl.message(
      'Lowest value',
      name: 'filter_sortBy_lowest',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get filter_sortBy_newest {
    return Intl.message(
      'Newest first',
      name: 'filter_sortBy_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest first`
  String get filter_sortBy_oldest {
    return Intl.message(
      'Oldest first',
      name: 'filter_sortBy_oldest',
      desc: '',
      args: [],
    );
  }

  /// `Z to A`
  String get filter_sortBy_zToA {
    return Intl.message(
      'Z to A',
      name: 'filter_sortBy_zToA',
      desc: '',
      args: [],
    );
  }

  /// `BUY BITCOIN`
  String get header_buyBitcoin {
    return Intl.message(
      'BUY BITCOIN',
      name: 'header_buyBitcoin',
      desc: '',
      args: [],
    );
  }

  /// `CHOOSE ACCOUNT`
  String get header_chooseAccount {
    return Intl.message(
      'CHOOSE ACCOUNT',
      name: 'header_chooseAccount',
      desc: '',
      args: [],
    );
  }

  /// `Swipe to show and hide your balance.`
  String get hide_amount_first_time_text {
    return Intl.message(
      'Swipe to show and hide your balance.',
      name: 'hide_amount_first_time_text',
      desc: '',
      args: [],
    );
  }

  /// `Tap the above card to receive Bitcoin.`
  String get hot_wallet_accounts_creation_done_text_explainer {
    return Intl.message(
      'Tap the above card to receive Bitcoin.',
      name: 'hot_wallet_accounts_creation_done_text_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Tap any of the above cards to receive Bitcoin.`
  String
      get hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt {
    return Intl.message(
      'Tap any of the above cards to receive Bitcoin.',
      name:
          'hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get launch_screen_faceID_fail_CTA {
    return Intl.message(
      'Try Again',
      name: 'launch_screen_faceID_fail_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Failed`
  String get launch_screen_faceID_fail_heading {
    return Intl.message(
      'Authentication Failed',
      name: 'launch_screen_faceID_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please try again`
  String get launch_screen_faceID_fail_subheading {
    return Intl.message(
      'Please try again',
      name: 'launch_screen_faceID_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Locked Out`
  String get launch_screen_lockedout_heading {
    return Intl.message(
      'Locked Out',
      name: 'launch_screen_lockedout_heading',
      desc: '',
      args: [],
    );
  }

  /// `Biometric authentication is disabled. Please close the app, wait 30 seconds and try again.`
  String get launch_screen_lockedout_wait_subheading {
    return Intl.message(
      'Biometric authentication is disabled. Please close the app, wait 30 seconds and try again.',
      name: 'launch_screen_lockedout_wait_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Defender`
  String get learning_center_device_defender {
    return Intl.message(
      'Defender',
      name: 'learning_center_device_defender',
      desc: '',
      args: [],
    );
  }

  /// `Envoy`
  String get learning_center_device_envoy {
    return Intl.message(
      'Envoy',
      name: 'learning_center_device_envoy',
      desc: '',
      args: [],
    );
  }

  /// `Passport`
  String get learning_center_device_passport {
    return Intl.message(
      'Passport',
      name: 'learning_center_device_passport',
      desc: '',
      args: [],
    );
  }

  /// `Passport Prime`
  String get learning_center_device_passportPrime {
    return Intl.message(
      'Passport Prime',
      name: 'learning_center_device_passportPrime',
      desc: '',
      args: [],
    );
  }

  /// `Applied filters are hiding all search results.\nUpdate or reset filters to view more results.`
  String get learning_center_filterEmpty_subheading {
    return Intl.message(
      'Applied filters are hiding all search results.\nUpdate or reset filters to view more results.',
      name: 'learning_center_filterEmpty_subheading',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get learning_center_filter_all {
    return Intl.message(
      'All',
      name: 'learning_center_filter_all',
      desc: '',
      args: [],
    );
  }

  /// `Results`
  String get learning_center_results_title {
    return Intl.message(
      'Results',
      name: 'learning_center_results_title',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get learning_center_search_input {
    return Intl.message(
      'Search...',
      name: 'learning_center_search_input',
      desc: '',
      args: [],
    );
  }

  /// `Blog`
  String get learning_center_title_blog {
    return Intl.message(
      'Blog',
      name: 'learning_center_title_blog',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get learning_center_title_faq {
    return Intl.message(
      'FAQs',
      name: 'learning_center_title_faq',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get learning_center_title_video {
    return Intl.message(
      'Videos',
      name: 'learning_center_title_video',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get learningcenter_status_read {
    return Intl.message(
      'Read',
      name: 'learningcenter_status_read',
      desc: '',
      args: [],
    );
  }

  /// `Watched`
  String get learningcenter_status_watched {
    return Intl.message(
      'Watched',
      name: 'learningcenter_status_watched',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_generate_backup_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_generate_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as tags, notes, accounts, and settings.`
  String get magic_setup_generate_backup_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as tags, notes, accounts, and settings.',
      name: 'magic_setup_generate_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your Android backup.`
  String get magic_setup_generate_envoy_key_android_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your Android backup.',
      name: 'magic_setup_generate_envoy_key_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Seed`
  String get magic_setup_generate_envoy_key_heading {
    return Intl.message(
      'Creating Your Envoy Seed',
      name: 'magic_setup_generate_envoy_key_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.`
  String get magic_setup_generate_envoy_key_ios_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.',
      name: 'magic_setup_generate_envoy_key_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recover with QR Code`
  String get magic_setup_recovery_fail_Android_CTA2 {
    return Intl.message(
      'Recover with QR Code',
      name: 'magic_setup_recovery_fail_Android_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Google account and that you’ve restored your latest device backup.`
  String get magic_setup_recovery_fail_Android_subheading {
    return Intl.message(
      'Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Google account and that you’ve restored your latest device backup.',
      name: 'magic_setup_recovery_fail_Android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Magic Backup Not Found`
  String get magic_setup_recovery_fail_backup_heading {
    return Intl.message(
      'Magic Backup Not Found',
      name: 'magic_setup_recovery_fail_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate a Magic Backup file on the Foundation server.\n\nPlease check you’re recovering a wallet that previously used Magic Backups.`
  String get magic_setup_recovery_fail_backup_subheading {
    return Intl.message(
      'Envoy is unable to locate a Magic Backup file on the Foundation server.\n\nPlease check you’re recovering a wallet that previously used Magic Backups.',
      name: 'magic_setup_recovery_fail_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Connection Error`
  String get magic_setup_recovery_fail_connectivity_heading {
    return Intl.message(
      'Connection Error',
      name: 'magic_setup_recovery_fail_connectivity_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to connect to the Foundation server to retrieve your Magic Backup data.\n\nYou can retry, import your own Envoy Backup File, or continue without one.\n`
  String get magic_setup_recovery_fail_connectivity_subheading {
    return Intl.message(
      'Envoy is unable to connect to the Foundation server to retrieve your Magic Backup data.\n\nYou can retry, import your own Envoy Backup File, or continue without one.\n',
      name: 'magic_setup_recovery_fail_connectivity_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recovery Unsuccessful`
  String get magic_setup_recovery_fail_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_setup_recovery_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.`
  String get magic_setup_recovery_fail_ios_subheading {
    return Intl.message(
      'Envoy is unable to locate a Magic Backup.\n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.',
      name: 'magic_setup_recovery_fail_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recovering your Envoy wallet`
  String get magic_setup_recovery_retry_header {
    return Intl.message(
      'Recovering your Envoy wallet',
      name: 'magic_setup_recovery_retry_header',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Your Backup`
  String get magic_setup_send_backup_to_envoy_server_heading {
    return Intl.message(
      'Uploading Your Backup',
      name: 'magic_setup_send_backup_to_envoy_server_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_send_backup_to_envoy_server_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_send_backup_to_envoy_server_subheading',
      desc: '',
      args: [],
    );
  }

  /// `The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically backs up your wallet and settings with Android Auto Backup, 100% end-to-end encrypted. \n\n[[Learn more]].`
  String get magic_setup_tutorial_android_subheading {
    return Intl.message(
      'The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically backs up your wallet and settings with Android Auto Backup, 100% end-to-end encrypted. \n\n[[Learn more]].',
      name: 'magic_setup_tutorial_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Magic Backups`
  String get magic_setup_tutorial_heading {
    return Intl.message(
      'Magic Backups',
      name: 'magic_setup_tutorial_heading',
      desc: '',
      args: [],
    );
  }

  /// `Create Magic Backup`
  String get magic_setup_tutorial_ios_CTA1 {
    return Intl.message(
      'Create Magic Backup',
      name: 'magic_setup_tutorial_ios_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Recover Magic Backup`
  String get magic_setup_tutorial_ios_CTA2 {
    return Intl.message(
      'Recover Magic Backup',
      name: 'magic_setup_tutorial_ios_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically back up your wallet and settings with iCloud Keychain, 100% end-to-end encrypted. \n\n[[Learn more]].`
  String get magic_setup_tutorial_ios_subheading {
    return Intl.message(
      'The easiest way to create a new Bitcoin wallet while maintaining your sovereignty.\n\nMagic Backups automatically back up your wallet and settings with iCloud Keychain, 100% end-to-end encrypted. \n\n[[Learn more]].',
      name: 'magic_setup_tutorial_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `For privacy, we create a new address each time you visit this screen.`
  String get manage_account_address_card_subheading {
    return Intl.message(
      'For privacy, we create a new address each time you visit this screen.',
      name: 'manage_account_address_card_subheading',
      desc: '',
      args: [],
    );
  }

  /// `ACCOUNT DETAILS`
  String get manage_account_address_heading {
    return Intl.message(
      'ACCOUNT DETAILS',
      name: 'manage_account_address_heading',
      desc: '',
      args: [],
    );
  }

  /// `Make sure not to share this descriptor unless you are comfortable with your transactions being public.`
  String get manage_account_descriptor_subheading {
    return Intl.message(
      'Make sure not to share this descriptor unless you are comfortable with your transactions being public.',
      name: 'manage_account_descriptor_subheading',
      desc: '',
      args: [],
    );
  }

  /// `EDIT ACCOUNT NAME`
  String get manage_account_menu_editAccountName {
    return Intl.message(
      'EDIT ACCOUNT NAME',
      name: 'manage_account_menu_editAccountName',
      desc: '',
      args: [],
    );
  }

  /// `SHOW DESCRIPTOR`
  String get manage_account_menu_showDescriptor {
    return Intl.message(
      'SHOW DESCRIPTOR',
      name: 'manage_account_menu_showDescriptor',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get manage_account_remove_heading {
    return Intl.message(
      'Are you sure?',
      name: 'manage_account_remove_heading',
      desc: '',
      args: [],
    );
  }

  /// `This only removes the account from Envoy.`
  String get manage_account_remove_subheading {
    return Intl.message(
      'This only removes the account from Envoy.',
      name: 'manage_account_remove_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Rename Account`
  String get manage_account_rename_heading {
    return Intl.message(
      'Rename Account',
      name: 'manage_account_rename_heading',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disconnect Passport?\nThis will remove the device from Envoy alongside any connected accounts.`
  String get manage_device_deletePassportWarning {
    return Intl.message(
      'Are you sure you want to disconnect Passport?\nThis will remove the device from Envoy alongside any connected accounts.',
      name: 'manage_device_deletePassportWarning',
      desc: '',
      args: [],
    );
  }

  /// `Paired`
  String get manage_device_details_devicePaired {
    return Intl.message(
      'Paired',
      name: 'manage_device_details_devicePaired',
      desc: '',
      args: [],
    );
  }

  /// `Serial`
  String get manage_device_details_deviceSerial {
    return Intl.message(
      'Serial',
      name: 'manage_device_details_deviceSerial',
      desc: '',
      args: [],
    );
  }

  /// `DEVICE DETAILS`
  String get manage_device_details_heading {
    return Intl.message(
      'DEVICE DETAILS',
      name: 'manage_device_details_heading',
      desc: '',
      args: [],
    );
  }

  /// `EDIT DEVICE NAME`
  String get manage_device_details_menu_editDevice {
    return Intl.message(
      'EDIT DEVICE NAME',
      name: 'manage_device_details_menu_editDevice',
      desc: '',
      args: [],
    );
  }

  /// `Rename your Passport`
  String get manage_device_rename_modal_heading {
    return Intl.message(
      'Rename your Passport',
      name: 'manage_device_rename_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Unable to backup. Please try again later.`
  String get manualToggleOnSeed_toastHeading_failedText {
    return Intl.message(
      'Unable to backup. Please try again later.',
      name: 'manualToggleOnSeed_toastHeading_failedText',
      desc: '',
      args: [],
    );
  }

  /// `This will discard any coin selection changes. Do you want to proceed?`
  String get manual_coin_preselection_dialog_description {
    return Intl.message(
      'This will discard any coin selection changes. Do you want to proceed?',
      name: 'manual_coin_preselection_dialog_description',
      desc: '',
      args: [],
    );
  }

  /// `Choose Destination`
  String get manual_setup_create_and_store_backup_CTA {
    return Intl.message(
      'Choose Destination',
      name: 'manual_setup_create_and_store_backup_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Save Envoy Backup File`
  String get manual_setup_create_and_store_backup_heading {
    return Intl.message(
      'Save Envoy Backup File',
      name: 'manual_setup_create_and_store_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get manual_setup_create_and_store_backup_modal_CTA {
    return Intl.message(
      'I understand',
      name: 'manual_setup_create_and_store_backup_modal_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Your Envoy Backup File is encrypted by your seed words. \n\nIf you lose access to your seed words, you will be unable to recover your backup.`
  String get manual_setup_create_and_store_backup_modal_subheading {
    return Intl.message(
      'Your Envoy Backup File is encrypted by your seed words. \n\nIf you lose access to your seed words, you will be unable to recover your backup.',
      name: 'manual_setup_create_and_store_backup_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy has generated your encrypted backup. This backup contains useful wallet data such as Tags, Notes, accounts and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.`
  String get manual_setup_create_and_store_backup_subheading {
    return Intl.message(
      'Envoy has generated your encrypted backup. This backup contains useful wallet data such as Tags, Notes, accounts and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.',
      name: 'manual_setup_create_and_store_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Generate Seed`
  String get manual_setup_generate_seed_CTA {
    return Intl.message(
      'Generate Seed',
      name: 'manual_setup_generate_seed_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Keep Your Seed Private`
  String get manual_setup_generate_seed_heading {
    return Intl.message(
      'Keep Your Seed Private',
      name: 'manual_setup_generate_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Remember to always keep your seed words private. Anyone with access to this seed can spend your Bitcoin!`
  String get manual_setup_generate_seed_subheading {
    return Intl.message(
      'Remember to always keep your seed words private. Anyone with access to this seed can spend your Bitcoin!',
      name: 'manual_setup_generate_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_again_quiz_infotext {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_again_quiz_infotext',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_heading {
    return Intl.message(
      'Let’s Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_1_4_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_1_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Entry`
  String get manual_setup_generate_seed_verify_seed_quiz_fail_invalid {
    return Intl.message(
      'Invalid Entry',
      name: 'manual_setup_generate_seed_verify_seed_quiz_fail_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to verify your seed. Please confirm that you correctly recorded your seed and try again.`
  String
      get manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading {
    return Intl.message(
      'Envoy is unable to verify your seed. Please confirm that you correctly recorded your seed and try again.',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `What’s your seed word number`
  String get manual_setup_generate_seed_verify_seed_quiz_question {
    return Intl.message(
      'What’s your seed word number',
      name: 'manual_setup_generate_seed_verify_seed_quiz_question',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get manual_setup_generate_seed_verify_seed_quiz_success_correct {
    return Intl.message(
      'Correct',
      name: 'manual_setup_generate_seed_verify_seed_quiz_success_correct',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will ask you some questions to verify you correctly recorded your seed.`
  String get manual_setup_generate_seed_verify_seed_subheading {
    return Intl.message(
      'Envoy will ask you some questions to verify you correctly recorded your seed.',
      name: 'manual_setup_generate_seed_verify_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Write Down These 24 Words`
  String get manual_setup_generate_seed_write_words_24_heading {
    return Intl.message(
      'Write Down These 24 Words',
      name: 'manual_setup_generate_seed_write_words_24_heading',
      desc: '',
      args: [],
    );
  }

  /// `Write Down These 12 Words`
  String get manual_setup_generate_seed_write_words_heading {
    return Intl.message(
      'Write Down These 12 Words',
      name: 'manual_setup_generate_seed_write_words_heading',
      desc: '',
      args: [],
    );
  }

  /// `Generating Seed`
  String get manual_setup_generatingSeedLoadingInfo {
    return Intl.message(
      'Generating Seed',
      name: 'manual_setup_generatingSeedLoadingInfo',
      desc: '',
      args: [],
    );
  }

  /// `Create Envoy Backup File`
  String get manual_setup_import_backup_CTA1 {
    return Intl.message(
      'Create Envoy Backup File',
      name: 'manual_setup_import_backup_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Import Envoy Backup File`
  String get manual_setup_import_backup_CTA2 {
    return Intl.message(
      'Import Envoy Backup File',
      name: 'manual_setup_import_backup_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `We can’t read Envoy Backup`
  String get manual_setup_import_backup_fails_modal_heading {
    return Intl.message(
      'We can’t read Envoy Backup',
      name: 'manual_setup_import_backup_fails_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Make sure you have selected the right file.`
  String get manual_setup_import_backup_fails_modal_subheading {
    return Intl.message(
      'Make sure you have selected the right file.',
      name: 'manual_setup_import_backup_fails_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to restore an existing Envoy Backup file?\n\nIf not, Envoy will create a new encrypted backup file.`
  String get manual_setup_import_backup_subheading {
    return Intl.message(
      'Would you like to restore an existing Envoy Backup file?\n\nIf not, Envoy will create a new encrypted backup file.',
      name: 'manual_setup_import_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `That seed appears to be invalid. Please check the words entered, including the order they are in and try again.`
  String get manual_setup_import_seed_12_words_fail_modal_subheading {
    return Intl.message(
      'That seed appears to be invalid. Please check the words entered, including the order they are in and try again.',
      name: 'manual_setup_import_seed_12_words_fail_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_seed_12_words_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_seed_12_words_heading',
      desc: '',
      args: [],
    );
  }

  /// `Import with QR code`
  String get manual_setup_import_seed_CTA1 {
    return Intl.message(
      'Import with QR code',
      name: 'manual_setup_import_seed_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `24 Word Seed`
  String get manual_setup_import_seed_CTA2 {
    return Intl.message(
      '24 Word Seed',
      name: 'manual_setup_import_seed_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `12 Word Seed`
  String get manual_setup_import_seed_CTA3 {
    return Intl.message(
      '12 Word Seed',
      name: 'manual_setup_import_seed_CTA3',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_seed_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_seed_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Import Your Seed`
  String get manual_setup_import_seed_heading {
    return Intl.message(
      'Import Your Seed',
      name: 'manual_setup_import_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Never import your Passport seed into the following screens.`
  String get manual_setup_import_seed_passport_warning {
    return Intl.message(
      'Never import your Passport seed into the following screens.',
      name: 'manual_setup_import_seed_passport_warning',
      desc: '',
      args: [],
    );
  }

  /// `Continue below to import an existing seed.\n\nYou’ll have the option to import an Envoy Backup File later.`
  String get manual_setup_import_seed_subheading {
    return Intl.message(
      'Continue below to import an existing seed.\n\nYou’ll have the option to import an Envoy Backup File later.',
      name: 'manual_setup_import_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Magic Backup Detected`
  String get manual_setup_magicBackupDetected_heading {
    return Intl.message(
      'Magic Backup Detected',
      name: 'manual_setup_magicBackupDetected_heading',
      desc: '',
      args: [],
    );
  }

  /// `Ignore`
  String get manual_setup_magicBackupDetected_ignore {
    return Intl.message(
      'Ignore',
      name: 'manual_setup_magicBackupDetected_ignore',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get manual_setup_magicBackupDetected_restore {
    return Intl.message(
      'Restore',
      name: 'manual_setup_magicBackupDetected_restore',
      desc: '',
      args: [],
    );
  }

  /// `A Magic Backup was found on the server.  \nRestore your backup?`
  String get manual_setup_magicBackupDetected_subheading {
    return Intl.message(
      'A Magic Backup was found on the server.  \nRestore your backup?',
      name: 'manual_setup_magicBackupDetected_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Import Seed Words`
  String get manual_setup_recovery_fail_cta2 {
    return Intl.message(
      'Import Seed Words',
      name: 'manual_setup_recovery_fail_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Unable to scan QR Code`
  String get manual_setup_recovery_fail_heading {
    return Intl.message(
      'Unable to scan QR Code',
      name: 'manual_setup_recovery_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Try scanning again or manually import your seed words instead.`
  String get manual_setup_recovery_fail_subheading {
    return Intl.message(
      'Try scanning again or manually import your seed words instead.',
      name: 'manual_setup_recovery_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `If you continue without a backup file, your wallet settings, additional accounts, Tags and Notes will not be restored.`
  String
      get manual_setup_recovery_import_backup_modal_fail_connectivity_subheading {
    return Intl.message(
      'If you continue without a backup file, your wallet settings, additional accounts, Tags and Notes will not be restored.',
      name:
          'manual_setup_recovery_import_backup_modal_fail_connectivity_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Re-type Passphrase`
  String get manual_setup_recovery_import_backup_modal_fail_cta1 {
    return Intl.message(
      'Re-type Passphrase',
      name: 'manual_setup_recovery_import_backup_modal_fail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Choose other Backup File`
  String get manual_setup_recovery_import_backup_modal_fail_cta2 {
    return Intl.message(
      'Choose other Backup File',
      name: 'manual_setup_recovery_import_backup_modal_fail_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy can’t open this Envoy Backup File`
  String get manual_setup_recovery_import_backup_modal_fail_heading {
    return Intl.message(
      'Envoy can’t open this Envoy Backup File',
      name: 'manual_setup_recovery_import_backup_modal_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `This could be because you imported a backup file from a different Envoy Wallet, or because your passphrase was entered incorrectly.`
  String get manual_setup_recovery_import_backup_modal_fail_subheading {
    return Intl.message(
      'This could be because you imported a backup file from a different Envoy Wallet, or because your passphrase was entered incorrectly.',
      name: 'manual_setup_recovery_import_backup_modal_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Re-type Your \nPassphrase`
  String get manual_setup_recovery_import_backup_re_enter_passphrase_heading {
    return Intl.message(
      'Re-type Your \nPassphrase',
      name: 'manual_setup_recovery_import_backup_re_enter_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Carefully re-type your passphrase so Envoy can open your Envoy Backup File.`
  String
      get manual_setup_recovery_import_backup_re_enter_passphrase_subheading {
    return Intl.message(
      'Carefully re-type your passphrase so Envoy can open your Envoy Backup File.',
      name:
          'manual_setup_recovery_import_backup_re_enter_passphrase_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Passphrase`
  String get manual_setup_recovery_passphrase_modal_heading {
    return Intl.message(
      'Enter Your Passphrase',
      name: 'manual_setup_recovery_passphrase_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `This seed is protected by a passphrase. Enter it below to import your Envoy Wallet.`
  String get manual_setup_recovery_passphrase_modal_subheading {
    return Intl.message(
      'This seed is protected by a passphrase. Enter it below to import your Envoy Wallet.',
      name: 'manual_setup_recovery_passphrase_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Importing your Seed`
  String get manual_setup_recovery_success_heading {
    return Intl.message(
      'Importing your Seed',
      name: 'manual_setup_recovery_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Seed`
  String get manual_setup_tutorial_CTA1 {
    return Intl.message(
      'Generate New Seed',
      name: 'manual_setup_tutorial_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Import Seed`
  String get manual_setup_tutorial_CTA2 {
    return Intl.message(
      'Import Seed',
      name: 'manual_setup_tutorial_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `Manual Seed Setup`
  String get manual_setup_tutorial_heading {
    return Intl.message(
      'Manual Seed Setup',
      name: 'manual_setup_tutorial_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you prefer to manage your own seed words, continue below to import or create a new seed.\n\nPlease note that you alone will be responsible for managing backups. No cloud services will be used.`
  String get manual_setup_tutorial_subheading {
    return Intl.message(
      'If you prefer to manage your own seed words, continue below to import or create a new seed.\n\nPlease note that you alone will be responsible for managing backups. No cloud services will be used.',
      name: 'manual_setup_tutorial_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Passphrase`
  String get manual_setup_verify_enterYourPassphrase {
    return Intl.message(
      'Enter Your Passphrase',
      name: 'manual_setup_verify_enterYourPassphrase',
      desc: '',
      args: [],
    );
  }

  /// `Passphrases are case and space sensitive. Enter with care.`
  String
      get manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading {
    return Intl.message(
      'Passphrases are case and space sensitive. Enter with care.',
      name:
          'manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `[[Passphrases]] are an advanced feature.`
  String
      get manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2 {
    return Intl.message(
      '[[Passphrases]] are an advanced feature.',
      name:
          'manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2',
      desc: '',
      args: [],
    );
  }

  /// `If you do not understand the implications of using one, close this box and continue without one.\n\nFoundation has no way to recover a lost or incorrect passphrase.`
  String
      get manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading {
    return Intl.message(
      'If you do not understand the implications of using one, close this box and continue without one.\n\nFoundation has no way to recover a lost or incorrect passphrase.',
      name:
          'manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Passphrase`
  String get manual_setup_verify_seed_12_words_verify_passphrase_modal_heading {
    return Intl.message(
      'Verify Your Passphrase',
      name: 'manual_setup_verify_seed_12_words_verify_passphrase_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please carefully re-enter your passphrase.`
  String
      get manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading {
    return Intl.message(
      'Please carefully re-enter your passphrase.',
      name:
          'manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Disabled for Manual Seed Configuration `
  String get manual_toggle_off_disabled_for_manual_seed_configuration {
    return Intl.message(
      'Disabled for Manual Seed Configuration ',
      name: 'manual_toggle_off_disabled_for_manual_seed_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Download Envoy Backup File`
  String get manual_toggle_off_download_wallet_data {
    return Intl.message(
      'Download Envoy Backup File',
      name: 'manual_toggle_off_download_wallet_data',
      desc: '',
      args: [],
    );
  }

  /// `View Envoy Seed`
  String get manual_toggle_off_view_wallet_seed {
    return Intl.message(
      'View Envoy Seed',
      name: 'manual_toggle_off_view_wallet_seed',
      desc: '',
      args: [],
    );
  }

  /// `Stored in Android Auto Backup`
  String get manual_toggle_on_seed_backedup_android_stored {
    return Intl.message(
      'Stored in Android Auto Backup',
      name: 'manual_toggle_on_seed_backedup_android_stored',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Backup File`
  String get manual_toggle_on_seed_backedup_android_wallet_data {
    return Intl.message(
      'Envoy Backup File',
      name: 'manual_toggle_on_seed_backedup_android_wallet_data',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Seed`
  String get manual_toggle_on_seed_backedup_android_wallet_seed {
    return Intl.message(
      'Envoy Seed',
      name: 'manual_toggle_on_seed_backedup_android_wallet_seed',
      desc: '',
      args: [],
    );
  }

  /// `Back Up Now`
  String get manual_toggle_on_seed_backedup_iOS_backup_now {
    return Intl.message(
      'Back Up Now',
      name: 'manual_toggle_on_seed_backedup_iOS_backup_now',
      desc: '',
      args: [],
    );
  }

  /// `Stored in iCloud Keychain`
  String get manual_toggle_on_seed_backedup_iOS_stored_in_cloud {
    return Intl.message(
      'Stored in iCloud Keychain',
      name: 'manual_toggle_on_seed_backedup_iOS_stored_in_cloud',
      desc: '',
      args: [],
    );
  }

  /// `to Foundation Servers`
  String get manual_toggle_on_seed_backedup_iOS_toFoundationServers {
    return Intl.message(
      'to Foundation Servers',
      name: 'manual_toggle_on_seed_backedup_iOS_toFoundationServers',
      desc: '',
      args: [],
    );
  }

  /// `Backup in Progress`
  String get manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress {
    return Intl.message(
      'Backup in Progress',
      name: 'manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Your Envoy backup is complete.`
  String get manual_toggle_on_seed_backup_in_progress_toast_heading {
    return Intl.message(
      'Your Envoy backup is complete.',
      name: 'manual_toggle_on_seed_backup_in_progress_toast_heading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Envoy Backup`
  String get manual_toggle_on_seed_backup_now_modal_heading {
    return Intl.message(
      'Uploading Envoy Backup',
      name: 'manual_toggle_on_seed_backup_now_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `This backup contains connected devices and accounts, labels and app settings. It contains no private key information.\n\nEnvoy backups are end-to-end encrypted, Foundation has no access or knowledge of their contents. \n\nEnvoy will notify you when the upload is complete.`
  String get manual_toggle_on_seed_backup_now_modal_subheading {
    return Intl.message(
      'This backup contains connected devices and accounts, labels and app settings. It contains no private key information.\n\nEnvoy backups are end-to-end encrypted, Foundation has no access or knowledge of their contents. \n\nEnvoy will notify you when the upload is complete.',
      name: 'manual_toggle_on_seed_backup_now_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Open Android Settings`
  String get manual_toggle_on_seed_not_backedup_android_open_settings {
    return Intl.message(
      'Open Android Settings',
      name: 'manual_toggle_on_seed_not_backedup_android_open_settings',
      desc: '',
      args: [],
    );
  }

  /// `Pending Android Auto Backup (once daily)`
  String
      get manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup {
    return Intl.message(
      'Pending Android Auto Backup (once daily)',
      name:
          'manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup',
      desc: '',
      args: [],
    );
  }

  /// `Pending backup to iCloud Keychain`
  String
      get manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup {
    return Intl.message(
      'Pending backup to iCloud Keychain',
      name:
          'manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup',
      desc: '',
      args: [],
    );
  }

  /// `ABOUT`
  String get menu_about {
    return Intl.message(
      'ABOUT',
      name: 'menu_about',
      desc: '',
      args: [],
    );
  }

  /// `BACKUPS`
  String get menu_backups {
    return Intl.message(
      'BACKUPS',
      name: 'menu_backups',
      desc: '',
      args: [],
    );
  }

  /// `ENVOY`
  String get menu_heading {
    return Intl.message(
      'ENVOY',
      name: 'menu_heading',
      desc: '',
      args: [],
    );
  }

  /// `SETTINGS`
  String get menu_settings {
    return Intl.message(
      'SETTINGS',
      name: 'menu_settings',
      desc: '',
      args: [],
    );
  }

  /// `SUPPORT`
  String get menu_support {
    return Intl.message(
      'SUPPORT',
      name: 'menu_support',
      desc: '',
      args: [],
    );
  }

  /// `Connect Passport\nwith Envoy`
  String get pair_existing_device_intro_heading {
    return Intl.message(
      'Connect Passport\nwith Envoy',
      name: 'pair_existing_device_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Manage Account > Connect Wallet > Envoy.`
  String get pair_existing_device_intro_subheading {
    return Intl.message(
      'On Passport, select Manage Account > Connect Wallet > Envoy.',
      name: 'pair_existing_device_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to validate`
  String get pair_new_device_QR_code_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate',
      name: 'pair_new_device_QR_code_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is a Bitcoin address belonging to your Passport.`
  String get pair_new_device_QR_code_subheading {
    return Intl.message(
      'This is a Bitcoin address belonging to your Passport.',
      name: 'pair_new_device_QR_code_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get pair_new_device_address_cta2 {
    return Intl.message(
      'Contact Support',
      name: 'pair_new_device_address_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Address validated?`
  String get pair_new_device_address_heading {
    return Intl.message(
      'Address validated?',
      name: 'pair_new_device_address_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get pair_new_device_address_subheading {
    return Intl.message(
      'If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'pair_new_device_address_subheading',
      desc: '',
      args: [],
    );
  }

  /// `This step allows Envoy to generate receive addresses for Passport and propose spend transactions that Passport must authorize. `
  String get pair_new_device_intro_connect_envoy_subheading {
    return Intl.message(
      'This step allows Envoy to generate receive addresses for Passport and propose spend transactions that Passport must authorize. ',
      name: 'pair_new_device_intro_connect_envoy_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code that Passport generates`
  String get pair_new_device_scan_heading {
    return Intl.message(
      'Scan the QR code that Passport generates',
      name: 'pair_new_device_scan_heading',
      desc: '',
      args: [],
    );
  }

  /// `The QR code contains the information required for Envoy to interact securely with Passport.`
  String get pair_new_device_scan_subheading {
    return Intl.message(
      'The QR code contains the information required for Envoy to interact securely with Passport.',
      name: 'pair_new_device_scan_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Validate receive address`
  String get pair_new_device_success_cta1 {
    return Intl.message(
      'Validate receive address',
      name: 'pair_new_device_success_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Continue to home screen`
  String get pair_new_device_success_cta2 {
    return Intl.message(
      'Continue to home screen',
      name: 'pair_new_device_success_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Connection successful`
  String get pair_new_device_success_heading {
    return Intl.message(
      'Connection successful',
      name: 'pair_new_device_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is now connected to your Passport.`
  String get pair_new_device_success_subheading {
    return Intl.message(
      'Envoy is now connected to your Passport.',
      name: 'pair_new_device_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get passport_welcome_screen_cta1 {
    return Intl.message(
      'Set up a new Passport',
      name: 'passport_welcome_screen_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get passport_welcome_screen_cta2 {
    return Intl.message(
      'Connect an existing Passport',
      name: 'passport_welcome_screen_cta2',
      desc: '',
      args: [],
    );
  }

  /// `I don’t have a Passport. [[Learn more.]]`
  String get passport_welcome_screen_cta3 {
    return Intl.message(
      'I don’t have a Passport. [[Learn more.]]',
      name: 'passport_welcome_screen_cta3',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Passport`
  String get passport_welcome_screen_heading {
    return Intl.message(
      'Welcome to Passport',
      name: 'passport_welcome_screen_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get passport_welcome_screen_subheading {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'passport_welcome_screen_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Node Connected`
  String get privacySetting_nodeConnected {
    return Intl.message(
      'Node Connected',
      name: 'privacySetting_nodeConnected',
      desc: '',
      args: [],
    );
  }

  /// `Application lock`
  String get privacy_applicationLock_title {
    return Intl.message(
      'Application lock',
      name: 'privacy_applicationLock_title',
      desc: '',
      args: [],
    );
  }

  /// `Unlock with biometrics or PIN`
  String get privacy_applicationLock_unlock {
    return Intl.message(
      'Unlock with biometrics or PIN',
      name: 'privacy_applicationLock_unlock',
      desc: '',
      args: [],
    );
  }

  /// `Improve your privacy by running your own node. Tap learn more above. `
  String get privacy_node_configure {
    return Intl.message(
      'Improve your privacy by running your own node. Tap learn more above. ',
      name: 'privacy_node_configure',
      desc: '',
      args: [],
    );
  }

  /// `Connected to`
  String get privacy_node_connectedTo {
    return Intl.message(
      'Connected to',
      name: 'privacy_node_connectedTo',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't reach node.`
  String get privacy_node_connection_couldNotReach {
    return Intl.message(
      'Couldn\'t reach node.',
      name: 'privacy_node_connection_couldNotReach',
      desc: '',
      args: [],
    );
  }

  /// `Even with ‘Improved Privacy’ active, Envoy cannot prevent interference by compromised devices on your local network.`
  String get privacy_node_connection_localAddress_warning {
    return Intl.message(
      'Even with ‘Improved Privacy’ active, Envoy cannot prevent interference by compromised devices on your local network.',
      name: 'privacy_node_connection_localAddress_warning',
      desc: '',
      args: [],
    );
  }

  /// `Enter your node address`
  String get privacy_node_nodeAddress {
    return Intl.message(
      'Enter your node address',
      name: 'privacy_node_nodeAddress',
      desc: '',
      args: [],
    );
  }

  /// `Foundation (Default)`
  String get privacy_node_nodeType_foundation {
    return Intl.message(
      'Foundation (Default)',
      name: 'privacy_node_nodeType_foundation',
      desc: '',
      args: [],
    );
  }

  /// `Personal Node`
  String get privacy_node_nodeType_personal {
    return Intl.message(
      'Personal Node',
      name: 'privacy_node_nodeType_personal',
      desc: '',
      args: [],
    );
  }

  /// `Node`
  String get privacy_node_title {
    return Intl.message(
      'Node',
      name: 'privacy_node_title',
      desc: '',
      args: [],
    );
  }

  /// `Better \nPerformance`
  String get privacy_privacyMode_betterPerformance {
    return Intl.message(
      'Better \nPerformance',
      name: 'privacy_privacyMode_betterPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Improved Privacy`
  String get privacy_privacyMode_improvedPrivacy {
    return Intl.message(
      'Improved Privacy',
      name: 'privacy_privacyMode_improvedPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Privacy mode`
  String get privacy_privacyMode_title {
    return Intl.message(
      'Privacy mode',
      name: 'privacy_privacyMode_title',
      desc: '',
      args: [],
    );
  }

  /// `Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users.`
  String get privacy_privacyMode_torSuggestionOff {
    return Intl.message(
      'Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users.',
      name: 'privacy_privacyMode_torSuggestionOff',
      desc: '',
      args: [],
    );
  }

  /// `Tor will be turned [[ON]] for improved privacy. Envoy’s connection may be unreliable.`
  String get privacy_privacyMode_torSuggestionOn {
    return Intl.message(
      'Tor will be turned [[ON]] for improved privacy. Envoy’s connection may be unreliable.',
      name: 'privacy_privacyMode_torSuggestionOn',
      desc: '',
      args: [],
    );
  }

  /// `Add Node`
  String get privacy_setting_add_node_modal_heading {
    return Intl.message(
      'Add Node',
      name: 'privacy_setting_add_node_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Edit Node`
  String get privacy_setting_clearnet_node_edit_note {
    return Intl.message(
      'Edit Node',
      name: 'privacy_setting_clearnet_node_edit_note',
      desc: '',
      args: [],
    );
  }

  /// `Your Node is connected via Clearnet.`
  String get privacy_setting_clearnet_node_subheading {
    return Intl.message(
      'Your Node is connected via Clearnet.',
      name: 'privacy_setting_clearnet_node_subheading',
      desc: '',
      args: [],
    );
  }

  /// `We couldn’t connect your node`
  String get privacy_setting_connecting_node_fails_modal_failed {
    return Intl.message(
      'We couldn’t connect your node',
      name: 'privacy_setting_connecting_node_fails_modal_failed',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get privacy_setting_connecting_node_modal_cta {
    return Intl.message(
      'Connect',
      name: 'privacy_setting_connecting_node_modal_cta',
      desc: '',
      args: [],
    );
  }

  /// `Connecting Your Node`
  String get privacy_setting_connecting_node_modal_loading {
    return Intl.message(
      'Connecting Your Node',
      name: 'privacy_setting_connecting_node_modal_loading',
      desc: '',
      args: [],
    );
  }

  /// `Your Node is connected via Tor.`
  String get privacy_setting_onion_node_sbheading {
    return Intl.message(
      'Your Node is connected via Tor.',
      name: 'privacy_setting_onion_node_sbheading',
      desc: '',
      args: [],
    );
  }

  /// `Choose Your Privacy`
  String get privacy_setting_perfomance_heading {
    return Intl.message(
      'Choose Your Privacy',
      name: 'privacy_setting_perfomance_heading',
      desc: '',
      args: [],
    );
  }

  /// `How would you like Envoy to connect to the Internet?`
  String get privacy_setting_perfomance_subheading {
    return Intl.message(
      'How would you like Envoy to connect to the Internet?',
      name: 'privacy_setting_perfomance_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Use Taproot Address`
  String get receive_QR_code_receive_QR_code_taproot_on_taproot_toggle {
    return Intl.message(
      'Use Taproot Address',
      name: 'receive_QR_code_receive_QR_code_taproot_on_taproot_toggle',
      desc: '',
      args: [],
    );
  }

  /// `RECEIVE`
  String get receive_qr_code_heading {
    return Intl.message(
      'RECEIVE',
      name: 'receive_qr_code_heading',
      desc: '',
      args: [],
    );
  }

  /// `Awaiting confirmation`
  String get receive_tx_list_awaitingConfirmation {
    return Intl.message(
      'Awaiting confirmation',
      name: 'receive_tx_list_awaitingConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get receive_tx_list_receive {
    return Intl.message(
      'Receive',
      name: 'receive_tx_list_receive',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get receive_tx_list_send {
    return Intl.message(
      'Send',
      name: 'receive_tx_list_send',
      desc: '',
      args: [],
    );
  }

  /// `Sign into Google and restore your backup data`
  String get recovery_scenario_Android_instruction1 {
    return Intl.message(
      'Sign into Google and restore your backup data',
      name: 'recovery_scenario_Android_instruction1',
      desc: '',
      args: [],
    );
  }

  /// `How to Recover?`
  String get recovery_scenario_heading {
    return Intl.message(
      'How to Recover?',
      name: 'recovery_scenario_heading',
      desc: '',
      args: [],
    );
  }

  /// `Install Envoy and tap “Set Up Envoy Wallet”`
  String get recovery_scenario_instruction2 {
    return Intl.message(
      'Install Envoy and tap “Set Up Envoy Wallet”',
      name: 'recovery_scenario_instruction2',
      desc: '',
      args: [],
    );
  }

  /// `Sign into iCloud and restore your iCloud backup`
  String get recovery_scenario_ios_instruction1 {
    return Intl.message(
      'Sign into iCloud and restore your iCloud backup',
      name: 'recovery_scenario_ios_instruction1',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically restore your Magic Backup`
  String get recovery_scenario_ios_instruction3 {
    return Intl.message(
      'Envoy will then automatically restore your Magic Backup',
      name: 'recovery_scenario_ios_instruction3',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Envoy wallet, follow these simple instructions.`
  String get recovery_scenario_subheading {
    return Intl.message(
      'To recover your Envoy wallet, follow these simple instructions.',
      name: 'recovery_scenario_subheading',
      desc: '',
      args: [],
    );
  }

  /// `The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. `
  String get replaceByFee_boost_chosenFeeAddCoinsWarning {
    return Intl.message(
      'The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. ',
      name: 'replaceByFee_boost_chosenFeeAddCoinsWarning',
      desc: '',
      args: [],
    );
  }

  /// `Boosting transaction`
  String get replaceByFee_boost_confirm_heading {
    return Intl.message(
      'Boosting transaction',
      name: 'replaceByFee_boost_confirm_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction could not be boosted`
  String get replaceByFee_boost_fail_header {
    return Intl.message(
      'Your transaction could not be boosted',
      name: 'replaceByFee_boost_fail_header',
      desc: '',
      args: [],
    );
  }

  /// `Review Coin Selection`
  String get replaceByFee_boost_reviewCoinSelection {
    return Intl.message(
      'Review Coin Selection',
      name: 'replaceByFee_boost_reviewCoinSelection',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction has been boosted`
  String get replaceByFee_boost_success_header {
    return Intl.message(
      'Your transaction has been boosted',
      name: 'replaceByFee_boost_success_header',
      desc: '',
      args: [],
    );
  }

  /// `Boost Fee`
  String get replaceByFee_boost_tx_boostFee {
    return Intl.message(
      'Boost Fee',
      name: 'replaceByFee_boost_tx_boostFee',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction is ready \nto be boosted`
  String get replaceByFee_boost_tx_heading {
    return Intl.message(
      'Your transaction is ready \nto be boosted',
      name: 'replaceByFee_boost_tx_heading',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get replaceByFee_cancelAmountNone_None {
    return Intl.message(
      'None',
      name: 'replaceByFee_cancelAmountNone_None',
      desc: '',
      args: [],
    );
  }

  /// `The network fee for cancelling this transaction means no funds will be sent back to your wallet.\n\nAre you sure you want to cancel?`
  String get replaceByFee_cancelAmountNone_overlay_modal_subheading {
    return Intl.message(
      'The network fee for cancelling this transaction means no funds will be sent back to your wallet.\n\nAre you sure you want to cancel?',
      name: 'replaceByFee_cancelAmountNone_overlay_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Canceling transaction`
  String get replaceByFee_cancel_confirm_heading {
    return Intl.message(
      'Canceling transaction',
      name: 'replaceByFee_cancel_confirm_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction could not be canceled`
  String get replaceByFee_cancel_fail_heading {
    return Intl.message(
      'Your transaction could not be canceled',
      name: 'replaceByFee_cancel_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Cancellation Fee`
  String get replaceByFee_cancel_overlay_modal_cancelationFees {
    return Intl.message(
      'Cancellation Fee',
      name: 'replaceByFee_cancel_overlay_modal_cancelationFees',
      desc: '',
      args: [],
    );
  }

  /// `Proceed with Cancellation`
  String get replaceByFee_cancel_overlay_modal_proceedWithCancelation {
    return Intl.message(
      'Proceed with Cancellation',
      name: 'replaceByFee_cancel_overlay_modal_proceedWithCancelation',
      desc: '',
      args: [],
    );
  }

  /// `Receiving Amount`
  String get replaceByFee_cancel_overlay_modal_receivingAmount {
    return Intl.message(
      'Receiving Amount',
      name: 'replaceByFee_cancel_overlay_modal_receivingAmount',
      desc: '',
      args: [],
    );
  }

  /// `Replace the unconfirmed transaction with one that contains a higher fee and sends the funds back to your wallet.`
  String get replaceByFee_cancel_overlay_modal_subheading {
    return Intl.message(
      'Replace the unconfirmed transaction with one that contains a higher fee and sends the funds back to your wallet.',
      name: 'replaceByFee_cancel_overlay_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction has been canceled`
  String get replaceByFee_cancel_success_heading {
    return Intl.message(
      'Your transaction has been canceled',
      name: 'replaceByFee_cancel_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is a cancellation attempt. There is a slight chance your original transaction is confirmed before this cancellation attempt.`
  String get replaceByFee_cancel_success_subheading {
    return Intl.message(
      'This is a cancellation attempt. There is a slight chance your original transaction is confirmed before this cancellation attempt.',
      name: 'replaceByFee_cancel_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Boost`
  String get replaceByFee_coindetails_overlay_boost {
    return Intl.message(
      'Boost',
      name: 'replaceByFee_coindetails_overlay_boost',
      desc: '',
      args: [],
    );
  }

  /// `Boost Transaction`
  String get replaceByFee_coindetails_overlay_modal_heading {
    return Intl.message(
      'Boost Transaction',
      name: 'replaceByFee_coindetails_overlay_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Increase the fee attached to your transaction to speed up confirmation time.`
  String get replaceByFee_coindetails_overlay_modal_subheading {
    return Intl.message(
      'Increase the fee attached to your transaction to speed up confirmation time.',
      name: 'replaceByFee_coindetails_overlay_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Required to Boost`
  String get replaceByFee_edit_transaction_requiredAmount {
    return Intl.message(
      'Required to Boost',
      name: 'replaceByFee_edit_transaction_requiredAmount',
      desc: '',
      args: [],
    );
  }

  /// `The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. `
  String get replaceByFee_warning_extraUTXO_overlay_modal_subheading {
    return Intl.message(
      'The chosen fee can only be achieved by adding more coins. Envoy does this automatically and will never include any locked coins. ',
      name: 'replaceByFee_warning_extraUTXO_overlay_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get send_keyboard_address_confirm {
    return Intl.message(
      'Confirm',
      name: 'send_keyboard_address_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get send_keyboard_address_loading {
    return Intl.message(
      'Loading...',
      name: 'send_keyboard_address_loading',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid address`
  String get send_keyboard_amount_enter_valid_address {
    return Intl.message(
      'Enter valid address',
      name: 'send_keyboard_amount_enter_valid_address',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient funds`
  String get send_keyboard_amount_insufficient_funds_info {
    return Intl.message(
      'Insufficient funds',
      name: 'send_keyboard_amount_insufficient_funds_info',
      desc: '',
      args: [],
    );
  }

  /// `Amount too low`
  String get send_keyboard_amount_too_low_info {
    return Intl.message(
      'Amount too low',
      name: 'send_keyboard_amount_too_low_info',
      desc: '',
      args: [],
    );
  }

  /// `Send Max`
  String get send_keyboard_send_max {
    return Intl.message(
      'Send Max',
      name: 'send_keyboard_send_max',
      desc: '',
      args: [],
    );
  }

  /// `To:`
  String get send_keyboard_to {
    return Intl.message(
      'To:',
      name: 'send_keyboard_to',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR with your Passport`
  String get send_qr_code_card_heading {
    return Intl.message(
      'Scan the QR with your Passport',
      name: 'send_qr_code_card_heading',
      desc: '',
      args: [],
    );
  }

  /// `It contains the transaction for your Passport to sign.`
  String get send_qr_code_card_subheading {
    return Intl.message(
      'It contains the transaction for your Passport to sign.',
      name: 'send_qr_code_card_subheading',
      desc: '',
      args: [],
    );
  }

  /// `You can now scan the QR code displayed on your Passport with your phone camera.`
  String get send_qr_code_subheading {
    return Intl.message(
      'You can now scan the QR code displayed on your Passport with your phone camera.',
      name: 'send_qr_code_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Sending Max: \nFees are deducted from amount being sent.`
  String get send_reviewScreen_sendMaxWarning {
    return Intl.message(
      'Sending Max: \nFees are deducted from amount being sent.',
      name: 'send_reviewScreen_sendMaxWarning',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get settings_advanced {
    return Intl.message(
      'Advanced',
      name: 'settings_advanced',
      desc: '',
      args: [],
    );
  }

  /// `Learn how to do that [[here]].`
  String get settings_advanced_enabled_testnet_modal_link {
    return Intl.message(
      'Learn how to do that [[here]].',
      name: 'settings_advanced_enabled_testnet_modal_link',
      desc: '',
      args: [],
    );
  }

  /// `Enabling Testnet adds a Testnet version of your Envoy Wallet, and allows you to connect Testnet accounts from your Passport.`
  String get settings_advanced_enabled_testnet_modal_subheading {
    return Intl.message(
      'Enabling Testnet adds a Testnet version of your Envoy Wallet, and allows you to connect Testnet accounts from your Passport.',
      name: 'settings_advanced_enabled_testnet_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Taproot`
  String get settings_advanced_taproot {
    return Intl.message(
      'Taproot',
      name: 'settings_advanced_taproot',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get settings_advanced_taproot_modal_cta1 {
    return Intl.message(
      'Activate',
      name: 'settings_advanced_taproot_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Taproot is an advanced feature and wallet support is still limited.\n\nProceed with caution.`
  String get settings_advanced_taproot_modal_subheading {
    return Intl.message(
      'Taproot is an advanced feature and wallet support is still limited.\n\nProceed with caution.',
      name: 'settings_advanced_taproot_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Testnet`
  String get settings_advanced_testnet {
    return Intl.message(
      'Testnet',
      name: 'settings_advanced_testnet',
      desc: '',
      args: [],
    );
  }

  /// `View Amount in Sats`
  String get settings_amount {
    return Intl.message(
      'View Amount in Sats',
      name: 'settings_amount',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get settings_currency {
    return Intl.message(
      'Currency',
      name: 'settings_currency',
      desc: '',
      args: [],
    );
  }

  /// `Display Fiat Values`
  String get settings_show_fiat {
    return Intl.message(
      'Display Fiat Values',
      name: 'settings_show_fiat',
      desc: '',
      args: [],
    );
  }

  /// `View Envoy Logs`
  String get settings_viewEnvoyLogs {
    return Intl.message(
      'View Envoy Logs',
      name: 'settings_viewEnvoyLogs',
      desc: '',
      args: [],
    );
  }

  /// `No thanks`
  String get stalls_before_sending_tx_add_note_modal_cta2 {
    return Intl.message(
      'No thanks',
      name: 'stalls_before_sending_tx_add_note_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Transaction notes can be useful when making future spends.`
  String get stalls_before_sending_tx_add_note_modal_subheading {
    return Intl.message(
      'Transaction notes can be useful when making future spends.',
      name: 'stalls_before_sending_tx_add_note_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction couldn’t be sent`
  String get stalls_before_sending_tx_scanning_broadcasting_fail_heading {
    return Intl.message(
      'Your transaction couldn’t be sent',
      name: 'stalls_before_sending_tx_scanning_broadcasting_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please check your connection and try again`
  String get stalls_before_sending_tx_scanning_broadcasting_fail_subheading {
    return Intl.message(
      'Please check your connection and try again',
      name: 'stalls_before_sending_tx_scanning_broadcasting_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your transaction was successfully sent`
  String get stalls_before_sending_tx_scanning_broadcasting_success_heading {
    return Intl.message(
      'Your transaction was successfully sent',
      name: 'stalls_before_sending_tx_scanning_broadcasting_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Review the details by tapping on the transaction from the account details screen.`
  String get stalls_before_sending_tx_scanning_broadcasting_success_subheading {
    return Intl.message(
      'Review the details by tapping on the transaction from the account details screen.',
      name: 'stalls_before_sending_tx_scanning_broadcasting_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Sending transaction`
  String get stalls_before_sending_tx_scanning_heading {
    return Intl.message(
      'Sending transaction',
      name: 'stalls_before_sending_tx_scanning_heading',
      desc: '',
      args: [],
    );
  }

  /// `This might take a few seconds`
  String get stalls_before_sending_tx_scanning_subheading {
    return Intl.message(
      'This might take a few seconds',
      name: 'stalls_before_sending_tx_scanning_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Edit Tag Name`
  String get tagDetails_EditTagName {
    return Intl.message(
      'Edit Tag Name',
      name: 'tagDetails_EditTagName',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get tagSelection_example1 {
    return Intl.message(
      'Expenses',
      name: 'tagSelection_example1',
      desc: '',
      args: [],
    );
  }

  /// `Personal`
  String get tagSelection_example2 {
    return Intl.message(
      'Personal',
      name: 'tagSelection_example2',
      desc: '',
      args: [],
    );
  }

  /// `Savings`
  String get tagSelection_example3 {
    return Intl.message(
      'Savings',
      name: 'tagSelection_example3',
      desc: '',
      args: [],
    );
  }

  /// `Donations`
  String get tagSelection_example4 {
    return Intl.message(
      'Donations',
      name: 'tagSelection_example4',
      desc: '',
      args: [],
    );
  }

  /// `Travel`
  String get tagSelection_example5 {
    return Intl.message(
      'Travel',
      name: 'tagSelection_example5',
      desc: '',
      args: [],
    );
  }

  /// `Discard Changes`
  String get tagged_coin_details_inputs_fails_cta2 {
    return Intl.message(
      'Discard Changes',
      name: 'tagged_coin_details_inputs_fails_cta2',
      desc: '',
      args: [],
    );
  }

  /// `EDIT TAG NAME`
  String get tagged_coin_details_menu_cta1 {
    return Intl.message(
      'EDIT TAG NAME',
      name: 'tagged_coin_details_menu_cta1',
      desc: '',
      args: [],
    );
  }

  /// `There are no coins assigned to this tag.`
  String get tagged_tagDetails_emptyState_explainer {
    return Intl.message(
      'There are no coins assigned to this tag.',
      name: 'tagged_tagDetails_emptyState_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Send Selected`
  String get tagged_tagDetails_sheet_cta1 {
    return Intl.message(
      'Send Selected',
      name: 'tagged_tagDetails_sheet_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Tag Selected`
  String get tagged_tagDetails_sheet_cta2 {
    return Intl.message(
      'Tag Selected',
      name: 'tagged_tagDetails_sheet_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Retag Selected`
  String get tagged_tagDetails_sheet_retag_cta2 {
    return Intl.message(
      'Retag Selected',
      name: 'tagged_tagDetails_sheet_retag_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Hold to drag and reorder your accounts.`
  String get tap_and_drag_first_time_text {
    return Intl.message(
      'Hold to drag and reorder your accounts.',
      name: 'tap_and_drag_first_time_text',
      desc: '',
      args: [],
    );
  }

  /// `Taproot on Passport`
  String get taproot_passport_dialog_heading {
    return Intl.message(
      'Taproot on Passport',
      name: 'taproot_passport_dialog_heading',
      desc: '',
      args: [],
    );
  }

  /// `Do It Later`
  String get taproot_passport_dialog_later {
    return Intl.message(
      'Do It Later',
      name: 'taproot_passport_dialog_later',
      desc: '',
      args: [],
    );
  }

  /// `Reconnect Passport`
  String get taproot_passport_dialog_reconnect {
    return Intl.message(
      'Reconnect Passport',
      name: 'taproot_passport_dialog_reconnect',
      desc: '',
      args: [],
    );
  }

  /// `To enable a Passport Taproot account, ensure you are running firmware 2.3.0 or later and reconnect your Passport.`
  String get taproot_passport_dialog_subheading {
    return Intl.message(
      'To enable a Passport Taproot account, ensure you are running firmware 2.3.0 or later and reconnect your Passport.',
      name: 'taproot_passport_dialog_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Foundation servers are not reachable`
  String get toast_foundationServersDown {
    return Intl.message(
      'Foundation servers are not reachable',
      name: 'toast_foundationServersDown',
      desc: '',
      args: [],
    );
  }

  /// `New Envoy update available`
  String get toast_newEnvoyUpdateAvailable {
    return Intl.message(
      'New Envoy update available',
      name: 'toast_newEnvoyUpdateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Retry Tor Connection`
  String get torToast_learnMore_retryTorConnection {
    return Intl.message(
      'Retry Tor Connection',
      name: 'torToast_learnMore_retryTorConnection',
      desc: '',
      args: [],
    );
  }

  /// `Temporarily Disable Tor`
  String get torToast_learnMore_temporarilyDisableTor {
    return Intl.message(
      'Temporarily Disable Tor',
      name: 'torToast_learnMore_temporarilyDisableTor',
      desc: '',
      args: [],
    );
  }

  /// `You may experience degraded app performance until Envoy can re-establish a connection to Tor.\n\nDisabling Tor will establish a direct connection with the Envoy server, but comes with privacy [[tradeoffs]].`
  String get torToast_learnMore_warningBody {
    return Intl.message(
      'You may experience degraded app performance until Envoy can re-establish a connection to Tor.\n\nDisabling Tor will establish a direct connection with the Envoy server, but comes with privacy [[tradeoffs]].',
      name: 'torToast_learnMore_warningBody',
      desc: '',
      args: [],
    );
  }

  /// `Issue establishing Tor connectivity`
  String get tor_connectivity_toast_warning {
    return Intl.message(
      'Issue establishing Tor connectivity',
      name: 'tor_connectivity_toast_warning',
      desc: '',
      args: [],
    );
  }

  /// `Envoy securely and automatically backs up your wallet seed with [[Android Auto Backup]].\n\nYour seed is always end-to-end encrypted and is never visible to Google.`
  String get wallet_security_modal_1_4_android_subheading {
    return Intl.message(
      'Envoy securely and automatically backs up your wallet seed with [[Android Auto Backup]].\n\nYour seed is always end-to-end encrypted and is never visible to Google.',
      name: 'wallet_security_modal_1_4_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy securely and automatically backs up your wallet seed to [[iCloud Keychain.]]\n\nYour seed is always end-to-end encrypted and is never visible to Apple.`
  String get wallet_security_modal_1_4_ios_subheading {
    return Intl.message(
      'Envoy securely and automatically backs up your wallet seed to [[iCloud Keychain.]]\n\nYour seed is always end-to-end encrypted and is never visible to Apple.',
      name: 'wallet_security_modal_1_4_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet data – including tags, notes, accounts and settings – is automatically backed up to Foundation servers.\n\nThis backup is first encrypted with your wallet seed, ensuring that Foundation can never access your data.`
  String get wallet_security_modal_2_4_subheading {
    return Intl.message(
      'Your wallet data – including tags, notes, accounts and settings – is automatically backed up to Foundation servers.\n\nThis backup is first encrypted with your wallet seed, ensuring that Foundation can never access your data.',
      name: 'wallet_security_modal_2_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `To recover your wallet, simply log into your Google account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your Google account with a strong password and 2FA.`
  String get wallet_security_modal_3_4_android_subheading {
    return Intl.message(
      'To recover your wallet, simply log into your Google account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your Google account with a strong password and 2FA.',
      name: 'wallet_security_modal_3_4_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `To recover your wallet, simply log into your iCloud account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your iCloud account with a strong password and 2FA.`
  String get wallet_security_modal_3_4_ios_subheading {
    return Intl.message(
      'To recover your wallet, simply log into your iCloud account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your iCloud account with a strong password and 2FA.',
      name: 'wallet_security_modal_3_4_ios_subheading',
      desc: '',
      args: [],
    );
  }

  /// `How Your Data is Secured`
  String get wallet_security_modal_4_4_heading {
    return Intl.message(
      'How Your Data is Secured',
      name: 'wallet_security_modal_4_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you prefer to opt out of Magic Backups and instead manually secure your wallet seed and data, no problem!\n\nSimply head back to the setup screen and choose Manually Configure Seed Words.`
  String get wallet_security_modal_4_4_subheading {
    return Intl.message(
      'If you prefer to opt out of Magic Backups and instead manually secure your wallet seed and data, no problem!\n\nSimply head back to the setup screen and choose Manually Configure Seed Words.',
      name: 'wallet_security_modal_4_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `How Your Wallet is Secured`
  String get wallet_security_modal_HowYourWalletIsSecured {
    return Intl.message(
      'How Your Wallet is Secured',
      name: 'wallet_security_modal_HowYourWalletIsSecured',
      desc: '',
      args: [],
    );
  }

  /// `Security Tip`
  String get wallet_security_modal__heading {
    return Intl.message(
      'Security Tip',
      name: 'wallet_security_modal__heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is storing more than the recommended amount of Bitcoin for a mobile, internet connected wallet.\n\nFor ultra-secure, offline storage, Foundation suggests Passport hardware wallet.`
  String get wallet_security_modal_subheading {
    return Intl.message(
      'Envoy is storing more than the recommended amount of Bitcoin for a mobile, internet connected wallet.\n\nFor ultra-secure, offline storage, Foundation suggests Passport hardware wallet.',
      name: 'wallet_security_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Wallet Is Ready`
  String get wallet_setup_success_heading {
    return Intl.message(
      'Your Wallet Is Ready',
      name: 'wallet_setup_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is set up and ready for your Bitcoin!`
  String get wallet_setup_success_subheading {
    return Intl.message(
      'Envoy is set up and ready for your Bitcoin!',
      name: 'wallet_setup_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Set Up Envoy Wallet`
  String get welcome_screen_ctA1 {
    return Intl.message(
      'Set Up Envoy Wallet',
      name: 'welcome_screen_ctA1',
      desc: '',
      args: [],
    );
  }

  /// `Manage Passport`
  String get welcome_screen_cta2 {
    return Intl.message(
      'Manage Passport',
      name: 'welcome_screen_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Envoy`
  String get welcome_screen_heading {
    return Intl.message(
      'Welcome to Envoy',
      name: 'welcome_screen_heading',
      desc: '',
      args: [],
    );
  }

  /// `Reclaim your sovereignty with Envoy, a simple Bitcoin wallet with powerful account management and privacy features.`
  String get welcome_screen_subheading {
    return Intl.message(
      'Reclaim your sovereignty with Envoy, a simple Bitcoin wallet with powerful account management and privacy features.',
      name: 'welcome_screen_subheading',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'ko-KR'),
      Locale.fromSubtags(languageCode: 'pt'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
