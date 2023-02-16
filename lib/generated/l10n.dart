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

  /// `Accounts`
  String get accounts_screen_bottom_menu_accounts {
    return Intl.message(
      'Accounts',
      name: 'accounts_screen_bottom_menu_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Activity`
  String get accounts_screen_bottom_menu_activity {
    return Intl.message(
      'Activity',
      name: 'accounts_screen_bottom_menu_activity',
      desc: '',
      args: [],
    );
  }

  /// `Learn`
  String get accounts_screen_bottom_menu_learn {
    return Intl.message(
      'Learn',
      name: 'accounts_screen_bottom_menu_learn',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get accounts_screen_bottom_menu_privacy {
    return Intl.message(
      'Privacy',
      name: 'accounts_screen_bottom_menu_privacy',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get accounts_screen_connect_button {
    return Intl.message(
      'Connect',
      name: 'accounts_screen_connect_button',
      desc: '',
      args: [],
    );
  }

  /// `Learn More`
  String get accounts_screen_learn_more_button {
    return Intl.message(
      'Learn More',
      name: 'accounts_screen_learn_more_button',
      desc: '',
      args: [],
    );
  }

  /// `Passport`
  String get accounts_screen_passport {
    return Intl.message(
      'Passport',
      name: 'accounts_screen_passport',
      desc: '',
      args: [],
    );
  }

  /// `0.00 SATS`
  String get accounts_screen_sats_amount {
    return Intl.message(
      '0.00 SATS',
      name: 'accounts_screen_sats_amount',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get accounts_screen_top_bar {
    return Intl.message(
      'Accounts',
      name: 'accounts_screen_top_bar',
      desc: '',
      args: [],
    );
  }

  /// `$0.00`
  String get accounts_screen_usd_amount {
    return Intl.message(
      '\$0.00',
      name: 'accounts_screen_usd_amount',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Wallet`
  String get accounts_screen_wallet_name {
    return Intl.message(
      'Envoy Wallet',
      name: 'accounts_screen_wallet_name',
      desc: '',
      args: [],
    );
  }

  /// `Hot Wallet`
  String get accounts_screen_wallet_type {
    return Intl.message(
      'Hot Wallet',
      name: 'accounts_screen_wallet_type',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get android_backup_info_CTA {
    return Intl.message(
      'Continue',
      name: 'android_backup_info_CTA',
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

  /// `Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Envoy Wallet backup is complete, we recommend performing a manual backup in your device Settings.`
  String get android_backup_info_subheading {
    return Intl.message(
      'Android automatically backs up your Envoy data every 24 hours.\n\nTo ensure your first Envoy Wallet backup is complete, we recommend performing a manual backup in your device Settings.',
      name: 'android_backup_info_subheading',
      desc: '',
      args: [],
    );
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

  /// `Done`
  String get component_done {
    return Intl.message(
      'Done',
      name: 'component_done',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'component_get-started' key

  // skipped getter for the 'component_go-back' key

  /// `Next`
  String get component_next {
    return Intl.message(
      'Next',
      name: 'component_next',
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

  /// `Privacy Policy`
  String get envoy_about_privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'envoy_about_privacy_policy',
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

  /// `Awaiting confirmation`
  String get envoy_account_awaiting_confirmation {
    return Intl.message(
      'Awaiting confirmation',
      name: 'envoy_account_awaiting_confirmation',
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

  /// `Edit account name`
  String get envoy_account_edit_name {
    return Intl.message(
      'Edit account name',
      name: 'envoy_account_edit_name',
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

  /// `Agree & Continue`
  String get envoy_account_email_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_email_cta',
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

  /// `Agree & Continue`
  String get envoy_account_email_entry_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_email_entry_cta',
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

  /// `9:41`
  String get envoy_account_email_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_account_email_os_clock',
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

  /// `We’ve sent a verification link to your email address`
  String get envoy_account_email_verify_heading {
    return Intl.message(
      'We’ve sent a verification link to your email address',
      name: 'envoy_account_email_verify_heading',
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

  /// `{{Learn More}}`
  String get envoy_account_intro_cta2 {
    return Intl.message(
      '{{Learn More}}',
      name: 'envoy_account_intro_cta2',
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

  /// `OK`
  String get envoy_account_leave_app_os_modal_allow {
    return Intl.message(
      'OK',
      name: 'envoy_account_leave_app_os_modal_allow',
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

  /// `Back`
  String get envoy_account_leave_app_os_modal_reject {
    return Intl.message(
      'Back',
      name: 'envoy_account_leave_app_os_modal_reject',
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

  /// `Privacy Policy`
  String get envoy_account_privacy_policy_heading {
    return Intl.message(
      'Privacy Policy',
      name: 'envoy_account_privacy_policy_heading',
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

  /// `Agree & Continue`
  String get envoy_account_privacy_policy_os_modal_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_privacy_policy_os_modal_cta',
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

  /// `Continue`
  String get envoy_account_privacy_warn_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_account_privacy_warn_cta',
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

  /// `Received`
  String get envoy_account_received {
    return Intl.message(
      'Received',
      name: 'envoy_account_received',
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

  /// `Sent`
  String get envoy_account_sent {
    return Intl.message(
      'Sent',
      name: 'envoy_account_sent',
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

  /// `Terms of Service`
  String get envoy_account_tos_heading {
    return Intl.message(
      'Terms of Service',
      name: 'envoy_account_tos_heading',
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

  /// `Agree & Continue`
  String get envoy_account_tos_os_modal_cta {
    return Intl.message(
      'Agree & Continue',
      name: 'envoy_account_tos_os_modal_cta',
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

  /// `1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\n\n2. Security\n\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\n3. Backups\n\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss. \nEt consequat purus et id tellus. Nulla imperdiet vel tempor nisi aliquam adipiscing eu dictum mauris. Justo habitant bibendum risus quam id donec odio vulputate massa. At et massa amet, massa, orci ut. Etiam vitae ornare ut nec eget nunc sem mi. Rhoncus duis aliquam et tincidunt sed. Eu egestas tempus, vel ut purus, sollicitudin vel adipiscing. Ac ultrices sit adipiscing faucibus amet, in eget. Sollicitudin lectus lacus, sem tellus ipsum amet. Morbi quam cras sollicitudin dui porttitor amet, ac velit. Et ac, interdum vitae, elementum amet, interdum.\nAmet vitae erat at lacus, ultrices in nisi, platea purus. Convallis sagittis ut ut diam mattis nulla vel. Ac cursus pulvinar nibh sed sed magnis. Leo lorem porttitor habitasse et sed eu arcu. Sem porttitor iaculis fames leo. Dui nisl odio aliquam purus. Praesent metus, pretium, aliquet consequat est, congue facilisis. Eros sem urna pharetra amet arcu, eget.`
  String get envoy_account_tos_subheading {
    return Intl.message(
      '1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\n\n2. Security\n\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\n3. Backups\n\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss. \nEt consequat purus et id tellus. Nulla imperdiet vel tempor nisi aliquam adipiscing eu dictum mauris. Justo habitant bibendum risus quam id donec odio vulputate massa. At et massa amet, massa, orci ut. Etiam vitae ornare ut nec eget nunc sem mi. Rhoncus duis aliquam et tincidunt sed. Eu egestas tempus, vel ut purus, sollicitudin vel adipiscing. Ac ultrices sit adipiscing faucibus amet, in eget. Sollicitudin lectus lacus, sem tellus ipsum amet. Morbi quam cras sollicitudin dui porttitor amet, ac velit. Et ac, interdum vitae, elementum amet, interdum.\nAmet vitae erat at lacus, ultrices in nisi, platea purus. Convallis sagittis ut ut diam mattis nulla vel. Ac cursus pulvinar nibh sed sed magnis. Leo lorem porttitor habitasse et sed eu arcu. Sem porttitor iaculis fames leo. Dui nisl odio aliquam purus. Praesent metus, pretium, aliquet consequat est, congue facilisis. Eros sem urna pharetra amet arcu, eget.',
      name: 'envoy_account_tos_subheading',
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

  /// `Connect an existing Passport`
  String get envoy_accounts_existing_passport {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_accounts_existing_passport',
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

  /// `No devices are connected.\nDon’t have a Passport? {{Learn more.}}`
  String get envoy_accounts_no_devices {
    return Intl.message(
      'No devices are connected.\nDon’t have a Passport? {{Learn more.}}',
      name: 'envoy_accounts_no_devices',
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

  /// `For privacy, we create a new address each time you visit this screen.`
  String get envoy_address_explainer {
    return Intl.message(
      'For privacy, we create a new address each time you visit this screen.',
      name: 'envoy_address_explainer',
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

  /// `Confirm`
  String get envoy_confirmation_confirm {
    return Intl.message(
      'Confirm',
      name: 'envoy_confirmation_confirm',
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

  /// `Make sure not to share this descriptor unless you are comfortable with your transactions being public.`
  String get envoy_descriptor_explainer {
    return Intl.message(
      'Make sure not to share this descriptor unless you are comfortable with your transactions being public.',
      name: 'envoy_descriptor_explainer',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to disconnect {device}?`
  String envoy_device_delete_are_you_sure(Object device) {
    return Intl.message(
      'Are you sure you want to disconnect $device?',
      name: 'envoy_device_delete_are_you_sure',
      desc: '',
      args: [device],
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

  /// `Edit device name`
  String get envoy_device_edit_device_name {
    return Intl.message(
      'Edit device name',
      name: 'envoy_device_edit_device_name',
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

  /// `Rename Device`
  String get envoy_device_rename {
    return Intl.message(
      'Rename Device',
      name: 'envoy_device_rename',
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

  /// `Connect an existing Passport`
  String get envoy_devices_existing_passport {
    return Intl.message(
      'Connect an existing Passport',
      name: 'envoy_devices_existing_passport',
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
  String get envoy_devices_no_devices {
    return Intl.message(
      'No devices are connected.\nDon’t have a Passport? {{Learn more.}}',
      name: 'envoy_devices_no_devices',
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

  /// `Set up a new Passport`
  String get envoy_devices_options_new_passport {
    return Intl.message(
      'Set up a new Passport',
      name: 'envoy_devices_options_new_passport',
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

  /// `Standard`
  String get envoy_fee_standard {
    return Intl.message(
      'Standard',
      name: 'envoy_fee_standard',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get envoy_fw_error_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_error_cta',
      desc: '',
      args: [],
    );
  }

  /// `Next, let’s update Passport’s firmware`
  String get envoy_fw_error_heading {
    return Intl.message(
      'Next, let’s update Passport’s firmware',
      name: 'envoy_fw_error_heading',
      desc: '',
      args: [],
    );
  }

  /// `Retry now`
  String get envoy_fw_error_modal_cta_1 {
    return Intl.message(
      'Retry now',
      name: 'envoy_fw_error_modal_cta_1',
      desc: '',
      args: [],
    );
  }

  /// `Try again later`
  String get envoy_fw_error_modal_cta_2 {
    return Intl.message(
      'Try again later',
      name: 'envoy_fw_error_modal_cta_2',
      desc: '',
      args: [],
    );
  }

  /// `Download from Github`
  String get envoy_fw_error_modal_cta_3 {
    return Intl.message(
      'Download from Github',
      name: 'envoy_fw_error_modal_cta_3',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, we can’t get the firmware update right now.`
  String get envoy_fw_error_modal_heading {
    return Intl.message(
      'Sorry, we can’t get the firmware update right now.',
      name: 'envoy_fw_error_modal_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy allows you to update your Passport from your phone using the included microSD adapter.\n\nAdvanced users can tap here to download and verify their own firmware on a computer.`
  String get envoy_fw_error_subheading {
    return Intl.message(
      'Envoy allows you to update your Passport from your phone using the included microSD adapter.\n\nAdvanced users can tap here to download and verify their own firmware on a computer.',
      name: 'envoy_fw_error_subheading',
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

  /// `Envoy allows you to update your Passport from your phone, using the included microSD adapter.\n\nAdvanced users can {{tap here}} to download and verify their own firmware on a computer.`
  String get envoy_fw_intro_subheading {
    return Intl.message(
      'Envoy allows you to update your Passport from your phone, using the included microSD adapter.\n\nAdvanced users can {{tap here}} to download and verify their own firmware on a computer.',
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
  String get envoy_fw_microsd_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_fw_microsd_cta',
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

  /// `Insert the provided microSD card adapter into your phone, then insert the microSD card into the adapter.`
  String get envoy_fw_microsd_subheading {
    return Intl.message(
      'Insert the provided microSD card adapter into your phone, then insert the microSD card into the adapter.',
      name: 'envoy_fw_microsd_subheading',
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

  /// `Remove the microSD card and insert into Passport `
  String get envoy_fw_passport_heading {
    return Intl.message(
      'Remove the microSD card and insert into Passport ',
      name: 'envoy_fw_passport_heading',
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

  /// `Insert the microSD card into Passport and follow the instructions.\n\nEnsure Passport has adequate battery charge.`
  String get envoy_fw_passport_subheading {
    return Intl.message(
      'Insert the microSD card into Passport and follow the instructions.\n\nEnsure Passport has adequate battery charge.',
      name: 'envoy_fw_passport_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Insert the microSD card into Passport and navigate to Settings -> Firmware -> Update Firmware.\n\nEnsure Passport has adequate battery charge.`
  String get envoy_fw_passport_subheading_after_onboarding {
    return Intl.message(
      'Insert the microSD card into Passport and navigate to Settings -> Firmware -> Update Firmware.\n\nEnsure Passport has adequate battery charge.',
      name: 'envoy_fw_passport_subheading_after_onboarding',
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

  /// `Firmware was successfully copied onto the microSD card`
  String get envoy_fw_success_heading {
    return Intl.message(
      'Firmware was successfully copied onto the microSD card',
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

  /// `Accounts`
  String get envoy_home_accounts {
    return Intl.message(
      'Accounts',
      name: 'envoy_home_accounts',
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

  /// `Learn`
  String get envoy_home_learn {
    return Intl.message(
      'Learn',
      name: 'envoy_home_learn',
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

  /// `Follow Envoy connection flow on Passport`
  String get envoy_import_pp_intro_heading {
    return Intl.message(
      'Follow Envoy connection flow on Passport',
      name: 'envoy_import_pp_intro_heading',
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

  /// `On Passport, select Connect Wallet > Envoy`
  String get envoy_import_pp_intro_subheading {
    return Intl.message(
      'On Passport, select Connect Wallet > Envoy',
      name: 'envoy_import_pp_intro_subheading',
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

  /// `Next, scan the QR code that Passport generates`
  String get envoy_import_pp_scan_heading {
    return Intl.message(
      'Next, scan the QR code that Passport generates',
      name: 'envoy_import_pp_scan_heading',
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

  /// `This QR code contains the information required for Envoy to include Passport in the multisig setup.`
  String get envoy_import_pp_scan_subheading {
    return Intl.message(
      'This QR code contains the information required for Envoy to include Passport in the multisig setup.',
      name: 'envoy_import_pp_scan_subheading',
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

  /// `Videos`
  String get envoy_learn_videos {
    return Intl.message(
      'Videos',
      name: 'envoy_learn_videos',
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

  /// `Continue`
  String get envoy_mobile_backup_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_backup_confirm_cta',
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
  String get envoy_mobile_backup_intro_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_mobile_backup_intro_os_clock',
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

  /// `Cloud Backup Option`
  String get envoy_mobile_cloud_heading {
    return Intl.message(
      'Cloud Backup Option',
      name: 'envoy_mobile_cloud_heading',
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

  /// `Continue`
  String get envoy_mobile_cloud_skip_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_cloud_skip_cta',
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

  /// `Losing access to your phone could result in the loss of this key without a proper manual backup.`
  String get envoy_mobile_cloud_skip_subheading {
    return Intl.message(
      'Losing access to your phone could result in the loss of this key without a proper manual backup.',
      name: 'envoy_mobile_cloud_skip_subheading',
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
  String get envoy_mobile_create_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_create_cta',
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

  /// `Continue`
  String get envoy_mobile_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_mobile_intro_cta',
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

  /// `Please review and accept the Passport Terms of Use`
  String get envoy_passport_tou_heading {
    return Intl.message(
      'Please review and accept the Passport Terms of Use',
      name: 'envoy_passport_tou_heading',
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

  /// `TOU to be inserted here.`
  String get envoy_passport_tou_subheading {
    return Intl.message(
      'TOU to be inserted here.',
      name: 'envoy_passport_tou_subheading',
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

  /// `Enter your PIN again to confirm`
  String get envoy_pin_confirm_heading {
    return Intl.message(
      'Enter your PIN again to confirm',
      name: 'envoy_pin_confirm_heading',
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
  String get envoy_pp_new_seed_backup_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_pp_new_seed_backup_cta',
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

  /// `On Passport, select \nCreate New Seed`
  String get envoy_pp_new_seed_heading {
    return Intl.message(
      'On Passport, select \nCreate New Seed',
      name: 'envoy_pp_new_seed_heading',
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

  /// `Passport's Avalanche Noise Source, an open source true random number generator, helps create a strong seed.`
  String get envoy_pp_new_seed_subheading {
    return Intl.message(
      'Passport\'s Avalanche Noise Source, an open source true random number generator, helps create a strong seed.',
      name: 'envoy_pp_new_seed_subheading',
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

  /// `Congratulations, your new seed has been created`
  String get envoy_pp_new_seed_success_heading {
    return Intl.message(
      'Congratulations, your new seed has been created',
      name: 'envoy_pp_new_seed_success_heading',
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

  /// `9:41`
  String get envoy_pp_restore_backup_os_clock {
    return Intl.message(
      '9:41',
      name: 'envoy_pp_restore_backup_os_clock',
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

  /// `Enter your encryption words`
  String get envoy_pp_restore_backup_password_heading {
    return Intl.message(
      'Enter your encryption words',
      name: 'envoy_pp_restore_backup_password_heading',
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

  /// `To decrypt the backup file, enter the 6 word backup password.`
  String get envoy_pp_restore_backup_password_subheading {
    return Intl.message(
      'To decrypt the backup file, enter the 6 word backup password.',
      name: 'envoy_pp_restore_backup_password_subheading',
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

  /// `Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the backup password to decrypt the backup.`
  String get envoy_pp_restore_backup_subheading {
    return Intl.message(
      'Use this feature to restore Passport using an encrypted microSD backup from another Passport.\n\nYou will need the backup password to decrypt the backup.',
      name: 'envoy_pp_restore_backup_subheading',
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

  /// `Your backup file has been restored successfully.`
  String get envoy_pp_restore_backup_success_heading {
    return Intl.message(
      'Your backup file has been restored successfully.',
      name: 'envoy_pp_restore_backup_success_heading',
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

  /// `Create encrypted backup?`
  String get envoy_pp_restore_seed_backup_heading {
    return Intl.message(
      'Create encrypted backup?',
      name: 'envoy_pp_restore_seed_backup_heading',
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

  /// `Use this feature to restore an existing 12, 18, or 24 word seed.`
  String get envoy_pp_restore_seed_subheading {
    return Intl.message(
      'Use this feature to restore an existing 12, 18, or 24 word seed.',
      name: 'envoy_pp_restore_seed_subheading',
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

  /// `Your seed has been successfully restored`
  String get envoy_pp_restore_seed_success_heading {
    return Intl.message(
      'Your seed has been successfully restored',
      name: 'envoy_pp_restore_seed_success_heading',
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
  String get envoy_pp_setup_intro_card1_cta1 {
    return Intl.message(
      'Create New Seed',
      name: 'envoy_pp_setup_intro_card1_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get envoy_pp_setup_intro_card1_cta2 {
    return Intl.message(
      'Restore Seed',
      name: 'envoy_pp_setup_intro_card1_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get envoy_pp_setup_intro_card1_cta3 {
    return Intl.message(
      'Restore Backup',
      name: 'envoy_pp_setup_intro_card1_cta3',
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

  /// `PSBT copied to clipboard!`
  String get envoy_psbt_copied_clipboard {
    return Intl.message(
      'PSBT copied to clipboard!',
      name: 'envoy_psbt_copied_clipboard',
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

  /// `Scan the QR on your Passport`
  String get envoy_psbt_scan_qr {
    return Intl.message(
      'Scan the QR on your Passport',
      name: 'envoy_psbt_scan_qr',
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

  /// `Transaction sent!`
  String get envoy_psbt_transaction_sent {
    return Intl.message(
      'Transaction sent!',
      name: 'envoy_psbt_transaction_sent',
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

  /// `Continue`
  String get envoy_recovery_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_intro_cta',
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

  /// `Copper`
  String get envoy_recovery_question_entry_card_1user_input {
    return Intl.message(
      'Copper',
      name: 'envoy_recovery_question_entry_card_1user_input',
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

  /// `Pizza`
  String get envoy_recovery_question_entry_user_card2_input {
    return Intl.message(
      'Pizza',
      name: 'envoy_recovery_question_entry_user_card2_input',
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

  /// `Continue`
  String get envoy_recovery_question_intro_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_question_intro_cta',
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

  /// `Continue`
  String get envoy_recovery_success_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_recovery_success_cta',
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

  /// `You can verify the answers to your security questions at any time.`
  String get envoy_recovery_success_subheading {
    return Intl.message(
      'You can verify the answers to your security questions at any time.',
      name: 'envoy_recovery_success_subheading',
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

  /// `This security check will ensure your Passport has not been tampered with during shipping.`
  String get envoy_scv_intro_subheading {
    return Intl.message(
      'This security check will ensure your Passport has not been tampered with during shipping.',
      name: 'envoy_scv_intro_subheading',
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

  /// `“Envoy” Would Like to Access the Camera`
  String get envoy_scv_permissions_os_modal_heading {
    return Intl.message(
      '“Envoy” Would Like to Access the Camera',
      name: 'envoy_scv_permissions_os_modal_heading',
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

  /// `Enable camera access to continue setting up your Passport`
  String get envoy_scv_permissions_os_modal_subheading {
    return Intl.message(
      'Enable camera access to continue setting up your Passport',
      name: 'envoy_scv_permissions_os_modal_subheading',
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

  /// `Your Passport may be insecure`
  String get envoy_scv_result_fail_heading {
    return Intl.message(
      'Your Passport may be insecure',
      name: 'envoy_scv_result_fail_heading',
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
  String get envoy_scv_result_update_card1_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_result_update_card1_cta',
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

  /// `Continue`
  String get envoy_scv_scan_qr_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_scv_scan_qr_cta',
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

  /// `This QR code completes the validation and shares some Passport information with Envoy.`
  String get envoy_scv_scan_qr_subheading {
    return Intl.message(
      'This QR code completes the validation and shares some Passport information with Envoy.',
      name: 'envoy_scv_scan_qr_subheading',
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

  /// `This QR code provides information for validation and setup.`
  String get envoy_scv_show_qr_subheading {
    return Intl.message(
      'This QR code provides information for validation and setup.',
      name: 'envoy_scv_show_qr_subheading',
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

  /// `Send Max`
  String get envoy_send_send_max {
    return Intl.message(
      'Send Max',
      name: 'envoy_send_send_max',
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

  /// `Custom Electrum Server`
  String get envoy_settings_custom_electrum_server {
    return Intl.message(
      'Custom Electrum Server',
      name: 'envoy_settings_custom_electrum_server',
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

  /// `Nah`
  String get envoy_settings_fiat_currency_nah {
    return Intl.message(
      'Nah',
      name: 'envoy_settings_fiat_currency_nah',
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

  /// `View Amount in Sats`
  String get envoy_settings_sat_amount {
    return Intl.message(
      'View Amount in Sats',
      name: 'envoy_settings_sat_amount',
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

  /// `Tor Connectivity`
  String get envoy_settings_tor_connectivity {
    return Intl.message(
      'Tor Connectivity',
      name: 'envoy_settings_tor_connectivity',
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

  /// `Continue`
  String get envoy_wallet_address_verify_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'envoy_wallet_address_verify_confirm_cta',
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

  /// `Address Validated?`
  String get envoy_wallet_address_verify_confirm_heading {
    return Intl.message(
      'Address Validated?',
      name: 'envoy_wallet_address_verify_confirm_heading',
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

  /// `If you get a success message on Passport, your wallet setup is complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get envoy_wallet_address_verify_confirm_subheading {
    return Intl.message(
      'If you get a success message on Passport, your wallet setup is complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'envoy_wallet_address_verify_confirm_subheading',
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

  /// `Scan this QR code with Passport to validate the receive address`
  String get envoy_wallet_address_verify_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate the receive address',
      name: 'envoy_wallet_address_verify_heading',
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

  /// `This is the first address in your Envoy Shield wallet.`
  String get envoy_wallet_address_verify_subheading {
    return Intl.message(
      'This is the first address in your Envoy Shield wallet.',
      name: 'envoy_wallet_address_verify_subheading',
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

  /// `There was a problem creating your wallet`
  String get envoy_wallet_create_fail_heading {
    return Intl.message(
      'There was a problem creating your wallet',
      name: 'envoy_wallet_create_fail_heading',
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

  /// `Please try again or contact support`
  String get envoy_wallet_create_fail_subheading {
    return Intl.message(
      'Please try again or contact support',
      name: 'envoy_wallet_create_fail_subheading',
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

  /// `Using a combination of your Mobile Key, Passport Key, and the Recovery Key, Envoy will now create a multisignature wallet where 2 out of those 3 keys are required to authorise any spends.`
  String get envoy_wallet_create_subheading {
    return Intl.message(
      'Using a combination of your Mobile Key, Passport Key, and the Recovery Key, Envoy will now create a multisignature wallet where 2 out of those 3 keys are required to authorise any spends.',
      name: 'envoy_wallet_create_subheading',
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

  /// `Wallet Creation Success`
  String get envoy_wallet_create_success_heading {
    return Intl.message(
      'Wallet Creation Success',
      name: 'envoy_wallet_create_success_heading',
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

  /// `Congratulations, your multisig wallet has been created. We just have a couple more steps before you are free to use the wallet to manage your Bitcoin.\n\nFirst off, let’s tell Passport about the new wallet configuration.`
  String get envoy_wallet_create_success_subheading {
    return Intl.message(
      'Congratulations, your multisig wallet has been created. We just have a couple more steps before you are free to use the wallet to manage your Bitcoin.\n\nFirst off, let’s tell Passport about the new wallet configuration.',
      name: 'envoy_wallet_create_success_subheading',
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

  /// `Your wallet has been connected successfully`
  String get envoy_wallet_pair_success_heading {
    return Intl.message(
      'Your wallet has been connected successfully',
      name: 'envoy_wallet_pair_success_heading',
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

  /// `Your Envoy Shield setup is now complete. You can confirm this by verifying a receive address on the next screen.`
  String get envoy_wallet_pair_success_subheading {
    return Intl.message(
      'Your Envoy Shield setup is now complete. You can confirm this by verifying a receive address on the next screen.',
      name: 'envoy_wallet_pair_success_subheading',
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

  /// `Scan this QR code with Passport to tell it about your Envoy wallet `
  String get envoy_wallet_show_qr_export_heading {
    return Intl.message(
      'Scan this QR code with Passport to tell it about your Envoy wallet ',
      name: 'envoy_wallet_show_qr_export_heading',
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

  /// `This QR contains the info Passport needs to authorise transactions for the multisig wallet. `
  String get envoy_wallet_show_qr_export_subheading {
    return Intl.message(
      'This QR contains the info Passport needs to authorise transactions for the multisig wallet. ',
      name: 'envoy_wallet_show_qr_export_subheading',
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

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get envoy_welcome_card1_subheading {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'envoy_welcome_card1_subheading',
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

  /// `Have an Envoy Shield Account? {{Log In}}`
  String get envoy_welcome_cta02 {
    return Intl.message(
      'Have an Envoy Shield Account? {{Log In}}',
      name: 'envoy_welcome_cta02',
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
  String get envoy_welcome_os_clock {
    return Intl.message(
      '4321',
      name: 'envoy_welcome_os_clock',
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

  /// `Establishing a private connection over Tor`
  String get envoy_widgets_torloader_establishing_connection {
    return Intl.message(
      'Establishing a private connection over Tor',
      name: 'envoy_widgets_torloader_establishing_connection',
      desc: '',
      args: [],
    );
  }

  /// `Loading over the Tor network\n`
  String get envoy_widgets_torloader_loading {
    return Intl.message(
      'Loading over the Tor network\n',
      name: 'envoy_widgets_torloader_loading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get learn_more_about_data_secured_1_4_CTA {
    return Intl.message(
      'Continue',
      name: 'learn_more_about_data_secured_1_4_CTA',
      desc: '',
      args: [],
    );
  }

  /// `How Your Wallet is Secured`
  String get learn_more_about_data_secured_1_4_heading {
    return Intl.message(
      'How Your Wallet is Secured',
      name: 'learn_more_about_data_secured_1_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get learn_more_about_data_secured_1_4_skip {
    return Intl.message(
      'Skip',
      name: 'learn_more_about_data_secured_1_4_skip',
      desc: '',
      args: [],
    );
  }

  /// `Envoy securely and automatically backs up your wallet seed to iCloud Keychain.\n\nYour seed is always end-to-end encrypted and is never visible to Apple.`
  String get learn_more_about_data_secured_1_4_subheading {
    return Intl.message(
      'Envoy securely and automatically backs up your wallet seed to iCloud Keychain.\n\nYour seed is always end-to-end encrypted and is never visible to Apple.',
      name: 'learn_more_about_data_secured_1_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `How Your Wallet is Secured`
  String get learn_more_about_data_secured_2_4_heading {
    return Intl.message(
      'How Your Wallet is Secured',
      name: 'learn_more_about_data_secured_2_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get learn_more_about_data_secured_2_4_skip {
    return Intl.message(
      'Skip',
      name: 'learn_more_about_data_secured_2_4_skip',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet data – including labels, accounts, and settings – is automatically backed up to Foundation servers.\n\nThis backup is end-to-end encrypted with your wallet seed, ensuring that Foundation can never access your data.`
  String get learn_more_about_data_secured_2_4_subheading {
    return Intl.message(
      'Your wallet data – including labels, accounts, and settings – is automatically backed up to Foundation servers.\n\nThis backup is end-to-end encrypted with your wallet seed, ensuring that Foundation can never access your data.',
      name: 'learn_more_about_data_secured_2_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get learn_more_about_data_secured_3_4_CTA {
    return Intl.message(
      'Continue',
      name: 'learn_more_about_data_secured_3_4_CTA',
      desc: '',
      args: [],
    );
  }

  /// `How Your Data is Secured`
  String get learn_more_about_data_secured_3_4_heading {
    return Intl.message(
      'How Your Data is Secured',
      name: 'learn_more_about_data_secured_3_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get learn_more_about_data_secured_3_4_skip {
    return Intl.message(
      'Skip',
      name: 'learn_more_about_data_secured_3_4_skip',
      desc: '',
      args: [],
    );
  }

  /// `To recover your wallet, simply log into your iCloud account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your iCloud account with a strong password and 2FA.`
  String get learn_more_about_data_secured_3_4_subheading {
    return Intl.message(
      'To recover your wallet, simply log into your iCloud account. Envoy will automatically download your wallet seed and backup data.\n\nWe recommend securing your iCloud account with a strong password and 2FA.',
      name: 'learn_more_about_data_secured_3_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get learn_more_about_data_secured_4_4_CTA {
    return Intl.message(
      'Continue',
      name: 'learn_more_about_data_secured_4_4_CTA',
      desc: '',
      args: [],
    );
  }

  /// `How Your Data is Secured`
  String get learn_more_about_data_secured_4_4_heading {
    return Intl.message(
      'How Your Data is Secured',
      name: 'learn_more_about_data_secured_4_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get learn_more_about_data_secured_4_4_skip {
    return Intl.message(
      'Skip',
      name: 'learn_more_about_data_secured_4_4_skip',
      desc: '',
      args: [],
    );
  }

  /// `If you prefer to opt out of automatic encrypted backups and instead manually secure your wallet seed and data, no problem!\n\nSimply head back to the setup screen and choose Manual Wallet Setup.`
  String get learn_more_about_data_secured_4_4_subheading {
    return Intl.message(
      'If you prefer to opt out of automatic encrypted backups and instead manually secure your wallet seed and data, no problem!\n\nSimply head back to the setup screen and choose Manual Wallet Setup.',
      name: 'learn_more_about_data_secured_4_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get magic_recovery_fail_android_CTA_1 {
    return Intl.message(
      'Retry',
      name: 'magic_recovery_fail_android_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `Recover with QR Code`
  String get magic_recovery_fail_android_CTA_2 {
    return Intl.message(
      'Recover with QR Code',
      name: 'magic_recovery_fail_android_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Recovery Unsuccessful`
  String get magic_recovery_fail_android_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_recovery_fail_android_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Google account and that you’ve restored your latest device backup.`
  String get magic_recovery_fail_android_subheading {
    return Intl.message(
      'Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Google account and that you’ve restored your latest device backup.',
      name: 'magic_recovery_fail_android_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recovering your Envoy Wallet`
  String get magic_recovery_flow_done_heading {
    return Intl.message(
      'Recovering your Envoy Wallet',
      name: 'magic_recovery_flow_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Sign into iCloud and install Envoy on the new device.`
  String get magic_recovery_flow_done_step_1 {
    return Intl.message(
      'Sign into iCloud and install Envoy on the new device.',
      name: 'magic_recovery_flow_done_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Open Envoy and tap ‘Recover Envoy   Wallet’.`
  String get magic_recovery_flow_done_step_2 {
    return Intl.message(
      'Open Envoy and tap ‘Recover Envoy   Wallet’.',
      name: 'magic_recovery_flow_done_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically reinstate your existing Envoy wallet.`
  String get magic_recovery_flow_done_step_3 {
    return Intl.message(
      'Envoy will then automatically reinstate your existing Envoy wallet.',
      name: 'magic_recovery_flow_done_step_3',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.`
  String get magic_recovery_flow_done_subheading {
    return Intl.message(
      'To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.',
      name: 'magic_recovery_flow_done_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recovering your Envoy wallet`
  String get magic_recovery_flow_heading {
    return Intl.message(
      'Recovering your Envoy wallet',
      name: 'magic_recovery_flow_heading',
      desc: '',
      args: [],
    );
  }

  /// `Recovering your Envoy Wallet`
  String get magic_recovery_flow_retry_2_heading {
    return Intl.message(
      'Recovering your Envoy Wallet',
      name: 'magic_recovery_flow_retry_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Sign into iCloud and install Envoy on the new device.`
  String get magic_recovery_flow_retry_2_step_1 {
    return Intl.message(
      'Sign into iCloud and install Envoy on the new device.',
      name: 'magic_recovery_flow_retry_2_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Open Envoy and tap ‘Recover Envoy   Wallet’.`
  String get magic_recovery_flow_retry_2_step_2 {
    return Intl.message(
      'Open Envoy and tap ‘Recover Envoy   Wallet’.',
      name: 'magic_recovery_flow_retry_2_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically reinstate your existing Envoy wallet.`
  String get magic_recovery_flow_retry_2_step_3 {
    return Intl.message(
      'Envoy will then automatically reinstate your existing Envoy wallet.',
      name: 'magic_recovery_flow_retry_2_step_3',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.`
  String get magic_recovery_flow_retry_2_subheading {
    return Intl.message(
      'To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.',
      name: 'magic_recovery_flow_retry_2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Recovering your Envoy wallet`
  String get magic_recovery_flow_retry_heading {
    return Intl.message(
      'Recovering your Envoy wallet',
      name: 'magic_recovery_flow_retry_heading',
      desc: '',
      args: [],
    );
  }

  /// `Sign into iCloud and install Envoy on the new device.`
  String get magic_recovery_flow_retry_step_1 {
    return Intl.message(
      'Sign into iCloud and install Envoy on the new device.',
      name: 'magic_recovery_flow_retry_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Open Envoy and tap ‘Recover Envoy   Wallet’.`
  String get magic_recovery_flow_retry_step_2 {
    return Intl.message(
      'Open Envoy and tap ‘Recover Envoy   Wallet’.',
      name: 'magic_recovery_flow_retry_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically reinstate your existing Envoy wallet.`
  String get magic_recovery_flow_retry_step_3 {
    return Intl.message(
      'Envoy will then automatically reinstate your existing Envoy wallet.',
      name: 'magic_recovery_flow_retry_step_3',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.`
  String get magic_recovery_flow_retry_subheading {
    return Intl.message(
      'To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.',
      name: 'magic_recovery_flow_retry_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Sign into iCloud and install Envoy on the new device.`
  String get magic_recovery_flow_step_1 {
    return Intl.message(
      'Sign into iCloud and install Envoy on the new device.',
      name: 'magic_recovery_flow_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Open Envoy and tap ‘Recover Envoy   Wallet’.`
  String get magic_recovery_flow_step_2 {
    return Intl.message(
      'Open Envoy and tap ‘Recover Envoy   Wallet’.',
      name: 'magic_recovery_flow_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically reinstate your existing Envoy wallet.`
  String get magic_recovery_flow_step_3 {
    return Intl.message(
      'Envoy will then automatically reinstate your existing Envoy wallet.',
      name: 'magic_recovery_flow_step_3',
      desc: '',
      args: [],
    );
  }

  /// `To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.`
  String get magic_recovery_flow_subheading {
    return Intl.message(
      'To recover your Envoy wallet onto a new device or Envoy app follow these simple instructions.',
      name: 'magic_recovery_flow_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get magic_recovery_retry_fail_CTA_1 {
    return Intl.message(
      'Retry',
      name: 'magic_recovery_retry_fail_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `Recover with QR Code`
  String get magic_recovery_retry_fail_CTA_2 {
    return Intl.message(
      'Recover with QR Code',
      name: 'magic_recovery_retry_fail_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Recovery Unsuccessful`
  String get magic_recovery_retry_fail_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_recovery_retry_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.`
  String get magic_recovery_retry_fail_subheading {
    return Intl.message(
      'Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.',
      name: 'magic_recovery_retry_fail_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get magic_recovery_retry_iOS_CTA_1 {
    return Intl.message(
      'Retry',
      name: 'magic_recovery_retry_iOS_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `Recover with QR Code`
  String get magic_recovery_retry_iOS_CTA_2 {
    return Intl.message(
      'Recover with QR Code',
      name: 'magic_recovery_retry_iOS_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Recovery Unsuccessful`
  String get magic_recovery_retry_iOS_heading {
    return Intl.message(
      'Recovery Unsuccessful',
      name: 'magic_recovery_retry_iOS_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.`
  String get magic_recovery_retry_iOS_subheading {
    return Intl.message(
      'Envoy is unable to locate an Envoy Wallet backup. \n\nPlease confirm you are logged in with the correct Apple account and that you’ve restored your latest iCloud backup.',
      name: 'magic_recovery_retry_iOS_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_encrypting_backup_1_5_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_encrypting_backup_1_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.`
  String get magic_setup_encrypting_backup_1_5_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.',
      name: 'magic_setup_encrypting_backup_1_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_encrypting_backup_2_5_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_encrypting_backup_2_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.`
  String get magic_setup_encrypting_backup_2_5_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.',
      name: 'magic_setup_encrypting_backup_2_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_encrypting_backup_3_5_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_encrypting_backup_3_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.`
  String get magic_setup_encrypting_backup_3_5_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.',
      name: 'magic_setup_encrypting_backup_3_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_encrypting_backup_4_5_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_encrypting_backup_4_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.`
  String get magic_setup_encrypting_backup_4_5_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.',
      name: 'magic_setup_encrypting_backup_4_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Encrypting Your Backup`
  String get magic_setup_encrypting_backup_5_5_heading {
    return Intl.message(
      'Encrypting Your Backup',
      name: 'magic_setup_encrypting_backup_5_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.`
  String get magic_setup_encrypting_backup_5_5_subheading {
    return Intl.message(
      'Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as labels, accounts, and settings.',
      name: 'magic_setup_encrypting_backup_5_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Key`
  String get magic_setup_envoy_key_creation_1_5_heading {
    return Intl.message(
      'Creating Your Envoy Key',
      name: 'magic_setup_envoy_key_creation_1_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.`
  String get magic_setup_envoy_key_creation_1_5_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.',
      name: 'magic_setup_envoy_key_creation_1_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Wallet`
  String get magic_setup_envoy_key_creation_2_5_heading {
    return Intl.message(
      'Creating Your Envoy Wallet',
      name: 'magic_setup_envoy_key_creation_2_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.`
  String get magic_setup_envoy_key_creation_2_5_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.',
      name: 'magic_setup_envoy_key_creation_2_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Wallet`
  String get magic_setup_envoy_key_creation_3_5_heading {
    return Intl.message(
      'Creating Your Envoy Wallet',
      name: 'magic_setup_envoy_key_creation_3_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.`
  String get magic_setup_envoy_key_creation_3_5_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.',
      name: 'magic_setup_envoy_key_creation_3_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Wallet`
  String get magic_setup_envoy_key_creation_4_5_heading {
    return Intl.message(
      'Creating Your Envoy Wallet',
      name: 'magic_setup_envoy_key_creation_4_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.`
  String get magic_setup_envoy_key_creation_4_5_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.',
      name: 'magic_setup_envoy_key_creation_4_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Creating Your Envoy Wallet`
  String get magic_setup_envoy_key_creation_5_5_heading {
    return Intl.message(
      'Creating Your Envoy Wallet',
      name: 'magic_setup_envoy_key_creation_5_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.`
  String get magic_setup_envoy_key_creation_5_5_subheading {
    return Intl.message(
      'Envoy is creating a secure Bitcoin wallet seed, which will be stored end-to-end encrypted in your iCloud Keychain.\n\nRemember to always secure your iCloud account with a strong password and 2FA.',
      name: 'magic_setup_envoy_key_creation_5_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Create New Wallet`
  String get magic_setup_flow_tutorial_CTA_1 {
    return Intl.message(
      'Create New Wallet',
      name: 'magic_setup_flow_tutorial_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get magic_setup_flow_tutorial_CTA_2 {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'magic_setup_flow_tutorial_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Set Up Your Wallet`
  String get magic_setup_flow_tutorial_heading {
    return Intl.message(
      'Set Up Your Wallet',
      name: 'magic_setup_flow_tutorial_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get magic_setup_flow_tutorial_skip {
    return Intl.message(
      'Skip',
      name: 'magic_setup_flow_tutorial_skip',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Wallet securely and automatically backs up your wallet to iCloud Keychain.  {{Learn more.}}`
  String get magic_setup_flow_tutorial_subheading {
    return Intl.message(
      'Envoy Wallet securely and automatically backs up your wallet to iCloud Keychain.  {{Learn more.}}',
      name: 'magic_setup_flow_tutorial_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get magic_setup_generate_wallet_CTA {
    return Intl.message(
      'Continue',
      name: 'magic_setup_generate_wallet_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get magic_setup_generate_wallet_skip {
    return Intl.message(
      'Skip',
      name: 'magic_setup_generate_wallet_skip',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nCreating a new Envoy Wallet will erase any existing Envoy Wallet associated with your iCloud account.`
  String get magic_setup_generate_wallet_subheading {
    return Intl.message(
      'WARNING\n\nCreating a new Envoy Wallet will erase any existing Envoy Wallet associated with your iCloud account.',
      name: 'magic_setup_generate_wallet_subheading',
      desc: '',
      args: [],
    );
  }

  /// `12 Word Seed`
  String get magic_setup_import_seed_CTA_1 {
    return Intl.message(
      '12 Word Seed',
      name: 'magic_setup_import_seed_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `24 Word Seed`
  String get magic_setup_import_seed_CTA_2 {
    return Intl.message(
      '24 Word Seed',
      name: 'magic_setup_import_seed_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Import your Seed`
  String get magic_setup_import_seed_heading {
    return Intl.message(
      'Import your Seed',
      name: 'magic_setup_import_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue below to import an existing 12 or 24 word seed.\n\nYou’ll have the option to apply a passphrase as well.`
  String get magic_setup_import_seed_subheading {
    return Intl.message(
      'Continue below to import an existing 12 or 24 word seed.\n\nYou’ll have the option to apply a passphrase as well.',
      name: 'magic_setup_import_seed_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Encrypted Backup`
  String get magic_setup_sending_backup_to_envoy_server_1_5_heading {
    return Intl.message(
      'Uploading Encrypted Backup',
      name: 'magic_setup_sending_backup_to_envoy_server_1_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_sending_backup_to_envoy_server_1_5_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_sending_backup_to_envoy_server_1_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Encrypted Backup`
  String get magic_setup_sending_backup_to_envoy_server_2_5_heading {
    return Intl.message(
      'Uploading Encrypted Backup',
      name: 'magic_setup_sending_backup_to_envoy_server_2_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_sending_backup_to_envoy_server_2_5_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_sending_backup_to_envoy_server_2_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Encrypted Backup`
  String get magic_setup_sending_backup_to_envoy_server_3_5_heading {
    return Intl.message(
      'Uploading Encrypted Backup',
      name: 'magic_setup_sending_backup_to_envoy_server_3_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_sending_backup_to_envoy_server_3_5_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_sending_backup_to_envoy_server_3_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Encrypted Backup`
  String get magic_setup_sending_backup_to_envoy_server_4_5_heading {
    return Intl.message(
      'Uploading Encrypted Backup',
      name: 'magic_setup_sending_backup_to_envoy_server_4_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_sending_backup_to_envoy_server_4_5_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_sending_backup_to_envoy_server_4_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Uploading Encrypted Backup`
  String get magic_setup_sending_backup_to_envoy_server_5_5_heading {
    return Intl.message(
      'Uploading Encrypted Backup',
      name: 'magic_setup_sending_backup_to_envoy_server_5_5_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.`
  String get magic_setup_sending_backup_to_envoy_server_5_5_subheading {
    return Intl.message(
      'Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents.',
      name: 'magic_setup_sending_backup_to_envoy_server_5_5_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get manual_seed_generate_seed_verify_seed_warning_CTA {
    return Intl.message(
      'Go back',
      name: 'manual_seed_generate_seed_verify_seed_warning_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to verify your seed. Please confirm that you correctly recorded your seed and try again.`
  String get manual_seed_generate_seed_verify_seed_warning_subheading {
    return Intl.message(
      'Envoy is unable to verify your seed. Please confirm that you correctly recorded your seed and try again.',
      name: 'manual_seed_generate_seed_verify_seed_warning_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_12_word_seed_enter_passphrase_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_12_word_seed_enter_passphrase_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Passphrase`
  String get manual_setup_12_word_seed_enter_passphrase_heading {
    return Intl.message(
      'Enter Your Passphrase',
      name: 'manual_setup_12_word_seed_enter_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passphrases are case and space sensitive. Enter with extreme care.`
  String get manual_setup_12_word_seed_enter_passphrase_subheading {
    return Intl.message(
      'Passphrases are case and space sensitive. Enter with extreme care.',
      name: 'manual_setup_12_word_seed_enter_passphrase_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_12_word_seed_passphrase_warning_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_12_word_seed_passphrase_warning_CTA',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\nPassphrases are an advanced feature\n\nIf you do not understand the implications of using one, close this box and continue without one.\n\nFoundation has no way to recover a lost or incorrect passphrase.`
  String get manual_setup_12_word_seed_passphrase_warning_subheading {
    return Intl.message(
      'WARNING\nPassphrases are an advanced feature\n\nIf you do not understand the implications of using one, close this box and continue without one.\n\nFoundation has no way to recover a lost or incorrect passphrase.',
      name: 'manual_setup_12_word_seed_passphrase_warning_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_12_word_seed_verify_passphrase_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_12_word_seed_verify_passphrase_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Passphrase`
  String get manual_setup_12_word_seed_verify_passphrase_heading {
    return Intl.message(
      'Verify Your Passphrase',
      name: 'manual_setup_12_word_seed_verify_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passphrases are case and space sensitive. Enter with extreme care.`
  String get manual_setup_12_word_seed_verify_passphrase_subheading {
    return Intl.message(
      'Passphrases are case and space sensitive. Enter with extreme care.',
      name: 'manual_setup_12_word_seed_verify_passphrase_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Your wallet backup is encrypted by your seed words. \n\nIf you lose access to your seed words, you will be unable to recover your backup.`
  String get manual_setup_encrypted_backup_location_1_2_subheading {
    return Intl.message(
      'Your wallet backup is encrypted by your seed words. \n\nIf you lose access to your seed words, you will be unable to recover your backup.',
      name: 'manual_setup_encrypted_backup_location_1_2_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Choose Destination`
  String get manual_setup_encrypted_backup_location_1_3_CTA {
    return Intl.message(
      'Choose Destination',
      name: 'manual_setup_encrypted_backup_location_1_3_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Store Your Encrypted Backup`
  String get manual_setup_encrypted_backup_location_1_3_heading {
    return Intl.message(
      'Store Your Encrypted Backup',
      name: 'manual_setup_encrypted_backup_location_1_3_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy has generated your encrypted backup. This backup contains useful wallet data such as labels, accounts, and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.`
  String get manual_setup_encrypted_backup_location_1_3_subheading {
    return Intl.message(
      'Envoy has generated your encrypted backup. This backup contains useful wallet data such as labels, accounts, and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.',
      name: 'manual_setup_encrypted_backup_location_1_3_subheading',
      desc: '',
      args: [],
    );
  }

  /// `I understand`
  String get manual_setup_encrypted_backup_location_2_3_CTA {
    return Intl.message(
      'I understand',
      name: 'manual_setup_encrypted_backup_location_2_3_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get manual_setup_encrypted_backup_location_3_3_CTA {
    return Intl.message(
      'Action',
      name: 'manual_setup_encrypted_backup_location_3_3_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Title Here`
  String get manual_setup_encrypted_backup_location_3_3_heading {
    return Intl.message(
      'Title Here',
      name: 'manual_setup_encrypted_backup_location_3_3_heading',
      desc: '',
      args: [],
    );
  }

  /// `Here’s to the crazy ones, the misfits, the rebels, the troublemakers...`
  String get manual_setup_encrypted_backup_location_3_3_subheading {
    return Intl.message(
      'Here’s to the crazy ones, the misfits, the rebels, the troublemakers...',
      name: 'manual_setup_encrypted_backup_location_3_3_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Seed`
  String get manual_setup_flow_tutorial_CTA_1 {
    return Intl.message(
      'Generate New Seed',
      name: 'manual_setup_flow_tutorial_CTA_1',
      desc: '',
      args: [],
    );
  }

  /// `Import Seed`
  String get manual_setup_flow_tutorial_CTA_2 {
    return Intl.message(
      'Import Seed',
      name: 'manual_setup_flow_tutorial_CTA_2',
      desc: '',
      args: [],
    );
  }

  /// `Set Up Your Wallet`
  String get manual_setup_flow_tutorial_heading {
    return Intl.message(
      'Set Up Your Wallet',
      name: 'manual_setup_flow_tutorial_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get manual_setup_flow_tutorial_skip {
    return Intl.message(
      'Skip',
      name: 'manual_setup_flow_tutorial_skip',
      desc: '',
      args: [],
    );
  }

  /// `Continue below to import an existing seed or create a new seed.`
  String get manual_setup_flow_tutorial_subheading {
    return Intl.message(
      'Continue below to import an existing seed or create a new seed.',
      name: 'manual_setup_flow_tutorial_subheading',
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

  /// `Continue`
  String get manual_setup_generate_seed_verify_quiz_4_4_done_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_done_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_quiz_4_4_done_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_quiz_4_4_done_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_done_info_text',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get manual_setup_generate_seed_verify_quiz_4_4_done_state_correct {
    return Intl.message(
      'Correct',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_done_state_correct',
      desc: '',
      args: [],
    );
  }

  /// `What is your #11 seed word?`
  String get manual_setup_generate_seed_verify_quiz_4_4_done_subheading {
    return Intl.message(
      'What is your #11 seed word?',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_done_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_quiz_4_4_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_quiz_4_4_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_info_text',
      desc: '',
      args: [],
    );
  }

  /// `What is your #11 seed word?`
  String get manual_setup_generate_seed_verify_quiz_4_4_subheading {
    return Intl.message(
      'What is your #11 seed word?',
      name: 'manual_setup_generate_seed_verify_quiz_4_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_quiz_success_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_quiz_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_quiz_success_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_quiz_success_info_text',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get manual_setup_generate_seed_verify_quiz_success_state_correct {
    return Intl.message(
      'Correct',
      name: 'manual_setup_generate_seed_verify_quiz_success_state_correct',
      desc: '',
      args: [],
    );
  }

  /// `What is your #2 seed word?`
  String get manual_setup_generate_seed_verify_quiz_success_subheading {
    return Intl.message(
      'What is your #2 seed word?',
      name: 'manual_setup_generate_seed_verify_quiz_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_generate_seed_verify_seed_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_generate_seed_verify_seed_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_generate_seed_verify_seed_again_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_generate_seed_verify_seed_again_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Write Down these 12 Words`
  String get manual_setup_generate_seed_verify_seed_again_heading {
    return Intl.message(
      'Write Down these 12 Words',
      name: 'manual_setup_generate_seed_verify_seed_again_heading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_again_quiz_1_4_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_again_quiz_1_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_again_quiz_1_4_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_again_quiz_1_4_info_text',
      desc: '',
      args: [],
    );
  }

  /// `What is your #2 seed word?`
  String get manual_setup_generate_seed_verify_seed_again_quiz_1_4_subheading {
    return Intl.message(
      'What is your #2 seed word?',
      name: 'manual_setup_generate_seed_verify_seed_again_quiz_1_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String
      get manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_heading {
    return Intl.message(
      'Verify Your Seed',
      name:
          'manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String
      get manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_info_text {
    return Intl.message(
      'Choose a word to continue',
      name:
          'manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_info_text',
      desc: '',
      args: [],
    );
  }

  /// `What is your #2 seed word?`
  String
      get manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_subheading {
    return Intl.message(
      'What is your #2 seed word?',
      name:
          'manual_setup_generate_seed_verify_seed_again_quiz_1_4_success_subheading',
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

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_quiz_1_4_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_quiz_1_4_info_text',
      desc: '',
      args: [],
    );
  }

  /// `What is your #2 seed word?`
  String get manual_setup_generate_seed_verify_seed_quiz_1_4_subheading {
    return Intl.message(
      'What is your #2 seed word?',
      name: 'manual_setup_generate_seed_verify_seed_quiz_1_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_2_4_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_2_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_quiz_2_4_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_quiz_2_4_info_text',
      desc: '',
      args: [],
    );
  }

  /// `What is your #9 seed word?`
  String get manual_setup_generate_seed_verify_seed_quiz_2_4_subheading {
    return Intl.message(
      'What is your #9 seed word?',
      name: 'manual_setup_generate_seed_verify_seed_quiz_2_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_2_4_success_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_2_4_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_quiz_2_4_success_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_quiz_2_4_success_info_text',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String
      get manual_setup_generate_seed_verify_seed_quiz_2_4_success_state_correct {
    return Intl.message(
      'Correct',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_2_4_success_state_correct',
      desc: '',
      args: [],
    );
  }

  /// `What is your #9 seed word?`
  String
      get manual_setup_generate_seed_verify_seed_quiz_2_4_success_subheading {
    return Intl.message(
      'What is your #9 seed word?',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_2_4_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_quiz_3_4_CTA {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_quiz_3_4_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_3_4_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_3_4_heading',
      desc: '',
      args: [],
    );
  }

  /// `What is your #5 seed word?`
  String get manual_setup_generate_seed_verify_seed_quiz_3_4_subheading {
    return Intl.message(
      'What is your #5 seed word?',
      name: 'manual_setup_generate_seed_verify_seed_quiz_3_4_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_3_4_success_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_3_4_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word to continue`
  String get manual_setup_generate_seed_verify_seed_quiz_3_4_success_info_text {
    return Intl.message(
      'Choose a word to continue',
      name: 'manual_setup_generate_seed_verify_seed_quiz_3_4_success_info_text',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String
      get manual_setup_generate_seed_verify_seed_quiz_3_4_success_state_correct {
    return Intl.message(
      'Correct',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_3_4_success_state_correct',
      desc: '',
      args: [],
    );
  }

  /// `What is your #5 seed word?`
  String
      get manual_setup_generate_seed_verify_seed_quiz_3_4_success_subheading {
    return Intl.message(
      'What is your #5 seed word?',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_3_4_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get manual_setup_generate_seed_verify_seed_quiz_fail_CTA {
    return Intl.message(
      'Try Again',
      name: 'manual_setup_generate_seed_verify_seed_quiz_fail_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_generate_seed_verify_seed_quiz_fail_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_generate_seed_verify_seed_quiz_fail_heading',
      desc: '',
      args: [],
    );
  }

  /// `Choose a word from the list below.`
  String get manual_setup_generate_seed_verify_seed_quiz_fail_info_text {
    return Intl.message(
      'Choose a word from the list below.',
      name: 'manual_setup_generate_seed_verify_seed_quiz_fail_info_text',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Entry`
  String
      get manual_setup_generate_seed_verify_seed_quiz_fail_state_invalid_entry {
    return Intl.message(
      'Invalid Entry',
      name:
          'manual_setup_generate_seed_verify_seed_quiz_fail_state_invalid_entry',
      desc: '',
      args: [],
    );
  }

  /// `What is your #2 seed word?`
  String get manual_setup_generate_seed_verify_seed_quiz_fail_subheading {
    return Intl.message(
      'What is your #2 seed word?',
      name: 'manual_setup_generate_seed_verify_seed_quiz_fail_subheading',
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

  /// `Done`
  String get manual_setup_generate_seed_write_seed_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_generate_seed_write_seed_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Write Down these 12 Words`
  String get manual_setup_generate_seed_write_seed_heading {
    return Intl.message(
      'Write Down these 12 Words',
      name: 'manual_setup_generate_seed_write_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_autocomplete_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_autocomplete_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_complete_1_2_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_complete_1_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_complete_2_2_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_complete_2_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_completing_android_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_completing_android_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_completing_iOS_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_completing_iOS_heading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_12_word_seed_done_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_12_word_seed_done_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_12_word_seed_done_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_12_word_seed_done_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_done_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_12_word_seed_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_12_word_seed_heading',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get manual_setup_import_12_word_seed_invalid_CTA {
    return Intl.message(
      'Go back',
      name: 'manual_setup_import_12_word_seed_invalid_CTA',
      desc: '',
      args: [],
    );
  }

  /// `That seed appears to be invalid. Please check the words entered, including the order they are in and try again.`
  String get manual_setup_import_12_word_seed_invalid_subheading {
    return Intl.message(
      'That seed appears to be invalid. Please check the words entered, including the order they are in and try again.',
      name: 'manual_setup_import_12_word_seed_invalid_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_12_word_seed_modify_seedword_1_2_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_12_word_seed_modify_seedword_1_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_12_word_seed_modify_seedword_1_2_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_12_word_seed_modify_seedword_1_2_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_12_word_seed_modify_seedword_1_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_12_word_seed_modify_seedword_1_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_12_word_seed_modify_seedword_2_2_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_12_word_seed_modify_seedword_2_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_12_word_seed_modify_seedword_2_2_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_12_word_seed_modify_seedword_2_2_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_12_word_seed_modify_seedword_2_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_12_word_seed_modify_seedword_2_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_12_word_seed_modify_seedword_done_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_12_word_seed_modify_seedword_done_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_12_word_seed_modify_seedword_done_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_12_word_seed_modify_seedword_done_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_12_word_seed_modify_seedword_done_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_12_word_seed_modify_seedword_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_1_2_autocomplete_done_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_1_2_autocomplete_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_1_2_autocomplete_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_1_2_autocomplete_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_import_24_word_seed_1_2_done_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_import_24_word_seed_1_2_done_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_1_2_done_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_1_2_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_1_2_entering_seedword_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_1_2_entering_seedword_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_1_2_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_1_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_24_word_seed_2_2_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_24_word_seed_2_2_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_24_word_seed_2_2_done_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_24_word_seed_2_2_done_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get manual_setup_import_24_word_seed_2_2_done_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name: 'manual_setup_import_24_word_seed_2_2_done_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_2_2_done_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_2_2_done_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_2_2_entering_seedwords_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_2_2_entering_seedwords_heading',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get manual_setup_import_24_word_seed_2_2_heading {
    return Intl.message(
      'Enter Your Seed',
      name: 'manual_setup_import_24_word_seed_2_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Go back`
  String get manual_setup_import_24_word_seed_invalid_seedword_CTA {
    return Intl.message(
      'Go back',
      name: 'manual_setup_import_24_word_seed_invalid_seedword_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is unable to validate your seed. Please confirm that you correctly entered your seed words and try again.`
  String get manual_setup_import_24_word_seed_invalid_seedword_subheading {
    return Intl.message(
      'Envoy is unable to validate your seed. Please confirm that you correctly entered your seed words and try again.',
      name: 'manual_setup_import_24_word_seed_invalid_seedword_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_import_24_word_seed_modify_seedword_1_2_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_import_24_word_seed_modify_seedword_1_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_24_word_seed_modify_seedword_1_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_24_word_seed_modify_seedword_1_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_import_24_word_seed_modify_seedword_2_2_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_import_24_word_seed_modify_seedword_2_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_24_word_seed_modify_seedword_2_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_24_word_seed_modify_seedword_2_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String
      get manual_setup_import_24_word_seed_verify_seedword_add_passphrase_CTA {
    return Intl.message(
      'Done',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_add_passphrase_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String
      get manual_setup_import_24_word_seed_verify_seedword_add_passphrase_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_add_passphrase_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String
      get manual_setup_import_24_word_seed_verify_seedword_add_passphrase_heading {
    return Intl.message(
      'Verify Your Seed',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_add_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get manual_setup_import_24_word_seed_verify_seedword_done_1_2_CTA {
    return Intl.message(
      'Continue',
      name: 'manual_setup_import_24_word_seed_verify_seedword_done_1_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_24_word_seed_verify_seedword_done_1_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_24_word_seed_verify_seedword_done_1_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get manual_setup_import_24_word_seed_verify_seedword_done_2_2_CTA {
    return Intl.message(
      'Done',
      name: 'manual_setup_import_24_word_seed_verify_seedword_done_2_2_CTA',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String
      get manual_setup_import_24_word_seed_verify_seedword_done_2_2_checkbox {
    return Intl.message(
      'My seed has a passphrase',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_done_2_2_checkbox',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get manual_setup_import_24_word_seed_verify_seedword_done_2_2_heading {
    return Intl.message(
      'Verify Your Seed',
      name: 'manual_setup_import_24_word_seed_verify_seedword_done_2_2_heading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String
      get manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_CTA {
    return Intl.message(
      'Continue',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Passphrase`
  String
      get manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_heading {
    return Intl.message(
      'Enter Your Passphrase',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passphrases are case and space sensitive. Enter with care.`
  String
      get manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_subheading {
    return Intl.message(
      'Passphrases are case and space sensitive. Enter with care.',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_enter_passphrase_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String
      get manual_setup_import_24_word_seed_verify_seedword_passphrase_warning_CTA {
    return Intl.message(
      'Continue',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_passphrase_warning_CTA',
      desc: '',
      args: [],
    );
  }

  /// `WARNING\n\nPassphrases are an advanced feature. Are you sure you want to apply a passphrase? \n\nEnvoy is unable to recover a forgotten or incorrect passphrase.`
  String
      get manual_setup_import_24_word_seed_verify_seedword_passphrase_warning_subheading {
    return Intl.message(
      'WARNING\n\nPassphrases are an advanced feature. Are you sure you want to apply a passphrase? \n\nEnvoy is unable to recover a forgotten or incorrect passphrase.',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_passphrase_warning_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String
      get manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_CTA {
    return Intl.message(
      'Continue',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Passphrase`
  String
      get manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_heading {
    return Intl.message(
      'Verify Your Passphrase',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_heading',
      desc: '',
      args: [],
    );
  }

  /// `Passphrases are case and space sensitive. Enter with care.`
  String
      get manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_subheading {
    return Intl.message(
      'Passphrases are case and space sensitive. Enter with care.',
      name:
          'manual_setup_import_24_word_seed_verify_seedword_verify_passphrase_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get pair_existing_device_address_cta1 {
    return Intl.message(
      'Continue',
      name: 'pair_existing_device_address_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Contact Support`
  String get pair_existing_device_address_cta2 {
    return Intl.message(
      'Contact Support',
      name: 'pair_existing_device_address_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Address Validated?`
  String get pair_existing_device_address_heading {
    return Intl.message(
      'Address Validated?',
      name: 'pair_existing_device_address_heading',
      desc: '',
      args: [],
    );
  }

  /// `If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get pair_existing_device_address_subheading {
    return Intl.message(
      'If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'pair_existing_device_address_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get pair_existing_device_intro_cta {
    return Intl.message(
      'Get Started',
      name: 'pair_existing_device_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Connect Passport with Envoy`
  String get pair_existing_device_intro_heading {
    return Intl.message(
      'Connect Passport with Envoy',
      name: 'pair_existing_device_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Connect Wallet > Envoy\n\nIf you want to use Envoy for firmware updates only, feel free to skip this step`
  String get pair_existing_device_intro_subheading {
    return Intl.message(
      'On Passport, select Connect Wallet > Envoy\n\nIf you want to use Envoy for firmware updates only, feel free to skip this step',
      name: 'pair_existing_device_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get pair_existing_device_qr_code_cta {
    return Intl.message(
      'Continue',
      name: 'pair_existing_device_qr_code_cta',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to validate`
  String get pair_existing_device_qr_code_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate',
      name: 'pair_existing_device_qr_code_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is now connected to your Passport.`
  String get pair_existing_device_qr_code_subheading {
    return Intl.message(
      'Envoy is now connected to your Passport.',
      name: 'pair_existing_device_qr_code_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get pair_existing_device_scan_cta {
    return Intl.message(
      'Continue',
      name: 'pair_existing_device_scan_cta',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code that Passport generates`
  String get pair_existing_device_scan_heading {
    return Intl.message(
      'Scan the QR code that Passport generates',
      name: 'pair_existing_device_scan_heading',
      desc: '',
      args: [],
    );
  }

  /// `This QR code contains the information required for Envoy to interact securely with Passport.`
  String get pair_existing_device_scan_subheading {
    return Intl.message(
      'This QR code contains the information required for Envoy to interact securely with Passport.',
      name: 'pair_existing_device_scan_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Validate Receive Address`
  String get pair_existing_device_success_cta1 {
    return Intl.message(
      'Validate Receive Address',
      name: 'pair_existing_device_success_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Continue to home screen`
  String get pair_existing_device_success_cta2 {
    return Intl.message(
      'Continue to home screen',
      name: 'pair_existing_device_success_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Connection successful`
  String get pair_existing_device_success_heading {
    return Intl.message(
      'Connection successful',
      name: 'pair_existing_device_success_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is now connected to your Passport.`
  String get pair_existing_device_success_subheading {
    return Intl.message(
      'Envoy is now connected to your Passport.',
      name: 'pair_existing_device_success_subheading',
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

  /// `Address Validated?`
  String get pair_new_device_address_heading {
    return Intl.message(
      'Address Validated?',
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

  /// `Get Started`
  String get pair_new_device_intro_cta {
    return Intl.message(
      'Get Started',
      name: 'pair_new_device_intro_cta',
      desc: '',
      args: [],
    );
  }

  /// `Connect Passport with Envoy`
  String get pair_new_device_intro_heading {
    return Intl.message(
      'Connect Passport with Envoy',
      name: 'pair_new_device_intro_heading',
      desc: '',
      args: [],
    );
  }

  /// `On Passport, select Connect Wallet > Envoy\n\nIf you want to use Envoy for firmware updates only, feel free to skip this step`
  String get pair_new_device_intro_subheading {
    return Intl.message(
      'On Passport, select Connect Wallet > Envoy\n\nIf you want to use Envoy for firmware updates only, feel free to skip this step',
      name: 'pair_new_device_intro_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get pair_new_device_qr_code_cta {
    return Intl.message(
      'Continue',
      name: 'pair_new_device_qr_code_cta',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with Passport to validate`
  String get pair_new_device_qr_code_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate',
      name: 'pair_new_device_qr_code_heading',
      desc: '',
      args: [],
    );
  }

  /// `This is a Bitcoin address beloning to your Passport.`
  String get pair_new_device_qr_code_subheading {
    return Intl.message(
      'This is a Bitcoin address beloning to your Passport.',
      name: 'pair_new_device_qr_code_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get pair_new_device_scan_cta {
    return Intl.message(
      'Continue',
      name: 'pair_new_device_scan_cta',
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

  /// `This QR code contains the information required for Envoy to interact securely with Passport.`
  String get pair_new_device_scan_subheading {
    return Intl.message(
      'This QR code contains the information required for Envoy to interact securely with Passport.',
      name: 'pair_new_device_scan_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Validate Receive Address`
  String get pair_new_device_success_cta1 {
    return Intl.message(
      'Validate Receive Address',
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

  /// `Continue`
  String get recovery_scenario_CTA {
    return Intl.message(
      'Continue',
      name: 'recovery_scenario_CTA',
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

  /// `Sign into iCloud and restore your iCloud backup`
  String get recovery_scenario_step_1 {
    return Intl.message(
      'Sign into iCloud and restore your iCloud backup',
      name: 'recovery_scenario_step_1',
      desc: '',
      args: [],
    );
  }

  /// `Install Envoy and tap “Recover Envoy Wallet”`
  String get recovery_scenario_step_2 {
    return Intl.message(
      'Install Envoy and tap “Recover Envoy Wallet”',
      name: 'recovery_scenario_step_2',
      desc: '',
      args: [],
    );
  }

  /// `Envoy will then automatically restore your existing Envoy wallet`
  String get recovery_scenario_step_3 {
    return Intl.message(
      'Envoy will then automatically restore your existing Envoy wallet',
      name: 'recovery_scenario_step_3',
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

  /// `Continue`
  String get single_envoy_import_pp_scan_cta {
    return Intl.message(
      'Continue',
      name: 'single_envoy_import_pp_scan_cta',
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
  String get single_envoy_wallet_address_verify_confirm_cta {
    return Intl.message(
      'Continue',
      name: 'single_envoy_wallet_address_verify_confirm_cta',
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

  /// `Address Validated?`
  String get single_envoy_wallet_address_verify_confirm_heading {
    return Intl.message(
      'Address Validated?',
      name: 'single_envoy_wallet_address_verify_confirm_heading',
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

  /// `If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.`
  String get single_envoy_wallet_address_verify_confirm_subheading {
    return Intl.message(
      'If you get a success message on Passport, your setup is now complete.\n\nIf Passport could not verify the address, please try again or contact support.',
      name: 'single_envoy_wallet_address_verify_confirm_subheading',
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

  /// `Scan this QR code with Passport to validate`
  String get single_envoy_wallet_address_verify_heading {
    return Intl.message(
      'Scan this QR code with Passport to validate',
      name: 'single_envoy_wallet_address_verify_heading',
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

  /// `This is a Bitcoin address belonging to your Passport.`
  String get single_envoy_wallet_address_verify_subheading {
    return Intl.message(
      'This is a Bitcoin address belonging to your Passport.',
      name: 'single_envoy_wallet_address_verify_subheading',
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

  /// `Connection successful`
  String get single_envoy_wallet_pair_success_heading {
    return Intl.message(
      'Connection successful',
      name: 'single_envoy_wallet_pair_success_heading',
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

  /// `Envoy is now connected to your Passport.`
  String get single_envoy_wallet_pair_success_subheading {
    return Intl.message(
      'Envoy is now connected to your Passport.',
      name: 'single_envoy_wallet_pair_success_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Create a New Wallet`
  String get splash_screen_cta1 {
    return Intl.message(
      'Create a New Wallet',
      name: 'splash_screen_cta1',
      desc: '',
      args: [],
    );
  }

  /// `Manual Wallet Setup`
  String get splash_screen_cta2 {
    return Intl.message(
      'Manual Wallet Setup',
      name: 'splash_screen_cta2',
      desc: '',
      args: [],
    );
  }

  /// `Passport-Only Setup`
  String get splash_screen_cta3 {
    return Intl.message(
      'Passport-Only Setup',
      name: 'splash_screen_cta3',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Envoy`
  String get splash_screen_heading {
    return Intl.message(
      'Welcome to Envoy',
      name: 'splash_screen_heading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get splash_screen_skip {
    return Intl.message(
      'Skip',
      name: 'splash_screen_skip',
      desc: '',
      args: [],
    );
  }

  /// `Envoy is a simple Bitcoin wallet and Passport companion app.`
  String get splash_screen_subheading {
    return Intl.message(
      'Envoy is a simple Bitcoin wallet and Passport companion app.',
      name: 'splash_screen_subheading',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get text_636d0bb5a3b7eb50b6015535 {
    return Intl.message(
      'Skip',
      name: 'text_636d0bb5a3b7eb50b6015535',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get text_636d0bb5a3b7eb50b6015538 {
    return Intl.message(
      'Skip',
      name: 'text_636d0bb5a3b7eb50b6015538',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport`
  String get text_636d0bb5a3b7eb50b601553b {
    return Intl.message(
      'The perfect companion for your Passport',
      name: 'text_636d0bb5a3b7eb50b601553b',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport`
  String get text_636d0bb5a3b7eb50b601553f {
    return Intl.message(
      'The perfect companion for your Passport',
      name: 'text_636d0bb5a3b7eb50b601553f',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get text_636d0bb5a3b7eb50b6015541 {
    return Intl.message(
      'Skip',
      name: 'text_636d0bb5a3b7eb50b6015541',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d0bb5a3b7eb50b6015544 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d0bb5a3b7eb50b6015544',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d0bb5a3b7eb50b6015548 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d0bb5a3b7eb50b6015548',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport@`
  String get text_636d0bb5a3b7eb50b601554a {
    return Intl.message(
      'The perfect companion for your Passport@',
      name: 'text_636d0bb5a3b7eb50b601554a',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have a Passport? Buy One`
  String get text_636d0bb5a3b7eb50b601554c {
    return Intl.message(
      'Don’t have a Passport? Buy One',
      name: 'text_636d0bb5a3b7eb50b601554c',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have a Passport? Buy One`
  String get text_636d0bb5a3b7eb50b6015550 {
    return Intl.message(
      'Don’t have a Passport? Buy One',
      name: 'text_636d0bb5a3b7eb50b6015550',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d0bb5a3b7eb50b6015552 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d0bb5a3b7eb50b6015552',
      desc: '',
      args: [],
    );
  }

  /// `Manage an Existing Passport`
  String get text_636d0bb5a3b7eb50b6015555 {
    return Intl.message(
      'Manage an Existing Passport',
      name: 'text_636d0bb5a3b7eb50b6015555',
      desc: '',
      args: [],
    );
  }

  /// `Manage an Existing Passport`
  String get text_636d0bb5a3b7eb50b6015559 {
    return Intl.message(
      'Manage an Existing Passport',
      name: 'text_636d0bb5a3b7eb50b6015559',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have a Passport? Buy One`
  String get text_636d0bb5a3b7eb50b601555b {
    return Intl.message(
      'Don’t have a Passport? Buy One',
      name: 'text_636d0bb5a3b7eb50b601555b',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get text_636d0bb5a3b7eb50b601555d {
    return Intl.message(
      'Skip',
      name: 'text_636d0bb5a3b7eb50b601555d',
      desc: '',
      args: [],
    );
  }

  /// `Set Up a New Passport`
  String get text_636d0bb5a3b7eb50b601555f {
    return Intl.message(
      'Set Up a New Passport',
      name: 'text_636d0bb5a3b7eb50b601555f',
      desc: '',
      args: [],
    );
  }

  /// `Set Up a New Passport`
  String get text_636d0bb5a3b7eb50b6015560 {
    return Intl.message(
      'Set Up a New Passport',
      name: 'text_636d0bb5a3b7eb50b6015560',
      desc: '',
      args: [],
    );
  }

  /// `Manage an Existing Passport`
  String get text_636d0bb5a3b7eb50b6015561 {
    return Intl.message(
      'Manage an Existing Passport',
      name: 'text_636d0bb5a3b7eb50b6015561',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport`
  String get text_636d0bb5a3b7eb50b6015563 {
    return Intl.message(
      'The perfect companion for your Passport',
      name: 'text_636d0bb5a3b7eb50b6015563',
      desc: '',
      args: [],
    );
  }

  /// `Set Up a New Passport`
  String get text_636d0bb5a3b7eb50b6015565 {
    return Intl.message(
      'Set Up a New Passport',
      name: 'text_636d0bb5a3b7eb50b6015565',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d0bb5a3b7eb50b6015566 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d0bb5a3b7eb50b6015566',
      desc: '',
      args: [],
    );
  }

  /// `I don’t have a Passport. Buy One`
  String get text_636d0bb5a3b7eb50b6015568 {
    return Intl.message(
      'I don’t have a Passport. Buy One',
      name: 'text_636d0bb5a3b7eb50b6015568',
      desc: '',
      args: [],
    );
  }

  /// `Manage an Existing Passport`
  String get text_636d0bb5a3b7eb50b601556a {
    return Intl.message(
      'Manage an Existing Passport',
      name: 'text_636d0bb5a3b7eb50b601556a',
      desc: '',
      args: [],
    );
  }

  /// `Set Up a New Passport`
  String get text_636d0bb5a3b7eb50b601556c {
    return Intl.message(
      'Set Up a New Passport',
      name: 'text_636d0bb5a3b7eb50b601556c',
      desc: '',
      args: [],
    );
  }

  /// `4321`
  String get text_636d0e1257301d8b9eb942f5 {
    return Intl.message(
      '4321',
      name: 'text_636d0e1257301d8b9eb942f5',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport Andy`
  String get text_636d0e1257301d8b9eb942f7 {
    return Intl.message(
      'The perfect companion for your Passport Andy',
      name: 'text_636d0e1257301d8b9eb942f7',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d0e1257301d8b9eb942f9 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d0e1257301d8b9eb942f9',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get text_636d0e1257301d8b9eb942fd {
    return Intl.message(
      'Skip',
      name: 'text_636d0e1257301d8b9eb942fd',
      desc: '',
      args: [],
    );
  }

  /// `Have an Envoy Shield Account? {{Log In}}`
  String get text_636d0e1257301d8b9eb942ff {
    return Intl.message(
      'Have an Envoy Shield Account? {{Log In}}',
      name: 'text_636d0e1257301d8b9eb942ff',
      desc: '',
      args: [],
    );
  }

  /// `Set up a new Passport`
  String get text_636d0e1257301d8b9eb94301 {
    return Intl.message(
      'Set up a new Passport',
      name: 'text_636d0e1257301d8b9eb94301',
      desc: '',
      args: [],
    );
  }

  /// `Connect an existing Passport`
  String get text_636d0e1257301d8b9eb94303 {
    return Intl.message(
      'Connect an existing Passport',
      name: 'text_636d0e1257301d8b9eb94303',
      desc: '',
      args: [],
    );
  }

  /// `I don’t have a Passport. {{Buy One}}`
  String get text_636d0e1257301d8b9eb94305 {
    return Intl.message(
      'I don’t have a Passport. {{Buy One}}',
      name: 'text_636d0e1257301d8b9eb94305',
      desc: '',
      args: [],
    );
  }

  /// `Skip!`
  String get text_636d1be00ce8d6d7ed885c2a {
    return Intl.message(
      'Skip!',
      name: 'text_636d1be00ce8d6d7ed885c2a',
      desc: '',
      args: [],
    );
  }

  /// `The perfect companion for your Passport`
  String get text_636d1be00ce8d6d7ed885c2c {
    return Intl.message(
      'The perfect companion for your Passport',
      name: 'text_636d1be00ce8d6d7ed885c2c',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_636d1be00ce8d6d7ed885c2e {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_636d1be00ce8d6d7ed885c2e',
      desc: '',
      args: [],
    );
  }

  /// `I don’t have a Passport. Buy One`
  String get text_636d1be00ce8d6d7ed885c30 {
    return Intl.message(
      'I don’t have a Passport. Buy One',
      name: 'text_636d1be00ce8d6d7ed885c30',
      desc: '',
      args: [],
    );
  }

  /// `Manage an Existing Passport`
  String get text_636d1be00ce8d6d7ed885c32 {
    return Intl.message(
      'Manage an Existing Passport',
      name: 'text_636d1be00ce8d6d7ed885c32',
      desc: '',
      args: [],
    );
  }

  /// `Set Up a New Passport`
  String get text_636d1be00ce8d6d7ed885c34 {
    return Intl.message(
      'Set Up a New Passport',
      name: 'text_636d1be00ce8d6d7ed885c34',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String
      get text_6399ff19b95f367561884578learn_more_about_data_secured_2_4_CTA {
    return Intl.message(
      'Continue',
      name:
          'text_6399ff19b95f367561884578learn_more_about_data_secured_2_4_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Setup Your Wallet`
  String get text_6399ff19b95f367561884580 {
    return Intl.message(
      'Let’s Setup Your Wallet',
      name: 'text_6399ff19b95f367561884580',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Setup Your Wallet`
  String get text_6399ff19b95f367561884586 {
    return Intl.message(
      'Let’s Setup Your Wallet',
      name: 'text_6399ff19b95f367561884586',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Setup Your Wallet`
  String get text_6399ff19b95f367561884588 {
    return Intl.message(
      'Let’s Setup Your Wallet',
      name: 'text_6399ff19b95f367561884588',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_6399ff19b95f36756188458a {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_6399ff19b95f36756188458a',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_6399ff19b95f36756188458c {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_6399ff19b95f36756188458c',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_6399ff19b95f367561884590 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_6399ff19b95f367561884590',
      desc: '',
      args: [],
    );
  }

  /// `Learn how your data is secured`
  String get text_6399ff19b95f367561884592 {
    return Intl.message(
      'Learn how your data is secured',
      name: 'text_6399ff19b95f367561884592',
      desc: '',
      args: [],
    );
  }

  /// `Learn how your data is secured`
  String get text_6399ff19b95f367561884594 {
    return Intl.message(
      'Learn how your data is secured',
      name: 'text_6399ff19b95f367561884594',
      desc: '',
      args: [],
    );
  }

  /// `Learn how your data is secured`
  String get text_6399ff19b95f367561884598 {
    return Intl.message(
      'Learn how your data is secured',
      name: 'text_6399ff19b95f367561884598',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get text_6399ff19b95f36756188459a {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'text_6399ff19b95f36756188459a',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get text_6399ff19b95f36756188459c {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'text_6399ff19b95f36756188459c',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get text_6399ff19b95f3675618845a0 {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'text_6399ff19b95f3675618845a0',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Wallet`
  String get text_6399ff19b95f3675618845a2 {
    return Intl.message(
      'Generate New Wallet',
      name: 'text_6399ff19b95f3675618845a2',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Wallet`
  String get text_6399ff19b95f3675618845a3 {
    return Intl.message(
      'Generate New Wallet',
      name: 'text_6399ff19b95f3675618845a3',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Setup Your Wallet`
  String get text_6399ff19b95f3675618845a4 {
    return Intl.message(
      'Let’s Setup Your Wallet',
      name: 'text_6399ff19b95f3675618845a4',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Wallet`
  String get text_6399ff19b95f3675618845a6 {
    return Intl.message(
      'Generate New Wallet',
      name: 'text_6399ff19b95f3675618845a6',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_6399ff19b95f3675618845a7 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_6399ff19b95f3675618845a7',
      desc: '',
      args: [],
    );
  }

  /// `Learn how your data is secured`
  String get text_6399ff19b95f3675618845a9 {
    return Intl.message(
      'Learn how your data is secured',
      name: 'text_6399ff19b95f3675618845a9',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get text_6399ff19b95f3675618845ab {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'text_6399ff19b95f3675618845ab',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Wallet`
  String get text_6399ff19b95f3675618845ad {
    return Intl.message(
      'Generate New Wallet',
      name: 'text_6399ff19b95f3675618845ad',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Setup Your Wallet`
  String get text_639a01a7b95f367561884984 {
    return Intl.message(
      'Let’s Setup Your Wallet',
      name: 'text_639a01a7b95f367561884984',
      desc: '',
      args: [],
    );
  }

  /// `Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.`
  String get text_639a01a7b95f367561884986 {
    return Intl.message(
      'Envoy offers secure Passport setup, easy firmware updates, and a zen-like Bitcoin wallet experience.',
      name: 'text_639a01a7b95f367561884986',
      desc: '',
      args: [],
    );
  }

  /// `We don’t keep your seed`
  String get text_639a01a7b95f367561884988 {
    return Intl.message(
      'We don’t keep your seed',
      name: 'text_639a01a7b95f367561884988',
      desc: '',
      args: [],
    );
  }

  /// `Recover Envoy Wallet`
  String get text_639a01a7b95f36756188498a {
    return Intl.message(
      'Recover Envoy Wallet',
      name: 'text_639a01a7b95f36756188498a',
      desc: '',
      args: [],
    );
  }

  /// `Generate New Wallet`
  String get text_639a01a7b95f36756188498c {
    return Intl.message(
      'Generate New Wallet',
      name: 'text_639a01a7b95f36756188498c',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6a1f {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6a1f',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639aec9fa3d8db28cd9f6a29 {
    return Intl.message(
      '2.',
      name: 'text_639aec9fa3d8db28cd9f6a29',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6a46 {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6a46',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6a67 {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6a67',
      desc: '',
      args: [],
    );
  }

  /// `sweet`
  String get text_639aec9fa3d8db28cd9f6a8b {
    return Intl.message(
      'sweet',
      name: 'text_639aec9fa3d8db28cd9f6a8b',
      desc: '',
      args: [],
    );
  }

  /// `original`
  String get text_639aec9fa3d8db28cd9f6aac {
    return Intl.message(
      'original',
      name: 'text_639aec9fa3d8db28cd9f6aac',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639aec9fa3d8db28cd9f6ac2 {
    return Intl.message(
      '1. abandon',
      name: 'text_639aec9fa3d8db28cd9f6ac2',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639aec9fa3d8db28cd9f6ac4 {
    return Intl.message(
      '9.',
      name: 'text_639aec9fa3d8db28cd9f6ac4',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639aec9fa3d8db28cd9f6ac8 {
    return Intl.message(
      '1. abandon',
      name: 'text_639aec9fa3d8db28cd9f6ac8',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639aec9fa3d8db28cd9f6aca {
    return Intl.message(
      '2.',
      name: 'text_639aec9fa3d8db28cd9f6aca',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639aec9fa3d8db28cd9f6ad3 {
    return Intl.message(
      '5.',
      name: 'text_639aec9fa3d8db28cd9f6ad3',
      desc: '',
      args: [],
    );
  }

  /// `foster`
  String get text_639aec9fa3d8db28cd9f6ad5 {
    return Intl.message(
      'foster',
      name: 'text_639aec9fa3d8db28cd9f6ad5',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get text_639aec9fa3d8db28cd9f6ad9 {
    return Intl.message(
      'Enter Your Seed',
      name: 'text_639aec9fa3d8db28cd9f6ad9',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639aec9fa3d8db28cd9f6ae2 {
    return Intl.message(
      '7. pelican',
      name: 'text_639aec9fa3d8db28cd9f6ae2',
      desc: '',
      args: [],
    );
  }

  /// `pelican`
  String get text_639aec9fa3d8db28cd9f6ae4 {
    return Intl.message(
      'pelican',
      name: 'text_639aec9fa3d8db28cd9f6ae4',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6aec {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6aec',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639aec9fa3d8db28cd9f6aee {
    return Intl.message(
      '7. pelican',
      name: 'text_639aec9fa3d8db28cd9f6aee',
      desc: '',
      args: [],
    );
  }

  /// `piano`
  String get text_639aec9fa3d8db28cd9f6af2 {
    return Intl.message(
      'piano',
      name: 'text_639aec9fa3d8db28cd9f6af2',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639aec9fa3d8db28cd9f6af4 {
    return Intl.message(
      '5.',
      name: 'text_639aec9fa3d8db28cd9f6af4',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639aec9fa3d8db28cd9f6afa {
    return Intl.message(
      '2. broccoli',
      name: 'text_639aec9fa3d8db28cd9f6afa',
      desc: '',
      args: [],
    );
  }

  /// `toast`
  String get text_639aec9fa3d8db28cd9f6b02 {
    return Intl.message(
      'toast',
      name: 'text_639aec9fa3d8db28cd9f6b02',
      desc: '',
      args: [],
    );
  }

  /// `castle`
  String get text_639aec9fa3d8db28cd9f6b04 {
    return Intl.message(
      'castle',
      name: 'text_639aec9fa3d8db28cd9f6b04',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639aec9fa3d8db28cd9f6b06 {
    return Intl.message(
      '2.',
      name: 'text_639aec9fa3d8db28cd9f6b06',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6b08 {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6b08',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6b0a {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b0a',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639aec9fa3d8db28cd9f6b0c {
    return Intl.message(
      '2. broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b0c',
      desc: '',
      args: [],
    );
  }

  /// `tank`
  String get text_639aec9fa3d8db28cd9f6b11 {
    return Intl.message(
      'tank',
      name: 'text_639aec9fa3d8db28cd9f6b11',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639aec9fa3d8db28cd9f6b16 {
    return Intl.message(
      '8. toast',
      name: 'text_639aec9fa3d8db28cd9f6b16',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639aec9fa3d8db28cd9f6b18 {
    return Intl.message(
      '11.',
      name: 'text_639aec9fa3d8db28cd9f6b18',
      desc: '',
      args: [],
    );
  }

  /// `piano`
  String get text_639aec9fa3d8db28cd9f6b1a {
    return Intl.message(
      'piano',
      name: 'text_639aec9fa3d8db28cd9f6b1a',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6b1c {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b1c',
      desc: '',
      args: [],
    );
  }

  /// `sweet`
  String get text_639aec9fa3d8db28cd9f6b1e {
    return Intl.message(
      'sweet',
      name: 'text_639aec9fa3d8db28cd9f6b1e',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639aec9fa3d8db28cd9f6b20 {
    return Intl.message(
      '2.',
      name: 'text_639aec9fa3d8db28cd9f6b20',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6b22 {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6b22',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639aec9fa3d8db28cd9f6b24 {
    return Intl.message(
      '9.',
      name: 'text_639aec9fa3d8db28cd9f6b24',
      desc: '',
      args: [],
    );
  }

  /// `glow`
  String get text_639aec9fa3d8db28cd9f6b26 {
    return Intl.message(
      'glow',
      name: 'text_639aec9fa3d8db28cd9f6b26',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639aec9fa3d8db28cd9f6b28 {
    return Intl.message(
      '8. toast',
      name: 'text_639aec9fa3d8db28cd9f6b28',
      desc: '',
      args: [],
    );
  }

  /// `piano`
  String get text_639aec9fa3d8db28cd9f6b2a {
    return Intl.message(
      'piano',
      name: 'text_639aec9fa3d8db28cd9f6b2a',
      desc: '',
      args: [],
    );
  }

  /// `catch`
  String get text_639aec9fa3d8db28cd9f6b2c {
    return Intl.message(
      'catch',
      name: 'text_639aec9fa3d8db28cd9f6b2c',
      desc: '',
      args: [],
    );
  }

  /// `original`
  String get text_639aec9fa3d8db28cd9f6b30 {
    return Intl.message(
      'original',
      name: 'text_639aec9fa3d8db28cd9f6b30',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639aec9fa3d8db28cd9f6b32 {
    return Intl.message(
      '2.',
      name: 'text_639aec9fa3d8db28cd9f6b32',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639aec9fa3d8db28cd9f6b34 {
    return Intl.message(
      '11.',
      name: 'text_639aec9fa3d8db28cd9f6b34',
      desc: '',
      args: [],
    );
  }

  /// `piano`
  String get text_639aec9fa3d8db28cd9f6b36 {
    return Intl.message(
      'piano',
      name: 'text_639aec9fa3d8db28cd9f6b36',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639aec9fa3d8db28cd9f6b38 {
    return Intl.message(
      '3. sweet',
      name: 'text_639aec9fa3d8db28cd9f6b38',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639aec9fa3d8db28cd9f6b3a {
    return Intl.message(
      '13. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b3a',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6b3c {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b3c',
      desc: '',
      args: [],
    );
  }

  /// `castle`
  String get text_639aec9fa3d8db28cd9f6b40 {
    return Intl.message(
      'castle',
      name: 'text_639aec9fa3d8db28cd9f6b40',
      desc: '',
      args: [],
    );
  }

  /// `Correct`
  String get text_639aec9fa3d8db28cd9f6b44 {
    return Intl.message(
      'Correct',
      name: 'text_639aec9fa3d8db28cd9f6b44',
      desc: '',
      args: [],
    );
  }

  /// `foster`
  String get text_639aec9fa3d8db28cd9f6b49 {
    return Intl.message(
      'foster',
      name: 'text_639aec9fa3d8db28cd9f6b49',
      desc: '',
      args: [],
    );
  }

  /// `tank`
  String get text_639aec9fa3d8db28cd9f6b4b {
    return Intl.message(
      'tank',
      name: 'text_639aec9fa3d8db28cd9f6b4b',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639aec9fa3d8db28cd9f6b4d {
    return Intl.message(
      '3. sweet',
      name: 'text_639aec9fa3d8db28cd9f6b4d',
      desc: '',
      args: [],
    );
  }

  /// `tank`
  String get text_639aec9fa3d8db28cd9f6b4f {
    return Intl.message(
      'tank',
      name: 'text_639aec9fa3d8db28cd9f6b4f',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639aec9fa3d8db28cd9f6b51 {
    return Intl.message(
      '9. castle',
      name: 'text_639aec9fa3d8db28cd9f6b51',
      desc: '',
      args: [],
    );
  }

  /// `19. bacon`
  String get text_639aec9fa3d8db28cd9f6b53 {
    return Intl.message(
      '19. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b53',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6b55 {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6b55',
      desc: '',
      args: [],
    );
  }

  /// `piano`
  String get text_639aec9fa3d8db28cd9f6b57 {
    return Intl.message(
      'piano',
      name: 'text_639aec9fa3d8db28cd9f6b57',
      desc: '',
      args: [],
    );
  }

  /// `pelican`
  String get text_639aec9fa3d8db28cd9f6b5a {
    return Intl.message(
      'pelican',
      name: 'text_639aec9fa3d8db28cd9f6b5a',
      desc: '',
      args: [],
    );
  }

  /// `sweet`
  String get text_639aec9fa3d8db28cd9f6b5c {
    return Intl.message(
      'sweet',
      name: 'text_639aec9fa3d8db28cd9f6b5c',
      desc: '',
      args: [],
    );
  }

  /// `catch`
  String get text_639aec9fa3d8db28cd9f6b5e {
    return Intl.message(
      'catch',
      name: 'text_639aec9fa3d8db28cd9f6b5e',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639aec9fa3d8db28cd9f6b60 {
    return Intl.message(
      '9. castle',
      name: 'text_639aec9fa3d8db28cd9f6b60',
      desc: '',
      args: [],
    );
  }

  /// `tank`
  String get text_639aec9fa3d8db28cd9f6b62 {
    return Intl.message(
      'tank',
      name: 'text_639aec9fa3d8db28cd9f6b62',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6b64 {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b64',
      desc: '',
      args: [],
    );
  }

  /// `14. bacon`
  String get text_639aec9fa3d8db28cd9f6b66 {
    return Intl.message(
      '14. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b66',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639aec9fa3d8db28cd9f6b68 {
    return Intl.message(
      '4. original',
      name: 'text_639aec9fa3d8db28cd9f6b68',
      desc: '',
      args: [],
    );
  }

  /// `catch`
  String get text_639aec9fa3d8db28cd9f6b6a {
    return Intl.message(
      'catch',
      name: 'text_639aec9fa3d8db28cd9f6b6a',
      desc: '',
      args: [],
    );
  }

  /// `abandon`
  String get text_639aec9fa3d8db28cd9f6b6c {
    return Intl.message(
      'abandon',
      name: 'text_639aec9fa3d8db28cd9f6b6c',
      desc: '',
      args: [],
    );
  }

  /// `original`
  String get text_639aec9fa3d8db28cd9f6b6f {
    return Intl.message(
      'original',
      name: 'text_639aec9fa3d8db28cd9f6b6f',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639aec9fa3d8db28cd9f6b71 {
    return Intl.message(
      '10. glow',
      name: 'text_639aec9fa3d8db28cd9f6b71',
      desc: '',
      args: [],
    );
  }

  /// `20. bacon`
  String get text_639aec9fa3d8db28cd9f6b73 {
    return Intl.message(
      '20. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b73',
      desc: '',
      args: [],
    );
  }

  /// `sweet`
  String get text_639aec9fa3d8db28cd9f6b75 {
    return Intl.message(
      'sweet',
      name: 'text_639aec9fa3d8db28cd9f6b75',
      desc: '',
      args: [],
    );
  }

  /// `catch`
  String get text_639aec9fa3d8db28cd9f6b77 {
    return Intl.message(
      'catch',
      name: 'text_639aec9fa3d8db28cd9f6b77',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639aec9fa3d8db28cd9f6b79 {
    return Intl.message(
      '4. original',
      name: 'text_639aec9fa3d8db28cd9f6b79',
      desc: '',
      args: [],
    );
  }

  /// `foster`
  String get text_639aec9fa3d8db28cd9f6b7b {
    return Intl.message(
      'foster',
      name: 'text_639aec9fa3d8db28cd9f6b7b',
      desc: '',
      args: [],
    );
  }

  /// `toast`
  String get text_639aec9fa3d8db28cd9f6b7d {
    return Intl.message(
      'toast',
      name: 'text_639aec9fa3d8db28cd9f6b7d',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639aec9fa3d8db28cd9f6b7f {
    return Intl.message(
      '10. glow',
      name: 'text_639aec9fa3d8db28cd9f6b7f',
      desc: '',
      args: [],
    );
  }

  /// `foster`
  String get text_639aec9fa3d8db28cd9f6b81 {
    return Intl.message(
      'foster',
      name: 'text_639aec9fa3d8db28cd9f6b81',
      desc: '',
      args: [],
    );
  }

  /// `original`
  String get text_639aec9fa3d8db28cd9f6b83 {
    return Intl.message(
      'original',
      name: 'text_639aec9fa3d8db28cd9f6b83',
      desc: '',
      args: [],
    );
  }

  /// `15. bacon`
  String get text_639aec9fa3d8db28cd9f6b85 {
    return Intl.message(
      '15. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b85',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639aec9fa3d8db28cd9f6b87 {
    return Intl.message(
      '5. foster',
      name: 'text_639aec9fa3d8db28cd9f6b87',
      desc: '',
      args: [],
    );
  }

  /// `foster`
  String get text_639aec9fa3d8db28cd9f6b8a {
    return Intl.message(
      'foster',
      name: 'text_639aec9fa3d8db28cd9f6b8a',
      desc: '',
      args: [],
    );
  }

  /// `broccoli`
  String get text_639aec9fa3d8db28cd9f6b8c {
    return Intl.message(
      'broccoli',
      name: 'text_639aec9fa3d8db28cd9f6b8c',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639aec9fa3d8db28cd9f6b8e {
    return Intl.message(
      '11. piano',
      name: 'text_639aec9fa3d8db28cd9f6b8e',
      desc: '',
      args: [],
    );
  }

  /// `21. bacon`
  String get text_639aec9fa3d8db28cd9f6b90 {
    return Intl.message(
      '21. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b90',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639aec9fa3d8db28cd9f6b95 {
    return Intl.message(
      '5. foster',
      name: 'text_639aec9fa3d8db28cd9f6b95',
      desc: '',
      args: [],
    );
  }

  /// `glow`
  String get text_639aec9fa3d8db28cd9f6b98 {
    return Intl.message(
      'glow',
      name: 'text_639aec9fa3d8db28cd9f6b98',
      desc: '',
      args: [],
    );
  }

  /// `16. bacon`
  String get text_639aec9fa3d8db28cd9f6b9b {
    return Intl.message(
      '16. bacon',
      name: 'text_639aec9fa3d8db28cd9f6b9b',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639aec9fa3d8db28cd9f6b9d {
    return Intl.message(
      '6. tank',
      name: 'text_639aec9fa3d8db28cd9f6b9d',
      desc: '',
      args: [],
    );
  }

  /// `sweet`
  String get text_639aec9fa3d8db28cd9f6ba0 {
    return Intl.message(
      'sweet',
      name: 'text_639aec9fa3d8db28cd9f6ba0',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639aec9fa3d8db28cd9f6ba2 {
    return Intl.message(
      '11. piano',
      name: 'text_639aec9fa3d8db28cd9f6ba2',
      desc: '',
      args: [],
    );
  }

  /// `castle`
  String get text_639aec9fa3d8db28cd9f6ba4 {
    return Intl.message(
      'castle',
      name: 'text_639aec9fa3d8db28cd9f6ba4',
      desc: '',
      args: [],
    );
  }

  /// `22. bacon`
  String get text_639aec9fa3d8db28cd9f6ba6 {
    return Intl.message(
      '22. bacon',
      name: 'text_639aec9fa3d8db28cd9f6ba6',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639aec9fa3d8db28cd9f6ba8 {
    return Intl.message(
      '12. catch',
      name: 'text_639aec9fa3d8db28cd9f6ba8',
      desc: '',
      args: [],
    );
  }

  /// `original`
  String get text_639aec9fa3d8db28cd9f6baa {
    return Intl.message(
      'original',
      name: 'text_639aec9fa3d8db28cd9f6baa',
      desc: '',
      args: [],
    );
  }

  /// `17. bacon`
  String get text_639aec9fa3d8db28cd9f6bac {
    return Intl.message(
      '17. bacon',
      name: 'text_639aec9fa3d8db28cd9f6bac',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639aec9fa3d8db28cd9f6bae {
    return Intl.message(
      '6. tank',
      name: 'text_639aec9fa3d8db28cd9f6bae',
      desc: '',
      args: [],
    );
  }

  /// `23. bacon`
  String get text_639aec9fa3d8db28cd9f6bb3 {
    return Intl.message(
      '23. bacon',
      name: 'text_639aec9fa3d8db28cd9f6bb3',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639aec9fa3d8db28cd9f6bb5 {
    return Intl.message(
      '12. catch',
      name: 'text_639aec9fa3d8db28cd9f6bb5',
      desc: '',
      args: [],
    );
  }

  /// `18. bacon`
  String get text_639aec9fa3d8db28cd9f6bb7 {
    return Intl.message(
      '18. bacon',
      name: 'text_639aec9fa3d8db28cd9f6bb7',
      desc: '',
      args: [],
    );
  }

  /// `24. bacon`
  String get text_639aec9fa3d8db28cd9f6bba {
    return Intl.message(
      '24. bacon',
      name: 'text_639aec9fa3d8db28cd9f6bba',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639aec9fa3d8db28cd9f6bbc {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639aec9fa3d8db28cd9f6bbc',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639aec9fa3d8db28cd9f6bbe {
    return Intl.message(
      'Done',
      name: 'text_639aec9fa3d8db28cd9f6bbe',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618453 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618453',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618456 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618456',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618458 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618458',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd61845b {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd61845b',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd61845e {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd61845e',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd618460 {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd618460',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd61846d {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd61846d',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd61846f {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd61846f',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd618477 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd618477',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd618486 {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd618486',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd618488 {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd618488',
      desc: '',
      args: [],
    );
  }

  /// `8. taost`
  String get text_639af7fc5ab3596bdd618490 {
    return Intl.message(
      '8. taost',
      name: 'text_639af7fc5ab3596bdd618490',
      desc: '',
      args: [],
    );
  }

  /// `3. swe`
  String get text_639af7fc5ab3596bdd6184a9 {
    return Intl.message(
      '3. swe',
      name: 'text_639af7fc5ab3596bdd6184a9',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6184ab {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6184ab',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6184ad {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6184ad',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd6184c6 {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd6184c6',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd6184c8 {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd6184c8',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd6184d2 {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd6184d2',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd6184dc {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd6184dc',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd6184de {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd6184de',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639af7fc5ab3596bdd6184e0 {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639af7fc5ab3596bdd6184e0',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd6184e4 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd6184e4',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639af7fc5ab3596bdd6184ea {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639af7fc5ab3596bdd6184ea',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6184ee {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6184ee',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6184f0 {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6184f0',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639af7fc5ab3596bdd6184f2 {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639af7fc5ab3596bdd6184f2',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6184fa {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6184fa',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd6184fe {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd6184fe',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd618500 {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd618500',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd618502 {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd618502',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd618504 {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd618504',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618506 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618506',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639af7fc5ab3596bdd61850c {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639af7fc5ab3596bdd61850c',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618510 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618510',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618512 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618512',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618514 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618514',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd618516 {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd618516',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd618518 {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd618518',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd61851a {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd61851a',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd61851c {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd61851c',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd618520 {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd618520',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd618522 {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd618522',
      desc: '',
      args: [],
    );
  }

  /// `1.`
  String get text_639af7fc5ab3596bdd618526 {
    return Intl.message(
      '1.',
      name: 'text_639af7fc5ab3596bdd618526',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd61852a {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd61852a',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd61852c {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd61852c',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd61852e {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd61852e',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd618530 {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd618530',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd618534 {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd618534',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd618536 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd618536',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618538 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618538',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd61853a {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd61853a',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd61853c {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd61853c',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639af7fc5ab3596bdd618540 {
    return Intl.message(
      '7.',
      name: 'text_639af7fc5ab3596bdd618540',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618542 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618542',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd618544 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd618544',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd618546 {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd618546',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd618548 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd618548',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd61854a {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd61854a',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639af7fc5ab3596bdd61854c {
    return Intl.message(
      '2. broccoli',
      name: 'text_639af7fc5ab3596bdd61854c',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd618552 {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd618552',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd618554 {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd618554',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd618556 {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd618556',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639af7fc5ab3596bdd618558 {
    return Intl.message(
      '8. toast',
      name: 'text_639af7fc5ab3596bdd618558',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd61855a {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd61855a',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639af7fc5ab3596bdd61855c {
    return Intl.message(
      '2.',
      name: 'text_639af7fc5ab3596bdd61855c',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd61855e {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd61855e',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd618560 {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd618560',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618562 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618562',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618566 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618566',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639af7fc5ab3596bdd618568 {
    return Intl.message(
      '1. abandon',
      name: 'text_639af7fc5ab3596bdd618568',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd61856a {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd61856a',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639af7fc5ab3596bdd61856c {
    return Intl.message(
      '8. toast',
      name: 'text_639af7fc5ab3596bdd61856c',
      desc: '',
      args: [],
    );
  }

  /// `8. to`
  String get text_639af7fc5ab3596bdd61856e {
    return Intl.message(
      '8. to',
      name: 'text_639af7fc5ab3596bdd61856e',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618570 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618570',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639af7fc5ab3596bdd618572 {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639af7fc5ab3596bdd618572',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd618574 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd618574',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd618576 {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd618576',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd618578 {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd618578',
      desc: '',
      args: [],
    );
  }

  /// `3. swe`
  String get text_639af7fc5ab3596bdd61857d {
    return Intl.message(
      '3. swe',
      name: 'text_639af7fc5ab3596bdd61857d',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639af7fc5ab3596bdd61857f {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639af7fc5ab3596bdd61857f',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639af7fc5ab3596bdd618581 {
    return Intl.message(
      '8.',
      name: 'text_639af7fc5ab3596bdd618581',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639af7fc5ab3596bdd618583 {
    return Intl.message(
      '7. pelican',
      name: 'text_639af7fc5ab3596bdd618583',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd618585 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd618585',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd618587 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd618587',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd618589 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd618589',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639af7fc5ab3596bdd61858b {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639af7fc5ab3596bdd61858b',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd61858d {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd61858d',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd61858f {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd61858f',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639af7fc5ab3596bdd618591 {
    return Intl.message(
      '8. toast',
      name: 'text_639af7fc5ab3596bdd618591',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd618595 {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd618595',
      desc: '',
      args: [],
    );
  }

  /// `8. taost`
  String get text_639af7fc5ab3596bdd618597 {
    return Intl.message(
      '8. taost',
      name: 'text_639af7fc5ab3596bdd618597',
      desc: '',
      args: [],
    );
  }

  /// `3.`
  String get text_639af7fc5ab3596bdd618599 {
    return Intl.message(
      '3.',
      name: 'text_639af7fc5ab3596bdd618599',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639af7fc5ab3596bdd61859b {
    return Intl.message(
      '8. toast',
      name: 'text_639af7fc5ab3596bdd61859b',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd61859d {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd61859d',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd61859f {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd61859f',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd6185a1 {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd6185a1',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639af7fc5ab3596bdd6185a3 {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639af7fc5ab3596bdd6185a3',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185a7 {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185a7',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6185a9 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6185a9',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6185ad {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6185ad',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639af7fc5ab3596bdd6185af {
    return Intl.message(
      '9.',
      name: 'text_639af7fc5ab3596bdd6185af',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6185b1 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6185b1',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd6185b3 {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd6185b3',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6185b5 {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6185b5',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd6185b7 {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd6185b7',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639af7fc5ab3596bdd6185b9 {
    return Intl.message(
      '8. toast',
      name: 'text_639af7fc5ab3596bdd6185b9',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639af7fc5ab3596bdd6185bd {
    return Intl.message(
      '4.',
      name: 'text_639af7fc5ab3596bdd6185bd',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd6185bf {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd6185bf',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd6185c3 {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd6185c3',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd6185c5 {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd6185c5',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185c7 {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185c7',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185c9 {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185c9',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd6185cb {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd6185cb',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6185cd {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6185cd',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd6185cf {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd6185cf',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185d3 {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185d3',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6185d5 {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6185d5',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639af7fc5ab3596bdd6185d7 {
    return Intl.message(
      '3. sweet',
      name: 'text_639af7fc5ab3596bdd6185d7',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639af7fc5ab3596bdd6185d9 {
    return Intl.message(
      '10.',
      name: 'text_639af7fc5ab3596bdd6185d9',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd6185db {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd6185db',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd6185dd {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd6185dd',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd6185df {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd6185df',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd6185e3 {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd6185e3',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd6185e5 {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd6185e5',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185e7 {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185e7',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd6185eb {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd6185eb',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd6185ed {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd6185ed',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639af7fc5ab3596bdd6185ef {
    return Intl.message(
      '9. castle',
      name: 'text_639af7fc5ab3596bdd6185ef',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639af7fc5ab3596bdd6185f1 {
    return Intl.message(
      '5.',
      name: 'text_639af7fc5ab3596bdd6185f1',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd6185f3 {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd6185f3',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd6185f5 {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd6185f5',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd6185f9 {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd6185f9',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd6185fb {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd6185fb',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd6185fd {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd6185fd',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd6185ff {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd6185ff',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd618601 {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd618601',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd618605 {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd618605',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618609 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618609',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd61860b {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd61860b',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd61860d {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd61860d',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639af7fc5ab3596bdd61860f {
    return Intl.message(
      '4. original',
      name: 'text_639af7fc5ab3596bdd61860f',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639af7fc5ab3596bdd618611 {
    return Intl.message(
      '11.',
      name: 'text_639af7fc5ab3596bdd618611',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618613 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618613',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd618615 {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd618615',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618617 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618617',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd61861b {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd61861b',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd61861f {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd61861f',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618621 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618621',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd618623 {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd618623',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639af7fc5ab3596bdd618625 {
    return Intl.message(
      '10. glow',
      name: 'text_639af7fc5ab3596bdd618625',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639af7fc5ab3596bdd618627 {
    return Intl.message(
      '6.',
      name: 'text_639af7fc5ab3596bdd618627',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618629 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618629',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd61862d {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd61862d',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd61862f {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd61862f',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd618631 {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd618631',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618633 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618633',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618639 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618639',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd61863b {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd61863b',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd61863d {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd61863d',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd618641 {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd618641',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618643 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618643',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639af7fc5ab3596bdd618644 {
    return Intl.message(
      '5. foster',
      name: 'text_639af7fc5ab3596bdd618644',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639af7fc5ab3596bdd618646 {
    return Intl.message(
      '12.',
      name: 'text_639af7fc5ab3596bdd618646',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd618648 {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd618648',
      desc: '',
      args: [],
    );
  }

  /// `“design”`
  String get text_639af7fc5ab3596bdd61864a {
    return Intl.message(
      '“design”',
      name: 'text_639af7fc5ab3596bdd61864a',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639af7fc5ab3596bdd618650 {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639af7fc5ab3596bdd618650',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd618652 {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd618652',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd618654 {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd618654',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639af7fc5ab3596bdd618658 {
    return Intl.message(
      '11. piano',
      name: 'text_639af7fc5ab3596bdd618658',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639af7fc5ab3596bdd61865c {
    return Intl.message(
      'Done',
      name: 'text_639af7fc5ab3596bdd61865c',
      desc: '',
      args: [],
    );
  }

  /// `Design`
  String get text_639af7fc5ab3596bdd618661 {
    return Intl.message(
      'Design',
      name: 'text_639af7fc5ab3596bdd618661',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd618665 {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd618665',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd618669 {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd618669',
      desc: '',
      args: [],
    );
  }

  /// `Designer`
  String get text_639af7fc5ab3596bdd61866c {
    return Intl.message(
      'Designer',
      name: 'text_639af7fc5ab3596bdd61866c',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639af7fc5ab3596bdd618674 {
    return Intl.message(
      '6. tank',
      name: 'text_639af7fc5ab3596bdd618674',
      desc: '',
      args: [],
    );
  }

  /// `Q`
  String get text_639af7fc5ab3596bdd61867e {
    return Intl.message(
      'Q',
      name: 'text_639af7fc5ab3596bdd61867e',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639af7fc5ab3596bdd618680 {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639af7fc5ab3596bdd618680',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639af7fc5ab3596bdd618683 {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639af7fc5ab3596bdd618683',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639af7fc5ab3596bdd61868d {
    return Intl.message(
      '12. catch',
      name: 'text_639af7fc5ab3596bdd61868d',
      desc: '',
      args: [],
    );
  }

  /// `W`
  String get text_639af7fc5ab3596bdd618694 {
    return Intl.message(
      'W',
      name: 'text_639af7fc5ab3596bdd618694',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639af7fc5ab3596bdd618696 {
    return Intl.message(
      'Done',
      name: 'text_639af7fc5ab3596bdd618696',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639af7fc5ab3596bdd618697 {
    return Intl.message(
      'Done',
      name: 'text_639af7fc5ab3596bdd618697',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639af7fc5ab3596bdd61869c {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639af7fc5ab3596bdd61869c',
      desc: '',
      args: [],
    );
  }

  /// `E`
  String get text_639af7fc5ab3596bdd6186a2 {
    return Intl.message(
      'E',
      name: 'text_639af7fc5ab3596bdd6186a2',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639af7fc5ab3596bdd6186a8 {
    return Intl.message(
      'Done',
      name: 'text_639af7fc5ab3596bdd6186a8',
      desc: '',
      args: [],
    );
  }

  /// `R`
  String get text_639af7fc5ab3596bdd6186ad {
    return Intl.message(
      'R',
      name: 'text_639af7fc5ab3596bdd6186ad',
      desc: '',
      args: [],
    );
  }

  /// `T`
  String get text_639af7fc5ab3596bdd6186b7 {
    return Intl.message(
      'T',
      name: 'text_639af7fc5ab3596bdd6186b7',
      desc: '',
      args: [],
    );
  }

  /// `Y`
  String get text_639af7fc5ab3596bdd6186c1 {
    return Intl.message(
      'Y',
      name: 'text_639af7fc5ab3596bdd6186c1',
      desc: '',
      args: [],
    );
  }

  /// `U`
  String get text_639af7fc5ab3596bdd6186cb {
    return Intl.message(
      'U',
      name: 'text_639af7fc5ab3596bdd6186cb',
      desc: '',
      args: [],
    );
  }

  /// `I`
  String get text_639af7fc5ab3596bdd6186d5 {
    return Intl.message(
      'I',
      name: 'text_639af7fc5ab3596bdd6186d5',
      desc: '',
      args: [],
    );
  }

  /// `O`
  String get text_639af7fc5ab3596bdd6186df {
    return Intl.message(
      'O',
      name: 'text_639af7fc5ab3596bdd6186df',
      desc: '',
      args: [],
    );
  }

  /// `P`
  String get text_639af7fc5ab3596bdd6186e9 {
    return Intl.message(
      'P',
      name: 'text_639af7fc5ab3596bdd6186e9',
      desc: '',
      args: [],
    );
  }

  /// `A`
  String get text_639af7fc5ab3596bdd6186f3 {
    return Intl.message(
      'A',
      name: 'text_639af7fc5ab3596bdd6186f3',
      desc: '',
      args: [],
    );
  }

  /// `S`
  String get text_639af7fc5ab3596bdd6186fd {
    return Intl.message(
      'S',
      name: 'text_639af7fc5ab3596bdd6186fd',
      desc: '',
      args: [],
    );
  }

  /// `D`
  String get text_639af7fc5ab3596bdd618709 {
    return Intl.message(
      'D',
      name: 'text_639af7fc5ab3596bdd618709',
      desc: '',
      args: [],
    );
  }

  /// `F`
  String get text_639af7fc5ab3596bdd618713 {
    return Intl.message(
      'F',
      name: 'text_639af7fc5ab3596bdd618713',
      desc: '',
      args: [],
    );
  }

  /// `G`
  String get text_639af7fc5ab3596bdd61871f {
    return Intl.message(
      'G',
      name: 'text_639af7fc5ab3596bdd61871f',
      desc: '',
      args: [],
    );
  }

  /// `H`
  String get text_639af7fc5ab3596bdd61872b {
    return Intl.message(
      'H',
      name: 'text_639af7fc5ab3596bdd61872b',
      desc: '',
      args: [],
    );
  }

  /// `J`
  String get text_639af7fc5ab3596bdd618735 {
    return Intl.message(
      'J',
      name: 'text_639af7fc5ab3596bdd618735',
      desc: '',
      args: [],
    );
  }

  /// `K`
  String get text_639af7fc5ab3596bdd61873f {
    return Intl.message(
      'K',
      name: 'text_639af7fc5ab3596bdd61873f',
      desc: '',
      args: [],
    );
  }

  /// `L`
  String get text_639af7fc5ab3596bdd618749 {
    return Intl.message(
      'L',
      name: 'text_639af7fc5ab3596bdd618749',
      desc: '',
      args: [],
    );
  }

  /// `Z`
  String get text_639af7fc5ab3596bdd61875f {
    return Intl.message(
      'Z',
      name: 'text_639af7fc5ab3596bdd61875f',
      desc: '',
      args: [],
    );
  }

  /// `X`
  String get text_639af7fc5ab3596bdd618767 {
    return Intl.message(
      'X',
      name: 'text_639af7fc5ab3596bdd618767',
      desc: '',
      args: [],
    );
  }

  /// `C`
  String get text_639af7fc5ab3596bdd618773 {
    return Intl.message(
      'C',
      name: 'text_639af7fc5ab3596bdd618773',
      desc: '',
      args: [],
    );
  }

  /// `V`
  String get text_639af7fc5ab3596bdd618777 {
    return Intl.message(
      'V',
      name: 'text_639af7fc5ab3596bdd618777',
      desc: '',
      args: [],
    );
  }

  /// `B`
  String get text_639af7fc5ab3596bdd618783 {
    return Intl.message(
      'B',
      name: 'text_639af7fc5ab3596bdd618783',
      desc: '',
      args: [],
    );
  }

  /// `N`
  String get text_639af7fc5ab3596bdd61878d {
    return Intl.message(
      'N',
      name: 'text_639af7fc5ab3596bdd61878d',
      desc: '',
      args: [],
    );
  }

  /// `M`
  String get text_639af7fc5ab3596bdd618797 {
    return Intl.message(
      'M',
      name: 'text_639af7fc5ab3596bdd618797',
      desc: '',
      args: [],
    );
  }

  /// `123`
  String get text_639af7fc5ab3596bdd6187a7 {
    return Intl.message(
      '123',
      name: 'text_639af7fc5ab3596bdd6187a7',
      desc: '',
      args: [],
    );
  }

  /// `space`
  String get text_639af7fc5ab3596bdd6187ad {
    return Intl.message(
      'space',
      name: 'text_639af7fc5ab3596bdd6187ad',
      desc: '',
      args: [],
    );
  }

  /// `return`
  String get text_639af7fc5ab3596bdd6187b3 {
    return Intl.message(
      'return',
      name: 'text_639af7fc5ab3596bdd6187b3',
      desc: '',
      args: [],
    );
  }

  /// `􀎸`
  String get text_639af7fc5ab3596bdd6187b9 {
    return Intl.message(
      '􀎸',
      name: 'text_639af7fc5ab3596bdd6187b9',
      desc: '',
      args: [],
    );
  }

  /// `􀊰`
  String get text_639af7fc5ab3596bdd6187be {
    return Intl.message(
      '􀊰',
      name: 'text_639af7fc5ab3596bdd6187be',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0588fe1a37c21666e85d {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0588fe1a37c21666e85d',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0588fe1a37c21666e880 {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0588fe1a37c21666e880',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639b0588fe1a37c21666e882 {
    return Intl.message(
      '13. bacon',
      name: 'text_639b0588fe1a37c21666e882',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639b0588fe1a37c21666e89c {
    return Intl.message(
      '13. bacon',
      name: 'text_639b0588fe1a37c21666e89c',
      desc: '',
      args: [],
    );
  }

  /// `1. `
  String get text_639b0588fe1a37c21666e89e {
    return Intl.message(
      '1. ',
      name: 'text_639b0588fe1a37c21666e89e',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your Seed`
  String get text_639b0588fe1a37c21666e8a0 {
    return Intl.message(
      'Enter Your Seed',
      name: 'text_639b0588fe1a37c21666e8a0',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0588fe1a37c21666e8a2 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0588fe1a37c21666e8a2',
      desc: '',
      args: [],
    );
  }

  /// `19.`
  String get text_639b0588fe1a37c21666e8a4 {
    return Intl.message(
      '19.',
      name: 'text_639b0588fe1a37c21666e8a4',
      desc: '',
      args: [],
    );
  }

  /// `13.`
  String get text_639b0588fe1a37c21666e8a8 {
    return Intl.message(
      '13.',
      name: 'text_639b0588fe1a37c21666e8a8',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0588fe1a37c21666e8aa {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0588fe1a37c21666e8aa',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639b0589fe1a37c21666e8ae {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639b0589fe1a37c21666e8ae',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639b0589fe1a37c21666e8b3 {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639b0589fe1a37c21666e8b3',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Seed`
  String get text_639b0589fe1a37c21666e8b5 {
    return Intl.message(
      'Verify Your Seed',
      name: 'text_639b0589fe1a37c21666e8b5',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639b0589fe1a37c21666e8c1 {
    return Intl.message(
      '7.',
      name: 'text_639b0589fe1a37c21666e8c1',
      desc: '',
      args: [],
    );
  }

  /// `19. bacon`
  String get text_639b0589fe1a37c21666e8c3 {
    return Intl.message(
      '19. bacon',
      name: 'text_639b0589fe1a37c21666e8c3',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639b0589fe1a37c21666e8c5 {
    return Intl.message(
      '8. toast',
      name: 'text_639b0589fe1a37c21666e8c5',
      desc: '',
      args: [],
    );
  }

  /// `14.`
  String get text_639b0589fe1a37c21666e8c7 {
    return Intl.message(
      '14.',
      name: 'text_639b0589fe1a37c21666e8c7',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639b0589fe1a37c21666e8c9 {
    return Intl.message(
      '13. bacon',
      name: 'text_639b0589fe1a37c21666e8c9',
      desc: '',
      args: [],
    );
  }

  /// `19.`
  String get text_639b0589fe1a37c21666e8cb {
    return Intl.message(
      '19.',
      name: 'text_639b0589fe1a37c21666e8cb',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e8cd {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e8cd',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e8d5 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e8d5',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e8d9 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e8d9',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e8db {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e8db',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639b0589fe1a37c21666e8dd {
    return Intl.message(
      '13. bacon',
      name: 'text_639b0589fe1a37c21666e8dd',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e8df {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e8df',
      desc: '',
      args: [],
    );
  }

  /// `2.`
  String get text_639b0589fe1a37c21666e8e3 {
    return Intl.message(
      '2.',
      name: 'text_639b0589fe1a37c21666e8e3',
      desc: '',
      args: [],
    );
  }

  /// `14. bacon`
  String get text_639b0589fe1a37c21666e8e5 {
    return Intl.message(
      '14. bacon',
      name: 'text_639b0589fe1a37c21666e8e5',
      desc: '',
      args: [],
    );
  }

  /// `20.`
  String get text_639b0589fe1a37c21666e8e7 {
    return Intl.message(
      '20.',
      name: 'text_639b0589fe1a37c21666e8e7',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e8e9 {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e8e9',
      desc: '',
      args: [],
    );
  }

  /// `19. bacon`
  String get text_639b0589fe1a37c21666e8eb {
    return Intl.message(
      '19. bacon',
      name: 'text_639b0589fe1a37c21666e8eb',
      desc: '',
      args: [],
    );
  }

  /// `14.`
  String get text_639b0589fe1a37c21666e8ed {
    return Intl.message(
      '14.',
      name: 'text_639b0589fe1a37c21666e8ed',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e8ef {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e8ef',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e8f1 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e8f1',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639b0589fe1a37c21666e8f7 {
    return Intl.message(
      '7.',
      name: 'text_639b0589fe1a37c21666e8f7',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639b0589fe1a37c21666e8f9 {
    return Intl.message(
      '7.',
      name: 'text_639b0589fe1a37c21666e8f9',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e8fb {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e8fb',
      desc: '',
      args: [],
    );
  }

  /// `19. bacon`
  String get text_639b0589fe1a37c21666e8ff {
    return Intl.message(
      '19. bacon',
      name: 'text_639b0589fe1a37c21666e8ff',
      desc: '',
      args: [],
    );
  }

  /// `7.`
  String get text_639b0589fe1a37c21666e901 {
    return Intl.message(
      '7.',
      name: 'text_639b0589fe1a37c21666e901',
      desc: '',
      args: [],
    );
  }

  /// `13. bacon`
  String get text_639b0589fe1a37c21666e903 {
    return Intl.message(
      '13. bacon',
      name: 'text_639b0589fe1a37c21666e903',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639b0589fe1a37c21666e905 {
    return Intl.message(
      '8.',
      name: 'text_639b0589fe1a37c21666e905',
      desc: '',
      args: [],
    );
  }

  /// `20. bacon`
  String get text_639b0589fe1a37c21666e907 {
    return Intl.message(
      '20. bacon',
      name: 'text_639b0589fe1a37c21666e907',
      desc: '',
      args: [],
    );
  }

  /// `15.`
  String get text_639b0589fe1a37c21666e909 {
    return Intl.message(
      '15.',
      name: 'text_639b0589fe1a37c21666e909',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e90b {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e90b',
      desc: '',
      args: [],
    );
  }

  /// `8. taost`
  String get text_639b0589fe1a37c21666e90d {
    return Intl.message(
      '8. taost',
      name: 'text_639b0589fe1a37c21666e90d',
      desc: '',
      args: [],
    );
  }

  /// `20.`
  String get text_639b0589fe1a37c21666e90f {
    return Intl.message(
      '20.',
      name: 'text_639b0589fe1a37c21666e90f',
      desc: '',
      args: [],
    );
  }

  /// `14. bacon`
  String get text_639b0589fe1a37c21666e911 {
    return Intl.message(
      '14. bacon',
      name: 'text_639b0589fe1a37c21666e911',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e913 {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e913',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e915 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e915',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e919 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e919',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e91b {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e91b',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e91d {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e91d',
      desc: '',
      args: [],
    );
  }

  /// `19. bacon`
  String get text_639b0589fe1a37c21666e921 {
    return Intl.message(
      '19. bacon',
      name: 'text_639b0589fe1a37c21666e921',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e923 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e923',
      desc: '',
      args: [],
    );
  }

  /// `14. bacon`
  String get text_639b0589fe1a37c21666e925 {
    return Intl.message(
      '14. bacon',
      name: 'text_639b0589fe1a37c21666e925',
      desc: '',
      args: [],
    );
  }

  /// `3.`
  String get text_639b0589fe1a37c21666e927 {
    return Intl.message(
      '3.',
      name: 'text_639b0589fe1a37c21666e927',
      desc: '',
      args: [],
    );
  }

  /// `15. bacon`
  String get text_639b0589fe1a37c21666e929 {
    return Intl.message(
      '15. bacon',
      name: 'text_639b0589fe1a37c21666e929',
      desc: '',
      args: [],
    );
  }

  /// `21.`
  String get text_639b0589fe1a37c21666e92b {
    return Intl.message(
      '21.',
      name: 'text_639b0589fe1a37c21666e92b',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e92d {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e92d',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e92f {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e92f',
      desc: '',
      args: [],
    );
  }

  /// `15.`
  String get text_639b0589fe1a37c21666e931 {
    return Intl.message(
      '15.',
      name: 'text_639b0589fe1a37c21666e931',
      desc: '',
      args: [],
    );
  }

  /// `20. bacon`
  String get text_639b0589fe1a37c21666e933 {
    return Intl.message(
      '20. bacon',
      name: 'text_639b0589fe1a37c21666e933',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e935 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e935',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e937 {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e937',
      desc: '',
      args: [],
    );
  }

  /// `2. broccoli`
  String get text_639b0589fe1a37c21666e939 {
    return Intl.message(
      '2. broccoli',
      name: 'text_639b0589fe1a37c21666e939',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639b0589fe1a37c21666e93b {
    return Intl.message(
      '8.',
      name: 'text_639b0589fe1a37c21666e93b',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639b0589fe1a37c21666e93d {
    return Intl.message(
      '8.',
      name: 'text_639b0589fe1a37c21666e93d',
      desc: '',
      args: [],
    );
  }

  /// `8. to`
  String get text_639b0589fe1a37c21666e93f {
    return Intl.message(
      '8. to',
      name: 'text_639b0589fe1a37c21666e93f',
      desc: '',
      args: [],
    );
  }

  /// `1. abandon`
  String get text_639b0589fe1a37c21666e941 {
    return Intl.message(
      '1. abandon',
      name: 'text_639b0589fe1a37c21666e941',
      desc: '',
      args: [],
    );
  }

  /// `14. bacon`
  String get text_639b0589fe1a37c21666e943 {
    return Intl.message(
      '14. bacon',
      name: 'text_639b0589fe1a37c21666e943',
      desc: '',
      args: [],
    );
  }

  /// `8.`
  String get text_639b0589fe1a37c21666e945 {
    return Intl.message(
      '8.',
      name: 'text_639b0589fe1a37c21666e945',
      desc: '',
      args: [],
    );
  }

  /// `20. bacon`
  String get text_639b0589fe1a37c21666e947 {
    return Intl.message(
      '20. bacon',
      name: 'text_639b0589fe1a37c21666e947',
      desc: '',
      args: [],
    );
  }

  /// `16.`
  String get text_639b0589fe1a37c21666e949 {
    return Intl.message(
      '16.',
      name: 'text_639b0589fe1a37c21666e949',
      desc: '',
      args: [],
    );
  }

  /// `21. bacon`
  String get text_639b0589fe1a37c21666e94b {
    return Intl.message(
      '21. bacon',
      name: 'text_639b0589fe1a37c21666e94b',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639b0589fe1a37c21666e94d {
    return Intl.message(
      '9.',
      name: 'text_639b0589fe1a37c21666e94d',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666e94f {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666e94f',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e951 {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e951',
      desc: '',
      args: [],
    );
  }

  /// `21.`
  String get text_639b0589fe1a37c21666e953 {
    return Intl.message(
      '21.',
      name: 'text_639b0589fe1a37c21666e953',
      desc: '',
      args: [],
    );
  }

  /// `15. bacon`
  String get text_639b0589fe1a37c21666e955 {
    return Intl.message(
      '15. bacon',
      name: 'text_639b0589fe1a37c21666e955',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e957 {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e957',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639b0589fe1a37c21666e959 {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639b0589fe1a37c21666e959',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639b0589fe1a37c21666e95b {
    return Intl.message(
      '8. toast',
      name: 'text_639b0589fe1a37c21666e95b',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e95d {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e95d',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e95f {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e95f',
      desc: '',
      args: [],
    );
  }

  /// `3. swe`
  String get text_639b0589fe1a37c21666e961 {
    return Intl.message(
      '3. swe',
      name: 'text_639b0589fe1a37c21666e961',
      desc: '',
      args: [],
    );
  }

  /// `7. pelican`
  String get text_639b0589fe1a37c21666e963 {
    return Intl.message(
      '7. pelican',
      name: 'text_639b0589fe1a37c21666e963',
      desc: '',
      args: [],
    );
  }

  /// `20. bacon`
  String get text_639b0589fe1a37c21666e965 {
    return Intl.message(
      '20. bacon',
      name: 'text_639b0589fe1a37c21666e965',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e967 {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e967',
      desc: '',
      args: [],
    );
  }

  /// `15. bacon`
  String get text_639b0589fe1a37c21666e969 {
    return Intl.message(
      '15. bacon',
      name: 'text_639b0589fe1a37c21666e969',
      desc: '',
      args: [],
    );
  }

  /// `22.`
  String get text_639b0589fe1a37c21666e96b {
    return Intl.message(
      '22.',
      name: 'text_639b0589fe1a37c21666e96b',
      desc: '',
      args: [],
    );
  }

  /// `16. bacon`
  String get text_639b0589fe1a37c21666e96d {
    return Intl.message(
      '16. bacon',
      name: 'text_639b0589fe1a37c21666e96d',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639b0589fe1a37c21666e96f {
    return Intl.message(
      '4.',
      name: 'text_639b0589fe1a37c21666e96f',
      desc: '',
      args: [],
    );
  }

  /// `16.`
  String get text_639b0589fe1a37c21666e971 {
    return Intl.message(
      '16.',
      name: 'text_639b0589fe1a37c21666e971',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e973 {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e973',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666e975 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666e975',
      desc: '',
      args: [],
    );
  }

  /// `21. bacon`
  String get text_639b0589fe1a37c21666e977 {
    return Intl.message(
      '21. bacon',
      name: 'text_639b0589fe1a37c21666e977',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639b0589fe1a37c21666e979 {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639b0589fe1a37c21666e979',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639b0589fe1a37c21666e97b {
    return Intl.message(
      '8. toast',
      name: 'text_639b0589fe1a37c21666e97b',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e97d {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e97d',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e97f {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e97f',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639b0589fe1a37c21666e981 {
    return Intl.message(
      '9.',
      name: 'text_639b0589fe1a37c21666e981',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639b0589fe1a37c21666e983 {
    return Intl.message(
      '9.',
      name: 'text_639b0589fe1a37c21666e983',
      desc: '',
      args: [],
    );
  }

  /// `9.`
  String get text_639b0589fe1a37c21666e985 {
    return Intl.message(
      '9.',
      name: 'text_639b0589fe1a37c21666e985',
      desc: '',
      args: [],
    );
  }

  /// `15. bacon`
  String get text_639b0589fe1a37c21666e987 {
    return Intl.message(
      '15. bacon',
      name: 'text_639b0589fe1a37c21666e987',
      desc: '',
      args: [],
    );
  }

  /// `2 broccoli.`
  String get text_639b0589fe1a37c21666e989 {
    return Intl.message(
      '2 broccoli.',
      name: 'text_639b0589fe1a37c21666e989',
      desc: '',
      args: [],
    );
  }

  /// `21. bacon`
  String get text_639b0589fe1a37c21666e98b {
    return Intl.message(
      '21. bacon',
      name: 'text_639b0589fe1a37c21666e98b',
      desc: '',
      args: [],
    );
  }

  /// `17.`
  String get text_639b0589fe1a37c21666e98d {
    return Intl.message(
      '17.',
      name: 'text_639b0589fe1a37c21666e98d',
      desc: '',
      args: [],
    );
  }

  /// `22. bacon`
  String get text_639b0589fe1a37c21666e98f {
    return Intl.message(
      '22. bacon',
      name: 'text_639b0589fe1a37c21666e98f',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639b0589fe1a37c21666e991 {
    return Intl.message(
      '10.',
      name: 'text_639b0589fe1a37c21666e991',
      desc: '',
      args: [],
    );
  }

  /// `22.`
  String get text_639b0589fe1a37c21666e993 {
    return Intl.message(
      '22.',
      name: 'text_639b0589fe1a37c21666e993',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666e995 {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666e995',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666e997 {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666e997',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e999 {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e999',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639b0589fe1a37c21666e99b {
    return Intl.message(
      '8. toast',
      name: 'text_639b0589fe1a37c21666e99b',
      desc: '',
      args: [],
    );
  }

  /// `16. bacon`
  String get text_639b0589fe1a37c21666e99d {
    return Intl.message(
      '16. bacon',
      name: 'text_639b0589fe1a37c21666e99d',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e99f {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e99f',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e9a1 {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e9a1',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639b0589fe1a37c21666e9a3 {
    return Intl.message(
      '4.',
      name: 'text_639b0589fe1a37c21666e9a3',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639b0589fe1a37c21666e9a5 {
    return Intl.message(
      '4.',
      name: 'text_639b0589fe1a37c21666e9a5',
      desc: '',
      args: [],
    );
  }

  /// `4.`
  String get text_639b0589fe1a37c21666e9a7 {
    return Intl.message(
      '4.',
      name: 'text_639b0589fe1a37c21666e9a7',
      desc: '',
      args: [],
    );
  }

  /// `21. bacon`
  String get text_639b0589fe1a37c21666e9a9 {
    return Intl.message(
      '21. bacon',
      name: 'text_639b0589fe1a37c21666e9a9',
      desc: '',
      args: [],
    );
  }

  /// `8. toast`
  String get text_639b0589fe1a37c21666e9ab {
    return Intl.message(
      '8. toast',
      name: 'text_639b0589fe1a37c21666e9ab',
      desc: '',
      args: [],
    );
  }

  /// `17. bacon`
  String get text_639b0589fe1a37c21666e9ad {
    return Intl.message(
      '17. bacon',
      name: 'text_639b0589fe1a37c21666e9ad',
      desc: '',
      args: [],
    );
  }

  /// `23.`
  String get text_639b0589fe1a37c21666e9af {
    return Intl.message(
      '23.',
      name: 'text_639b0589fe1a37c21666e9af',
      desc: '',
      args: [],
    );
  }

  /// `16. bacon`
  String get text_639b0589fe1a37c21666e9b1 {
    return Intl.message(
      '16. bacon',
      name: 'text_639b0589fe1a37c21666e9b1',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639b0589fe1a37c21666e9b3 {
    return Intl.message(
      '5.',
      name: 'text_639b0589fe1a37c21666e9b3',
      desc: '',
      args: [],
    );
  }

  /// `17.`
  String get text_639b0589fe1a37c21666e9b5 {
    return Intl.message(
      '17.',
      name: 'text_639b0589fe1a37c21666e9b5',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666e9b7 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666e9b7',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666e9b9 {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666e9b9',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e9bb {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e9bb',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e9bd {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e9bd',
      desc: '',
      args: [],
    );
  }

  /// `22. bacon`
  String get text_639b0589fe1a37c21666e9bf {
    return Intl.message(
      '22. bacon',
      name: 'text_639b0589fe1a37c21666e9bf',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639b0589fe1a37c21666e9c1 {
    return Intl.message(
      '10.',
      name: 'text_639b0589fe1a37c21666e9c1',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666e9c3 {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666e9c3',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e9c5 {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e9c5',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639b0589fe1a37c21666e9c7 {
    return Intl.message(
      '10.',
      name: 'text_639b0589fe1a37c21666e9c7',
      desc: '',
      args: [],
    );
  }

  /// `10.`
  String get text_639b0589fe1a37c21666e9c9 {
    return Intl.message(
      '10.',
      name: 'text_639b0589fe1a37c21666e9c9',
      desc: '',
      args: [],
    );
  }

  /// `16. bacon`
  String get text_639b0589fe1a37c21666e9cb {
    return Intl.message(
      '16. bacon',
      name: 'text_639b0589fe1a37c21666e9cb',
      desc: '',
      args: [],
    );
  }

  /// `3. sweet`
  String get text_639b0589fe1a37c21666e9cd {
    return Intl.message(
      '3. sweet',
      name: 'text_639b0589fe1a37c21666e9cd',
      desc: '',
      args: [],
    );
  }

  /// `23. bacon`
  String get text_639b0589fe1a37c21666e9cf {
    return Intl.message(
      '23. bacon',
      name: 'text_639b0589fe1a37c21666e9cf',
      desc: '',
      args: [],
    );
  }

  /// `22. bacon`
  String get text_639b0589fe1a37c21666e9d3 {
    return Intl.message(
      '22. bacon',
      name: 'text_639b0589fe1a37c21666e9d3',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666e9d5 {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666e9d5',
      desc: '',
      args: [],
    );
  }

  /// `23.`
  String get text_639b0589fe1a37c21666e9d7 {
    return Intl.message(
      '23.',
      name: 'text_639b0589fe1a37c21666e9d7',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639b0589fe1a37c21666e9d9 {
    return Intl.message(
      '11.',
      name: 'text_639b0589fe1a37c21666e9d9',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666e9db {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666e9db',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e9dd {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e9dd',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e9df {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e9df',
      desc: '',
      args: [],
    );
  }

  /// `17. bacon`
  String get text_639b0589fe1a37c21666e9e1 {
    return Intl.message(
      '17. bacon',
      name: 'text_639b0589fe1a37c21666e9e1',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639b0589fe1a37c21666e9e3 {
    return Intl.message(
      '5.',
      name: 'text_639b0589fe1a37c21666e9e3',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666e9e5 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666e9e5',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666e9e7 {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666e9e7',
      desc: '',
      args: [],
    );
  }

  /// `22. bacon`
  String get text_639b0589fe1a37c21666e9e9 {
    return Intl.message(
      '22. bacon',
      name: 'text_639b0589fe1a37c21666e9e9',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639b0589fe1a37c21666e9eb {
    return Intl.message(
      '5.',
      name: 'text_639b0589fe1a37c21666e9eb',
      desc: '',
      args: [],
    );
  }

  /// `5.`
  String get text_639b0589fe1a37c21666e9ed {
    return Intl.message(
      '5.',
      name: 'text_639b0589fe1a37c21666e9ed',
      desc: '',
      args: [],
    );
  }

  /// `9. castle`
  String get text_639b0589fe1a37c21666e9ef {
    return Intl.message(
      '9. castle',
      name: 'text_639b0589fe1a37c21666e9ef',
      desc: '',
      args: [],
    );
  }

  /// `18. bacon`
  String get text_639b0589fe1a37c21666e9f1 {
    return Intl.message(
      '18. bacon',
      name: 'text_639b0589fe1a37c21666e9f1',
      desc: '',
      args: [],
    );
  }

  /// `17. bacon`
  String get text_639b0589fe1a37c21666e9f5 {
    return Intl.message(
      '17. bacon',
      name: 'text_639b0589fe1a37c21666e9f5',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666e9f7 {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666e9f7',
      desc: '',
      args: [],
    );
  }

  /// `18.`
  String get text_639b0589fe1a37c21666e9f9 {
    return Intl.message(
      '18.',
      name: 'text_639b0589fe1a37c21666e9f9',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639b0589fe1a37c21666e9fb {
    return Intl.message(
      '6.',
      name: 'text_639b0589fe1a37c21666e9fb',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666e9fd {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666e9fd',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666e9ff {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666e9ff',
      desc: '',
      args: [],
    );
  }

  /// `23. bacon`
  String get text_639b0589fe1a37c21666ea02 {
    return Intl.message(
      '23. bacon',
      name: 'text_639b0589fe1a37c21666ea02',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639b0589fe1a37c21666ea04 {
    return Intl.message(
      '11.',
      name: 'text_639b0589fe1a37c21666ea04',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666ea06 {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666ea06',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666ea08 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666ea08',
      desc: '',
      args: [],
    );
  }

  /// `17. bacon`
  String get text_639b0589fe1a37c21666ea0a {
    return Intl.message(
      '17. bacon',
      name: 'text_639b0589fe1a37c21666ea0a',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639b0589fe1a37c21666ea0c {
    return Intl.message(
      '11.',
      name: 'text_639b0589fe1a37c21666ea0c',
      desc: '',
      args: [],
    );
  }

  /// `11.`
  String get text_639b0589fe1a37c21666ea0e {
    return Intl.message(
      '11.',
      name: 'text_639b0589fe1a37c21666ea0e',
      desc: '',
      args: [],
    );
  }

  /// `24. bacon`
  String get text_639b0589fe1a37c21666ea12 {
    return Intl.message(
      '24. bacon',
      name: 'text_639b0589fe1a37c21666ea12',
      desc: '',
      args: [],
    );
  }

  /// `4. original`
  String get text_639b0589fe1a37c21666ea14 {
    return Intl.message(
      '4. original',
      name: 'text_639b0589fe1a37c21666ea14',
      desc: '',
      args: [],
    );
  }

  /// `23. bacon`
  String get text_639b0589fe1a37c21666ea16 {
    return Intl.message(
      '23. bacon',
      name: 'text_639b0589fe1a37c21666ea16',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea18 {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea18',
      desc: '',
      args: [],
    );
  }

  /// `24.`
  String get text_639b0589fe1a37c21666ea1a {
    return Intl.message(
      '24.',
      name: 'text_639b0589fe1a37c21666ea1a',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639b0589fe1a37c21666ea1c {
    return Intl.message(
      '12.',
      name: 'text_639b0589fe1a37c21666ea1c',
      desc: '',
      args: [],
    );
  }

  /// `10. glow`
  String get text_639b0589fe1a37c21666ea1d {
    return Intl.message(
      '10. glow',
      name: 'text_639b0589fe1a37c21666ea1d',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666ea1f {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666ea1f',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666ea21 {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666ea21',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666ea23 {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666ea23',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639b0589fe1a37c21666ea25 {
    return Intl.message(
      '6.',
      name: 'text_639b0589fe1a37c21666ea25',
      desc: '',
      args: [],
    );
  }

  /// `18. bacon`
  String get text_639b0589fe1a37c21666ea27 {
    return Intl.message(
      '18. bacon',
      name: 'text_639b0589fe1a37c21666ea27',
      desc: '',
      args: [],
    );
  }

  /// `23. bacon`
  String get text_639b0589fe1a37c21666ea29 {
    return Intl.message(
      '23. bacon',
      name: 'text_639b0589fe1a37c21666ea29',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639b0589fe1a37c21666ea2b {
    return Intl.message(
      '6.',
      name: 'text_639b0589fe1a37c21666ea2b',
      desc: '',
      args: [],
    );
  }

  /// `6.`
  String get text_639b0589fe1a37c21666ea2d {
    return Intl.message(
      '6.',
      name: 'text_639b0589fe1a37c21666ea2d',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666ea33 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666ea33',
      desc: '',
      args: [],
    );
  }

  /// `5. foster`
  String get text_639b0589fe1a37c21666ea35 {
    return Intl.message(
      '5. foster',
      name: 'text_639b0589fe1a37c21666ea35',
      desc: '',
      args: [],
    );
  }

  /// `18. bacon`
  String get text_639b0589fe1a37c21666ea39 {
    return Intl.message(
      '18. bacon',
      name: 'text_639b0589fe1a37c21666ea39',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666ea3b {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666ea3b',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666ea3d {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666ea3d',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea3f {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea3f',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639b0589fe1a37c21666ea41 {
    return Intl.message(
      '12.',
      name: 'text_639b0589fe1a37c21666ea41',
      desc: '',
      args: [],
    );
  }

  /// `24. bacon`
  String get text_639b0589fe1a37c21666ea43 {
    return Intl.message(
      '24. bacon',
      name: 'text_639b0589fe1a37c21666ea43',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639b0589fe1a37c21666ea48 {
    return Intl.message(
      '12.',
      name: 'text_639b0589fe1a37c21666ea48',
      desc: '',
      args: [],
    );
  }

  /// `12.`
  String get text_639b0589fe1a37c21666ea4a {
    return Intl.message(
      '12.',
      name: 'text_639b0589fe1a37c21666ea4a',
      desc: '',
      args: [],
    );
  }

  /// `18. bacon`
  String get text_639b0589fe1a37c21666ea4c {
    return Intl.message(
      '18. bacon',
      name: 'text_639b0589fe1a37c21666ea4c',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666ea4e {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666ea4e',
      desc: '',
      args: [],
    );
  }

  /// `11. piano`
  String get text_639b0589fe1a37c21666ea50 {
    return Intl.message(
      '11. piano',
      name: 'text_639b0589fe1a37c21666ea50',
      desc: '',
      args: [],
    );
  }

  /// `24. bacon`
  String get text_639b0589fe1a37c21666ea52 {
    return Intl.message(
      '24. bacon',
      name: 'text_639b0589fe1a37c21666ea52',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea5d {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea5d',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666ea5f {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666ea5f',
      desc: '',
      args: [],
    );
  }

  /// `24. bacon`
  String get text_639b0589fe1a37c21666ea63 {
    return Intl.message(
      '24. bacon',
      name: 'text_639b0589fe1a37c21666ea63',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666ea6e {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666ea6e',
      desc: '',
      args: [],
    );
  }

  /// `6. tank`
  String get text_639b0589fe1a37c21666ea70 {
    return Intl.message(
      '6. tank',
      name: 'text_639b0589fe1a37c21666ea70',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea72 {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea72',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea74 {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea74',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639b0589fe1a37c21666ea7d {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639b0589fe1a37c21666ea7d',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639b0589fe1a37c21666ea88 {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639b0589fe1a37c21666ea88',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639b0589fe1a37c21666ea8a {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639b0589fe1a37c21666ea8a',
      desc: '',
      args: [],
    );
  }

  /// `12. catch`
  String get text_639b0589fe1a37c21666ea8c {
    return Intl.message(
      '12. catch',
      name: 'text_639b0589fe1a37c21666ea8c',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639b0589fe1a37c21666ea8e {
    return Intl.message(
      'Done',
      name: 'text_639b0589fe1a37c21666ea8e',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639b0589fe1a37c21666ea95 {
    return Intl.message(
      'Done',
      name: 'text_639b0589fe1a37c21666ea95',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639b0589fe1a37c21666eaa0 {
    return Intl.message(
      'Done',
      name: 'text_639b0589fe1a37c21666eaa0',
      desc: '',
      args: [],
    );
  }

  /// `My seed has a passphrase`
  String get text_639b0589fe1a37c21666eaa1 {
    return Intl.message(
      'My seed has a passphrase',
      name: 'text_639b0589fe1a37c21666eaa1',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get text_639b0589fe1a37c21666eaad {
    return Intl.message(
      'Done',
      name: 'text_639b0589fe1a37c21666eaad',
      desc: '',
      args: [],
    );
  }

  /// `18.`
  String get text_639b0589fe1a37c21666eb8e {
    return Intl.message(
      '18.',
      name: 'text_639b0589fe1a37c21666eb8e',
      desc: '',
      args: [],
    );
  }

  /// `24.`
  String get text_639b0589fe1a37c21666eb96 {
    return Intl.message(
      '24.',
      name: 'text_639b0589fe1a37c21666eb96',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_639b1606dab75c7f53a911a8 {
    return Intl.message(
      '1',
      name: 'text_639b1606dab75c7f53a911a8',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_639b1606dab75c7f53a911ae {
    return Intl.message(
      '1',
      name: 'text_639b1606dab75c7f53a911ae',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_639b1606dab75c7f53a911b2 {
    return Intl.message(
      '1',
      name: 'text_639b1606dab75c7f53a911b2',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_639b1606dab75c7f53a911b4 {
    return Intl.message(
      '1',
      name: 'text_639b1606dab75c7f53a911b4',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_639b1606dab75c7f53a911b8 {
    return Intl.message(
      '2',
      name: 'text_639b1606dab75c7f53a911b8',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_639b1606dab75c7f53a911be {
    return Intl.message(
      '2',
      name: 'text_639b1606dab75c7f53a911be',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_639b1606dab75c7f53a911c2 {
    return Intl.message(
      '2',
      name: 'text_639b1606dab75c7f53a911c2',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_639b1606dab75c7f53a911c4 {
    return Intl.message(
      '2',
      name: 'text_639b1606dab75c7f53a911c4',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_639b1606dab75c7f53a911c8 {
    return Intl.message(
      '3',
      name: 'text_639b1606dab75c7f53a911c8',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_639b1606dab75c7f53a911ce {
    return Intl.message(
      '3',
      name: 'text_639b1606dab75c7f53a911ce',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_639b1606dab75c7f53a911d1 {
    return Intl.message(
      '3',
      name: 'text_639b1606dab75c7f53a911d1',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_639b1606dab75c7f53a911d3 {
    return Intl.message(
      '3',
      name: 'text_639b1606dab75c7f53a911d3',
      desc: '',
      args: [],
    );
  }

  /// `Store Your Encrypted Backup`
  String get text_639b189339d43a7643a01f7b {
    return Intl.message(
      'Store Your Encrypted Backup',
      name: 'text_639b189339d43a7643a01f7b',
      desc: '',
      args: [],
    );
  }

  /// `Envoy has generated your encrypted backup. This backup contains useful wallet data such as labels, accounts, and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.`
  String get text_639b189339d43a7643a01f81 {
    return Intl.message(
      'Envoy has generated your encrypted backup. This backup contains useful wallet data such as labels, accounts, and settings.\n\nYou can choose to secure it on the cloud, another device, or an external storage option like a microSD card.',
      name: 'text_639b189339d43a7643a01f81',
      desc: '',
      args: [],
    );
  }

  /// `Store Your Encrypted Backup`
  String get text_639b189339d43a7643a01f84 {
    return Intl.message(
      'Store Your Encrypted Backup',
      name: 'text_639b189339d43a7643a01f84',
      desc: '',
      args: [],
    );
  }

  /// `Choose destination`
  String get text_639b189339d43a7643a01f86 {
    return Intl.message(
      'Choose destination',
      name: 'text_639b189339d43a7643a01f86',
      desc: '',
      args: [],
    );
  }

  /// `Envoy has generated your encrypted seed backup. You can choose to secure it on cloud, on a device, or on a micro SD.`
  String get text_639b189339d43a7643a01f87 {
    return Intl.message(
      'Envoy has generated your encrypted seed backup. You can choose to secure it on cloud, on a device, or on a micro SD.',
      name: 'text_639b189339d43a7643a01f87',
      desc: '',
      args: [],
    );
  }

  /// `Choose destination`
  String get text_639b189339d43a7643a01f89 {
    return Intl.message(
      'Choose destination',
      name: 'text_639b189339d43a7643a01f89',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_639b19e631a859f38996807d {
    return Intl.message(
      '1',
      name: 'text_639b19e631a859f38996807d',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get text_639b19e631a859f389968081 {
    return Intl.message(
      'Devices',
      name: 'text_639b19e631a859f389968081',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_639b19e631a859f389968088 {
    return Intl.message(
      '2',
      name: 'text_639b19e631a859f389968088',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_639b19e631a859f389968090 {
    return Intl.message(
      '3',
      name: 'text_639b19e631a859f389968090',
      desc: '',
      args: [],
    );
  }

  /// `Update Firmware`
  String get text_63ea44c3d7462fb1215fd9f8 {
    return Intl.message(
      'Update Firmware',
      name: 'text_63ea44c3d7462fb1215fd9f8',
      desc: '',
      args: [],
    );
  }

  /// `No MicroSD`
  String get text_63ea44c3d7462fb1215fd9fd {
    return Intl.message(
      'No MicroSD',
      name: 'text_63ea44c3d7462fb1215fd9fd',
      desc: '',
      args: [],
    );
  }

  /// `Please insert a\nmicroSD card`
  String get text_63ea44c3d7462fb1215fda03 {
    return Intl.message(
      'Please insert a\nmicroSD card',
      name: 'text_63ea44c3d7462fb1215fda03',
      desc: '',
      args: [],
    );
  }

  /// `Security Check`
  String get text_63ea7dda4becab0635a97e63 {
    return Intl.message(
      'Security Check',
      name: 'text_63ea7dda4becab0635a97e63',
      desc: '',
      args: [],
    );
  }

  /// `Scan with Envoy`
  String get text_63ea7dda4becab0635a97e64 {
    return Intl.message(
      'Scan with Envoy',
      name: 'text_63ea7dda4becab0635a97e64',
      desc: '',
      args: [],
    );
  }

  /// `Create Seed`
  String get text_63eb47cef06e51c88ad46df3 {
    return Intl.message(
      'Create Seed',
      name: 'text_63eb47cef06e51c88ad46df3',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get text_63eb47cef06e51c88ad46df4 {
    return Intl.message(
      'Restore Seed',
      name: 'text_63eb47cef06e51c88ad46df4',
      desc: '',
      args: [],
    );
  }

  /// `Create Seed`
  String get text_63eb47cef06e51c88ad46df5 {
    return Intl.message(
      'Create Seed',
      name: 'text_63eb47cef06e51c88ad46df5',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get text_63eb47cef06e51c88ad46df6 {
    return Intl.message(
      'Restore Backup',
      name: 'text_63eb47cef06e51c88ad46df6',
      desc: '',
      args: [],
    );
  }

  /// `Enter word 1 of 24`
  String get text_63eb47cef06e51c88ad46df7 {
    return Intl.message(
      'Enter word 1 of 24',
      name: 'text_63eb47cef06e51c88ad46df7',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get text_63eb47cef06e51c88ad46df8 {
    return Intl.message(
      'Restore Backup',
      name: 'text_63eb47cef06e51c88ad46df8',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get text_63eb47cef06e51c88ad46df9 {
    return Intl.message(
      'Restore Seed',
      name: 'text_63eb47cef06e51c88ad46df9',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46dfa {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46dfa',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get text_63eb47cef06e51c88ad46dfb {
    return Intl.message(
      'Create New Seed',
      name: 'text_63eb47cef06e51c88ad46dfb',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get text_63eb47cef06e51c88ad46dfc {
    return Intl.message(
      'Restore Seed',
      name: 'text_63eb47cef06e51c88ad46dfc',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get text_63eb47cef06e51c88ad46dff {
    return Intl.message(
      'Create New Seed',
      name: 'text_63eb47cef06e51c88ad46dff',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e01 {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e01',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get text_63eb47cef06e51c88ad46e04 {
    return Intl.message(
      'Backup',
      name: 'text_63eb47cef06e51c88ad46e04',
      desc: '',
      args: [],
    );
  }

  /// `Backup Code`
  String get text_63eb47cef06e51c88ad46e06 {
    return Intl.message(
      'Backup Code',
      name: 'text_63eb47cef06e51c88ad46e06',
      desc: '',
      args: [],
    );
  }

  /// `ski`
  String get text_63eb47cef06e51c88ad46e09 {
    return Intl.message(
      'ski',
      name: 'text_63eb47cef06e51c88ad46e09',
      desc: '',
      args: [],
    );
  }

  /// `slab`
  String get text_63eb47cef06e51c88ad46e0b {
    return Intl.message(
      'slab',
      name: 'text_63eb47cef06e51c88ad46e0b',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_63eb47cef06e51c88ad46e0e {
    return Intl.message(
      '1',
      name: 'text_63eb47cef06e51c88ad46e0e',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get text_63eb47cef06e51c88ad46e10 {
    return Intl.message(
      'Restore Backup',
      name: 'text_63eb47cef06e51c88ad46e10',
      desc: '',
      args: [],
    );
  }

  /// `Create encrypted backup?`
  String get text_63eb47cef06e51c88ad46e11 {
    return Intl.message(
      'Create encrypted backup?',
      name: 'text_63eb47cef06e51c88ad46e11',
      desc: '',
      args: [],
    );
  }

  /// `Create Seed`
  String get text_63eb47cef06e51c88ad46e14 {
    return Intl.message(
      'Create Seed',
      name: 'text_63eb47cef06e51c88ad46e14',
      desc: '',
      args: [],
    );
  }

  /// `How Would you like to Set Up your Passport?`
  String get text_63eb47cef06e51c88ad46e15 {
    return Intl.message(
      'How Would you like to Set Up your Passport?',
      name: 'text_63eb47cef06e51c88ad46e15',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get text_63eb47cef06e51c88ad46e16 {
    return Intl.message(
      'Backup',
      name: 'text_63eb47cef06e51c88ad46e16',
      desc: '',
      args: [],
    );
  }

  /// `This is an optional but step to backup your wallet seed. Head to settings > Backup > Create Backup. `
  String get text_63eb47cef06e51c88ad46e17 {
    return Intl.message(
      'This is an optional but step to backup your wallet seed. Head to settings > Backup > Create Backup. ',
      name: 'text_63eb47cef06e51c88ad46e17',
      desc: '',
      args: [],
    );
  }

  /// `Enter word 1 of 6`
  String get text_63eb47cef06e51c88ad46e18 {
    return Intl.message(
      'Enter word 1 of 6',
      name: 'text_63eb47cef06e51c88ad46e18',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_63eb47cef06e51c88ad46e1a {
    return Intl.message(
      '2',
      name: 'text_63eb47cef06e51c88ad46e1a',
      desc: '',
      args: [],
    );
  }

  /// `slam`
  String get text_63eb47cef06e51c88ad46e1b {
    return Intl.message(
      'slam',
      name: 'text_63eb47cef06e51c88ad46e1b',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_63eb47cef06e51c88ad46e1e {
    return Intl.message(
      '3',
      name: 'text_63eb47cef06e51c88ad46e1e',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46e20 {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46e20',
      desc: '',
      args: [],
    );
  }

  /// `Backup Code`
  String get text_63eb47cef06e51c88ad46e22 {
    return Intl.message(
      'Backup Code',
      name: 'text_63eb47cef06e51c88ad46e22',
      desc: '',
      args: [],
    );
  }

  /// `As a new owner of a Passport you can create a new seed. You can also restore a wallet using seed words, or restore a backup from an existing Passport.`
  String get text_63eb47cef06e51c88ad46e23 {
    return Intl.message(
      'As a new owner of a Passport you can create a new seed. You can also restore a wallet using seed words, or restore a backup from an existing Passport.',
      name: 'text_63eb47cef06e51c88ad46e23',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get text_63eb47cef06e51c88ad46e24 {
    return Intl.message(
      'Restore Backup',
      name: 'text_63eb47cef06e51c88ad46e24',
      desc: '',
      args: [],
    );
  }

  /// `Restore Backup`
  String get text_63eb47cef06e51c88ad46e27 {
    return Intl.message(
      'Restore Backup',
      name: 'text_63eb47cef06e51c88ad46e27',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_63eb47cef06e51c88ad46e28 {
    return Intl.message(
      '1',
      name: 'text_63eb47cef06e51c88ad46e28',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e29 {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e29',
      desc: '',
      args: [],
    );
  }

  /// `4`
  String get text_63eb47cef06e51c88ad46e2b {
    return Intl.message(
      '4',
      name: 'text_63eb47cef06e51c88ad46e2b',
      desc: '',
      args: [],
    );
  }

  /// `play`
  String get text_63eb47cef06e51c88ad46e2d {
    return Intl.message(
      'play',
      name: 'text_63eb47cef06e51c88ad46e2d',
      desc: '',
      args: [],
    );
  }

  /// `play`
  String get text_63eb47cef06e51c88ad46e2e {
    return Intl.message(
      'play',
      name: 'text_63eb47cef06e51c88ad46e2e',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_63eb47cef06e51c88ad46e2f {
    return Intl.message(
      '2',
      name: 'text_63eb47cef06e51c88ad46e2f',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get text_63eb47cef06e51c88ad46e30 {
    return Intl.message(
      'Restore Seed',
      name: 'text_63eb47cef06e51c88ad46e30',
      desc: '',
      args: [],
    );
  }

  /// `Restore Seed`
  String get text_63eb47cef06e51c88ad46e31 {
    return Intl.message(
      'Restore Seed',
      name: 'text_63eb47cef06e51c88ad46e31',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_63eb47cef06e51c88ad46e33 {
    return Intl.message(
      '3',
      name: 'text_63eb47cef06e51c88ad46e33',
      desc: '',
      args: [],
    );
  }

  /// `skew`
  String get text_63eb47cef06e51c88ad46e34 {
    return Intl.message(
      'skew',
      name: 'text_63eb47cef06e51c88ad46e34',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e35 {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e35',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Seed Words`
  String get text_63eb47cef06e51c88ad46e36 {
    return Intl.message(
      'Enter your Seed Words',
      name: 'text_63eb47cef06e51c88ad46e36',
      desc: '',
      args: [],
    );
  }

  /// `slot`
  String get text_63eb47cef06e51c88ad46e37 {
    return Intl.message(
      'slot',
      name: 'text_63eb47cef06e51c88ad46e37',
      desc: '',
      args: [],
    );
  }

  /// `4`
  String get text_63eb47cef06e51c88ad46e38 {
    return Intl.message(
      '4',
      name: 'text_63eb47cef06e51c88ad46e38',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get text_63eb47cef06e51c88ad46e39 {
    return Intl.message(
      'Create New Seed',
      name: 'text_63eb47cef06e51c88ad46e39',
      desc: '',
      args: [],
    );
  }

  /// `Create New Seed`
  String get text_63eb47cef06e51c88ad46e3a {
    return Intl.message(
      'Create New Seed',
      name: 'text_63eb47cef06e51c88ad46e3a',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e3b {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e3b',
      desc: '',
      args: [],
    );
  }

  /// `plus`
  String get text_63eb47cef06e51c88ad46e3c {
    return Intl.message(
      'plus',
      name: 'text_63eb47cef06e51c88ad46e3c',
      desc: '',
      args: [],
    );
  }

  /// `6`
  String get text_63eb47cef06e51c88ad46e3d {
    return Intl.message(
      '6',
      name: 'text_63eb47cef06e51c88ad46e3d',
      desc: '',
      args: [],
    );
  }

  /// `Passport uses predictive text entry to make seed word entry much faster.\n\nFor instance, to enter the word ‘car’, simply type 2-2-7. Passport will display all words associated with that key combination.`
  String get text_63eb47cef06e51c88ad46e3e {
    return Intl.message(
      'Passport uses predictive text entry to make seed word entry much faster.\n\nFor instance, to enter the word ‘car’, simply type 2-2-7. Passport will display all words associated with that key combination.',
      name: 'text_63eb47cef06e51c88ad46e3e',
      desc: '',
      args: [],
    );
  }

  /// `6`
  String get text_63eb47cef06e51c88ad46e40 {
    return Intl.message(
      '6',
      name: 'text_63eb47cef06e51c88ad46e40',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46e43 {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46e43',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46e45 {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46e45',
      desc: '',
      args: [],
    );
  }

  /// `8`
  String get text_63eb47cef06e51c88ad46e48 {
    return Intl.message(
      '8',
      name: 'text_63eb47cef06e51c88ad46e48',
      desc: '',
      args: [],
    );
  }

  /// `8`
  String get text_63eb47cef06e51c88ad46e49 {
    return Intl.message(
      '8',
      name: 'text_63eb47cef06e51c88ad46e49',
      desc: '',
      args: [],
    );
  }

  /// `9`
  String get text_63eb47cef06e51c88ad46e4b {
    return Intl.message(
      '9',
      name: 'text_63eb47cef06e51c88ad46e4b',
      desc: '',
      args: [],
    );
  }

  /// `9`
  String get text_63eb47cef06e51c88ad46e4c {
    return Intl.message(
      '9',
      name: 'text_63eb47cef06e51c88ad46e4c',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get text_63eb47cef06e51c88ad46e4d {
    return Intl.message(
      '0',
      name: 'text_63eb47cef06e51c88ad46e4d',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get text_63eb47cef06e51c88ad46e4e {
    return Intl.message(
      '0',
      name: 'text_63eb47cef06e51c88ad46e4e',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_63eb47cef06e51c88ad46e4f {
    return Intl.message(
      '1',
      name: 'text_63eb47cef06e51c88ad46e4f',
      desc: '',
      args: [],
    );
  }

  /// `1`
  String get text_63eb47cef06e51c88ad46e50 {
    return Intl.message(
      '1',
      name: 'text_63eb47cef06e51c88ad46e50',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_63eb47cef06e51c88ad46e51 {
    return Intl.message(
      '2',
      name: 'text_63eb47cef06e51c88ad46e51',
      desc: '',
      args: [],
    );
  }

  /// `2`
  String get text_63eb47cef06e51c88ad46e52 {
    return Intl.message(
      '2',
      name: 'text_63eb47cef06e51c88ad46e52',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_63eb47cef06e51c88ad46e53 {
    return Intl.message(
      '3',
      name: 'text_63eb47cef06e51c88ad46e53',
      desc: '',
      args: [],
    );
  }

  /// `3`
  String get text_63eb47cef06e51c88ad46e54 {
    return Intl.message(
      '3',
      name: 'text_63eb47cef06e51c88ad46e54',
      desc: '',
      args: [],
    );
  }

  /// `4`
  String get text_63eb47cef06e51c88ad46e55 {
    return Intl.message(
      '4',
      name: 'text_63eb47cef06e51c88ad46e55',
      desc: '',
      args: [],
    );
  }

  /// `4`
  String get text_63eb47cef06e51c88ad46e56 {
    return Intl.message(
      '4',
      name: 'text_63eb47cef06e51c88ad46e56',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e57 {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e57',
      desc: '',
      args: [],
    );
  }

  /// `5`
  String get text_63eb47cef06e51c88ad46e58 {
    return Intl.message(
      '5',
      name: 'text_63eb47cef06e51c88ad46e58',
      desc: '',
      args: [],
    );
  }

  /// `6`
  String get text_63eb47cef06e51c88ad46e59 {
    return Intl.message(
      '6',
      name: 'text_63eb47cef06e51c88ad46e59',
      desc: '',
      args: [],
    );
  }

  /// `6`
  String get text_63eb47cef06e51c88ad46e5a {
    return Intl.message(
      '6',
      name: 'text_63eb47cef06e51c88ad46e5a',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46e5b {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46e5b',
      desc: '',
      args: [],
    );
  }

  /// `7`
  String get text_63eb47cef06e51c88ad46e5c {
    return Intl.message(
      '7',
      name: 'text_63eb47cef06e51c88ad46e5c',
      desc: '',
      args: [],
    );
  }

  /// `8`
  String get text_63eb47cef06e51c88ad46e5d {
    return Intl.message(
      '8',
      name: 'text_63eb47cef06e51c88ad46e5d',
      desc: '',
      args: [],
    );
  }

  /// `8`
  String get text_63eb47cef06e51c88ad46e5e {
    return Intl.message(
      '8',
      name: 'text_63eb47cef06e51c88ad46e5e',
      desc: '',
      args: [],
    );
  }

  /// `9`
  String get text_63eb47cef06e51c88ad46e5f {
    return Intl.message(
      '9',
      name: 'text_63eb47cef06e51c88ad46e5f',
      desc: '',
      args: [],
    );
  }

  /// `9`
  String get text_63eb47cef06e51c88ad46e60 {
    return Intl.message(
      '9',
      name: 'text_63eb47cef06e51c88ad46e60',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get text_63eb47cef06e51c88ad46e61 {
    return Intl.message(
      '0',
      name: 'text_63eb47cef06e51c88ad46e61',
      desc: '',
      args: [],
    );
  }

  /// `0`
  String get text_63eb47cef06e51c88ad46e62 {
    return Intl.message(
      '0',
      name: 'text_63eb47cef06e51c88ad46e62',
      desc: '',
      args: [],
    );
  }

  /// `Write down the Backup Code your Passport generates`
  String get text_63eb47cef06e51c88ad46e64 {
    return Intl.message(
      'Write down the Backup Code your Passport generates',
      name: 'text_63eb47cef06e51c88ad46e64',
      desc: '',
      args: [],
    );
  }

  /// `The 20 digit code displayed on your passport is REQUIRED to decrypt the backup.\n\nUse the included security card to write down the backup code and store it in a secure location.`
  String get text_63eb47cef06e51c88ad46e66 {
    return Intl.message(
      'The 20 digit code displayed on your passport is REQUIRED to decrypt the backup.\n\nUse the included security card to write down the backup code and store it in a secure location.',
      name: 'text_63eb47cef06e51c88ad46e66',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get text_63eb53d531b6213e846c1d8b {
    return Intl.message(
      'Continue',
      name: 'text_63eb53d531b6213e846c1d8b',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get text_63eb53d531b6213e846c1d8d {
    return Intl.message(
      'Continue',
      name: 'text_63eb53d531b6213e846c1d8d',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get text_63eb53d531b6213e846c1d8f {
    return Intl.message(
      'Continue',
      name: 'text_63eb53d531b6213e846c1d8f',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get text_63eb5ba0b6fe43bcae1c747b {
    return Intl.message(
      'Connect',
      name: 'text_63eb5ba0b6fe43bcae1c747b',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get wallet_is_setup_CTA {
    return Intl.message(
      'Continue',
      name: 'wallet_is_setup_CTA',
      desc: '',
      args: [],
    );
  }

  /// `Your Wallet Is Ready`
  String get wallet_is_setup_heading {
    return Intl.message(
      'Your Wallet Is Ready',
      name: 'wallet_is_setup_heading',
      desc: '',
      args: [],
    );
  }

  /// `Envoy Wallet is set up and ready for your Bitcoin!`
  String get wallet_is_setup_subheading {
    return Intl.message(
      'Envoy Wallet is set up and ready for your Bitcoin!',
      name: 'wallet_is_setup_subheading',
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
