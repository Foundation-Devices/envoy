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

  /// `OK`
  String get OK {
    return Intl.message(
      'OK',
      name: 'OK',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get Sent {
    return Intl.message(
      'Sent',
      name: 'Sent',
      desc: '',
      args: [],
    );
  }

  /// `Watched`
  String get Watched {
    return Intl.message(
      'Watched',
      name: 'Watched',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get _ {
    return Intl.message(
      'Continue',
      name: '_',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get account_details_filter_tags_applyFilters {
    return Intl.message(
      'Apply',
      name: 'account_details_filter_tags_applyFilters',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get account_details_filter_tags_filter {
    return Intl.message(
      'Filter',
      name: 'account_details_filter_tags_filter',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get account_details_filter_tags_received {
    return Intl.message(
      'Received',
      name: 'account_details_filter_tags_received',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get account_details_filter_tags_resetFilter {
    return Intl.message(
      'Reset',
      name: 'account_details_filter_tags_resetFilter',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get account_details_filter_tags_resetSorting {
    return Intl.message(
      'Reset',
      name: 'account_details_filter_tags_resetSorting',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get account_details_filter_tags_sent {
    return Intl.message(
      'Sent',
      name: 'account_details_filter_tags_sent',
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

  /// `Mobile Wallet`
  String get accounts_screen_walletType_defaultName {
    return Intl.message(
      'Mobile Wallet',
      name: 'accounts_screen_walletType_defaultName',
      desc: '',
      args: [],
    );
  }

  /// `Envoy`
  String get accounts_screen_walletType_mobile {
    return Intl.message(
      'Envoy',
      name: 'accounts_screen_walletType_mobile',
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

  /// `Firmware update available`
  String get activity_firmwareUpdate {
    return Intl.message(
      'Firmware update available',
      name: 'activity_firmwareUpdate',
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

  /// `Save`
  String get add_note_modal_cta {
    return Intl.message(
      'Save',
      name: 'add_note_modal_cta',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get add_note_modal_cta2 {
    return Intl.message(
      'Cancel',
      name: 'add_note_modal_cta2',
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

  /// `Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Magic Backup is complete, we recommend performing a manual backup in your device [[Settings.]]`
  String get android_backup_info_subheading {
    return Intl.message(
      'Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Magic Backup is complete, we recommend performing a manual backup in your device [[Settings.]]',
      name: 'android_backup_info_subheading',
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

  /// `Back`
  String get azteco_redeem_modal_cta2 {
    return Intl.message(
      'Back',
      name: 'azteco_redeem_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get azteco_redeem_modal_fail_cta {
    return Intl.message(
      'Continue',
      name: 'azteco_redeem_modal_fail_cta',
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

  /// `Redeem your Voucher?`
  String get azteco_redeem_modal_heading {
    return Intl.message(
      'Redeem your Voucher?',
      name: 'azteco_redeem_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get azteco_redeem_modal_success_cta {
    return Intl.message(
      'Continue',
      name: 'azteco_redeem_modal_success_cta',
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

  /// `Continue`
  String get backups_erase_wallets_and_backups_modal_1_2_ios_cta {
    return Intl.message(
      'Continue',
      name: 'backups_erase_wallets_and_backups_modal_1_2_ios_cta',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get backups_erase_wallets_and_backups_modal_1_2_ios_cta1 {
    return Intl.message(
      'Cancel',
      name: 'backups_erase_wallets_and_backups_modal_1_2_ios_cta1',
      desc: '',
      args: [],
    );
  }

  /// `WARNING`
  String get backups_erase_wallets_and_backups_modal_1_2_ios_heading {
    return Intl.message(
      'WARNING',
      name: 'backups_erase_wallets_and_backups_modal_1_2_ios_heading',
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

  /// `Continue`
  String get change_output_from_multiple_tags_modal_cta1 {
    return Intl.message(
      'Continue',
      name: 'change_output_from_multiple_tags_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Edit Transaction`
  String get change_output_from_multiple_tags_modal_cta2 {
    return Intl.message(
      'Edit Transaction',
      name: 'change_output_from_multiple_tags_modal_cta2',
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

  /// `Cancel`
  String get coincontrol_coin_change_spendable_state_modal_cta2 {
    return Intl.message(
      'Cancel',
      name: 'coincontrol_coin_change_spendable_state_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get coincontrol_coin_change_spendable_tate_modal_cta1 {
    return Intl.message(
      'Continue',
      name: 'coincontrol_coin_change_spendable_tate_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `\nYour transaction ID will be copied to the clipboard and may be visible to other apps on your phone.`
  String get coincontrol_coin_change_spendable_tate_modal_subheading {
    return Intl.message(
      '\nYour transaction ID will be copied to the clipboard and may be visible to other apps on your phone.',
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

  /// `Continue`
  String get coincontrol_edit_transaction_cta {
    return Intl.message(
      'Continue',
      name: 'coincontrol_edit_transaction_cta',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get coincontrol_edit_transaction_cta2 {
    return Intl.message(
      'Cancel',
      name: 'coincontrol_edit_transaction_cta2',
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

  /// `Selected amount`
  String get coincontrol_edit_transaction_selected_inputs {
    return Intl.message(
      'Selected amount',
      name: 'coincontrol_edit_transaction_selected_inputs',
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

  /// `Back`
  String get coincontrol_lock_coin_modal_cta2 {
    return Intl.message(
      'Back',
      name: 'coincontrol_lock_coin_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Don’t show again`
  String get coincontrol_lock_coin_modal_dontShowAgain {
    return Intl.message(
      'Don’t show again',
      name: 'coincontrol_lock_coin_modal_dontShowAgain',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nLocking coins will prevent them from being used in transactions.`
  String get coincontrol_lock_coin_modal_subheading {
    return Intl.message(
      'WARNING\n\nLocking coins will prevent them from being used in transactions.',
      name: 'coincontrol_lock_coin_modal_subheading',
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

  /// `Add a Note`
  String get coincontrol_tx_add_note_heading {
    return Intl.message(
      'Add a Note',
      name: 'coincontrol_tx_add_note_heading',
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

  /// `TRANSACTION Details`
  String get coincontrol_tx_detail_expand_heading {
    return Intl.message(
      'TRANSACTION Details',
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

  /// `Updating your fee may have changed\nyour coin selection. Please review.`
  String get coincontrol_tx_detail_feeChange_information {
    return Intl.message(
      'Updating your fee may have changed\nyour coin selection. Please review.',
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

  /// `Review transaction`
  String get coincontrol_tx_detail_passport_cta {
    return Intl.message(
      'Review transaction',
      name: 'coincontrol_tx_detail_passport_cta',
      desc: '',
      args: [],
    );
  }

  /// `Cancel transaction`
  String get coincontrol_tx_detail_passport_cta2 {
    return Intl.message(
      'Cancel transaction',
      name: 'coincontrol_tx_detail_passport_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get coincontrol_tx_detail_passport_heading {
    return Intl.message(
      'Are you sure?',
      name: 'coincontrol_tx_detail_passport_heading',
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

  /// `ACCOUNT DETAILS`
  String get coincontrol_tx_history_filter_off_heading {
    return Intl.message(
      'ACCOUNT DETAILS',
      name: 'coincontrol_tx_history_filter_off_heading',
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

  /// `WARNING\n\nUnlocking coins will make them available for use in transactions.`
  String get coincontrol_unlock_coin_modal_subheading {
    return Intl.message(
      'WARNING\n\nUnlocking coins will make them available for use in transactions.',
      name: 'coincontrol_unlock_coin_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `coin details`
  String get coindetails_overlay_heading {
    return Intl.message(
      'coin details',
      name: 'coindetails_overlay_heading',
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

  /// `Done`
  String get component_done {
    return Intl.message(
      'Done',
      name: 'component_done',
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

  /// `Choose a Tag`
  String get create_first_tag_modal_1_2_heading {
    return Intl.message(
      'Choose a Tag',
      name: 'create_first_tag_modal_1_2_heading',
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

  /// `Continue`
  String get create_first_tag_modal_2_2_cta {
    return Intl.message(
      'Continue',
      name: 'create_first_tag_modal_2_2_cta',
      desc: '',
      args: [],
    );
  }

  /// `Choose a Tag`
  String get create_first_tag_modal_2_2_heading {
    return Intl.message(
      'Choose a Tag',
      name: 'create_first_tag_modal_2_2_heading',
      desc: '',
      args: [],
    );
  }

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

  /// `Back`
  String get delete_emptyTag_modal_cta1 {
    return Intl.message(
      'Back',
      name: 'delete_emptyTag_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Delete Tag`
  String get delete_emptyTag_modal_cta2 {
    return Intl.message(
      'Delete Tag',
      name: 'delete_emptyTag_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nAre you sure you want to delete this tag?`
  String get delete_emptyTag_modal_subheading {
    return Intl.message(
      'WARNING\n\nAre you sure you want to delete this tag?',
      name: 'delete_emptyTag_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get delete_tag_modal_cta1 {
    return Intl.message(
      'Back',
      name: 'delete_tag_modal_cta1',
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

  /// `WARNING\n\nDeleting this tag will automatically mark these coins as untagged.`
  String get delete_tag_modal_subheading {
    return Intl.message(
      'WARNING\n\nDeleting this tag will automatically mark these coins as untagged.',
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

  /// `Skip`
  String get delete_wallet_for_good_instant_android_cta2 {
    return Intl.message(
      'Skip',
      name: 'delete_wallet_for_good_instant_android_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Android Backs Up Every 24h`
  String get delete_wallet_for_good_instant_android_heading {
    return Intl.message(
      'Android Backs Up Every 24h',
      name: 'delete_wallet_for_good_instant_android_heading',
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

  /// `Cancel`
  String get delete_wallet_for_good_modal_cta1 {
    return Intl.message(
      'Cancel',
      name: 'delete_wallet_for_good_modal_cta1',
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

  /// `Learn More`
  String get devices_empty_learn_more {
    return Intl.message(
      'Learn More',
      name: 'devices_empty_learn_more',
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

  /// `LEARN`
  String get devices_empty_modal_video_header {
    return Intl.message(
      'LEARN',
      name: 'devices_empty_modal_video_header',
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

  /// `Delete Tag`
  String get empty_tag_modal_cta2 {
    return Intl.message(
      'Delete Tag',
      name: 'empty_tag_modal_cta2',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nYour {tagName} tag is now empty. Would you like to delete it?`
  String empty_tag_modal_subheading(Object tagName) {
    return Intl.message(
      'WARNING\n\nYour $tagName tag is now empty. Would you like to delete it?',
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

  /// `Try again`
  String get envoy_fw_fail_cta {
    return Intl.message(
      'Try again',
      name: 'envoy_fw_fail_cta',
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

  /// `Continue`
  String get envoy_fw_ios_instructions_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_ios_instructions_cta',
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

  /// `Insert the microSD card into your Phone`
  String get envoy_fw_microsd_heading {
    return Intl.message(
      'Insert the microSD card into your Phone',
      name: 'envoy_fw_microsd_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_fw_microsd_heading_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_microsd_heading_cta',
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

  /// `Continue`
  String get envoy_fw_passport_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_passport_cta',
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

  /// `Envoy is now copying the firmware onto the \nmicroSD card`
  String get envoy_fw_progress_heading {
    return Intl.message(
      'Envoy is now copying the firmware onto the \nmicroSD card',
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

  /// `Continue`
  String get envoy_fw_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_fw_success_cta_ios {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_success_cta_ios',
      desc: '',
      args: [],
    );
  }

  /// `Firmware was successfully copied onto the microSD card`
  String get envoy_fw_success_heading {
    return Intl.message(
      'Firmware was successfully copied onto the microSD card',
      name: 'envoy_fw_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Firmware was successfully copied onto the microSD card`
  String get envoy_fw_success_heading_ios {
    return Intl.message(
      'Firmware was successfully copied onto the microSD card',
      name: 'envoy_fw_success_heading_ios',
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

  /// `Continue`
  String get envoy_pin_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pin_intro_cta',
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

  /// `Continue`
  String get envoy_pp_new_seed_backup_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_backup_cta',
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

  /// `Continue`
  String get envoy_pp_new_seed_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_cta',
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

  /// `Continue`
  String get envoy_pp_new_seed_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_success_cta',
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

  /// `Continue`
  String get envoy_pp_restore_backup_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_backup_cta',
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

  /// `Continue`
  String get envoy_pp_restore_backup_password_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_backup_password_cta',
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

  /// `To decrypt the backup file, enter the 20 digit backup code shown to you when creating the  backup file.\n\nIf you have lost or forgotten this code, you can restore using the seed words instead.`
  String get envoy_pp_restore_backup_password_subheading {
    return Intl.message(
      'To decrypt the backup file, enter the 20 digit backup code shown to you when creating the  backup file.\n\nIf you have lost or forgotten this code, you can restore using the seed words instead.',
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

  /// `Continue`
  String get envoy_pp_restore_backup_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_backup_success_cta',
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

  /// `Next, we will connect Envoy and Passport.`
  String get envoy_pp_restore_backup_success_subheading {
    return Intl.message(
      'Next, we will connect Envoy and Passport.',
      name: 'envoy_pp_restore_backup_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_pp_restore_seed_backup_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_seed_backup_cta',
      desc: '',
      args: [],
    );
  }

  /// `Now, create an encrypted backup of your seed`
  String get envoy_pp_restore_seed_backup_heading {
    return Intl.message(
      'Now, create an encrypted backup of your seed',
      name: 'envoy_pp_restore_seed_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passport will back up your seed and device settings to an encrypted microSD card.`
  String get envoy_pp_restore_seed_backup_subheading {
    return Intl.message(
      'Passport will back up your seed and device settings to an encrypted microSD card.',
      name: 'envoy_pp_restore_seed_backup_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_pp_restore_seed_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_seed_cta',
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

  /// `Continue`
  String get envoy_pp_restore_seed_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_restore_seed_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `Your seed has been \nsuccessfully restored`
  String get envoy_pp_restore_seed_success_heading {
    return Intl.message(
      'Your seed has been \nsuccessfully restored',
      name: 'envoy_pp_restore_seed_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Next, we will connect Envoy and Passport.`
  String get envoy_pp_restore_seed_success_subheading {
    return Intl.message(
      'Next, we will connect Envoy and Passport.',
      name: 'envoy_pp_restore_seed_success_subheading',
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

  /// `Next`
  String get envoy_scv_intro_cta {
    return Intl.message(
      'Next',
      name: 'envoy_scv_intro_cta',
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

  /// `Retry`
  String get envoy_scv_result_fail_cta {
    return Intl.message(
      'Retry',
      name: 'envoy_scv_result_fail_cta',
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

  /// `Continue`
  String get envoy_scv_result_ok_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_result_ok_cta',
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

  /// `Continue`
  String get envoy_scv_scan_qr_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_scan_qr_cta',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get envoy_scv_show_qr_cta {
    return Intl.message(
      'Next',
      name: 'envoy_scv_show_qr_cta',
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

  /// `Skip`
  String get envoy_welcome_screen_skip {
    return Intl.message(
      'Skip',
      name: 'envoy_welcome_screen_skip',
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

  /// `Done`
  String get export_seed_modal_12_words_CTA1 {
    return Intl.message(
      'Done',
      name: 'export_seed_modal_12_words_CTA1',
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

  /// `Done`
  String get export_seed_modal_QR_code_CTA1 {
    return Intl.message(
      'Done',
      name: 'export_seed_modal_QR_code_CTA1',
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

  /// `WARNING\nThe following screen displays highly sensitive information.\n\nAnyone with access to this data can steal your Bitcoin. Proceed with extreme caution.`
  String get export_seed_modal_subheading {
    return Intl.message(
      'WARNING\nThe following screen displays highly sensitive information.\n\nAnyone with access to this data can steal your Bitcoin. Proceed with extreme caution.',
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

  /// `Swipe to show and hide your balance.`
  String get hide_amount_first_time_text {
    return Intl.message(
      'Swipe to show and hide your balance.',
      name: 'hide_amount_first_time_text',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get hide_amount_first_time_text_button {
    return Intl.message(
      'Dismiss',
      name: 'hide_amount_first_time_text_button',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get hot_wallet_accounts_creation_done_button {
    return Intl.message(
      'Dismiss',
      name: 'hot_wallet_accounts_creation_done_button',
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

  /// `All`
  String get learning_center_filter_all {
    return Intl.message(
      'All',
      name: 'learning_center_filter_all',
      desc: '',
      args: [],
    );
  }

  /// `Blog posts`
  String get learning_center_filter_blog {
    return Intl.message(
      'Blog posts',
      name: 'learning_center_filter_blog',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get learning_center_filter_faqs {
    return Intl.message(
      'FAQs',
      name: 'learning_center_filter_faqs',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get learning_center_filter_heading {
    return Intl.message(
      'Filter',
      name: 'learning_center_filter_heading',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get learning_center_filter_reset_filter_cta {
    return Intl.message(
      'Reset',
      name: 'learning_center_filter_reset_filter_cta',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get learning_center_filter_videos {
    return Intl.message(
      'Videos',
      name: 'learning_center_filter_videos',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get learning_center_main_cta {
    return Intl.message(
      'Apply',
      name: 'learning_center_main_cta',
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

  /// `Sort by`
  String get learning_center_sort_heading {
    return Intl.message(
      'Sort by',
      name: 'learning_center_sort_heading',
      desc: '',
      args: [],
    );
  }

  /// `Newest first`
  String get learning_center_sort_newest {
    return Intl.message(
      'Newest first',
      name: 'learning_center_sort_newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest first`
  String get learning_center_sort_oldest {
    return Intl.message(
      'Oldest first',
      name: 'learning_center_sort_oldest',
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

  /// `Creating Your Envoy Seed`
  String get magic_setup_generate_envoy_key_android_heading {
    return Intl.message(
      'Creating Your Envoy Seed',
      name: 'magic_setup_generate_envoy_key_android_heading',
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
  String get magic_setup_generate_envoy_key_ios_heading {
    return Intl.message(
      'Creating Your Envoy Seed',
      name: 'magic_setup_generate_envoy_key_ios_heading',
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

  /// `WARNING\n\nCreating a new Magic Backup will erase any existing Magic Backup associated with your Google account.`
  String get magic_setup_generate_wallet_modal_android_subheading {
    return Intl.message(
      'WARNING\n\nCreating a new Magic Backup will erase any existing Magic Backup associated with your Google account.',
      name: 'magic_setup_generate_wallet_modal_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get magic_setup_generate_wallet_modal_ios_cta {
    return Intl.message(
      'Continue',
      name: 'magic_setup_generate_wallet_modal_ios_cta',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nCreating a new Magic Backup will erase any existing Magic Backup associated with your iCloud account.`
  String get magic_setup_generate_wallet_modal_ios_subheading {
    return Intl.message(
      'WARNING\n\nCreating a new Magic Backup will erase any existing Magic Backup associated with your iCloud account.',
      name: 'magic_setup_generate_wallet_modal_ios_subheading',
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

  /// `Recovery Unsuccessful`
  String get magic_setup_recovery_fail_Android_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_setup_recovery_fail_Android_heading',
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

  /// `Retry`
  String get magic_setup_recovery_fail_backup_cta1 {
    return Intl.message(
      'Retry',
      name: 'magic_setup_recovery_fail_backup_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Import Envoy Backup File`
  String get magic_setup_recovery_fail_backup_cta2 {
    return Intl.message(
      'Import Envoy Backup File',
      name: 'magic_setup_recovery_fail_backup_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get magic_setup_recovery_fail_backup_cta3 {
    return Intl.message(
      'Continue',
      name: 'magic_setup_recovery_fail_backup_cta3',
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

  /// `Retry`
  String get magic_setup_recovery_fail_connectivity_cta1 {
    return Intl.message(
      'Retry',
      name: 'magic_setup_recovery_fail_connectivity_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Import Envoy Backup File`
  String get magic_setup_recovery_fail_connectivity_cta2 {
    return Intl.message(
      'Import Envoy Backup File',
      name: 'magic_setup_recovery_fail_connectivity_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get magic_setup_recovery_fail_connectivity_cta3 {
    return Intl.message(
      'Continue',
      name: 'magic_setup_recovery_fail_connectivity_cta3',
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
  String get magic_setup_recovery_fail_ios_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_setup_recovery_fail_ios_heading',
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

  /// `Magic Backups`
  String get magic_setup_tutorial_ios_heading {
    return Intl.message(
      'Magic Backups',
      name: 'magic_setup_tutorial_ios_heading',
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

  /// `Account details`
  String get manage_account_address_heading {
    return Intl.message(
      'Account details',
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

  /// `DELETE`
  String get manage_account_menu_delete {
    return Intl.message(
      'DELETE',
      name: 'manage_account_menu_delete',
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

  /// `Delete`
  String get manage_account_remove_cta {
    return Intl.message(
      'Delete',
      name: 'manage_account_remove_cta',
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

  /// `Save`
  String get manage_account_rename_cta {
    return Intl.message(
      'Save',
      name: 'manage_account_rename_cta',
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

  /// `Paired`
  String get manage_device_details_devicePaired {
    return Intl.message(
      'Paired',
      name: 'manage_device_details_devicePaired',
      desc: '',
      args: [],
    );
  }

  /// `Serial: `
  String get manage_device_details_deviceSerial {
    return Intl.message(
      'Serial: ',
      name: 'manage_device_details_deviceSerial',
      desc: '',
      args: [],
    );
  }

  /// `Device DETAILS`
  String get manage_device_details_heading {
    return Intl.message(
      'Device DETAILS',
      name: 'manage_device_details_heading',
      desc: '',
      args: [],
    );
  }

  /// `DELETE`
  String get manage_device_details_menu_Delete {
    return Intl.message(
      'DELETE',
      name: 'manage_device_details_menu_Delete',
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

  /// `Delete`
  String get manage_device_disconnect_modal {
    return Intl.message(
      'Delete',
      name: 'manage_device_disconnect_modal',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get manage_device_disconnect_modal_cta {
    return Intl.message(
      'Save',
      name: 'manage_device_disconnect_modal_cta',
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

  /// `Yes`
  String get manual_coin_preselection_dialog_cta1 {
    return Intl.message(
      'Yes',
      name: 'manual_coin_preselection_dialog_cta1',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get manual_coin_preselection_dialog_cta2 {
    return Intl.message(
      'No',
      name: 'manual_coin_preselection_dialog_cta2',
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

  /// `Don't remind me again`
  String get manual_coin_preselection_dialog_dontShowAgain {
    return Intl.message(
      'Don\'t remind me again',
      name: 'manual_coin_preselection_dialog_dontShowAgain',
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

  /// `Envoy has generated your encrypted backup. This backup contains useful wallet data such as tags, notes, accounts and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.`
  String get manual_setup_create_and_store_backup_subheading {
    return Intl.message(
      'Envoy has generated your encrypted backup. This backup contains useful wallet data such as tags, notes, accounts and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.',
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

  /// `Back`
  String
      get manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_CTA {
    return Intl.message(
      'Back',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_CTA',
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

  /// `Write Down these 12 Words`
  String get manual_setup_generate_seed_write_words_heading {
    return Intl.message(
      'Write Down these 12 Words',
      name: 'manual_setup_generate_seed_write_words_heading',
      desc: '',
      args: [],
    );
  }

  /// `Create New Envoy Backup`
  String get manual_setup_import_backup_CTA1 {
    return Intl.message(
      'Create New Envoy Backup',
      name: 'manual_setup_import_backup_CTA1',
      desc: '',
      args: [],
    );
  }

  /// `Import Envoy Backup`
  String get manual_setup_import_backup_CTA2 {
    return Intl.message(
      'Import Envoy Backup',
      name: 'manual_setup_import_backup_CTA2',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_import_backup_fails_modal_continue {
    return Intl.message(
      'Continue',
      name: 'manual_setup_import_backup_fails_modal_continue',
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

  /// `Import Envoy Backup`
  String get manual_setup_import_backup_heading {
    return Intl.message(
      'Import Envoy Backup',
      name: 'manual_setup_import_backup_heading',
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

  /// `Done`
  String get manual_setup_import_seed_12_words_CTA_inactive {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_seed_12_words_CTA_inactive',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get manual_setup_import_seed_12_words_fail_modal_CTA {
    return Intl.message(
      'Back',
      name: 'manual_setup_import_seed_12_words_fail_modal_CTA',
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

  /// `Import your Seed`
  String get manual_setup_import_seed_heading {
    return Intl.message(
      'Import your Seed',
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

  /// `Continue`
  String get manual_setup_recovery_import_backup_modal_fail_connectivity_cta1 {
    return Intl.message(
      'Continue',
      name: 'manual_setup_recovery_import_backup_modal_fail_connectivity_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get manual_setup_recovery_import_backup_modal_fail_connectivity_cta2 {
    return Intl.message(
      'Back',
      name: 'manual_setup_recovery_import_backup_modal_fail_connectivity_cta2',
      desc: '',
      args: [],
    );
  }

  /// `WARNING`
  String
      get manual_setup_recovery_import_backup_modal_fail_connectivity_heading {
    return Intl.message(
      'WARNING',
      name:
          'manual_setup_recovery_import_backup_modal_fail_connectivity_heading',
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

  /// `This seed is protected by a passphrase. Enter it below to import your Envoy Wallet.`
  String get manual_setup_recovery_passphrase_modal_subheading {
    return Intl.message(
      'This seed is protected by a passphrase. Enter it below to import your Envoy Wallet.',
      name: 'manual_setup_recovery_passphrase_modal_subheading',
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
  String get manual_setup_verify_seed_12_words_enter_passphrase_modal_heading {
    return Intl.message(
      'Enter Your Passphrase',
      name: 'manual_setup_verify_seed_12_words_enter_passphrase_modal_heading',
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

  /// `Continue`
  String get manual_setup_verify_seed_12_words_passphrase_warning_modal_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_verify_seed_12_words_passphrase_warning_modal_CTA',
      desc: '',
      args: [],
    );
  }

  /// `WARNING`
  String
      get manual_setup_verify_seed_12_words_passphrase_warning_modal_heading {
    return Intl.message(
      'WARNING',
      name:
          'manual_setup_verify_seed_12_words_passphrase_warning_modal_heading',
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

  /// `Magic Backups`
  String get manual_toggle_off_automatic_backups {
    return Intl.message(
      'Magic Backups',
      name: 'manual_toggle_off_automatic_backups',
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

  /// `Continue`
  String get manual_toggle_on_seed_backup_now_modal_cta {
    return Intl.message(
      'Continue',
      name: 'manual_toggle_on_seed_backup_now_modal_cta',
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

  /// `Pending backup to Foundation servers`
  String
      get manual_toggle_on_seed_not_backedup_pending_android_data_pending_backup {
    return Intl.message(
      'Pending backup to Foundation servers',
      name:
          'manual_toggle_on_seed_not_backedup_pending_android_data_pending_backup',
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

  /// `support`
  String get menu_support {
    return Intl.message(
      'support',
      name: 'menu_support',
      desc: '',
      args: [],
    );
  }

  /// `Connect Passport \nwith Envoy`
  String get pair_existing_device_intro_heading {
    return Intl.message(
      'Connect Passport \nwith Envoy',
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

  /// `Continue`
  String get pair_new_device_QR_code_cta {
    return Intl.message(
      'Continue',
      name: 'pair_new_device_QR_code_cta',
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

  /// `Continue`
  String get pair_new_device_address_cta1 {
    return Intl.message(
      'Continue',
      name: 'pair_new_device_address_cta1',
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

  /// `Skip`
  String get passport_welcome_screen_skip {
    return Intl.message(
      'Skip',
      name: 'passport_welcome_screen_skip',
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

  /// `Learn more`
  String get privacy_node_learnMore {
    return Intl.message(
      'Learn more',
      name: 'privacy_node_learnMore',
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

  /// `Improved\nPrivacy`
  String get privacy_privacyMode_improvedPrivacy {
    return Intl.message(
      'Improved\nPrivacy',
      name: 'privacy_privacyMode_improvedPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Learn more`
  String get privacy_privacyMode_learnMore {
    return Intl.message(
      'Learn more',
      name: 'privacy_privacyMode_learnMore',
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
  String get privacy_privacyMode_torSuggestion {
    return Intl.message(
      'Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users.',
      name: 'privacy_privacyMode_torSuggestion',
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

  /// `Enter your node address`
  String get privacy_setting_add_node_modal_text_field {
    return Intl.message(
      'Enter your node address',
      name: 'privacy_setting_add_node_modal_text_field',
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

  /// `Node Connected`
  String get privacy_setting_clearnet_node_heading {
    return Intl.message(
      'Node Connected',
      name: 'privacy_setting_clearnet_node_heading',
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

  /// `Retry`
  String get privacy_setting_connecting_node_fails_modal_cta {
    return Intl.message(
      'Retry',
      name: 'privacy_setting_connecting_node_fails_modal_cta',
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

  /// `Add Node`
  String get privacy_setting_connecting_node_success_modal_heading {
    return Intl.message(
      'Add Node',
      name: 'privacy_setting_connecting_node_success_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get privacy_setting_connecting_node_success_modal_heading_cta {
    return Intl.message(
      'Continue',
      name: 'privacy_setting_connecting_node_success_modal_heading_cta',
      desc: '',
      args: [],
    );
  }

  /// `Node Connected`
  String get privacy_setting_onion_node_heading {
    return Intl.message(
      'Node Connected',
      name: 'privacy_setting_onion_node_heading',
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

  /// `Better \nPerformance`
  String get privacy_setting_perfomance_better_performance {
    return Intl.message(
      'Better \nPerformance',
      name: 'privacy_setting_perfomance_better_performance',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get privacy_setting_perfomance_cta {
    return Intl.message(
      'Continue',
      name: 'privacy_setting_perfomance_cta',
      desc: '',
      args: [],
    );
  }

  /// `Choose your Privacy`
  String get privacy_setting_perfomance_heading {
    return Intl.message(
      'Choose your Privacy',
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

  /// `Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users.`
  String get privacy_setting_perfomance_tor_off {
    return Intl.message(
      'Envoy’s connection will be reliable with Tor turned [[OFF]]. Suggested for new users.',
      name: 'privacy_setting_perfomance_tor_off',
      desc: '',
      args: [],
    );
  }

  /// `Improved Privacy`
  String get privacy_setting_privacy_better_privacy {
    return Intl.message(
      'Improved Privacy',
      name: 'privacy_setting_privacy_better_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Tor will be turned [[ON]] for improved privacy. Envoy’s connection may be unreliable.`
  String get privacy_setting_privacy_tor_on {
    return Intl.message(
      'Tor will be turned [[ON]] for improved privacy. Envoy’s connection may be unreliable.',
      name: 'privacy_setting_privacy_tor_on',
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

  /// `Sign into Google and restore your  backup data`
  String get recovery_scenario_Android_instruction1 {
    return Intl.message(
      'Sign into Google and restore your  backup data',
      name: 'recovery_scenario_Android_instruction1',
      desc: '',
      args: [],
    );
  }

  /// `Install Envoy and tap “Set Up Envoy Wallet”`
  String get recovery_scenario_Android_instruction2 {
    return Intl.message(
      'Install Envoy and tap “Set Up Envoy Wallet”',
      name: 'recovery_scenario_Android_instruction2',
      desc: '',
      args: [],
    );
  }

  /// `How to Recover?`
  String get recovery_scenario_android_heading {
    return Intl.message(
      'How to Recover?',
      name: 'recovery_scenario_android_heading',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Magic Backup, follow these simple instructions.`
  String get recovery_scenario_android_subheading {
    return Intl.message(
      'To recover your Magic Backup, follow these simple instructions.',
      name: 'recovery_scenario_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `How to Recover?`
  String get recovery_scenario_ios_heading {
    return Intl.message(
      'How to Recover?',
      name: 'recovery_scenario_ios_heading',
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

  /// `Install Envoy and tap “Set Up Envoy Wallet”`
  String get recovery_scenario_ios_instruction2 {
    return Intl.message(
      'Install Envoy and tap “Set Up Envoy Wallet”',
      name: 'recovery_scenario_ios_instruction2',
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
  String get recovery_scenario_ios_subheading {
    return Intl.message(
      'To recover your Envoy wallet, follow these simple instructions.',
      name: 'recovery_scenario_ios_subheading',
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

  /// `SEND`
  String get send_qr_code_heading {
    return Intl.message(
      'SEND',
      name: 'send_qr_code_heading',
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

  /// `Continue`
  String get settings_advanced_enabled_testnet_modal_cta {
    return Intl.message(
      'Continue',
      name: 'settings_advanced_enabled_testnet_modal_cta',
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

  /// `Enable Testnet`
  String get settings_advanced_testnet {
    return Intl.message(
      'Enable Testnet',
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

  /// `Save`
  String get stalls_before_sending_tx_add_note_modal_cta1 {
    return Intl.message(
      'Save',
      name: 'stalls_before_sending_tx_add_note_modal_cta1',
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

  /// `Try Again`
  String get stalls_before_sending_tx_scanning_broadcasting_fail_cta1 {
    return Intl.message(
      'Try Again',
      name: 'stalls_before_sending_tx_scanning_broadcasting_fail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Review Transaction`
  String get stalls_before_sending_tx_scanning_broadcasting_fail_cta2 {
    return Intl.message(
      'Review Transaction',
      name: 'stalls_before_sending_tx_scanning_broadcasting_fail_cta2',
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

  /// `Continue`
  String get stalls_before_sending_tx_scanning_broadcasting_success_cta {
    return Intl.message(
      'Continue',
      name: 'stalls_before_sending_tx_scanning_broadcasting_success_cta',
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

  /// `This might a take few seconds`
  String get stalls_before_sending_tx_scanning_subheading {
    return Intl.message(
      'This might a take few seconds',
      name: 'stalls_before_sending_tx_scanning_subheading',
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

  /// `TAG Details`
  String get tagged_coin_details_locked_heading {
    return Intl.message(
      'TAG Details',
      name: 'tagged_coin_details_locked_heading',
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

  /// `DELETE TAG`
  String get tagged_coin_details_menu_cta2 {
    return Intl.message(
      'DELETE TAG',
      name: 'tagged_coin_details_menu_cta2',
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

  /// `Dismiss`
  String get tap_and_drag_first_time_text_button {
    return Intl.message(
      'Dismiss',
      name: 'tap_and_drag_first_time_text_button',
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

  /// `To enable a Passport Taproot account,  ensure you are running firmware 2.3.0 or later and reconnect your Passport.`
  String get taproot_passport_dialog_subheading {
    return Intl.message(
      'To enable a Passport Taproot account,  ensure you are running firmware 2.3.0 or later and reconnect your Passport.',
      name: 'taproot_passport_dialog_subheading',
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

  /// `Learn More`
  String get tor_connectivity_toast_warning_learn_more {
    return Intl.message(
      'Learn More',
      name: 'tor_connectivity_toast_warning_learn_more',
      desc: '',
      args: [],
    );
  }

  /// `Tag Details`
  String get untagged_coin_details_locked_heading {
    return Intl.message(
      'Tag Details',
      name: 'untagged_coin_details_locked_heading',
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

  /// `How Your Data is Secured`
  String get wallet_security_modal_3_4_ios_heading {
    return Intl.message(
      'How Your Data is Secured',
      name: 'wallet_security_modal_3_4_ios_heading',
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

  /// `Learn More`
  String get wallet_security_modal_cta1 {
    return Intl.message(
      'Learn More',
      name: 'wallet_security_modal_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get wallet_security_modal_cta2 {
    return Intl.message(
      'Back',
      name: 'wallet_security_modal_cta2',
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
      Locale.fromSubtags(languageCode: 'es'),
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
