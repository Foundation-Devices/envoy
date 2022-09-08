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

  /// `© 2022 Foundation Devices, Inc.`
  String get component_app_store_copyright {
    return Intl.message(
      '© 2022 Foundation Devices, Inc.',
      name: 'component_app_store_copyright',
      desc: '',
      args: [],
    );
  }

  /// `Envoy by Foundation is the perfect mobile companion to your Passport hardware wallet.\n\nEnvoy performs four key functions:\n\n1. Helps you securely and easily set up Passport.\n\n2. Keeps you up-to-date with firmware updates, no computer required!\n\n3. Provides quick and easy access to support resources.\n\n4. Offers a refreshingly simple Bitcoin software wallet.`
  String get component_app_store_description {
    return Intl.message(
      'Envoy by Foundation is the perfect mobile companion to your Passport hardware wallet.\n\nEnvoy performs four key functions:\n\n1. Helps you securely and easily set up Passport.\n\n2. Keeps you up-to-date with firmware updates, no computer required!\n\n3. Provides quick and easy access to support resources.\n\n4. Offers a refreshingly simple Bitcoin software wallet.',
      name: 'component_app_store_description',
      desc: '',
      args: [],
    );
  }

  /// `bitcoin, wallet, passport, foundation, foundation devices`
  String get component_app_store_keywords {
    return Intl.message(
      'bitcoin, wallet, passport, foundation, foundation devices',
      name: 'component_app_store_keywords',
      desc: '',
      args: [],
    );
  }

  /// `The perfect mobile companion for your Passport hardware wallet.`
  String get component_app_store_promotional_text {
    return Intl.message(
      'The perfect mobile companion for your Passport hardware wallet.',
      name: 'component_app_store_promotional_text',
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

  /// `Confirm`
  String get component_confirm {
    return Intl.message(
      'Confirm',
      name: 'component_confirm',
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

  /// `Just Now`
  String get component_dateformatter_justnow {
    return Intl.message(
      'Just Now',
      name: 'component_dateformatter_justnow',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get component_dateformatter_yesterday {
    return Intl.message(
      'Yesterday',
      name: 'component_dateformatter_yesterday',
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

  /// `OK`
  String get component_ok {
    return Intl.message(
      'OK',
      name: 'component_ok',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get component_os_clock {
    return Intl.message(
      '4321',
      name: 'component_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Envoy by Foundation`
  String get component_play_store_app_name {
    return Intl.message(
      'Envoy by Foundation',
      name: 'component_play_store_app_name',
      desc: '',
      args: [],
    );
  }

  /// `Envoy by Foundation is the perfect mobile companion to your Passport hardware wallet.\n\nEnvoy performs four key functions:\n\n1. Helps you securely and easily set up Passport.\n\n2. Keeps you up-to-date with firmware updates, no computer required!\n\n3. Provides quick and easy access to support resources.\n\n4. Offers a refreshingly simple Bitcoin software wallet.`
  String get component_play_store_full_description {
    return Intl.message(
      'Envoy by Foundation is the perfect mobile companion to your Passport hardware wallet.\n\nEnvoy performs four key functions:\n\n1. Helps you securely and easily set up Passport.\n\n2. Keeps you up-to-date with firmware updates, no computer required!\n\n3. Provides quick and easy access to support resources.\n\n4. Offers a refreshingly simple Bitcoin software wallet.',
      name: 'component_play_store_full_description',
      desc: '',
      args: [],
    );
  }

  /// `The perfect mobile companion for your Passport hardware wallet.`
  String get component_play_store_short_description {
    return Intl.message(
      'The perfect mobile companion for your Passport hardware wallet.',
      name: 'component_play_store_short_description',
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

  /// `4321`
  String get envoy_loading {
    return Intl.message(
      '4321',
      name: 'envoy_loading',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_loading_01 {
    return Intl.message(
      '4321',
      name: 'envoy_loading_01',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get envoy_welcome_card1_subheading {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'envoy_welcome_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_welcome_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_welcome_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport`
  String get envoy_welcome_card1_heading {
    return Intl.message(
      'The perfect companion for your Passport',
      name: 'envoy_welcome_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_welcome_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_welcome_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Have an Envoy Shield Account? {{Log In}}`
  String get envoy_welcome_cta02 {
    return Intl.message(
      'Have an Envoy Shield Account? {{Log In}}',
      name: 'envoy_welcome_cta02',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get envoy_welcome_cta {
    return Intl.message(
      'Set up a new Passport',
      name: 'envoy_welcome_cta',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get envoy_welcome_cta01 {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_welcome_cta01',
      desc: '',
      args: [],
    );
  }

  /// `I don’t have a Passport. {{Buy One}}`
  String get envoy_welcome_cta03 {
    return Intl.message(
      'I don’t have a Passport. {{Buy One}}',
      name: 'envoy_welcome_cta03',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_intro_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_intro_right_action',
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

  /// `Next`
  String get envoy_scv_intro_cta {
    return Intl.message(
      'Next',
      name: 'envoy_scv_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_show_qr_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_show_qr_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_show_qr_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_show_qr_right_action',
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

  /// `Next`
  String get envoy_scv_show_qr_cta {
    return Intl.message(
      'Next',
      name: 'envoy_scv_show_qr_cta',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_scan_qr_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_scan_qr_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_scan_qr_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_scan_qr_right_action',
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

  /// `Continue`
  String get envoy_scv_scan_qr_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_scan_qr_cta',
      desc: '',
      args: [],
    );
  }

  /// `“Envoy” Would Like to Access the Camera`
  String get envoy_scv_permissions_os_modal_heading {
    return Intl.message(
      '“Envoy” Would Like to Access the Camera',
      name: 'envoy_scv_permissions_os_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enable camera access to continue setting up your Passport`
  String get envoy_scv_permissions_os_modal_subheading {
    return Intl.message(
      'Enable camera access to continue setting up your Passport',
      name: 'envoy_scv_permissions_os_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Don’t Allow`
  String get envoy_scv_permissions_os_modal_refuse {
    return Intl.message(
      'Don’t Allow',
      name: 'envoy_scv_permissions_os_modal_refuse',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get envoy_scv_permissions_os_modal_allow {
    return Intl.message(
      'Allow',
      name: 'envoy_scv_permissions_os_modal_allow',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_result_ok_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_result_ok_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_result_ok_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_result_ok_right_action',
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
  String get envoy_scv_result_ok_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_result_ok_cta',
      desc: '',
      args: [],
    );
  }

  /// `Update Passport’s Firmware`
  String get envoy_scv_result_update_card1_subheading {
    return Intl.message(
      'Update Passport’s Firmware',
      name: 'envoy_scv_result_update_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your Passport is running an outdated firmware version. Envoy will download the latest firmware for installation.`
  String get envoy_scv_result_update_card1_subheading1 {
    return Intl.message(
      'Your Passport is running an outdated firmware version. Envoy will download the latest firmware for installation.',
      name: 'envoy_scv_result_update_card1_subheading1',
      desc: '',
      args: [],
    );
  }

  /// `Next, create a PIN to secure your Passport`
  String get envoy_scv_result_update_card2_subheading {
    return Intl.message(
      'Next, create a PIN to secure your Passport',
      name: 'envoy_scv_result_update_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `A PIN will encrypt your Passport so that only you can access your Bitcoin.`
  String get envoy_scv_result_update_card2_subheading1 {
    return Intl.message(
      'A PIN will encrypt your Passport so that only you can access your Bitcoin.',
      name: 'envoy_scv_result_update_card2_subheading1',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_result_update_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_result_update_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_result_update_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_result_update_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Your Passport is secure\nbut needs a firmware update`
  String get envoy_scv_result_update_heading {
    return Intl.message(
      'Your Passport is secure\nbut needs a firmware update',
      name: 'envoy_scv_result_update_heading',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get envoy_scv_result_fail_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_scv_result_fail_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_scv_result_fail_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_scv_result_fail_right_action',
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

  /// `Retry`
  String get envoy_scv_result_fail_cta {
    return Intl.message(
      'Retry',
      name: 'envoy_scv_result_fail_cta',
      desc: '',
      args: [],
    );
  }

  /// `CONTACT US`
  String get envoy_scv_result_fail_cta1 {
    return Intl.message(
      'CONTACT US',
      name: 'envoy_scv_result_fail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pin_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pin_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pin_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pin_intro_right_action',
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

  /// `Passport will always ask for the PIN when starting up. We recommend using a unique PIN and writing it down. \n\nIf you forget your PIN, there is no way to recover Passport, and the device will be permanently disabled.`
  String get envoy_pin_intro_subheading {
    return Intl.message(
      'Passport will always ask for the PIN when starting up. We recommend using a unique PIN and writing it down. \n\nIf you forget your PIN, there is no way to recover Passport, and the device will be permanently disabled.',
      name: 'envoy_pin_intro_subheading',
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

  /// `9:41`
  String get envoy_pin_confirm_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pin_confirm_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pin_confirm_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pin_confirm_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Enter your PIN again to confirm`
  String get envoy_pin_confirm_heading {
    return Intl.message(
      'Enter your PIN again to confirm',
      name: 'envoy_pin_confirm_heading',
      desc: '',
      args: [],
    );
  }

  /// `By entering your PIN twice, Passport will confirm that there are no typos.`
  String get envoy_pin_confirm_subheading {
    return Intl.message(
      'By entering your PIN twice, Passport will confirm that there are no typos.',
      name: 'envoy_pin_confirm_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_pin_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pin_confirm_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_fw_microsd_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_fw_microsd_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_fw_microsd_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_fw_microsd_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into your phone `
  String get envoy_fw_microsd_heading {
    return Intl.message(
      'Insert the microSD card into your phone ',
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

  /// `Continue`
  String get envoy_fw_microsd_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_microsd_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_fw_ios_instructions_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_fw_ios_instructions_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_fw_ios_instructions_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_fw_ios_instructions_right_action',
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

  /// `Grant Envoy access to copy files to the microSD card, tap PASSPORT-SD, then Done.`
  String get envoy_fw_ios_instructions_subheading {
    return Intl.message(
      'Grant Envoy access to copy files to the microSD card, tap PASSPORT-SD, then Done.',
      name: 'envoy_fw_ios_instructions_subheading',
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

  /// `9:41`
  String get envoy_fw_passport_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_fw_passport_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_fw_passport_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_fw_passport_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Remove the microSD card and insert into Passport `
  String get envoy_fw_passport_heading {
    return Intl.message(
      'Remove the microSD card and insert into Passport ',
      name: 'envoy_fw_passport_heading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into Passport and follow the instructions.\n\nEnsure Passport has adequate battery charge.`
  String get envoy_fw_passport_subheading {
    return Intl.message(
      'Insert the microSD card into Passport and follow the instructions.\n\nEnsure Passport has adequate battery charge.',
      name: 'envoy_fw_passport_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Finished`
  String get envoy_fw_passport_cta {
    return Intl.message(
      'Finished',
      name: 'envoy_fw_passport_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_account_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_account_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Now let’s create an Envoy account to securely backup your Passport to the cloud `
  String get envoy_account_intro_heading {
    return Intl.message(
      'Now let’s create an Envoy account to securely backup your Passport to the cloud ',
      name: 'envoy_account_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `{{Learn More}}`
  String get envoy_account_intro_cta2 {
    return Intl.message(
      '{{Learn More}}',
      name: 'envoy_account_intro_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Create an account`
  String get envoy_account_intro_cta {
    return Intl.message(
      'Create an account',
      name: 'envoy_account_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Continue without Account`
  String get envoy_account_intro_cta1 {
    return Intl.message(
      'Continue without Account',
      name: 'envoy_account_intro_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get envoy_account_email_card1_heading {
    return Intl.message(
      'Enter your email address',
      name: 'envoy_account_email_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.`
  String get envoy_account_email_card1_subheading {
    return Intl.message(
      'Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.',
      name: 'envoy_account_email_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get envoy_account_email_card2_subheading {
    return Intl.message(
      'I understand',
      name: 'envoy_account_email_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Using an email address already known to Foundation will result in degraded privacy. It is best practice to use a new email address when setting up your Envoy account.`
  String get envoy_account_email_card2_subheading1 {
    return Intl.message(
      'Using an email address already known to Foundation will result in degraded privacy. It is best practice to use a new email address when setting up your Envoy account.',
      name: 'envoy_account_email_card2_subheading1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_email_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_email_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_account_email_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_account_email_right_action',
      desc: '',
      args: [],
    );
  }

  /// `\nusername@emailprovider.com`
  String get envoy_account_email_user_input {
    return Intl.message(
      '\nusername@emailprovider.com',
      name: 'envoy_account_email_user_input',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_account_email_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_email_cta',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email to create an Envoy account`
  String get envoy_account_email_prompt_os_modal_heading {
    return Intl.message(
      'Enter your email to create an Envoy account',
      name: 'envoy_account_email_prompt_os_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `To get started, we need an email address.`
  String get envoy_account_email_prompt_os_modal_subheading {
    return Intl.message(
      'To get started, we need an email address.',
      name: 'envoy_account_email_prompt_os_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get envoy_account_email_prompt_os_modal_allow {
    return Intl.message(
      'OK',
      name: 'envoy_account_email_prompt_os_modal_allow',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get envoy_account_privacy_warn_card1_heading {
    return Intl.message(
      'Enter your email address',
      name: 'envoy_account_privacy_warn_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.`
  String get envoy_account_privacy_warn_card1_subheading {
    return Intl.message(
      'Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.',
      name: 'envoy_account_privacy_warn_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get envoy_account_privacy_warn_card2_subheading {
    return Intl.message(
      'I understand',
      name: 'envoy_account_privacy_warn_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `It’s best practice to use a new email address when setting up your Envoy account. Using an email address already known to Foundation Devices will result in degraded privacy.`
  String get envoy_account_privacy_warn_card2_subheading1 {
    return Intl.message(
      'It’s best practice to use a new email address when setting up your Envoy account. Using an email address already known to Foundation Devices will result in degraded privacy.',
      name: 'envoy_account_privacy_warn_card2_subheading1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_privacy_warn_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_privacy_warn_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_account_privacy_warn_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_account_privacy_warn_right_action',
      desc: '',
      args: [],
    );
  }

  /// `\nusername@emailprovider.com`
  String get envoy_account_privacy_warn_user_input {
    return Intl.message(
      '\nusername@emailprovider.com',
      name: 'envoy_account_privacy_warn_user_input',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_account_privacy_warn_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_account_privacy_warn_cta',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get envoy_account_email_entry_card1_heading {
    return Intl.message(
      'Enter your email address',
      name: 'envoy_account_email_entry_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.`
  String get envoy_account_email_entry_card1_subheading {
    return Intl.message(
      'Your email is used for notification and approval of any recovery spends involving the anonymous recovery key.',
      name: 'envoy_account_email_entry_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get envoy_account_email_entry_card2_subheading {
    return Intl.message(
      'I understand',
      name: 'envoy_account_email_entry_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Using an email address already known to Foundation Devices will result in degraded privacy. It is best practice to use a new email address when setting up your Envoy account.`
  String get envoy_account_email_entry_card2_subheading1 {
    return Intl.message(
      'Using an email address already known to Foundation Devices will result in degraded privacy. It is best practice to use a new email address when setting up your Envoy account.',
      name: 'envoy_account_email_entry_card2_subheading1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_email_entry_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_email_entry_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_account_email_entry_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_account_email_entry_right_action',
      desc: '',
      args: [],
    );
  }

  /// `\nusername@emailprovider.com`
  String get envoy_account_email_entry_user_input {
    return Intl.message(
      '\nusername@emailprovider.com',
      name: 'envoy_account_email_entry_user_input',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_account_email_entry_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_email_entry_cta',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service and Privacy Policy`
  String get envoy_account_tos_prompt_os_modal_heading {
    return Intl.message(
      'Terms of Service and Privacy Policy',
      name: 'envoy_account_tos_prompt_os_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Before proceeding, please read and accept our Terms of Service and Privacy Policy.`
  String get envoy_account_tos_prompt_os_modal_subheading {
    return Intl.message(
      'Before proceeding, please read and accept our Terms of Service and Privacy Policy.',
      name: 'envoy_account_tos_prompt_os_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get envoy_account_tos_prompt_os_modal_allow {
    return Intl.message(
      'OK',
      name: 'envoy_account_tos_prompt_os_modal_allow',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_tos_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_tos_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get envoy_account_tos_heading {
    return Intl.message(
      'Terms of Service',
      name: 'envoy_account_tos_heading',
      desc: '',
      args: [],
    );
  }

  /// `1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\n\n2. Security\n\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\n3. Backups\n\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss. \nEt consequat purus et id tellus. Nulla imperdiet vel tempor nisi aliquam adipiscing eu dictum mauris. Justo habitant bibendum risus quam id donec odio vulputate massa. At et massa amet, massa, orci ut. Etiam vitae ornare ut nec eget nunc sem mi. Rhoncus duis aliquam et tincidunt sed. Eu egestas tempus, vel ut purus, sollicitudin vel adipiscing. Ac ultrices sit adipiscing faucibus amet, in eget. Sollicitudin lectus lacus, sem tellus ipsum amet. Morbi quam cras sollicitudin dui porttitor amet, ac velit. Et ac, interdum vitae, elementum amet, interdum.\nAmet vitae erat at lacus, ultrices in nisi, platea purus. Convallis sagittis ut ut diam mattis nulla vel. Ac cursus pulvinar nibh sed sed magnis. Leo lorem porttitor habitasse et sed eu arcu. Sem porttitor iaculis fames leo. Dui nisl odio aliquam purus. Praesent metus, pretium, aliquet consequat est, congue facilisis. Eros sem urna pharetra amet arcu, eget.`
  String get envoy_account_tos_subheading {
    return Intl.message(
      '1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\n\n2. Security\n\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\n3. Backups\n\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss. \nEt consequat purus et id tellus. Nulla imperdiet vel tempor nisi aliquam adipiscing eu dictum mauris. Justo habitant bibendum risus quam id donec odio vulputate massa. At et massa amet, massa, orci ut. Etiam vitae ornare ut nec eget nunc sem mi. Rhoncus duis aliquam et tincidunt sed. Eu egestas tempus, vel ut purus, sollicitudin vel adipiscing. Ac ultrices sit adipiscing faucibus amet, in eget. Sollicitudin lectus lacus, sem tellus ipsum amet. Morbi quam cras sollicitudin dui porttitor amet, ac velit. Et ac, interdum vitae, elementum amet, interdum.\nAmet vitae erat at lacus, ultrices in nisi, platea purus. Convallis sagittis ut ut diam mattis nulla vel. Ac cursus pulvinar nibh sed sed magnis. Leo lorem porttitor habitasse et sed eu arcu. Sem porttitor iaculis fames leo. Dui nisl odio aliquam purus. Praesent metus, pretium, aliquet consequat est, congue facilisis. Eros sem urna pharetra amet arcu, eget.',
      name: 'envoy_account_tos_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_account_tos_os_modal_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_tos_os_modal_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_privacy_policy_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_privacy_policy_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get envoy_account_privacy_policy_heading {
    return Intl.message(
      'Privacy Policy',
      name: 'envoy_account_privacy_policy_heading',
      desc: '',
      args: [],
    );
  }

  /// `Effective date: August 27, 2020.\n\nThis “Privacy Policy” describes the privacy practices of Foundation Devices, Inc. (collectively, “Foundational Devices”, “we”, “us”, or “our”) in connection with the https://foundationdevices.com website (the “Site”) and the informational services made available through the Site (collectively Site and such services, the “Services”), and the rights and choices available to individuals with respect to their information.\n\nFoundational Devices may provide additional or supplemental privacy policies to individuals for specific products or services that we offer at the time we collect personal information. These supplemental privacy policies will govern how we may process the information in the context of the specific product or service.\n1. Personal Information We Collect\n\nInformation you provide to us. Personal information you provide to us through the Service or otherwise includes:\n\n    Information necessary to make a purchase, such as your first and last name, email and mailing addresses, phone number, credit card information, products purchased and, if purchasing using Bitcoin, the information collected in connection with such payment.\n    Feedback or correspondence, such as information you provide when you contact us with questions, feedback, or otherwise correspond with us online.\n    Demographic Information, such as your city, state, country of residence, and postal code.\n    Transaction information, such as information about payments to and from you and other details of products or services you have purchased from us.\n    Usage information, such as information about how you use the Service and interact with us, including information associated with any content you upload to the websites or otherwise submit to us, and information you provide when you use any interactive features of the Service.\n    Marketing information, such as your preferences for receiving communications about our activities, events, and publications, and details about how you engage with our communications\n    Other information that we may collect which is not specifically listed here, but which we will use in accordance with this Privacy Policy or as otherwise disclosed at the time of collection.\n\nInformation we obtain from social media platforms. We may maintain pages for our Company on social media platforms, such as Facebook, LinkedIn, Twitter, Google, YouTube, Instagram, and other third party platforms. When you visit or interact with our pages on those platforms, the platform provider’s privacy policy will apply to your interactions and their collection, use and processing of your personal information. You or the platforms may provide us with information through the platform, and we will treat such information in accordance with this Privacy Policy.\n\nInformation we obtain from other third parties. We may receive personal information about you from third-party sources. For example, a business partner may share your contact information with us if you have expressed interest in learning specifically about our products or services, or the types of products or services we offer. We may obtain your personal information from other third parties, such as marketing partners, publicly-available sources and data providers.\n\nCookies and Other Information Collected by Automated Means\n\nWe, our service providers, and our business partners may automatically log information about you, your computer or mobile device, and activity occurring on or through the Service, including but not limited, your computer or mobile device operating system type and version number, manufacturer and model, device identifier (such as the Google Advertising ID or Apple ID for Advertising), browser type, screen resolution, IP address, the website you visited before browsing to our website, general location information such as city, state or geographic area; information about your use of and actions on the Service, such as pages or screens you viewed, how long you spent on a page or screen, navigation paths between pages or screens, information about your activity on a page or screen, access times, and length of access; and other personal information. Our service providers and business partners may collect this type of information over time and across third-party websites and mobile applications.\n\nOn our webpages, this information is collected using cookies, browser web storage (also known as locally stored objects, or “LSOs”), and similar technologies.\n\nA “cookie” is a text file that websites send to a visitor‘s computer or other Internet-connected device to uniquely identify the visitor’s browser or to store information or settings in the browser. Browser web storage, or LSOs, are used for similar purposes as cookies. Browser web storage enables the storage of a larger amount of data than cookies.\n\nWeb browsers may offer users of our websites or mobile apps the ability to disable receiving certain types of cookies; however, if cookies are disabled, some features or functionality of our websites may not function correctly. Please see the “Targeted online advertising” section for information about how to exercise choice regarding the use of browsing behavior for purposes of targeted advertising.\n`
  String get envoy_account_privacy_policy_subheading {
    return Intl.message(
      'Effective date: August 27, 2020.\n\nThis “Privacy Policy” describes the privacy practices of Foundation Devices, Inc. (collectively, “Foundational Devices”, “we”, “us”, or “our”) in connection with the https://foundationdevices.com website (the “Site”) and the informational services made available through the Site (collectively Site and such services, the “Services”), and the rights and choices available to individuals with respect to their information.\n\nFoundational Devices may provide additional or supplemental privacy policies to individuals for specific products or services that we offer at the time we collect personal information. These supplemental privacy policies will govern how we may process the information in the context of the specific product or service.\n1. Personal Information We Collect\n\nInformation you provide to us. Personal information you provide to us through the Service or otherwise includes:\n\n    Information necessary to make a purchase, such as your first and last name, email and mailing addresses, phone number, credit card information, products purchased and, if purchasing using Bitcoin, the information collected in connection with such payment.\n    Feedback or correspondence, such as information you provide when you contact us with questions, feedback, or otherwise correspond with us online.\n    Demographic Information, such as your city, state, country of residence, and postal code.\n    Transaction information, such as information about payments to and from you and other details of products or services you have purchased from us.\n    Usage information, such as information about how you use the Service and interact with us, including information associated with any content you upload to the websites or otherwise submit to us, and information you provide when you use any interactive features of the Service.\n    Marketing information, such as your preferences for receiving communications about our activities, events, and publications, and details about how you engage with our communications\n    Other information that we may collect which is not specifically listed here, but which we will use in accordance with this Privacy Policy or as otherwise disclosed at the time of collection.\n\nInformation we obtain from social media platforms. We may maintain pages for our Company on social media platforms, such as Facebook, LinkedIn, Twitter, Google, YouTube, Instagram, and other third party platforms. When you visit or interact with our pages on those platforms, the platform provider’s privacy policy will apply to your interactions and their collection, use and processing of your personal information. You or the platforms may provide us with information through the platform, and we will treat such information in accordance with this Privacy Policy.\n\nInformation we obtain from other third parties. We may receive personal information about you from third-party sources. For example, a business partner may share your contact information with us if you have expressed interest in learning specifically about our products or services, or the types of products or services we offer. We may obtain your personal information from other third parties, such as marketing partners, publicly-available sources and data providers.\n\nCookies and Other Information Collected by Automated Means\n\nWe, our service providers, and our business partners may automatically log information about you, your computer or mobile device, and activity occurring on or through the Service, including but not limited, your computer or mobile device operating system type and version number, manufacturer and model, device identifier (such as the Google Advertising ID or Apple ID for Advertising), browser type, screen resolution, IP address, the website you visited before browsing to our website, general location information such as city, state or geographic area; information about your use of and actions on the Service, such as pages or screens you viewed, how long you spent on a page or screen, navigation paths between pages or screens, information about your activity on a page or screen, access times, and length of access; and other personal information. Our service providers and business partners may collect this type of information over time and across third-party websites and mobile applications.\n\nOn our webpages, this information is collected using cookies, browser web storage (also known as locally stored objects, or “LSOs”), and similar technologies.\n\nA “cookie” is a text file that websites send to a visitor‘s computer or other Internet-connected device to uniquely identify the visitor’s browser or to store information or settings in the browser. Browser web storage, or LSOs, are used for similar purposes as cookies. Browser web storage enables the storage of a larger amount of data than cookies.\n\nWeb browsers may offer users of our websites or mobile apps the ability to disable receiving certain types of cookies; however, if cookies are disabled, some features or functionality of our websites may not function correctly. Please see the “Targeted online advertising” section for information about how to exercise choice regarding the use of browsing behavior for purposes of targeted advertising.\n',
      name: 'envoy_account_privacy_policy_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_account_privacy_policy_os_modal_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_privacy_policy_os_modal_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_account_email_verify_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_email_verify_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_account_email_verify_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_account_email_verify_right_action',
      desc: '',
      args: [],
    );
  }

  /// `We’ve sent a verification link to your email address`
  String get envoy_account_email_verify_heading {
    return Intl.message(
      'We’ve sent a verification link to your email address',
      name: 'envoy_account_email_verify_heading',
      desc: '',
      args: [],
    );
  }

  /// `We just need to verify your email address. Please choose a method below.`
  String get envoy_account_email_verify_subheading {
    return Intl.message(
      'We just need to verify your email address. Please choose a method below.',
      name: 'envoy_account_email_verify_subheading',
      desc: '',
      args: [],
    );
  }

  /// `\nusername@emailprovider.com`
  String get envoy_account_email_verify_user_input {
    return Intl.message(
      '\nusername@emailprovider.com',
      name: 'envoy_account_email_verify_user_input',
      desc: '',
      args: [],
    );
  }

  /// `open the link using your email app`
  String get envoy_account_email_verify_cta {
    return Intl.message(
      'open the link using your email app',
      name: 'envoy_account_email_verify_cta',
      desc: '',
      args: [],
    );
  }

  /// `Scan the link using a separate device `
  String get envoy_account_email_verify_cta1 {
    return Intl.message(
      'Scan the link using a separate device ',
      name: 'envoy_account_email_verify_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Leave this app`
  String get envoy_account_leave_app_os_modal_heading {
    return Intl.message(
      'Leave this app',
      name: 'envoy_account_leave_app_os_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please choose your email application from the list`
  String get envoy_account_leave_app_os_modal_subheading {
    return Intl.message(
      'Please choose your email application from the list',
      name: 'envoy_account_leave_app_os_modal_subheading',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get envoy_account_leave_app_os_modal_allow {
    return Intl.message(
      'OK',
      name: 'envoy_account_leave_app_os_modal_allow',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get envoy_account_leave_app_os_modal_reject {
    return Intl.message(
      'Back',
      name: 'envoy_account_leave_app_os_modal_reject',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations!\nYour account has been setup successfully`
  String get envoy_mobile_intro_card1_heading {
    return Intl.message(
      'Congratulations!\nYour account has been setup successfully',
      name: 'envoy_mobile_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Next, Envoy will guide you through the creation of the three keys that will be used to secure your Bitcoin. \n\n1x Mobile Key (backed up securely to your cloud provider)\n1x Passport Key\n1x Secure and anonymous recovery key (held on the Envoy server)`
  String get envoy_mobile_intro_card1_subheading {
    return Intl.message(
      'Next, Envoy will guide you through the creation of the three keys that will be used to secure your Bitcoin. \n\n1x Mobile Key (backed up securely to your cloud provider)\n1x Passport Key\n1x Secure and anonymous recovery key (held on the Envoy server)',
      name: 'envoy_mobile_intro_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `First, let’s create your Envoy mobile key`
  String get envoy_mobile_intro_card2_heading {
    return Intl.message(
      'First, let’s create your Envoy mobile key',
      name: 'envoy_mobile_intro_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Click continue to automatically generate your mobile key.`
  String get envoy_mobile_intro_card2_subheading {
    return Intl.message(
      'Click continue to automatically generate your mobile key.',
      name: 'envoy_mobile_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_mobile_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_mobile_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_mobile_create_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_mobile_create_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Securely creating your mobile key`
  String get envoy_mobile_create_heading {
    return Intl.message(
      'Securely creating your mobile key',
      name: 'envoy_mobile_create_heading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_mobile_create_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_create_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_create_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_create_cta',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Key\nsecurely created`
  String get envoy_mobile_backup_intro_card1_heading {
    return Intl.message(
      'Mobile Key\nsecurely created',
      name: 'envoy_mobile_backup_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `You’ll be able to view the seed words for this key in the settings after setup is complete.`
  String get envoy_mobile_backup_intro_card1_subheading {
    return Intl.message(
      'You’ll be able to view the seed words for this key in the settings after setup is complete.',
      name: 'envoy_mobile_backup_intro_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Let’s backup your mobile key to your cloud`
  String get envoy_mobile_backup_intro_card2_heading {
    return Intl.message(
      'Let’s backup your mobile key to your cloud',
      name: 'envoy_mobile_backup_intro_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Part of the key is stored in your cloud and the other on the recovery server.\n\nThis step ensures your mobile key is recoverable in the event that you lose your phone.\n\nUpon signing into Envoy on your new phone, both parts are pulled from their respective storage locations and combined to recreate your mobile key.`
  String get envoy_mobile_backup_intro_card2_subheading {
    return Intl.message(
      'Part of the key is stored in your cloud and the other on the recovery server.\n\nThis step ensures your mobile key is recoverable in the event that you lose your phone.\n\nUpon signing into Envoy on your new phone, both parts are pulled from their respective storage locations and combined to recreate your mobile key.',
      name: 'envoy_mobile_backup_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_mobile_backup_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_backup_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_backup_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_backup_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_mobile_cloud_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_cloud_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_mobile_cloud_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_mobile_cloud_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Backup Option`
  String get envoy_mobile_cloud_heading {
    return Intl.message(
      'Cloud Backup Option',
      name: 'envoy_mobile_cloud_heading',
      desc: '',
      args: [],
    );
  }

  /// `apple ID\ngoogle ID\nNextcloud\nCalyx [Nextcloud]\n\nDisclosure Text\nabout information storag TBC`
  String get envoy_mobile_cloud_subheading {
    return Intl.message(
      'apple ID\ngoogle ID\nNextcloud\nCalyx [Nextcloud]\n\nDisclosure Text\nabout information storag TBC',
      name: 'envoy_mobile_cloud_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_cloud_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_cloud_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_mobile_cloud_skip_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_cloud_skip_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_mobile_cloud_skip_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_mobile_cloud_skip_right_action',
      desc: '',
      args: [],
    );
  }

  /// `WARNING`
  String get envoy_mobile_cloud_skip_heading {
    return Intl.message(
      'WARNING',
      name: 'envoy_mobile_cloud_skip_heading',
      desc: '',
      args: [],
    );
  }

  /// `Losing access to your phone could result in the loss of this key without a proper manual backup.`
  String get envoy_mobile_cloud_skip_subheading {
    return Intl.message(
      'Losing access to your phone could result in the loss of this key without a proper manual backup.',
      name: 'envoy_mobile_cloud_skip_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_cloud_skip_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_cloud_skip_cta',
      desc: '',
      args: [],
    );
  }

  /// `Mobile key backup configured`
  String get envoy_mobile_backup_confirm_card1_heading {
    return Intl.message(
      'Mobile key backup configured',
      name: 'envoy_mobile_backup_confirm_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your mobile key has been successfully backup up to the cloud.`
  String get envoy_mobile_backup_confirm_card1_subheading {
    return Intl.message(
      'Your mobile key has been successfully backup up to the cloud.',
      name: 'envoy_mobile_backup_confirm_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Next, let’s set up your Passport`
  String get envoy_mobile_backup_confirm_card2_heading {
    return Intl.message(
      'Next, let’s set up your Passport',
      name: 'envoy_mobile_backup_confirm_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passport forms the 2nd of the 3 keys required to create your Envoy Shield. `
  String get envoy_mobile_backup_confirm_card2_subheading {
    return Intl.message(
      'Passport forms the 2nd of the 3 keys required to create your Envoy Shield. ',
      name: 'envoy_mobile_backup_confirm_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_mobile_backup_confirm_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_backup_confirm_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_mobile_backup_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_backup_confirm_cta',
      desc: '',
      args: [],
    );
  }

  /// `How would you like to set up your Passport?`
  String get envoy_pp_setup_intro_card1_heading {
    return Intl.message(
      'How would you like to set up your Passport?',
      name: 'envoy_pp_setup_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `As a new owner of a Passport you can create a new key. You can also restore a wallet using seed words, or restore a backup from an existing Passport.`
  String get envoy_pp_setup_intro_card1_subheading {
    return Intl.message(
      'As a new owner of a Passport you can create a new key. You can also restore a wallet using seed words, or restore a backup from an existing Passport.',
      name: 'envoy_pp_setup_intro_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get envoy_pp_setup_intro_card2_heading {
    return Intl.message(
      'Create New Seed',
      name: 'envoy_pp_setup_intro_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `New owner/new passport`
  String get envoy_pp_setup_intro_card2_subheading {
    return Intl.message(
      'New owner/new passport',
      name: 'envoy_pp_setup_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get envoy_pp_setup_intro_card3_heading {
    return Intl.message(
      'Restore Seed',
      name: 'envoy_pp_setup_intro_card3_heading',
      desc: '',
      args: [],
    );
  }

  /// `Restore Wallet using seed words`
  String get envoy_pp_setup_intro_card3_subheading {
    return Intl.message(
      'Restore Wallet using seed words',
      name: 'envoy_pp_setup_intro_card3_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get envoy_pp_setup_intro_card4_heading {
    return Intl.message(
      'Restore Backup',
      name: 'envoy_pp_setup_intro_card4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Migrating from an existing Passport\n`
  String get envoy_pp_setup_intro_card4_subheading {
    return Intl.message(
      'Migrating from an existing Passport\n',
      name: 'envoy_pp_setup_intro_card4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_setup_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_setup_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_setup_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_setup_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_new_seed_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_new_seed_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_new_seed_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_new_seed_right_action',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select \nCreate New Seed`
  String get envoy_pp_new_seed_heading {
    return Intl.message(
      'On Passport, select \nCreate New Seed',
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
  String get envoy_pp_new_seed_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_new_seed_backup_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_new_seed_backup_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_new_seed_backup_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_new_seed_backup_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Next, create an encrypted backup of your seed`
  String get envoy_pp_new_seed_backup_heading {
    return Intl.message(
      'Next, create an encrypted backup of your seed',
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
  String get envoy_pp_new_seed_backup_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_backup_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_new_seed_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_new_seed_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_new_seed_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_new_seed_success_right_action',
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

  /// `Next`
  String get envoy_pp_new_seed_success_cta {
    return Intl.message(
      'Next',
      name: 'envoy_pp_new_seed_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_restore_seed_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_seed_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_seed_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_seed_right_action',
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

  /// `Use this feature to restore an existing 12, 18, or 24 word seed.`
  String get envoy_pp_restore_seed_subheading {
    return Intl.message(
      'Use this feature to restore an existing 12, 18, or 24 word seed.',
      name: 'envoy_pp_restore_seed_subheading',
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

  /// `9:41`
  String get envoy_pp_restore_seed_backup_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_seed_backup_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_seed_backup_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_seed_backup_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Create encrypted backup?`
  String get envoy_pp_restore_seed_backup_heading {
    return Intl.message(
      'Create encrypted backup?',
      name: 'envoy_pp_restore_seed_backup_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is an optional but recommended step to backup your wallet seed. Head to Settings > Backup > Create Backup`
  String get envoy_pp_restore_seed_backup_subheading {
    return Intl.message(
      'This is an optional but recommended step to backup your wallet seed. Head to Settings > Backup > Create Backup',
      name: 'envoy_pp_restore_seed_backup_subheading',
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

  /// `9:41`
  String get envoy_pp_restore_seed_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_seed_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_seed_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_seed_success_right_action',
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

  /// `Next, we will connect Envoy and Passport.`
  String get envoy_pp_restore_seed_success_subheading {
    return Intl.message(
      'Next, we will connect Envoy and Passport.',
      name: 'envoy_pp_restore_seed_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get envoy_pp_restore_seed_success_cta {
    return Intl.message(
      'Next',
      name: 'envoy_pp_restore_seed_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_pp_restore_backup_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_backup_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_backup_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_backup_right_action',
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

  /// `Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the backup password to decrypt the backup.`
  String get envoy_pp_restore_backup_subheading {
    return Intl.message(
      'Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the backup password to decrypt the backup.',
      name: 'envoy_pp_restore_backup_subheading',
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

  /// `9:41`
  String get envoy_pp_restore_backup_password_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_backup_password_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_backup_password_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_backup_password_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Enter your encryption words`
  String get envoy_pp_restore_backup_password_heading {
    return Intl.message(
      'Enter your encryption words',
      name: 'envoy_pp_restore_backup_password_heading',
      desc: '',
      args: [],
    );
  }

  /// `To decrypt the backup file, enter the 6 word backup password.`
  String get envoy_pp_restore_backup_password_subheading {
    return Intl.message(
      'To decrypt the backup file, enter the 6 word backup password.',
      name: 'envoy_pp_restore_backup_password_subheading',
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

  /// `9:41`
  String get envoy_pp_restore_backup_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_backup_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_pp_restore_backup_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_pp_restore_backup_success_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Your backup file has been restored successfully.`
  String get envoy_pp_restore_backup_success_heading {
    return Intl.message(
      'Your backup file has been restored successfully.',
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

  /// `Next`
  String get envoy_pp_restore_backup_success_cta {
    return Intl.message(
      'Next',
      name: 'envoy_pp_restore_backup_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `Connect Passport with Envoy`
  String get single_envoy_import_pp_intro_card1_heading {
    return Intl.message(
      'Connect Passport with Envoy',
      name: 'single_envoy_import_pp_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Connect Wallet > Envoy`
  String get single_envoy_import_pp_intro_card1_subheading {
    return Intl.message(
      'On Passport, select Connect Wallet > Envoy',
      name: 'single_envoy_import_pp_intro_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `If you want to use Envoy for firmware updates only, feel free to skip this step.`
  String get single_envoy_import_pp_intro_card2_subheading {
    return Intl.message(
      'If you want to use Envoy for firmware updates only, feel free to skip this step.',
      name: 'single_envoy_import_pp_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get single_envoy_import_pp_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'single_envoy_import_pp_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get single_envoy_import_pp_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'single_envoy_import_pp_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get single_envoy_import_pp_intro_cta {
    return Intl.message(
      'Get Started',
      name: 'single_envoy_import_pp_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_import_pp_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_import_pp_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_import_pp_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_import_pp_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Follow Envoy connection flow on Passport`
  String get envoy_import_pp_intro_heading {
    return Intl.message(
      'Follow Envoy connection flow on Passport',
      name: 'envoy_import_pp_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Connect Wallet > Envoy`
  String get envoy_import_pp_intro_subheading {
    return Intl.message(
      'On Passport, select Connect Wallet > Envoy',
      name: 'envoy_import_pp_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get envoy_import_pp_intro_cta {
    return Intl.message(
      'Get Started',
      name: 'envoy_import_pp_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get single_envoy_import_pp_scan_os_clock {
    return Intl.message(
      '9:41',
      name: 'single_envoy_import_pp_scan_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get single_envoy_import_pp_scan_right_action {
    return Intl.message(
      'Skip',
      name: 'single_envoy_import_pp_scan_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code that Passport generates`
  String get single_envoy_import_pp_scan_heading {
    return Intl.message(
      'Scan the QR code that Passport generates',
      name: 'single_envoy_import_pp_scan_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR code contains the information required for Envoy to interact securely with Passport.`
  String get single_envoy_import_pp_scan_subheading {
    return Intl.message(
      'This QR code contains the information required for Envoy to interact securely with Passport.',
      name: 'single_envoy_import_pp_scan_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get single_envoy_import_pp_scan_cta {
    return Intl.message(
      'Continue',
      name: 'single_envoy_import_pp_scan_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_import_pp_scan_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_import_pp_scan_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_import_pp_scan_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_import_pp_scan_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Next, scan the QR code that Passport generates`
  String get envoy_import_pp_scan_heading {
    return Intl.message(
      'Next, scan the QR code that Passport generates',
      name: 'envoy_import_pp_scan_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR code contains the information required for Envoy to include Passport in the multisig setup.`
  String get envoy_import_pp_scan_subheading {
    return Intl.message(
      'This QR code contains the information required for Envoy to include Passport in the multisig setup.',
      name: 'envoy_import_pp_scan_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_import_pp_scan_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_import_pp_scan_cta',
      desc: '',
      args: [],
    );
  }

  /// `Your Passport key has been imported.`
  String get envoy_recovery_intro_card1_heading {
    return Intl.message(
      'Your Passport key has been imported.',
      name: 'envoy_recovery_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Finally, let’s create your recovery key`
  String get envoy_recovery_intro_card2_heading {
    return Intl.message(
      'Finally, let’s create your recovery key',
      name: 'envoy_recovery_intro_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `The recovery key is stored sceurely on the Envoy server and is used to recover funds if you lose access to either your mobile or Passport key.`
  String get envoy_recovery_intro_card2_subheading {
    return Intl.message(
      'The recovery key is stored sceurely on the Envoy server and is used to recover funds if you lose access to either your mobile or Passport key.',
      name: 'envoy_recovery_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_recovery_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_recovery_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_recovery_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_recovery_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_recovery_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Your recovery key is protected 3 security questions.`
  String get envoy_recovery_question_intro_card1_heading {
    return Intl.message(
      'Your recovery key is protected 3 security questions.',
      name: 'envoy_recovery_question_intro_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Keep the answers to these questions safe!`
  String get envoy_recovery_question_intro_card2_heading {
    return Intl.message(
      'Keep the answers to these questions safe!',
      name: 'envoy_recovery_question_intro_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `In the unlikely event that you need the help of the recovery key to transfer your Bitcoin to a new multisig setup, Envoy will ask you to provide the answers to these questions.  `
  String get envoy_recovery_question_intro_card2_subheading {
    return Intl.message(
      'In the unlikely event that you need the help of the recovery key to transfer your Bitcoin to a new multisig setup, Envoy will ask you to provide the answers to these questions.  ',
      name: 'envoy_recovery_question_intro_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_recovery_question_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_recovery_question_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_recovery_question_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_recovery_question_intro_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_recovery_question_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_question_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `What is your favourite colour?`
  String get envoy_recovery_question_card1_heading {
    return Intl.message(
      'What is your favourite colour?',
      name: 'envoy_recovery_question_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 1`
  String get envoy_recovery_question_card1_subheading {
    return Intl.message(
      'Question 1',
      name: 'envoy_recovery_question_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Type your answer here...`
  String get envoy_recovery_question_card1_user_input {
    return Intl.message(
      'Type your answer here...',
      name: 'envoy_recovery_question_card1_user_input',
      desc: '',
      args: [],
    );
  }

  /// `What is your favourite food?`
  String get envoy_recovery_question_card2_heading {
    return Intl.message(
      'What is your favourite food?',
      name: 'envoy_recovery_question_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 2`
  String get envoy_recovery_question_card2_subheading {
    return Intl.message(
      'Question 2',
      name: 'envoy_recovery_question_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Type your answer here...`
  String get envoy_recovery_question_card2_user_input {
    return Intl.message(
      'Type your answer here...',
      name: 'envoy_recovery_question_card2_user_input',
      desc: '',
      args: [],
    );
  }

  /// `What was the name of your first pet?`
  String get envoy_recovery_question_card3_heading {
    return Intl.message(
      'What was the name of your first pet?',
      name: 'envoy_recovery_question_card3_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 3`
  String get envoy_recovery_question_card3_subheading {
    return Intl.message(
      'Question 3',
      name: 'envoy_recovery_question_card3_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Type your answer here...`
  String get envoy_recovery_question_card3_user_input {
    return Intl.message(
      'Type your answer here...',
      name: 'envoy_recovery_question_card3_user_input',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_recovery_question_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_recovery_question_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_recovery_question_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_recovery_question_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_recovery_question_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_recovery_question_cta',
      desc: '',
      args: [],
    );
  }

  /// `What is your favourite colour?`
  String get envoy_recovery_question_entry_card1_heading {
    return Intl.message(
      'What is your favourite colour?',
      name: 'envoy_recovery_question_entry_card1_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 1`
  String get envoy_recovery_question_entry_card1_subheading {
    return Intl.message(
      'Question 1',
      name: 'envoy_recovery_question_entry_card1_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Copper`
  String get envoy_recovery_question_entry_card_1user_input {
    return Intl.message(
      'Copper',
      name: 'envoy_recovery_question_entry_card_1user_input',
      desc: '',
      args: [],
    );
  }

  /// `What is your favourite food?`
  String get envoy_recovery_question_entry_card2_heading {
    return Intl.message(
      'What is your favourite food?',
      name: 'envoy_recovery_question_entry_card2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 2`
  String get envoy_recovery_question_entry_card2_subheading {
    return Intl.message(
      'Question 2',
      name: 'envoy_recovery_question_entry_card2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Pizza`
  String get envoy_recovery_question_entry_user_card2_input {
    return Intl.message(
      'Pizza',
      name: 'envoy_recovery_question_entry_user_card2_input',
      desc: '',
      args: [],
    );
  }

  /// `What was the name of your first pet?`
  String get envoy_recovery_question_entry_card3_heading {
    return Intl.message(
      'What was the name of your first pet?',
      name: 'envoy_recovery_question_entry_card3_heading',
      desc: '',
      args: [],
    );
  }

  /// `Question 3`
  String get envoy_recovery_question_entry_card3_subheading {
    return Intl.message(
      'Question 3',
      name: 'envoy_recovery_question_entry_card3_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Dog`
  String get envoy_recovery_question_entry_card3_user_input {
    return Intl.message(
      'Dog',
      name: 'envoy_recovery_question_entry_card3_user_input',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_recovery_question_entry_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_recovery_question_entry_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_recovery_question_entry_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_recovery_question_entry_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get envoy_recovery_question_entry_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_recovery_question_entry_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_recovery_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_recovery_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_recovery_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_recovery_success_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Your recovery key has been created. \n\nKeep your security answers safe. Foundation cannot assist in recovering them.`
  String get envoy_recovery_success_heading {
    return Intl.message(
      'Your recovery key has been created. \n\nKeep your security answers safe. Foundation cannot assist in recovering them.',
      name: 'envoy_recovery_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `You can verify the answers to your security questions at any time.`
  String get envoy_recovery_success_subheading {
    return Intl.message(
      'You can verify the answers to your security questions at any time.',
      name: 'envoy_recovery_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_recovery_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_create_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_create_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_create_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_create_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Create Multisig?`
  String get envoy_wallet_create_heading {
    return Intl.message(
      'Create Multisig?',
      name: 'envoy_wallet_create_heading',
      desc: '',
      args: [],
    );
  }

  /// `Using a combination of your Mobile Key, Passport Key, and the Recovery Key, Envoy will now create a multisignature wallet where 2 out of those 3 keys are required to authorise any spends.`
  String get envoy_wallet_create_subheading {
    return Intl.message(
      'Using a combination of your Mobile Key, Passport Key, and the Recovery Key, Envoy will now create a multisignature wallet where 2 out of those 3 keys are required to authorise any spends.',
      name: 'envoy_wallet_create_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get envoy_wallet_create_cta {
    return Intl.message(
      'Yes',
      name: 'envoy_wallet_create_cta',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get envoy_wallet_create_cta1 {
    return Intl.message(
      'No',
      name: 'envoy_wallet_create_cta1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get single_envoy_wallet_pair_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'single_envoy_wallet_pair_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get single_envoy_wallet_pair_success_right_action {
    return Intl.message(
      'Skip',
      name: 'single_envoy_wallet_pair_success_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Connection successful`
  String get single_envoy_wallet_pair_success_heading {
    return Intl.message(
      'Connection successful',
      name: 'single_envoy_wallet_pair_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is now connected to your Passport.`
  String get single_envoy_wallet_pair_success_subheading {
    return Intl.message(
      'Envoy is now connected to your Passport.',
      name: 'single_envoy_wallet_pair_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Validate receive address`
  String get single_envoy_wallet_pair_success_cta {
    return Intl.message(
      'Validate receive address',
      name: 'single_envoy_wallet_pair_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `Continue to home screen`
  String get single_envoy_wallet_pair_success_cta1 {
    return Intl.message(
      'Continue to home screen',
      name: 'single_envoy_wallet_pair_success_cta1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_create_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_create_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_create_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_create_success_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Creation Success`
  String get envoy_wallet_create_success_heading {
    return Intl.message(
      'Wallet Creation Success',
      name: 'envoy_wallet_create_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations, your multisig wallet has been created. We just have a couple more steps before you are free to use the wallet to manage your Bitcoin.\n\nFirst off, let’s tell Passport about the new wallet configuration.`
  String get envoy_wallet_create_success_subheading {
    return Intl.message(
      'Congratulations, your multisig wallet has been created. We just have a couple more steps before you are free to use the wallet to manage your Bitcoin.\n\nFirst off, let’s tell Passport about the new wallet configuration.',
      name: 'envoy_wallet_create_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_wallet_create_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_wallet_create_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_create_fail_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_create_fail_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_create_fail_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_create_fail_right_action',
      desc: '',
      args: [],
    );
  }

  /// `There was a problem creating your wallet`
  String get envoy_wallet_create_fail_heading {
    return Intl.message(
      'There was a problem creating your wallet',
      name: 'envoy_wallet_create_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Please try again or contact support`
  String get envoy_wallet_create_fail_subheading {
    return Intl.message(
      'Please try again or contact support',
      name: 'envoy_wallet_create_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get envoy_wallet_create_fail_cta {
    return Intl.message(
      'Retry',
      name: 'envoy_wallet_create_fail_cta',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get envoy_wallet_create_fail_cta1 {
    return Intl.message(
      'Contact support',
      name: 'envoy_wallet_create_fail_cta1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_show_qr_export_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_show_qr_export_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_show_qr_export_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_show_qr_export_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to tell it about your Envoy wallet `
  String get envoy_wallet_show_qr_export_heading {
    return Intl.message(
      'Scan this QR code with Passport to tell it about your Envoy wallet ',
      name: 'envoy_wallet_show_qr_export_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR contains the info Passport needs to authorise transactions for the multisig wallet. `
  String get envoy_wallet_show_qr_export_subheading {
    return Intl.message(
      'This QR contains the info Passport needs to authorise transactions for the multisig wallet. ',
      name: 'envoy_wallet_show_qr_export_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_wallet_show_qr_export_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_wallet_show_qr_export_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_pair_success_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_pair_success_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_pair_success_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_pair_success_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet has been connected successfully`
  String get envoy_wallet_pair_success_heading {
    return Intl.message(
      'Your wallet has been connected successfully',
      name: 'envoy_wallet_pair_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Your Envoy Shield setup is now complete. You can confirm this by verifying a receive address on the next screen.`
  String get envoy_wallet_pair_success_subheading {
    return Intl.message(
      'Your Envoy Shield setup is now complete. You can confirm this by verifying a receive address on the next screen.',
      name: 'envoy_wallet_pair_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Validate receive address`
  String get envoy_wallet_pair_success_cta {
    return Intl.message(
      'Validate receive address',
      name: 'envoy_wallet_pair_success_cta',
      desc: '',
      args: [],
    );
  }

  /// `Continue to home screen`
  String get envoy_wallet_pair_success_cta1 {
    return Intl.message(
      'Continue to home screen',
      name: 'envoy_wallet_pair_success_cta1',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get single_envoy_wallet_address_verify_os_clock {
    return Intl.message(
      '9:41',
      name: 'single_envoy_wallet_address_verify_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get single_envoy_wallet_address_verify_right_action {
    return Intl.message(
      'Skip',
      name: 'single_envoy_wallet_address_verify_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to validate`
  String get single_envoy_wallet_address_verify_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate',
      name: 'single_envoy_wallet_address_verify_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is a Bitcoin address belonging to your Passport.`
  String get single_envoy_wallet_address_verify_subheading {
    return Intl.message(
      'This is a Bitcoin address belonging to your Passport.',
      name: 'single_envoy_wallet_address_verify_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get single_envoy_wallet_address_verify_cta {
    return Intl.message(
      'Continue',
      name: 'single_envoy_wallet_address_verify_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_address_verify_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_address_verify_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_address_verify_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_address_verify_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to validate the receive address`
  String get envoy_wallet_address_verify_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate the receive address',
      name: 'envoy_wallet_address_verify_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is the first address in your Envoy Shield wallet.`
  String get envoy_wallet_address_verify_subheading {
    return Intl.message(
      'This is the first address in your Envoy Shield wallet.',
      name: 'envoy_wallet_address_verify_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_wallet_address_verify_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_wallet_address_verify_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get single_envoy_wallet_address_verify_confirm_os_clock {
    return Intl.message(
      '9:41',
      name: 'single_envoy_wallet_address_verify_confirm_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get single_envoy_wallet_address_verify_confirm_right_action {
    return Intl.message(
      'Skip',
      name: 'single_envoy_wallet_address_verify_confirm_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Address Validated?`
  String get single_envoy_wallet_address_verify_confirm_heading {
    return Intl.message(
      'Address Validated?',
      name: 'single_envoy_wallet_address_verify_confirm_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get single_envoy_wallet_address_verify_confirm_subheading {
    return Intl.message(
      'If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'single_envoy_wallet_address_verify_confirm_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get single_envoy_wallet_address_verify_confirm_cta1 {
    return Intl.message(
      'Contact support',
      name: 'single_envoy_wallet_address_verify_confirm_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get single_envoy_wallet_address_verify_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'single_envoy_wallet_address_verify_confirm_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_wallet_address_verify_confirm_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_wallet_address_verify_confirm_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_wallet_address_verify_confirm_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_wallet_address_verify_confirm_right_action',
      desc: '',
      args: [],
    );
  }

  /// `Address Validated?`
  String get envoy_wallet_address_verify_confirm_heading {
    return Intl.message(
      'Address Validated?',
      name: 'envoy_wallet_address_verify_confirm_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you get a success message on Passport, your wallet setup is complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get envoy_wallet_address_verify_confirm_subheading {
    return Intl.message(
      'If you get a success message on Passport, your wallet setup is complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'envoy_wallet_address_verify_confirm_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get envoy_wallet_address_verify_confirm_cta1 {
    return Intl.message(
      'Contact support',
      name: 'envoy_wallet_address_verify_confirm_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_wallet_address_verify_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_wallet_address_verify_confirm_cta',
      desc: '',
      args: [],
    );
  }

  /// `9:41`
  String get envoy_fw_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_fw_intro_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get envoy_fw_intro_right_action {
    return Intl.message(
      'Skip',
      name: 'envoy_fw_intro_right_action',
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

  /// `Envoy allows you to update your Passport from your phone, using the included microSD adapter.\n\nAdvanced users can {{tap here}} to download and verify their own firmware on a computer.`
  String get envoy_fw_intro_subheading {
    return Intl.message(
      'Envoy allows you to update your Passport from your phone, using the included microSD adapter.\n\nAdvanced users can {{tap here}} to download and verify their own firmware on a computer.',
      name: 'envoy_fw_intro_subheading',
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

  /// `9:41`
  String get envoy_passport_tou_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_passport_tou_os_clock',
      desc: '',
      args: [],
    );
  }

  /// `Please review and accept the Passport Terms of Use`
  String get envoy_passport_tou_heading {
    return Intl.message(
      'Please review and accept the Passport Terms of Use',
      name: 'envoy_passport_tou_heading',
      desc: '',
      args: [],
    );
  }

  /// `TOU to be inserted here.`
  String get envoy_passport_tou_subheading {
    return Intl.message(
      'TOU to be inserted here.',
      name: 'envoy_passport_tou_subheading',
      desc: '',
      args: [],
    );
  }

  /// `I Accept`
  String get envoy_passport_tou_cta {
    return Intl.message(
      'I Accept',
      name: 'envoy_passport_tou_cta',
      desc: '',
      args: [],
    );
  }

  /// `Send Max`
  String get envoy_send_send_max {
    return Intl.message(
      'Send Max',
      name: 'envoy_send_send_max',
      desc: '',
      args: [],
    );
  }

  /// `Enter Valid Address`
  String get envoy_send_enter_valid_address {
    return Intl.message(
      'Enter Valid Address',
      name: 'envoy_send_enter_valid_address',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient Funds`
  String get envoy_send_insufficient_funds {
    return Intl.message(
      'Insufficient Funds',
      name: 'envoy_send_insufficient_funds',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR on your Passport`
  String get envoy_psbt_scan_qr {
    return Intl.message(
      'Scan the QR on your Passport',
      name: 'envoy_psbt_scan_qr',
      desc: '',
      args: [],
    );
  }

  /// `It contains the transaction for your Passport to sign.`
  String get envoy_psbt_explainer {
    return Intl.message(
      'It contains the transaction for your Passport to sign.',
      name: 'envoy_psbt_explainer',
      desc: '',
      args: [],
    );
  }

  /// `PSBT copied to clipboard!`
  String get envoy_psbt_copied_clipboard {
    return Intl.message(
      'PSBT copied to clipboard!',
      name: 'envoy_psbt_copied_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Transaction sent!`
  String get envoy_psbt_transaction_sent {
    return Intl.message(
      'Transaction sent!',
      name: 'envoy_psbt_transaction_sent',
      desc: '',
      args: [],
    );
  }

  /// `Not able to broadcast transaction.`
  String get envoy_psbt_transaction_not_sent {
    return Intl.message(
      'Not able to broadcast transaction.',
      name: 'envoy_psbt_transaction_not_sent',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get envoy_fee_standard {
    return Intl.message(
      'Standard',
      name: 'envoy_fee_standard',
      desc: '',
      args: [],
    );
  }

  /// `60 min`
  String get envoy_fee_60_min {
    return Intl.message(
      '60 min',
      name: 'envoy_fee_60_min',
      desc: '',
      args: [],
    );
  }

  /// `Boost`
  String get envoy_fee_boost {
    return Intl.message(
      'Boost',
      name: 'envoy_fee_boost',
      desc: '',
      args: [],
    );
  }

  /// `10 min`
  String get envoy_fee_10_min {
    return Intl.message(
      '10 min',
      name: 'envoy_fee_10_min',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get envoy_confirmation_confirm {
    return Intl.message(
      'Confirm',
      name: 'envoy_confirmation_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Make sure not to share this descriptor unless you are comfortable with your transactions being public.`
  String get envoy_descriptor_explainer {
    return Intl.message(
      'Make sure not to share this descriptor unless you are comfortable with your transactions being public.',
      name: 'envoy_descriptor_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Descriptor copied to clipboard!`
  String get envoy_descriptor_copied_clipboard {
    return Intl.message(
      'Descriptor copied to clipboard!',
      name: 'envoy_descriptor_copied_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to send Bitcoin?`
  String get envoy_broadcast_are_you_sure {
    return Intl.message(
      'Are you sure you want to send Bitcoin?',
      name: 'envoy_broadcast_are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get envoy_broadcast_fee {
    return Intl.message(
      'Fee',
      name: 'envoy_broadcast_fee',
      desc: '',
      args: [],
    );
  }

  /// `Transaction ID:`
  String get envoy_broadcast_transaction_id {
    return Intl.message(
      'Transaction ID:',
      name: 'envoy_broadcast_transaction_id',
      desc: '',
      args: [],
    );
  }

  /// `For privacy, we create a new address each time you visit this screen.`
  String get envoy_address_explainer {
    return Intl.message(
      'For privacy, we create a new address each time you visit this screen.',
      name: 'envoy_address_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Address copied to clipboard!`
  String get envoy_address_copied_clipboard {
    return Intl.message(
      'Address copied to clipboard!',
      name: 'envoy_address_copied_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Transaction ID copied to clipboard!`
  String get envoy_account_transaction_copied_clipboard {
    return Intl.message(
      'Transaction ID copied to clipboard!',
      name: 'envoy_account_transaction_copied_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Awaiting confirmation`
  String get envoy_account_awaiting_confirmation {
    return Intl.message(
      'Awaiting confirmation',
      name: 'envoy_account_awaiting_confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get envoy_account_sent {
    return Intl.message(
      'Sent',
      name: 'envoy_account_sent',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get envoy_account_received {
    return Intl.message(
      'Received',
      name: 'envoy_account_received',
      desc: '',
      args: [],
    );
  }

  /// `Show Descriptor`
  String get envoy_account_show_descriptor {
    return Intl.message(
      'Show Descriptor',
      name: 'envoy_account_show_descriptor',
      desc: '',
      args: [],
    );
  }

  /// `Edit account name`
  String get envoy_account_edit_name {
    return Intl.message(
      'Edit account name',
      name: 'envoy_account_edit_name',
      desc: '',
      args: [],
    );
  }

  /// `Rename Account`
  String get envoy_account_rename {
    return Intl.message(
      'Rename Account',
      name: 'envoy_account_rename',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get envoy_account_delete_are_you_sure {
    return Intl.message(
      'Are you sure?',
      name: 'envoy_account_delete_are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `This only removes the account from Envoy.`
  String get envoy_account_delete_explainer {
    return Intl.message(
      'This only removes the account from Envoy.',
      name: 'envoy_account_delete_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Rename Device`
  String get envoy_device_rename {
    return Intl.message(
      'Rename Device',
      name: 'envoy_device_rename',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disconnect ${device.name}?`
  String get envoy_device_delete_are_you_sure {
    return Intl.message(
      'Are you sure you want to disconnect \${device.name}?',
      name: 'envoy_device_delete_are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `This will remove the device from Envoy alongside any connected accounts.`
  String get envoy_device_delete_explainer {
    return Intl.message(
      'This will remove the device from Envoy alongside any connected accounts.',
      name: 'envoy_device_delete_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Serial`
  String get envoy_device_serial {
    return Intl.message(
      'Serial',
      name: 'envoy_device_serial',
      desc: '',
      args: [],
    );
  }

  /// `Paired`
  String get envoy_device_paired {
    return Intl.message(
      'Paired',
      name: 'envoy_device_paired',
      desc: '',
      args: [],
    );
  }

  /// `Edit device name`
  String get envoy_device_edit_device_name {
    return Intl.message(
      'Edit device name',
      name: 'envoy_device_edit_device_name',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get envoy_about_app_version {
    return Intl.message(
      'App Version',
      name: 'envoy_about_app_version',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licences`
  String get envoy_about_licences {
    return Intl.message(
      'Open Source Licences',
      name: 'envoy_about_licences',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get envoy_about_show {
    return Intl.message(
      'Show',
      name: 'envoy_about_show',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Use`
  String get envoy_about_terms_of_use {
    return Intl.message(
      'Terms of Use',
      name: 'envoy_about_terms_of_use',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get envoy_about_privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'envoy_about_privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to the Tor Network`
  String get envoy_video_player_connecting_tor {
    return Intl.message(
      'Connecting to the Tor Network',
      name: 'envoy_video_player_connecting_tor',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is loading your video over the Tor Network`
  String get envoy_video_player_loading_tor {
    return Intl.message(
      'Envoy is loading your video over the Tor Network',
      name: 'envoy_video_player_loading_tor',
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

  /// `Telegram`
  String get envoy_support_telegram {
    return Intl.message(
      'Telegram',
      name: 'envoy_support_telegram',
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

  /// `Fiat Currency`
  String get envoy_settings_fiat_currency {
    return Intl.message(
      'Fiat Currency',
      name: 'envoy_settings_fiat_currency',
      desc: '',
      args: [],
    );
  }

  /// `View Amount in Sats`
  String get envoy_settings_sat_amount {
    return Intl.message(
      'View Amount in Sats',
      name: 'envoy_settings_sat_amount',
      desc: '',
      args: [],
    );
  }

  /// `Tor Connectivity`
  String get envoy_settings_tor_connectivity {
    return Intl.message(
      'Tor Connectivity',
      name: 'envoy_settings_tor_connectivity',
      desc: '',
      args: [],
    );
  }

  /// `Custom Electrum Server`
  String get envoy_settings_custom_electrum_server {
    return Intl.message(
      'Custom Electrum Server',
      name: 'envoy_settings_custom_electrum_server',
      desc: '',
      args: [],
    );
  }

  /// `Nah`
  String get envoy_settings_fiat_currency_nah {
    return Intl.message(
      'Nah',
      name: 'envoy_settings_fiat_currency_nah',
      desc: '',
      args: [],
    );
  }

  /// `Show Fiat`
  String get envoy_settings_show_fiat {
    return Intl.message(
      'Show Fiat',
      name: 'envoy_settings_show_fiat',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get envoy_settings_currency {
    return Intl.message(
      'Currency',
      name: 'envoy_settings_currency',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get envoy_home_accounts {
    return Intl.message(
      'Accounts',
      name: 'envoy_home_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Learn`
  String get envoy_home_learn {
    return Intl.message(
      'Learn',
      name: 'envoy_home_learn',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get envoy_home_devices {
    return Intl.message(
      'Devices',
      name: 'envoy_home_devices',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get envoy_devices_options_new_passport {
    return Intl.message(
      'Set up a new Passport',
      name: 'envoy_devices_options_new_passport',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get envoy_devices_options_existing_passport {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_devices_options_existing_passport',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get envoy_devices_existing_passport {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_devices_existing_passport',
      desc: '',
      args: [],
    );
  }

  /// `No devices are connected.\nDon’t have a Passport? {{Learn more.}}`
  String get envoy_devices_no_devices {
    return Intl.message(
      'No devices are connected.\nDon’t have a Passport? {{Learn more.}}',
      name: 'envoy_devices_no_devices',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get envoy_devices_new_passport {
    return Intl.message(
      'Set up a new Passport',
      name: 'envoy_devices_new_passport',
      desc: '',
      args: [],
    );
  }

  /// `No devices are connected.\nDon’t have a Passport? {{Learn more.}}`
  String get envoy_accounts_no_devices {
    return Intl.message(
      'No devices are connected.\nDon’t have a Passport? {{Learn more.}}',
      name: 'envoy_accounts_no_devices',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get envoy_accounts_new_passport {
    return Intl.message(
      'Set up a new Passport',
      name: 'envoy_accounts_new_passport',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get envoy_accounts_existing_passport {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_accounts_existing_passport',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get envoy_learn_videos {
    return Intl.message(
      'Videos',
      name: 'envoy_learn_videos',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get envoy_learn_faqs {
    return Intl.message(
      'FAQs',
      name: 'envoy_learn_faqs',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get envoy_settings_menu_settings {
    return Intl.message(
      'Settings',
      name: 'envoy_settings_menu_settings',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get envoy_settings_menu_support {
    return Intl.message(
      'Support',
      name: 'envoy_settings_menu_support',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get envoy_settings_menu_about {
    return Intl.message(
      'About',
      name: 'envoy_settings_menu_about',
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
