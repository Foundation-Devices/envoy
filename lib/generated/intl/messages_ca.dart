// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ca locale. All the
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
  String get localeName => 'ca';

  static String m0(MB_name) => "Passport Prime Magic Backup\n”${MB_name}”";

  static String m1(period) =>
      "Aquest val va caducar el dia {període} . Si us plau, poseu-vos en contacte amb l\'emissor amb qualsevol pregunta relacionada amb el val.";

  static String m2(AccountName) =>
      "Ves a ${AccountName} del Passport, selecciona ‘Account Tools’ > ‘Verify Address’ i escaneja el codi QR.";

  static String m3(number) => "Fee is ${number}% of total amount";

  static String m4(tagName) =>
      "La teva etiqueta ${tagName} està buida. Vols eliminar-la?";

  static String m5(number) => "ADDRESS #${number}";

  static String m6(time_remaining) => "${time_remaining} remaining";

  static String m7(current_keyOS_version) =>
      "Your Passport Prime is currently running ${current_keyOS_version}.\n\nUpdate now for the latest bug fixes and features.";

  static String m8(est_upd_time) => "Estimated Update Time: ${est_upd_time}";

  static String m9(new_keyOS_version) => "What’s New in ${new_keyOS_version}";

  static String m10(new_keyOS_version) =>
      "Passport Prime was successfully \nupdated to ${new_keyOS_version}";

  static String m11(amount, total_amount) =>
      "Re-syncing your accounts.\nPlease do not close Envoy.\n\n${amount} of ${total_amount} synced";

  static String m12(passport_color) => "Color: ${passport_color}";

  static String m13(firmware_version) => "Firmware: ${firmware_version}";

  static String m14(serial_number) => "Serial Number: ${serial_number}";

  static String m15(AccountName) =>
      "Navigate to ${AccountName} on Passport, choose ‘Account Tools’ then ‘Verify Address’ and scan the QR code below.";

  static String m16(AccountName) =>
      "Tap the Account ${AccountName} on Passport, choose ‘Verify Address’ and scan the QR code below.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage("6:15"),
        "about_appVersion":
            MessageLookupByLibrary.simpleMessage("Versió de l\'aplicació"),
        "about_openSourceLicences":
            MessageLookupByLibrary.simpleMessage("Llicències de Codi Obert"),
        "about_privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacitat"),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostra"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Condicions d\'Ús"),
        "accountDetails_descriptor_legacy":
            MessageLookupByLibrary.simpleMessage("Legacy"),
        "accountDetails_descriptor_segwit":
            MessageLookupByLibrary.simpleMessage("Segwit"),
        "accountDetails_descriptor_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "accountDetails_descriptor_wrappedSegwit":
            MessageLookupByLibrary.simpleMessage("Wrapped Segwit"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage("Ordena per"),
        "account_details_untagged_card":
            MessageLookupByLibrary.simpleMessage("Sense etiquetar"),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
                "Els filtres aplicats amaguen totes les transaccions.\nActualitzeu o reinicieu els filtres per veure les transaccions."),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "No hi ha transaccions en aquest compte.\nRep la teva primera transacció a continuació."),
        "account_type_label_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "account_type_sublabel_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Creeu una cartera mòbil amb Còpia de Seguretat Màgica."),
        "accounts_empty_text_learn_more":
            MessageLookupByLibrary.simpleMessage("Comença"),
        "accounts_forceUpdate_cta":
            MessageLookupByLibrary.simpleMessage("Actualitza Envoy"),
        "accounts_forceUpdate_heading": MessageLookupByLibrary.simpleMessage(
            "Es requereix l\'actualització d\'Envoy"),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
            "Hi ha disponible una nova actualització d\'Envoy que conté actualitzacions i correccions importants. \n\nPer continuar utilitzant Envoy, actualitzeu-lo a la versió més recent. Gràcies."),
        "accounts_loading_loadingAccount":
            MessageLookupByLibrary.simpleMessage("Loading Account…"),
        "accounts_screen_walletType_Envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "accounts_screen_walletType_Passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "accounts_screen_walletType_defaultName":
            MessageLookupByLibrary.simpleMessage("Cartera Mòbil"),
        "accounts_switchDefault":
            MessageLookupByLibrary.simpleMessage("Default"),
        "accounts_switchPassphrase":
            MessageLookupByLibrary.simpleMessage("Passphrase"),
        "accounts_toastNewUpdate_content": MessageLookupByLibrary.simpleMessage(
            "New Update - See what’s new."),
        "accounts_upgradeBdkSignetModal_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy now uses Global Signet instead of Mutinynet. Your previous Signet accounts have been removed. \n\nTo begin using Global Signet, go Settings and enable the Signet toggle."),
        "accounts_upgradeBdkSignetModal_header":
            MessageLookupByLibrary.simpleMessage("Global Signet"),
        "accounts_upgradeBdkTestnetModal_content":
            MessageLookupByLibrary.simpleMessage(
                "‘Testnet3’ has been deprecated and Envoy now uses ‘testnet4’. Your previous testnet3 accounts have been removed. \n\nTo begin using testnet4, go Settings and enable the Testnet toggle."),
        "accounts_upgradeBdkTestnetModal_header":
            MessageLookupByLibrary.simpleMessage("Introducing testnet4"),
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Aumentat"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("Cancel·lant…"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
            "No hi ha cap activitat per mostrar."),
        "activity_envoyUpdate": MessageLookupByLibrary.simpleMessage(
            "S\'ha actualitzat l\'Aplicació Envoy"),
        "activity_envoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Actualització d\'Envoy disponible"),
        "activity_firmwareUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualització del firmware disponible"),
        "activity_incomingPurchase":
            MessageLookupByLibrary.simpleMessage("Compra Entrant"),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Avui"),
        "activity_passportUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualització de Passaport disponible"),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pendent"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Rebut"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Enviats"),
        "activity_sent_boosted":
            MessageLookupByLibrary.simpleMessage("Enviat (Augmentat)"),
        "activity_sent_canceled":
            MessageLookupByLibrary.simpleMessage("Cancel·lat"),
        "add_note_modal_heading":
            MessageLookupByLibrary.simpleMessage("Afegeix una Nota"),
        "add_note_modal_ie_text_field": MessageLookupByLibrary.simpleMessage(
            "He comprat una cartera Passport"),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Enregistreu alguns detalls sobre aquesta transacció."),
        "android_backup_info_heading": MessageLookupByLibrary.simpleMessage(
            "Android fa una Còpia de Seguretat cada 24 hores"),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
            "Android fa una còpia de seguretat automàtica de les teves dades d\'Envoy cada 24 hores.\n\nPer assegurar-vos que la vostra primera còpia de seguretat s\'hagi completat, us recomanem que feu una còpia de seguretat manual al vostre dispositiu [[Configuració.]]"),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
            "Envoy és una cartera Bitcoin senzilla amb potents funcions de privacitati gestió de comptes. Utilitzeu Envoy juntament amb la cartera Passport per a la configuració, actualitzacions de firmware i molt més. Envoy ofereix les següents característiques:\n\n1. Còpies de Seguretat Màgiques. Posat en marxa amb l\'autocustodia en només 60 segons amb còpies de seguretat xifrades automàtiques. Clau Privada opcionals.\n\n2. Gestioneu la vostra cartera mòbil i els comptes de la cartera Passport a la mateixa aplicació.\n\n3. Envia i rep Bitcoin en una interfície amigable.\n\n4. Connecteu la vostra cartera Passport per a la configuració, les actualitzacions de microprogramari i els vídeos d\'assistència. Utilitzeu Envoy com a cartera connectada al vostre Passport.\n\n5. Codi obert totalment i preservació de la privacitat. \n\n6. De forma opcional, connecteu el vostre propi node Bitcoin."),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Cupó Azteco pendent"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No es pot establir la Connexió"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot connectar amb Azteco.\n\nPoseu-vos en contacte amb support@azte.co o torneu-ho a provar més tard."),
        "azteco_note": MessageLookupByLibrary.simpleMessage("Val Azteco"),
        "azteco_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Val Azteco Pendent"),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage("CODI DE CUPÓ"),
        "azteco_redeem_modal_amount":
            MessageLookupByLibrary.simpleMessage("Quantitat"),
        "azteco_redeem_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Bescanvia"),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("No es pot Bescanviar"),
        "azteco_redeem_modal_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Si us plau, confirmeu que el vostre cupó encara és vàlid.\n\nPoseu-vos en contacte amb support@azte.co amb qualsevol pregunta relacionada amb el cupó."),
        "azteco_redeem_modal_heading":
            MessageLookupByLibrary.simpleMessage("Bescanviar el Cupó?"),
        "azteco_redeem_modal_saleDate":
            MessageLookupByLibrary.simpleMessage("Data de Venda"),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage("Val Bescanviat"),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aviat apareixerà una transacció entrant al vostre compte."),
        "backups_advancedBackups":
            MessageLookupByLibrary.simpleMessage("Advanced Backups"),
        "backups_downloadBIP329BackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Export Tags & Labels (BIP-329)"),
        "backups_downloadSettingsDataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Download Settings & Data Backup File"),
        "backups_downloadSettingsMetadataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Download Settings & Metadata Backup File"),
        "backups_erase_mobile_wallet":
            MessageLookupByLibrary.simpleMessage("Erase Mobile Wallet"),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage(
                "Esborra Carteres i Còpies de Seguretat"),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esteu a punt de suprimir permanentment la vostra cartera Envoy.\n\nSi utilitzeu Magic Backups, la vostra Envoy Seed també es suprimirà d\'Android Auto Backup."),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esteu a punt de suprimir permanentment la vostra cartera Envoy. Si utilitzeu Còpies de Seguretat Màgiques, la vostra clau privada d\'Envoy també s\'eliminarà del Clauer d\'iCloud."),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Els comptes de Passport connectats no s\'eliminaran com a part d\'aquest procés. Abans d\'eliminar la cartera d\'Envoy, assegurem-nos que la vostra Clau Privada i la Còpia de Seguretat estigui desat."),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Mostra les Paraules"),
        "backups_magicToManualErrorModal_header":
            MessageLookupByLibrary.simpleMessage("Unable to Continue"),
        "backups_magicToManualErrorModal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Envoy Magic Backup cannot be disabled while a Passport Prime Magic Backup is active.\n\nTo continue, first disable the Passport Prime Magic Backup on device."),
        "backups_manualToMagicrModal_header":
            MessageLookupByLibrary.simpleMessage("Enabling Magic Backups"),
        "backups_manualToMagicrModal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "This will enable a Magic Backup of your Envoy wallet. Your Envoy seed will be encrypted and backed up to your Apple or Google account. Envoy data will be encrypted and sent to the Foundation Server."),
        "backups_primeMagicBackups": m0,
        "backups_primeMasterKeyBackup": MessageLookupByLibrary.simpleMessage(
            "Master Key Backup (1 of 3 parts)"),
        "backups_settingsAndData":
            MessageLookupByLibrary.simpleMessage("Settings & Data"),
        "backups_settingsAndMetadata":
            MessageLookupByLibrary.simpleMessage("Settings & Metadata"),
        "backups_toggle_envoy_magic_backups":
            MessageLookupByLibrary.simpleMessage("Envoy Magic Backups"),
        "backups_toggle_envoy_mobile_wallet_key":
            MessageLookupByLibrary.simpleMessage("Mobile Wallet Key"),
        "backups_viewMobileWalletSeed":
            MessageLookupByLibrary.simpleMessage("View Mobile Wallet Seed"),
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Comptes"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Activitat"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositius"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprèn"),
        "bottomNav_privacy": MessageLookupByLibrary.simpleMessage("Privacitat"),
        "bottomNav_transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "btcpay_connection_modal_expired_subheading": m1,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Val de descompte caducat"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no es pot connectar amb la botiga BTCPay de l\'emissor. Poseu-vos en contacte amb l\'emissor o torneu-ho a provar més tard."),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El val escanejat no s\'ha creat amb suport onchain. Poseu-vos en contacte amb el creador del val."),
        "btcpay_note": MessageLookupByLibrary.simpleMessage("Val BTCPay"),
        "btcpay_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Val BTCPay pendent"),
        "btcpay_redeem_modal_description":
            MessageLookupByLibrary.simpleMessage("Descripció:"),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nom:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Xarxa incorrecta"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aquest és un val on-chain. No es pot bescanviar en un compte de Testnet o Signet."),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage("Tria un altre compte"),
        "buy_bitcoin_accountSelection_heading":
            MessageLookupByLibrary.simpleMessage(
                "On s\'ha d\'enviar el Bitcoin?"),
        "buy_bitcoin_accountSelection_modal_heading":
            MessageLookupByLibrary.simpleMessage("Sortint d\'Envoy"),
        "buy_bitcoin_accountSelection_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esteu a punt de deixar Envoy per al nostre servei de socis per comprar Bitcoin. Foundation mai s\'assabenta de cap informació de compra."),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El vostre Bitcoin s\'enviarà a aquesta adreça:"),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
                "Verifiqueu l\'adreça amb Passport"),
        "buy_bitcoin_accountSelection_verify_modal_heading": m2,
        "buy_bitcoin_buyOptions_atms_heading":
            MessageLookupByLibrary.simpleMessage("Com t\'agradaria comprar?"),
        "buy_bitcoin_buyOptions_atms_map_modal_openingHours":
            MessageLookupByLibrary.simpleMessage("Horari d\'obertura:"),
        "buy_bitcoin_buyOptions_atms_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Els diferents proveïdors de caixers automàtics requereixen quantitats variables d\'informació personal. Aquesta informació no es comparteix mai amb Foundation."),
        "buy_bitcoin_buyOptions_atms_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Trobeu un caixer automàtic de Bitcoin a la vostra àrea local per comprar Bitcoin amb efectiu."),
        "buy_bitcoin_buyOptions_card_atms":
            MessageLookupByLibrary.simpleMessage("Caixers automàtics"),
        "buy_bitcoin_buyOptions_card_commingSoon":
            MessageLookupByLibrary.simpleMessage("Pròximament a la teva zona."),
        "buy_bitcoin_buyOptions_card_disabledInSettings":
            MessageLookupByLibrary.simpleMessage(
                "Desactivada a la configuració."),
        "buy_bitcoin_buyOptions_card_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("Compra a Envoy"),
        "buy_bitcoin_buyOptions_card_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compreu Bitcoin en qüestió de segons, directament al vostre compte de Passport o cartera mòbil."),
        "buy_bitcoin_buyOptions_card_peerToPeer":
            MessageLookupByLibrary.simpleMessage("Peer to Peer"),
        "buy_bitcoin_buyOptions_card_vouchers":
            MessageLookupByLibrary.simpleMessage("Vals"),
        "buy_bitcoin_buyOptions_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("Com t\'agradaria comprar?"),
        "buy_bitcoin_buyOptions_inEnvoy_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Informació compartida amb Ramp quan compreu Bitcoin mitjançant aquest mètode. Aquesta informació no es comparteix mai amb Foundation.."),
        "buy_bitcoin_buyOptions_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra amb targeta de crèdit, Apple Pay, Google Pay o transferència bancària directament al teu compte Passport o a la cartera mòbil."),
        "buy_bitcoin_buyOptions_modal_address":
            MessageLookupByLibrary.simpleMessage("Direcció"),
        "buy_bitcoin_buyOptions_modal_bankingInfo":
            MessageLookupByLibrary.simpleMessage("Informació bancària"),
        "buy_bitcoin_buyOptions_modal_email":
            MessageLookupByLibrary.simpleMessage("Correu electrònic"),
        "buy_bitcoin_buyOptions_modal_identification":
            MessageLookupByLibrary.simpleMessage("Identificació"),
        "buy_bitcoin_buyOptions_modal_poweredBy":
            MessageLookupByLibrary.simpleMessage("Impulsat per "),
        "buy_bitcoin_buyOptions_notSupported_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Fes una ullada a aquestes altres formes de comprar Bitcoin."),
        "buy_bitcoin_buyOptions_peerToPeer_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La majoria de les operacions no requereixen compartir informació, però el vostre soci comercial pot conèixer la vostra informació bancària. Aquesta informació mai es comparteix amb Foundation."),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk":
            MessageLookupByLibrary.simpleMessage("AgoraDesk"),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compres de Bitcoin sense custòdia, peer-to-peer."),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq":
            MessageLookupByLibrary.simpleMessage("Bisq"),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compres de Bitcoin sense custòdia, peer-to-peer."),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl":
            MessageLookupByLibrary.simpleMessage("Hodl Hodl"),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compres de Bitcoin sense custòdia, peer-to-peer."),
        "buy_bitcoin_buyOptions_peerToPeer_options_heading":
            MessageLookupByLibrary.simpleMessage("Selecciona una opció"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach":
            MessageLookupByLibrary.simpleMessage("Peach"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compres de Bitcoin sense custòdia, peer-to-peer."),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats":
            MessageLookupByLibrary.simpleMessage("Robosats"),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compres de Bitcoin sense custòdia, natives de Lightning, peer-to-peer."),
        "buy_bitcoin_buyOptions_peerToPeer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Comprar Bitcoin fora d\'Envoy, sense intermediaris. Requereix més passos, però pot ser més privat."),
        "buy_bitcoin_buyOptions_vouchers_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Els diferents proveïdors requeriran quantitats variables d\'informació personal. Aquesta informació no es comparteix mai amb Foundation."),
        "buy_bitcoin_buyOptions_vouchers_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra vals de Bitcoin en línia o en persona. Bescanvia amb l\'escàner des de qualsevol compte."),
        "buy_bitcoin_defineLocation_heading":
            MessageLookupByLibrary.simpleMessage("La teva Regió"),
        "buy_bitcoin_defineLocation_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Seleccioneu la vostra regió perquè Envoy pugui mostrar les opcions de compra disponibles.  Aquesta informació no sortirà mai d\'Envoy."),
        "buy_bitcoin_details_menu_editRegion":
            MessageLookupByLibrary.simpleMessage("EDITA LA REGIÓ"),
        "buy_bitcoin_exit_modal_heading":
            MessageLookupByLibrary.simpleMessage("Cancel·lar Procés de Compra"),
        "buy_bitcoin_exit_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estàs a punt de cancel·lar el procés de compra. Estàs segur?"),
        "buy_bitcoin_mapLoadingError_header":
            MessageLookupByLibrary.simpleMessage(
                "No s\'ha pogut carregar el mapa"),
        "buy_bitcoin_mapLoadingError_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Actualment, Envoy no pot carregar les dades del mapa. Comprova la teva connexió o torna-ho a provar més tard."),
        "buy_bitcoin_purchaseComplete_heading":
            MessageLookupByLibrary.simpleMessage("Compra Finalitzada"),
        "buy_bitcoin_purchaseComplete_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La finalització pot trigar un temps depenent de la forma de pagament i congestió de la xarxa."),
        "buy_bitcoin_purchaseError_contactRamp":
            MessageLookupByLibrary.simpleMessage(
                "Poseu-vos en contacte amb Ramp per obtenir assistència."),
        "buy_bitcoin_purchaseError_contactStripe":
            MessageLookupByLibrary.simpleMessage(
                "Please contact Stripe for support."),
        "buy_bitcoin_purchaseError_heading":
            MessageLookupByLibrary.simpleMessage("S\'ha produït un error"),
        "buy_bitcoin_purchaseError_purchaseID":
            MessageLookupByLibrary.simpleMessage("ID de Compra:"),
        "card_coin_locked":
            MessageLookupByLibrary.simpleMessage("Moneda Bloquejada"),
        "card_coin_selected":
            MessageLookupByLibrary.simpleMessage("Moneda Seleccionada"),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Moneda"),
        "card_coins_locked":
            MessageLookupByLibrary.simpleMessage("Monedes Bloquejades"),
        "card_coins_selected":
            MessageLookupByLibrary.simpleMessage("Monedes Seleccionades"),
        "card_coins_unselected":
            MessageLookupByLibrary.simpleMessage("Monedes"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("de"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Trieu una Etiqueta"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
                "Aquesta transacció gasta monedes de diverses etiquetes. Com t\'agradaria etiquetar el teu canvi?"),
        "coinDetails_tagDetails":
            MessageLookupByLibrary.simpleMessage("DETALLS DE L\'ETIQUETA"),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El vostre identificador de transacció es copiarà al porta-retalls i és possible que sigui visible per a altres aplicacions del vostre telèfon."),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Saldo disponible"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Import Requerit"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Quantitat Seleccionada"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Bloqueja"),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Bloquejar les monedes evitarà que s\'utilitzin en transaccions"),
        "coincontrol_switchActivity":
            MessageLookupByLibrary.simpleMessage("Activitat"),
        "coincontrol_switchTags":
            MessageLookupByLibrary.simpleMessage("Etiquetes"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Revisa la Transacció"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage("Signar amb Passaport"),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
                "La vostra transacció està a punt per ser signada"),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Confirmeu que els detalls de la transacció són correctes abans de signar amb Passport."),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Deseu alguns detalls sobre la vostra transacció."),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Mostra els detalls"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Import a enviar"),
        "coincontrol_tx_detail_change":
            MessageLookupByLibrary.simpleMessage("Canvi rebut"),
        "coincontrol_tx_detail_cta1":
            MessageLookupByLibrary.simpleMessage("Enviar Transacció"),
        "coincontrol_tx_detail_cta2":
            MessageLookupByLibrary.simpleMessage("Edita la Transacció"),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Confirmeu la Tarifa"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Més del 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage("Destinació"),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Mostra l\'adreça"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Canvi rebut"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage("moneda"),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage("monedes"),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("DETALLS DE LA TRANSACCIÓ"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Gastat de"),
        "coincontrol_tx_detail_fee":
            MessageLookupByLibrary.simpleMessage("Comissió"),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
                "Actualitzar la teva tarifa pot haver modificat la selecció de monedes. Si us plau, revisa-ho."),
        "coincontrol_tx_detail_fee_alert": m3,
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage("Altres"),
        "coincontrol_tx_detail_fee_fast":
            MessageLookupByLibrary.simpleMessage("Fast"),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage("Més ràpid"),
        "coincontrol_tx_detail_fee_slow":
            MessageLookupByLibrary.simpleMessage("Slow"),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage("Normal"),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
            "La teva transacció està a punt per ser enviada"),
        "coincontrol_tx_detail_high_fee_info_overlay_learnMore":
            MessageLookupByLibrary.simpleMessage("[[Aprèn més]]"),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Algunes monedes més petites s\'han exclòs d\'aquesta transacció. A la tarifa escollida, costen més d\'incloure del que valen."),
        "coincontrol_tx_detail_newFee":
            MessageLookupByLibrary.simpleMessage("Nova Tarifa"),
        "coincontrol_tx_detail_no_change":
            MessageLookupByLibrary.simpleMessage("Sense canvis"),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage("Cancela la Transacció"),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
                "En cancelar, perdràs tot el progrés de la transacció."),
        "coincontrol_tx_detail_subheading": MessageLookupByLibrary.simpleMessage(
            "Confirmeu que els detalls de la transacció són correctes abans d\'enviar-los."),
        "coincontrol_tx_detail_total":
            MessageLookupByLibrary.simpleMessage("Total"),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Desbloqueja"),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Desbloquejar les monedes les permetrà utilitzar-les en transaccions."),
        "coindetails_overlay_address":
            MessageLookupByLibrary.simpleMessage("Direcció"),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("a"),
        "coindetails_overlay_block":
            MessageLookupByLibrary.simpleMessage("Block"),
        "coindetails_overlay_boostedFees":
            MessageLookupByLibrary.simpleMessage("Tarifa Augmentada"),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage("Confirmació en"),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage("Confirmació en"),
        "coindetails_overlay_confirmationIn_day":
            MessageLookupByLibrary.simpleMessage("dia"),
        "coindetails_overlay_confirmationIn_days":
            MessageLookupByLibrary.simpleMessage("dies"),
        "coindetails_overlay_confirmationIn_month":
            MessageLookupByLibrary.simpleMessage("Mes"),
        "coindetails_overlay_confirmationIn_week":
            MessageLookupByLibrary.simpleMessage("setmana"),
        "coindetails_overlay_confirmationIn_weeks":
            MessageLookupByLibrary.simpleMessage("setmanes"),
        "coindetails_overlay_confirmation_boost":
            MessageLookupByLibrary.simpleMessage("Augmenta"),
        "coindetails_overlay_confirmations":
            MessageLookupByLibrary.simpleMessage("Confirmations"),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Data"),
        "coindetails_overlay_explorer":
            MessageLookupByLibrary.simpleMessage("Explorador"),
        "coindetails_overlay_heading":
            MessageLookupByLibrary.simpleMessage("DETALLS DE LA MONEDA"),
        "coindetails_overlay_modal_explorer_heading":
            MessageLookupByLibrary.simpleMessage("Obre a l\'explorador"),
        "coindetails_overlay_modal_explorer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esteu a punt de deixar Envoy i veure aquesta transacció en un explorador de blockchain allotjat per la Fundació. Assegureu-vos d\'entendre les compensacions de privacitat abans de continuar. "),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "No es pot augmentar la transacció"),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Això es deu al fet que no hi ha prou monedes confirmades o desbloquejades per triar. \n\nSempre que sigui possible, permeteu que les monedes pendents confirmin o desbloquegin algunes monedes i torneu-ho a provar."),
        "coindetails_overlay_noCancelNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "No es Pot Cancel·lar la Transacció"),
        "coindetails_overlay_noCanceltNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Not enough confirmed or unlocked coins available to cancel this transaction. \n\nWhere possible, allow pending coins to confirm, or unlock some coins and try again."),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Notes"),
        "coindetails_overlay_paymentID":
            MessageLookupByLibrary.simpleMessage("ID de pagament"),
        "coindetails_overlay_rampFee":
            MessageLookupByLibrary.simpleMessage("Tarifes de Ramp"),
        "coindetails_overlay_rampID":
            MessageLookupByLibrary.simpleMessage("ID de Ramp"),
        "coindetails_overlay_status":
            MessageLookupByLibrary.simpleMessage("Estat"),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmat"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage("Pendent"),
        "coindetails_overlay_stripeFee":
            MessageLookupByLibrary.simpleMessage("Stripe Fees"),
        "coindetails_overlay_stripeID":
            MessageLookupByLibrary.simpleMessage("Stripe ID"),
        "coindetails_overlay_tag":
            MessageLookupByLibrary.simpleMessage("Etiqueta"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage("ID de transacció"),
        "common_button_contactSupport":
            MessageLookupByLibrary.simpleMessage("Contact Support"),
        "component_Apply": MessageLookupByLibrary.simpleMessage("Aplica"),
        "component_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "component_apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "component_areYouSure":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "component_back": MessageLookupByLibrary.simpleMessage("Enrere"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancel·la"),
        "component_confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "component_content": MessageLookupByLibrary.simpleMessage("Contingut"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Esborrar"),
        "component_device": MessageLookupByLibrary.simpleMessage("Dispositiu"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Descarta"),
        "component_done": MessageLookupByLibrary.simpleMessage("Fet"),
        "component_dontShowAgain":
            MessageLookupByLibrary.simpleMessage("No ho tornis a mostrar"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filtra"),
        "component_filter_button_all":
            MessageLookupByLibrary.simpleMessage("Tot"),
        "component_goToSettings":
            MessageLookupByLibrary.simpleMessage("Vés a Configuració"),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Més informació"),
        "component_minishield_buy":
            MessageLookupByLibrary.simpleMessage("Comprar"),
        "component_next": MessageLookupByLibrary.simpleMessage("Següent"),
        "component_no": MessageLookupByLibrary.simpleMessage("No"),
        "component_notificationLink":
            MessageLookupByLibrary.simpleMessage("Learn more"),
        "component_ok": MessageLookupByLibrary.simpleMessage("D\'ACORD"),
        "component_recover": MessageLookupByLibrary.simpleMessage("Recover"),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Bescanviar"),
        "component_reset": MessageLookupByLibrary.simpleMessage("Reinicia"),
        "component_resetFilter":
            MessageLookupByLibrary.simpleMessage("Reset filter"),
        "component_resetSorting":
            MessageLookupByLibrary.simpleMessage("Reset sorting"),
        "component_retry":
            MessageLookupByLibrary.simpleMessage("Torna-ho a provar"),
        "component_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "component_searching":
            MessageLookupByLibrary.simpleMessage("Searching"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Saltar"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Ordena per"),
        "component_tryAgain":
            MessageLookupByLibrary.simpleMessage("Torna-ho a Provar"),
        "component_update":
            MessageLookupByLibrary.simpleMessage("Actualització"),
        "component_warning":
            MessageLookupByLibrary.simpleMessage("ADVERTÈNCIA"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "contactRampForSupport":
            MessageLookupByLibrary.simpleMessage("Contact Ramp for support"),
        "contactStripeForSupport":
            MessageLookupByLibrary.simpleMessage("Contact Stripe for support"),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
            "La teva adreça es copiarà al porta-retalls i pot ser que la puguin veure altres aplicacions del teu telèfon."),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
            "L\'identificador de la transacció es copiarà al porta-retalls i és possible que sigui visible per a altres aplicacions del telèfon."),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Les etiquetes són una manera útil d\'organitzar les teves monedes."),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage("Suggeriments"),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Més utilitzats"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esteu segur que voleu suprimir aquesta etiqueta?"),
        "delete_tag_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Suprimeix L\'etiqueta"),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "En suprimir aquesta etiqueta, aquestes monedes es marcaran automàticament com a sense etiquetar."),
        "delete_wallet_for_good_error_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy was unable to contact the Foundation server to delete your encrypted wallet data. Please try again or contact support."),
        "delete_wallet_for_good_error_title":
            MessageLookupByLibrary.simpleMessage("Unable to Delete"),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Android fa una còpia de seguretat automàtica de les teves dades d\'Envoy cada 24 hores.\n\nPer eliminar immediatament el vostre Envoy Seed de les còpies de seguretat d\'Android Auto, podeu fer una còpia de seguretat manual al vostre dispositiu [[Configuració.]]"),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage(
                "S\'està suprimint la cartera Envoy"),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Suprimeix Cartera"),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Confirmes que vols ELIMINAR la teva cartera Envoy?"),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "La teva cartera s\'ha suprimit correctament"),
        "devices_empty_modal_video_cta1":
            MessageLookupByLibrary.simpleMessage("Comprar Passport"),
        "devices_empty_modal_video_cta2":
            MessageLookupByLibrary.simpleMessage("Mirar Després"),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Assegureu el vostre Bitcoin amb Passport."),
        "empty_tag_modal_subheading": m4,
        "envoy_account_tos_cta":
            MessageLookupByLibrary.simpleMessage("Accepto"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
            "Reviseu i accepteu les Condicions d\'ús de Passport"),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
            "Envoy requereix accés a la càmera per escanejar codis QR. Si us plau, aneu a la configuració i concediu els permisos de la càmera."),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Permís necessari"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
            "Envoy és una aplicació de cartera mòbil de Bitcoin i Passport, disponible a iOS i Android."),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
            "No, tothom pot descarregar, verificar i instal·lar manualment el nou firmware. Consulteu [[aquí]] per obtenir més informació."),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
            "Absolutament, no hi ha límit en el nombre de Passaports que pots gestionar i interactuar utilitzant Envoy."),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
            "Sí, Envoy fa que la gestió de múltiples comptes sigui senzilla."),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
            "Envoy comunica principalment mitjançant codis QR, però les actualitzacions de firmware s\'envien des del teu telèfon a través d\'una targeta microSD. Passport inclou adaptadors de microSD per al teu telèfon."),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
            "Sí, tingues en compte que qualsevol informació específica de la cartera, com ara l\'adreça o l\'etiquetatge de les UTXO, no es copiarà a Envoy ni des d\'Envoy."),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
            "Això pot ser possible ja que la majoria de carteres de maquinari habilitades per a QR comuniquen de maneres molt similars, però això no està explícitament suportat. Com que Envoy és de codi obert, donem la benvinguda a altres carteres basades en QR per afegir suport!"),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
            "En aquest moment, Envoy només funciona amb Bitcoin \'on-chain\'. Tenim previst donar suport al Lightning en el futur."),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
            "Qualsevol persona que trobi el teu telèfon primer hauria de superar el PIN del sistema operatiu del teu telèfon o l\'autenticació biomètrica per accedir a Envoy. En el improbable cas que ho aconseguissin, l\'atacant podria enviar fons des del teu Moneder Mòbil d\'Envoy i veure la quantitat de Bitcoin emmagatzemada en qualsevol compte de Passport connectat. Aquests fons de Passport no estan en perill perquè qualsevol transacció ha de ser autoritzada pel dispositiu Passport emparellat."),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
            "Si s\'utilitza amb un Passport, Envoy actua com a moneder \'només per a visualització\' connectat al teu Hardware Wallet. Això significa que Envoy pot construir transaccions, però són inútils sense l\'autorització pertinent, que només Passport pot proporcionar. Passport és l\'emmagatzematge en fred i Envoy és simplement la interfície connectada a Internet! Si utilitzes Envoy per crear un moneder mòbil, on les claus es guarden de manera segura al teu telèfon, aquest moneder mòbil no es consideraria emmagatzematge en fred. Això no té cap efecte sobre la seguretat de cap compte connectat a Passport."),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
            "Sí, Envoy es connecta utilitzant el protocol del servidor Electrum. Per connectar amb el teu propi servidor Electrum, escaneja el codi QR o introdueix l\'URL proporcionat a la configuració de xarxa en Envoy."),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
            "Envoy està dissenyat per oferir l\'experiència més fàcil d\'utilitzar de qualsevol cartera Bitcoin, sense comprometre la vostra privacitat. Amb les Còpies de Seguretat d\'Envoy, configureu una cartera mòbil de Bitcoin amb custòdia pròpia en 60 segons, sense paraules inicials! Els usuaris de Passport poden connectar els seus dispositius a Envoy per a una fàcil configuració, actualitzacions de firmware i una experiència senzilla de cartera de Bitcoin."),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
            "Descarregar i instal·lar Envoy no requereix cap informació personal i Envoy pot connectar-se a internet mitjançant Tor, un protocol de preservació de la privacitat. Això significa que Foundation no té cap manera de saber qui ets. Envoy també permet als usuaris més avançats connectar-se al seu propi node de Bitcoin per eliminar qualsevol dependència dels servidors de lFoundation completament."),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
            "Sí. A partir de la versió 1.4.0, Envoy ara suporta una selecció completa de monedes, així com l\'etiquetatge de monedes."),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
            "En aquest moment, Envoy no admet despeses en lot."),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
            "Sí. A partir de la versió 1.4.0, Envoy permet personalitzar totalment les comissions dels miners, així com dues opcions ràpides de selecció de comissions: \'Estàndard\' i \'Més ràpid\'. \'Estàndard\' té com a objectiu finalitzar la teva transacció en un termini de 60 minuts i \'Més ràpid\' en 10 minuts. Aquestes són estimacions basades en la congestió de la xarxa en el moment de construir la transacció i sempre et mostrarem el cost de les dues opcions abans de finalitzar la transacció."),
        "envoy_faq_answer_24": MessageLookupByLibrary.simpleMessage(
            "Sí! A partir de la v1.7.0 ara podeu comprar Bitcoin dins d\'Envoy i dipositar-lo automàticament al vostre compte mòbil o a qualsevol compte de Passport connectat. Només cal que feu clic al botó de compra des de la pantalla principal de comptes."),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
            "Envoy és una cartera Bitcoin senzilla amb potents funcions de privacitat i gestió de comptes, com ara les Còpies de Seguretat Màgiques. Utilitzeu Envoy juntament amb la vostra cartera Passport per a la configuració, actualitzacions de firmware i molt més."),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
            "Còpies de seguretat Màgiques és la manera més fàcil de configurar i fer una còpia de seguretat d\'una cartera mòbil de Bitcoin. La Còpia de Seguretat Màgica emmagatzema la clau privada de la teva cartera mòbil xifrada d\'extrem a extrem a Clauer d\'iCloud o Còpia de Seguretat Automàtica d\'Android. Totes les dades de l\'aplicació estan xifrades per la vostra clau privada i s\'emmagatzemen als servidors de Foundation. Configura la teva cartera en 60 segons i restaura automàticament si perds el telèfon!"),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
            "Les Còpies de Seguretat Màgiques són completament opcionals per als usuaris que vulguin aprofitar Envoy com a cartera mòbil. Si prefereixes gestionar les teves pròpies paraules clau de llavor de cartera mòbil i el fitxer de còpia de seguretat, selecciona \'Configurar manualment la clau privada\' durant la configuració de la cartera."),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
            "El fitxer de còpia de seguretat de l\'Envoy conté la configuració de l\'aplicació, la informació del compte i les etiquetes de les transaccions. El fitxer està encriptat amb les paraules de l\'embrió de la teva cartera mòbil. Per als usuaris de Magic Backup, això s\'emmagatzema totalment encriptat en el servidor de Foundation. Els usuaris de l\'Envoy de còpia de seguretat manual poden descarregar i emmagatzemar el fitxer de còpia de seguretat on vulguin. Això pot ser qualsevol combinació del teu telèfon, un servidor personal de núvol o alguna cosa física com una targeta microSD o una unitat USB."),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
            "No, les funcionalitats principals de l\'Envoy seran sempre gratuïtes per a ús. En el futur, podríem introduir serveis opcionals de pagament o subscripcions."),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
            "Sí, com tot el que fem a Foundation, Envoy és completament de codi obert. Envoy està llicenciat sota la mateixa llicència [[GPLv3]]. Per a aquells que vulguin comprovar el nostre codi font, feu clic a [[here]]."),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
            "No, ens enorgullim de garantir que el Passport sigui compatible amb tantes carteres diferents com sigui possible. Consulteu la nostra llista completa, inclosos els tutorials [[here]]."),
        "envoy_faq_link_10": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/firmware-updates/passport/"),
        "envoy_faq_link_8_1": MessageLookupByLibrary.simpleMessage(
            "https://www.gnu.org/licenses/gpl-3.0.en.html"),
        "envoy_faq_link_8_2": MessageLookupByLibrary.simpleMessage(
            "https://github.com/Foundation-Devices/envoy"),
        "envoy_faq_link_9": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/passport/connect/"),
        "envoy_faq_question_1":
            MessageLookupByLibrary.simpleMessage("Què és Envoy?"),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
            "He d\'utilitzar Envoy per actualitzar el firmware del Passport?"),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
            "Puc gestionar més d\'un Passport amb Envoy?"),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
            "Puc gestionar diversos comptes des del mateix Passport?"),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
            "Com es comunica Envoy amb Passport?"),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
            "Puc utilitzar Envoy en paral·lel a un altre programari com Sparrow Wallet?"),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
            "Puc gestionar altres carteres amb Envoy?"),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
            "Envoy és compatible amb Lightning Network?"),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
            "Què passa si perdo el meu telèfon amb Envoy instal·lat?"),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
            "Es considera Envoy un \"Emmagatzematge en Fred\"?"),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
            "Puc connectar Envoy al meu propi node Bitcoin?"),
        "envoy_faq_question_2": MessageLookupByLibrary.simpleMessage(
            "Per què hauria d\'utilitzar Envoy?"),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
            "Com protegeix Envoy la meva privacitat?"),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
            "Envoy ofereix control de monedes?"),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
            "Envoy admet les despeses per lots?"),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
            "Envoy permet la selecció personalitzada de tarifes de miners?"),
        "envoy_faq_question_24": MessageLookupByLibrary.simpleMessage(
            "Puc comprar Bitcoin a Envoy?"),
        "envoy_faq_question_3":
            MessageLookupByLibrary.simpleMessage("Què pot fer Envoy?"),
        "envoy_faq_question_4": MessageLookupByLibrary.simpleMessage(
            "Què son les Còpies de Seguretat Màgiques d\'Envoy?"),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
            "He d\'utilitzar les Còpies de Seguretat Màgiques d\'Envoy?"),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
            "Què és el fitxer de Còpia de Seguretat d\'Envoy?"),
        "envoy_faq_question_7":
            MessageLookupByLibrary.simpleMessage("He de pagar per Envoy?"),
        "envoy_faq_question_8":
            MessageLookupByLibrary.simpleMessage("Envoy és de Codi Obert?"),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
            "He d\'utilitzar Envoy per fer transaccions amb Passport?"),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy no ha pogut copiar el firmware a la targeta microSD."),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Assegureu-vos que la targeta microSD estigui inserida correctament al vostre telèfon i torneu-ho a provar. Alternativament, el firmware es pot descarregar des del nostre [[GitHub]]."),
        "envoy_fw_intro_cta":
            MessageLookupByLibrary.simpleMessage("Descarrega el Firmware"),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
            "A continuació, actualitzem el firmware del Passport"),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy us permet actualitzar el vostre Passport des del vostre telèfon mitjançant l\'adaptador microSD inclòs.\n\nEls usuaris avançats poden [[tocar aquí]] per descarregar i verificar el firmware en un ordinador."),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
                "Permet que Envoy accedeixi a la targeta microSD"),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Concedeix accés a Envoy per copiar fitxers a la targeta microSD. Toqueu Navega, després PASSPORT-SD i, a continuació, Obre."),
        "envoy_fw_microsd_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Descarregar des de Github"),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
            "Ho sentim, ara mateix no podem obtenir l\'actualització del firmware."),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
            "Insereix la targeta microSD al teu telèfon"),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
            "Insereix l\'adaptador de la targeta microSD proporcionat al teu telèfon, després insereix la targeta microSD a l\'adaptador."),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
            "Treu la targeta microSD i insereix-la a Passport"),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Inseriu la targeta microSD al Passport i navegueu a Configuració -> Firmware -> Actualitza el Firmware.\n\nAssegureu-vos que Passport tingui una càrrega de bateria adequada abans de dur a terme aquesta operació."),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
            "Inseriu la targeta microSD al Passport i seguiu les instruccions.\n\nAssegureu-vos que Passport tingui una càrrega de bateria adequada abans de dur a terme aquesta operació."),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy ara està copiant el firmware a la targeta microSD"),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
            "Això pot trigar uns segons. Si us plau, no retireu la targeta microSD."),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
            "El firmware s\'ha copiat amb èxit a la targeta microSD"),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Assegureu-vos de tocar el botó Desmuntar targeta SD del Gestor de Fitxers abans de treure la targeta microSD del telèfon."),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
            "L\'últim firmware s\'ha copiat a la targeta microSD i està llest per aplicar-se al Passport."),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Introduïu un PIN de 6 a 12 dígits al vostre Passport"),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport sempre demanarà el PIN en iniciar-se. Us recomanem que utilitzeu un PIN únic i escriu-lo.\n\nSi oblideu el vostre PIN, no hi ha manera de recuperar Passport i el dispositiu es desactivarà permanentment."),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Ara, crea una còpia de seguretat encriptada de la teva clau"),
        "envoy_pp_new_seed_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport farà una còpia de seguretat de la configuració de la clau i del dispositiu en una targeta microSD xifrada."),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
            "A Passport, seleccioneu\nCrear Nova Clau"),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "La Passport Avalanche Noise Source de Passport, un generador de nombres aleatoris de codi obert, ajuda a crear una clau privada forta."),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Felicitats, s\'ha creat la teva nova clau"),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A continuació, connectarem Envoy i Passport."),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
            "A Passport, seleccioneu Restaura la Còpia de Seguretat"),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage(
                "Desxifra la teva Còpia de Seguretat"),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Per desxifrar el fitxer de còpia de seguretat, introduïu el codi de còpia de seguretat de 20 dígits que se us mostra quan creeu el fitxer de còpia de seguretat.\n\nSi heu perdut o oblidat aquest codi, podeu restaurar-lo fent servir les teves paraules."),
        "envoy_pp_restore_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Utilitzeu aquesta funció per restaurar Passport mitjançant una còpia de seguretat microSD xifrada d\'un altre Passport.\n\nNecessitareu la contrasenya per desxifrar la còpia de seguretat."),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "El vostre Fitxer de Còpia de Seguretat s\'ha restaurat correctament"),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
            "A Passport, seleccioneu Restaura la Clau Privada"),
        "envoy_pp_restore_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Utilitza aquesta funció per restaurar una clau existent de 12 o 24 paraules."),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "La teva clau s\'ha restaurat correctament"),
        "envoy_pp_setup_intro_cta1":
            MessageLookupByLibrary.simpleMessage("Crea una Nova Clau Privada"),
        "envoy_pp_setup_intro_cta2":
            MessageLookupByLibrary.simpleMessage("Restaurar Clau Privada"),
        "envoy_pp_setup_intro_cta3": MessageLookupByLibrary.simpleMessage(
            "Restaurar Còpia de Seguretat"),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Com vols configurar el teu Passport?"),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Com a nou propietari d\'un Passaport, pots crear una nova Clau Privada, restaurar una cartera utilitzant paraules clau o restaurar una còpia de seguretat d\'un Passport existent."),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Primer, assegurem-nos que el vostre Passport estigui segur"),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Aquesta comprovació de seguretat garantirà que el teu Passport no ha estat manipulat durant l\'enviament."),
        "envoy_scv_result_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Contacteu Amb Nosaltres"),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
            "El vostre Passport pot ser insegur"),
        "envoy_scv_result_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy no ha pogut validar la seguretat del teu Passport. Si us plau, contacta\'ns per rebre assistència."),
        "envoy_scv_result_ok_heading":
            MessageLookupByLibrary.simpleMessage("El teu Passport és segur"),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
            "A continuació, crea un PIN per protegir el teu Passport"),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
            "A continuació, escaneja el codi QR a la pantalla del Passport"),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Aquest codi QR completa la validació i comparteix informació de Passport amb Envoy."),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
            "A Passport, selecciona l\'aplicació Envoy i escaneja aquest Codi QR"),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Aquest codi QR proporciona informació per a la validació i la configuració."),
        "envoy_support_community":
            MessageLookupByLibrary.simpleMessage("COMUNITAT"),
        "envoy_support_documentation":
            MessageLookupByLibrary.simpleMessage("Documentació"),
        "envoy_support_email":
            MessageLookupByLibrary.simpleMessage("Correu electrònic"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
            "Activar Còpies de Seguretat Màgiques"),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Configura Manualment La Clau Privada"),
        "envoy_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Crear Cartera Nova"),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Per a una configuració perfecta, us recomanem que activeu [[Còpia de seguretat màgica]].\n\nEls usuaris avançats poden crear o restaurar manualment una clau privada."),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage("Torna als meus Comptes"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage(
                "Suprimeix els comptes de totes maneres"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Abans d\'eliminar la cartera d\'Envoy, buideu els vostres comptes.\nAneu a Còpies de Seguretat > Esborra Carteres i Còpies de Seguretat un cop hàgiu acabat."),
        "exploreAddresses_listFilter_unused":
            MessageLookupByLibrary.simpleMessage("Unused"),
        "exploreAddresses_listFilter_used":
            MessageLookupByLibrary.simpleMessage("Used"),
        "exploreAddresses_listFilter_zeroBalance":
            MessageLookupByLibrary.simpleMessage("0 Balance"),
        "exploreAddresses_listModal_backToList":
            MessageLookupByLibrary.simpleMessage("Back to List"),
        "exploreAddresses_listModal_content": MessageLookupByLibrary.simpleMessage(
            "This address has been used at least once. When receiving Bitcoin it is a privacy best practice to use a new address."),
        "exploreAddresses_listModal_showAddress":
            MessageLookupByLibrary.simpleMessage("Show Address"),
        "exploreAddresses_list_header":
            MessageLookupByLibrary.simpleMessage("Explore addresses"),
        "exploreAddresses_qr_derivationPath":
            MessageLookupByLibrary.simpleMessage("Derivation Path"),
        "exploreAddresses_qr_header": m5,
        "exploreAddresses_qr_warningReused": MessageLookupByLibrary.simpleMessage(
            "This address has already been used. Avoid address reuse to preserve your privacy. "),
        "exploreAdresses_activityOptions_deleteAccount":
            MessageLookupByLibrary.simpleMessage("Delete Account"),
        "exploreAdresses_activityOptions_editAccountName":
            MessageLookupByLibrary.simpleMessage("Edit Account Name"),
        "exploreAdresses_activityOptions_exploreAddresses":
            MessageLookupByLibrary.simpleMessage("Explore Addresses"),
        "exploreAdresses_activityOptions_showDescriptor":
            MessageLookupByLibrary.simpleMessage("Show Descriptor"),
        "exploreAdresses_activityOptions_signMessage":
            MessageLookupByLibrary.simpleMessage("Sign Message"),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Aquest fitxer xifrat conté dades útils de la cartera, com ara etiquetes, comptes i configuració. Aquest fitxer està xifrat amb el vostre Clau Privada d\'Envoy. Assegureu-vos que la vostra clau tingui una còpia de seguretat segura."),
        "export_backup_send_CTA1": MessageLookupByLibrary.simpleMessage(
            "Descarrega la Còpia de Seguretat"),
        "export_backup_send_CTA2":
            MessageLookupByLibrary.simpleMessage("Descartar"),
        "export_seed_modal_12_words_CTA2":
            MessageLookupByLibrary.simpleMessage("Veure com a Codi QR"),
        "export_seed_modal_QR_code_CTA2":
            MessageLookupByLibrary.simpleMessage("Veure Clau Privada"),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Per utilitzar aquest codi QR a Envoy en un telèfon nou, aneu a Configurar la cartera d\'Envoy > Recuperar de Magic Backup > Recuperar amb codi QR"),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
                "This seed is protected by a passphrase. You need these seed words and the passphrase to recover your funds."),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "La pantalla següent mostra informació molt sensible.\n\nQualsevol persona amb accés a aquestes dades pot robar el vostre Bitcoin. Procediu amb extrema precaució."),
        "filter_sortBy_aToZ":
            MessageLookupByLibrary.simpleMessage("De la A a la Z"),
        "filter_sortBy_highest":
            MessageLookupByLibrary.simpleMessage("Valor més alt"),
        "filter_sortBy_lowest":
            MessageLookupByLibrary.simpleMessage("Valor més baix"),
        "filter_sortBy_newest":
            MessageLookupByLibrary.simpleMessage("El més nou primer"),
        "filter_sortBy_oldest":
            MessageLookupByLibrary.simpleMessage("El més antic primer"),
        "filter_sortBy_zToA":
            MessageLookupByLibrary.simpleMessage("De la Z a la A."),
        "finalize_catchAll_backUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Back Up Master Key"),
        "finalize_catchAll_backingUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Backing Up Master Key"),
        "finalize_catchAll_connectAccount":
            MessageLookupByLibrary.simpleMessage("Connect Account"),
        "finalize_catchAll_connectingAccount":
            MessageLookupByLibrary.simpleMessage("Connecting Account"),
        "finalize_catchAll_creatingPin":
            MessageLookupByLibrary.simpleMessage("Creating PIN"),
        "finalize_catchAll_header":
            MessageLookupByLibrary.simpleMessage("Continue on Passport Prime"),
        "finalize_catchAll_masterKeyBackedUp":
            MessageLookupByLibrary.simpleMessage("Master Key Backed Up"),
        "finalize_catchAll_masterKeySetUp":
            MessageLookupByLibrary.simpleMessage("Master Key Set Up"),
        "finalize_catchAll_pinCreated":
            MessageLookupByLibrary.simpleMessage("PIN created"),
        "finalize_catchAll_setUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Set Up Master Key"),
        "finalize_catchAll_settingUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Setting Up Master Key"),
        "finish_connectedSuccess_content": MessageLookupByLibrary.simpleMessage(
            "Envoy is set up and ready for your Bitcoin!"),
        "finish_connectedSuccess_header": MessageLookupByLibrary.simpleMessage(
            "Wallet Connected Successfully"),
        "firmware_downloadingUpdate_downloaded":
            MessageLookupByLibrary.simpleMessage("Update Downloaded"),
        "firmware_downloadingUpdate_header":
            MessageLookupByLibrary.simpleMessage("Downloading Update"),
        "firmware_downloadingUpdate_timeRemaining": m6,
        "firmware_downloadingUpdate_transferring":
            MessageLookupByLibrary.simpleMessage(
                "Transferring to Passport Prime"),
        "firmware_updateAvailable_content2": m7,
        "firmware_updateAvailable_estimatedUpdateTime": m8,
        "firmware_updateAvailable_header":
            MessageLookupByLibrary.simpleMessage("Update Available"),
        "firmware_updateAvailable_whatsNew": m9,
        "firmware_updateError_downloadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to Download"),
        "firmware_updateError_header":
            MessageLookupByLibrary.simpleMessage("Update Failed"),
        "firmware_updateError_installFailed":
            MessageLookupByLibrary.simpleMessage("Failed to Install"),
        "firmware_updateError_receivingFailed":
            MessageLookupByLibrary.simpleMessage("Failed to Transfer"),
        "firmware_updateError_verifyFailed":
            MessageLookupByLibrary.simpleMessage("Failed to Verify"),
        "firmware_updateModalConnectionLostToast_unableToReconnect":
            MessageLookupByLibrary.simpleMessage(
                "Unable to reconnect to Passport Prime."),
        "firmware_updateModalConnectionLost_exit":
            MessageLookupByLibrary.simpleMessage("Exit Onboarding"),
        "firmware_updateModalConnectionLost_header":
            MessageLookupByLibrary.simpleMessage("Connection Lost"),
        "firmware_updateModalConnectionLost_reconnecting":
            MessageLookupByLibrary.simpleMessage("Reconnecting…"),
        "firmware_updateModalConnectionLost_tryToReconnect":
            MessageLookupByLibrary.simpleMessage("Try to Reconnect"),
        "firmware_updateSuccess_content1": m10,
        "firmware_updateSuccess_content2": MessageLookupByLibrary.simpleMessage(
            "Continue the setup on Passport Prime."),
        "firmware_updateSuccess_header":
            MessageLookupByLibrary.simpleMessage("Update Successful"),
        "firmware_updatingDownload_content":
            MessageLookupByLibrary.simpleMessage("Keep both devices nearby."),
        "firmware_updatingDownload_downloading":
            MessageLookupByLibrary.simpleMessage("Downloading Update"),
        "firmware_updatingDownload_header":
            MessageLookupByLibrary.simpleMessage("Updating"),
        "firmware_updatingDownload_transfer":
            MessageLookupByLibrary.simpleMessage("Transfer to Passport Prime"),
        "firmware_updatingPrime_content2": MessageLookupByLibrary.simpleMessage(
            "Setup will resume after Prime has restarted."),
        "firmware_updatingPrime_installUpdate":
            MessageLookupByLibrary.simpleMessage("Install Update"),
        "firmware_updatingPrime_installingUpdate":
            MessageLookupByLibrary.simpleMessage("Installing Update"),
        "firmware_updatingPrime_primeRestarting":
            MessageLookupByLibrary.simpleMessage(
                "Passport Prime is restarting"),
        "firmware_updatingPrime_restartPrime":
            MessageLookupByLibrary.simpleMessage("Restart Passport Prime"),
        "firmware_updatingPrime_updateInstalled":
            MessageLookupByLibrary.simpleMessage("Update Installed"),
        "firmware_updatingPrime_verified":
            MessageLookupByLibrary.simpleMessage("Update Verified"),
        "firmware_updatingPrime_verifying":
            MessageLookupByLibrary.simpleMessage("Verifying Update"),
        "header_buyBitcoin":
            MessageLookupByLibrary.simpleMessage("COMPRA BITCOIN"),
        "header_chooseAccount":
            MessageLookupByLibrary.simpleMessage("TRIA UN COMPTE"),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Feu lliscar el dit per mostrar i amagar el vostre saldo."),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Toqueu la targeta anterior per rebre Bitcoin."),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
                "Toqueu qualsevol de les targetes anteriors per rebre Bitcoin."),
        "invalid_qr_heading":
            MessageLookupByLibrary.simpleMessage("Invalid QR Code"),
        "invalid_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "QR code does not contain a valid Bitcoin transaction (PSBT). Please check and try again."),
        "launch_screen_faceID_fail_CTA":
            MessageLookupByLibrary.simpleMessage("Torna-ho A Provar"),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage("L\'autenticació Ha Fallat"),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage("Siusplau torna-ho a provar"),
        "launch_screen_lockedout_heading":
            MessageLookupByLibrary.simpleMessage("Bloquejat"),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
                "L\'autenticació biomètrica està desactivada. Tanqueu l\'aplicació, espereu 30 segons i torneu-ho a provar."),
        "learning_center_device_envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "learning_center_device_passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "learning_center_device_passportCore":
            MessageLookupByLibrary.simpleMessage("Passport Core"),
        "learning_center_device_passportPrime":
            MessageLookupByLibrary.simpleMessage("Passport Prime"),
        "learning_center_filterEmpty_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Els filtres aplicats amaguen tots els resultats de la cerca.\nActualitzeu o restabliu els filtres per veure més resultats."),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("Totes"),
        "learning_center_results_title":
            MessageLookupByLibrary.simpleMessage("Resultats"),
        "learning_center_search_input":
            MessageLookupByLibrary.simpleMessage("Buscar..."),
        "learning_center_title_blog":
            MessageLookupByLibrary.simpleMessage("Blog"),
        "learning_center_title_faq":
            MessageLookupByLibrary.simpleMessage("Preguntes freqüents"),
        "learning_center_title_video":
            MessageLookupByLibrary.simpleMessage("Vídeos"),
        "learningcenter_status_read":
            MessageLookupByLibrary.simpleMessage("Llegeix"),
        "learningcenter_status_watched":
            MessageLookupByLibrary.simpleMessage("Mirat"),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Encriptant la vostra Còpia de Seguretat"),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy està encriptant la còpia de seguretat de la cartera.\n\nAquesta còpia de seguretat conté dades útils de la cartera, com ara etiquetes, notes, comptes i configuració."),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy està creant una clau privada de Bitcoin, que es guardarà encriptada d\'extrem a extrem en la còpia de seguretat del teu Android."),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage(
                "Creant la Vostra Clau Privada d\'Envoy"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy està creant una clau segura per a la cartera de Bitcoin, que s\'emmagatzemarà encriptada d\'extrem a extrem en el teu Clauer d\'iCloud."),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage("Recuperació amb codi QR"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot localitzar una Còpia de Seguretat Màgica.\n\nConfirmeu que heu iniciat la sessió amb el compte de Google correcte i que heu restaurat la còpia de seguretat del dispositiu més recent."),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Còpia De Seguretat Màgica Non Trobat"),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot localitzar la Còpia de Seguretat Màgica al servidor Foundation. Si us plau, comproveu que esteu recuperant una cartera que abans utilitzava la Còpia de Seguretat Màgica."),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Problema De Connexió"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no es pot connectar al servidor de Foundation per recuperar les dades de la Còpia de Seguretat Màgica.\n\nPodeu tornar-ho a provar, importar el vostre propi fitxer de còpia de seguretat d\'Envoy o continuar sense cap."),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage("Recuperació Sense Èxit"),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot localitzar una Còpia de Seguretat Màgica.\n\nConfirmeu que heu iniciat sessió amb el compte d\'Apple correctament i que heu restaurat la vostra ultima còpia de seguretat d\'iCloud."),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
                "Recuperant la teva cartera Envoy"),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage("Pujant Còpia de Seguretat"),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy està penjant la còpia de seguretat de la cartera xifrada als servidors de Foundation.\n\nCom que la vostra còpia de seguretat està xifrada d\'extrem a extrem, Foundation no té accés a la vostra còpia de seguretat ni al coneixement del seu contingut."),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La manera més senzilla de crear una nova cartera Bitcoin mantenint la teva sobirania.\nLEs Còpies de Seguretat Màgiques fa una còpia de seguretat automàtica de la teva cartera i de la teva configuració amb Còpia de Seguretat Automàtica d\'Android, 100% xifrat d\'extrem a extrem.\n\n[[Aprèn més]]."),
        "magic_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
            "Còpies de Seguretat Màgiques"),
        "magic_setup_tutorial_ios_CTA1": MessageLookupByLibrary.simpleMessage(
            "Crear Còpia de Seguretat Màgica"),
        "magic_setup_tutorial_ios_CTA2": MessageLookupByLibrary.simpleMessage(
            "Recuperar Còpia de Seguretat Màgica"),
        "magic_setup_tutorial_ios_subheading": MessageLookupByLibrary.simpleMessage(
            "La manera més senzilla de crear una nova cartera Bitcoin mantenint la vostra sobirania.\n\nLa Còpia de Seguretat Màgica fa una còpia de seguretat automàtica de la teva cartera i configuració amb Clauer d\'ICloud , 100% xifrat d\'extrem a extrem. [[Aprèn més]]."),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy generarà una nova adreça després que s\'utilitzi la següent."),
        "manage_account_address_heading":
            MessageLookupByLibrary.simpleMessage("DETALLS DEL COMPTE"),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Assegureu-vos de no compartir aquest descriptor tret que us sentiu còmode amb que les vostres transaccions siguin públiques."),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage("EDITA EL NOM DEL COMPTE"),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage("MOSTRA DESCRIPTOR"),
        "manage_account_remove_heading":
            MessageLookupByLibrary.simpleMessage("Estàs segur?"),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Això només elimina el compte d\'Envoy."),
        "manage_account_rename_heading":
            MessageLookupByLibrary.simpleMessage("Canvia el Nom del Compte"),
        "manage_device_deletePassportWarning": MessageLookupByLibrary.simpleMessage(
            "Estàs segur que vols desconnectar Passport?\nAixò eliminarà el dispositiu d\'Envoy juntament amb els comptes connectats."),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage("Vinculat"),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage("Sèrie"),
        "manage_device_details_heading":
            MessageLookupByLibrary.simpleMessage("DETALLS DEL DISPOSITIU"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage("EDITAR NOM DEL DISPOSITIU"),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Canvia el nom del teu Passport"),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
                "No es pot fer còpia de seguretat. Intenta-ho més tard."),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
                "Això descartarà qualsevol canvi de selecció de monedes. Vols continuar?"),
        "manual_setup_change_from_magic_header":
            MessageLookupByLibrary.simpleMessage("Magic Backups deactivated"),
        "manual_setup_change_from_magic_modal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Your Magic backup is about to be permanently erased. Ensure your seed is securely backed up and that you download your Envoy backup file.\n\nThis action will permanently delete your Envoy seed from your Apple or Google account, and your encrypted Envoy data from Foundation servers after a 24h waiting period."),
        "manual_setup_change_from_magic_subheaderApple":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy Magic Backup data was successfully deleted from your Apple account and Foundation servers."),
        "manual_setup_change_from_magic_subheaderGoogle":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy Magic Backup data was successfully deleted from your Google account and Foundation servers."),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Trieu Destinació"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage("Desa el Fitxer d\'Envoy"),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("Ho entenc"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El vostre fitxer de còpia de seguretat d\'Envoy està xifrat amb les vostres paraules clau inicials. Si perdeu l\'accés a les vostres paraules inicials, no podreu recuperar la vostra còpia de seguretat."),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy ha generat la vostra còpia de seguretat xifrada. Aquesta còpia de seguretat conté dades útils de la cartera, com ara Etiquetes, Notes, comptes i configuracions.\n\nPodeu triar protegir-lo al núvol, un altre dispositiu o una opció d\'emmagatzematge extern com una targeta microSD."),
        "manual_setup_generate_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Genera Clau"),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Mantingueu La Vostra Clau Privada"),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Recordeu mantenir sempre privada la vostra clau. Qualsevol persona amb accés a aquesta clau pot gastar el vostre Bitcoin!"),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage(
                "Trieu una paraula per continuar"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Verifiquem La Teva Clau Privada"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage(
                "Verifiqueu la Teva Clau Privada"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Entrada No Vàlida"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot verificar la vostra clau. Si us plau, confirmeu que heu enregistrat correctament la vostra clau i torneu-ho a provar."),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage(
                "Quin és el vostre número de clau privada"),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correcte"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy et farà algunes preguntes per verificar que has enregistrat correctament la teva clau semilla."),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Escriu Aquestes 24 Paraules"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Escriu Aquestes 12 Paraules"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Generant Clau Privada"),
        "manual_setup_import_backup_CTA1": MessageLookupByLibrary.simpleMessage(
            "Crear Còpia de Seguretat D\'Envoy"),
        "manual_setup_import_backup_CTA2": MessageLookupByLibrary.simpleMessage(
            "Importar Còpia de Seguretat d\'Envoy"),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "No podem llegir la còpia de Seguretat d\'Envoy"),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Assegureu-vos que heu seleccionat el fitxer correcte."),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Voleu restaurar un fitxer de còpia de seguretat d\'Envoy existent?\n\nSi no, Envoy crearà un nou fitxer de còpia de seguretat xifrat."),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Sembla que aquesta clau no és vàlida. Comproveu les paraules introduïdes, inclòs l\'ordre en què es troben i torneu-ho a provar."),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Introduïu La Vostra Clau"),
        "manual_setup_import_seed_CTA1":
            MessageLookupByLibrary.simpleMessage("Importa amb codi QR"),
        "manual_setup_import_seed_CTA2":
            MessageLookupByLibrary.simpleMessage("Clau Privada de 24 Paraules"),
        "manual_setup_import_seed_CTA3":
            MessageLookupByLibrary.simpleMessage("Clau Privada de 12 Paraules"),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage("My seed has a passphrase"),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Importa La Teva Clau Privada"),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
                "Mai importis la teva clau privada de Passport en les següents pantalles."),
        "manual_setup_import_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Continueu a continuació per importar una clau existent.\n\nMés endavant tindreu l\'opció d\'importar un fitxer de còpia de seguretat d\'Envoy."),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Importació de Clau Privada"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage(
                "S\'ha detectat una Còpia de Seguretat"),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignorar"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
                "S\'ha trobat una Còpia de Seguretat al servidor.\nVoleu Restaurar la vostra còpia de seguretat?"),
        "manual_setup_recovery_fail_cta2":
            MessageLookupByLibrary.simpleMessage("Importar Clau Privada"),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No es pot escanejar el Codi QR"),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Proveu d\'escanejar de nou o importar manualment la clau privada."),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si continues sense un fitxer de còpia de seguretat, la configuració de la teva cartera, els comptes addicionals, les Etiquetes i les Notes no es restauraran."),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Re-type Passphrase"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage(
                "Trieu un altre Fitxer de Còpia de Seguretat"),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no pot obrir aquest Fitxer de Còpia de Seguretat de l\'Envoy"),
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
            MessageLookupByLibrary.simpleMessage(
                "Importa la teva Clau Privada"),
        "manual_setup_tutorial_CTA1": MessageLookupByLibrary.simpleMessage(
            "Genera una Nova Clau Privada"),
        "manual_setup_tutorial_CTA2":
            MessageLookupByLibrary.simpleMessage("Importar Clau"),
        "manual_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
            "Configuració Manual de Claus"),
        "manual_setup_tutorial_subheading": MessageLookupByLibrary.simpleMessage(
            "Si prefereixes gestionar les teves pròpies paraules clau, continua a continuació per importar o crear una nova paraula clau.\n\nSi us plau, tingueu en compte que vostè serà l\'únic responsable de gestionar les còpies de seguretat. No s\'utilitzaran serveis de núvol."),
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
                "Desactivat per a la configuració manual de Claus Privades"),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage(
                "Baixeu la Copia de Seguretat d\'Envoy"),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Veure Envoy Clau Privada"),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
                "Emmagatzemat a Còpia de seguretat Automàtica d\'Android"),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Còpia de Seguretat d\'Envoy"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Envoy Clau Privada"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Fer Còpia Ara"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage(
                "Emmagatzemat al Clauer d\'iCloud"),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage("als Servidors de Foundation"),
        "manual_toggle_on_seed_backingup":
            MessageLookupByLibrary.simpleMessage("Backing up…"),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage(
                "Còpia de Seguretat en Progrés"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
                "La còpia de seguretat d\'Envoy s\'ha completat."),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Carregant Còpia de Seguretat d\'Envoy"),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aquesta còpia de seguretat conté dispositius i comptes connectats, etiquetes i configuració d\'aplicacions. No conté informació de la teva clau privada.\n\nLes còpies de seguretat d\'Envoy estan xifrades d\'extrem a extrem, Foundation no té accés ni coneixement dels seus continguts.\n\nEnvoy us notificarà quan s\'hagi completat la càrrega."),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Configuració d\'Android"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Còpia de Seguretat Automàtica d\'Android Pendent (un cop al dia)"),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Còpia de Seguretat pendent al Clauer d\'iCloud"),
        "manual_toggle_on_seed_uploading_foundation_servers":
            MessageLookupByLibrary.simpleMessage(
                "Uploading to Foundation Servers"),
        "menu_about": MessageLookupByLibrary.simpleMessage("SOBRE"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("CÒPIES DE SEGURETAT"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("CONFIGURACIÓ"),
        "menu_support": MessageLookupByLibrary.simpleMessage("SUPORT"),
        "onboardin_unifiedAccountsModal_content":
            MessageLookupByLibrary.simpleMessage(
                "From version 2.0.0, all address types are now accessible under a single account card.\n\nThe default receive address type can be changed in Settings."),
        "onboardin_unifiedAccountsModal_tilte":
            MessageLookupByLibrary.simpleMessage("Unified Address Types"),
        "onboarding_advancedModal_content": MessageLookupByLibrary.simpleMessage(
            "If you continue without Magic Backups, you will be responsible for storing your own seed words and backup data."),
        "onboarding_advancedModal_header":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "onboarding_advanced_magicBackupSwitchText":
            MessageLookupByLibrary.simpleMessage(
                "Simple, secure backup and recovery"),
        "onboarding_advanced_magicBackups":
            MessageLookupByLibrary.simpleMessage("Magic Backups"),
        "onboarding_advanced_magicBackupsContent":
            MessageLookupByLibrary.simpleMessage(
                "Automatic encrypted backups of your data for instant, stress-free recovery."),
        "onboarding_advanced_title":
            MessageLookupByLibrary.simpleMessage("Advanced"),
        "onboarding_bluetoothDisabled_content":
            MessageLookupByLibrary.simpleMessage(
                "Passport Prime requires Bluetooth for initial setup with QuantumLink. This allows for syncing of date and time, firmware updates, security checks, backups, and more.\n\nPlease enable Bluetooth permissions in Envoy settings."),
        "onboarding_bluetoothDisabled_enable":
            MessageLookupByLibrary.simpleMessage("Enable in Settings"),
        "onboarding_bluetoothDisabled_header":
            MessageLookupByLibrary.simpleMessage(
                "Enable Bluetooth for QuantumLink Connection"),
        "onboarding_bluetoothIntro_connect":
            MessageLookupByLibrary.simpleMessage("Connect with QuantumLink"),
        "onboarding_bluetoothIntro_content": MessageLookupByLibrary.simpleMessage(
            "Passport Prime uses a new, secure Bluetooth-based protocol for real time communication with Envoy.\n\nQuantumLink creates and end-to-end encrypted tunnel between Passport and Envoy, ensuring a secure connection."),
        "onboarding_bluetoothIntro_header":
            MessageLookupByLibrary.simpleMessage(
                "Secure Bluetooth with\nQuantumLink"),
        "onboarding_connectionChecking_SecurityPassed":
            MessageLookupByLibrary.simpleMessage("Security Check Passed"),
        "onboarding_connectionChecking_forUpdates":
            MessageLookupByLibrary.simpleMessage("Checking for Updates"),
        "onboarding_connectionIntroError_content":
            MessageLookupByLibrary.simpleMessage(
                "This device may not be genuine or may have been tampered with during shipping."),
        "onboarding_connectionIntroError_exitSetup":
            MessageLookupByLibrary.simpleMessage("Exit Setup"),
        "onboarding_connectionIntroError_securityCheckFailed":
            MessageLookupByLibrary.simpleMessage("Security Check Failed"),
        "onboarding_connectionIntroWarning_content":
            MessageLookupByLibrary.simpleMessage(
                "Ensure Passport Prime is powered on and near your phone."),
        "onboarding_connectionIntroWarning_header":
            MessageLookupByLibrary.simpleMessage("Setup Paused"),
        "onboarding_connectionIntro_checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Check for Updates"),
        "onboarding_connectionIntro_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage("Checking Device Security"),
        "onboarding_connectionIntro_connectedToPrime":
            MessageLookupByLibrary.simpleMessage("Connected to Passport Prime"),
        "onboarding_connectionIntro_header":
            MessageLookupByLibrary.simpleMessage("Passport Prime Connected"),
        "onboarding_connectionNoUpdates_noUpdates":
            MessageLookupByLibrary.simpleMessage("No Updates Available"),
        "onboarding_connectionUpdatesAvailable_updatesAvailable":
            MessageLookupByLibrary.simpleMessage("New Update Available"),
        "onboarding_magicUserMobileCreating_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is creating a secure key for use with your Bitcoin Mobile Wallet, which will be stored end-to-end encrypted in your Apple or Google account."),
        "onboarding_magicUserMobileCreating_header":
            MessageLookupByLibrary.simpleMessage("Creating Mobile Wallet Key"),
        "onboarding_magicUserMobileEncrypting_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is encrypting your wallet backup.\n\nThis backup contains useful wallet data such as tags, notes, accounts, and settings."),
        "onboarding_magicUserMobileEncrypting_header":
            MessageLookupByLibrary.simpleMessage("Encrypting Wallet Backup"),
        "onboarding_magicUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
                "Also known as a “hot wallet”. Spending from this wallet requires only your phone for authorization."),
        "onboarding_magicUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
                "Your Mobile Wallet Key will be stored in your phone\'s secure enclave, encrypted, and backed up to your Apple or Google account."),
        "onboarding_magicUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage(
                "Set up a Mobile Wallet with Magic Backups"),
        "onboarding_magicUserMobileIntro_learnMoreMagicBackups":
            MessageLookupByLibrary.simpleMessage(
                "Learn more about Magic Backups"),
        "onboarding_magicUserMobileSuccess_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is set up and ready for your Bitcoin!"),
        "onboarding_magicUserMobileSuccess_header":
            MessageLookupByLibrary.simpleMessage("Your Mobile Wallet Is Ready"),
        "onboarding_magicUserMobileUploading_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy is uploading your encrypted wallet backup to Foundation servers.\n\nSince your backup is end-to-end encrypted, Foundation has no access to your backup or knowledge of its contents."),
        "onboarding_magicUserMobileUploading_header":
            MessageLookupByLibrary.simpleMessage("Uploading Your Backup"),
        "onboarding_migrating_xOfYSynced": m11,
        "onboarding_passpportSelectCamera_sub235VersionAlert":
            MessageLookupByLibrary.simpleMessage(
                "Setting up a Passport Core on firmware v2.3.5 or earlier?"),
        "onboarding_passpportSelectCamera_tapHere":
            MessageLookupByLibrary.simpleMessage("Tap here"),
        "onboarding_primeIntro_content": MessageLookupByLibrary.simpleMessage(
            "Congratulations on taking the first step to secure your entire digital life.\n\nSetting up your Passport Prime will take only 5-10 minutes. Pick up your device and let’s get started!"),
        "onboarding_primeIntro_header":
            MessageLookupByLibrary.simpleMessage("Set Up Your Passport Prime"),
        "onboarding_sovereignUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
                "Also known as a “hot wallet.” Spending from this wallet requires only your phone for authorization."),
        "onboarding_sovereignUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
                "Your Bitcoin keys will be stored in your phone\'s secure enclave. You alone are responsible for maintaining a backup of your seed."),
        "onboarding_sovereignUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage("Set up Mobile Wallet"),
        "onboarding_tutorialColdWallet_content":
            MessageLookupByLibrary.simpleMessage(
                "Also known as a “cold wallet.” Spending from this wallet requires authorization from your Passport device. \n\nYour Passport Master Key is always stored securely offline.\n\nUse this wallet to secure the majority of your Bitcoin savings."),
        "onboarding_tutorialColdWallet_header":
            MessageLookupByLibrary.simpleMessage("Passport Wallet"),
        "onboarding_tutorialHotWallet_content":
            MessageLookupByLibrary.simpleMessage(
                "Also known as a “hot wallet.” Spending from this wallet requires only your phone for authorization.\n\nSince your Mobile Wallet is connected to the Internet, use this wallet to store small amounts of Bitcoin for frequent transactions."),
        "onboarding_tutorialHotWallet_header":
            MessageLookupByLibrary.simpleMessage("Mobile Wallet"),
        "onboarding_welcome_content": MessageLookupByLibrary.simpleMessage(
            "Reclaim your sovereignty with Envoy, a simple Bitcoin wallet with powerful account management and privacy features."),
        "onboarding_welcome_createMobileWallet":
            MessageLookupByLibrary.simpleMessage("Create a \nMobile Wallet"),
        "onboarding_welcome_header":
            MessageLookupByLibrary.simpleMessage("Welcome to Envoy"),
        "onboarding_welcome_setUpPassport":
            MessageLookupByLibrary.simpleMessage("Set Up a \nPassport Device"),
        "pair_existing_device_intro_heading":
            MessageLookupByLibrary.simpleMessage(
                "Connecteu Passport amb Envoy"),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Passport, seleccioneu Gestiona el Compte > Conecta el Wallet > Envoy."),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
            "Escaneja aquest codi QR amb el Passport per validar"),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aquesta és una adreça de Bitcoin que pertany al teu Passport."),
        "pair_new_device_address_cta2":
            MessageLookupByLibrary.simpleMessage("Contactar Servei Tècnic"),
        "pair_new_device_address_heading":
            MessageLookupByLibrary.simpleMessage("Adreça validada?"),
        "pair_new_device_address_subheading": MessageLookupByLibrary.simpleMessage(
            "Si rebeu un missatge d\'èxit a Passport, la vostra configuració ja s\'ha completat. Si Passport no ha pogut verificar l\'adreça, torneu-ho a provar o poseu-vos en contacte amb el servei t\'écnic."),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aquest pas permet a Envoy generar adreces de rebuda per Passport i proposar transaccions que Passport ha d\'autoritzar."),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
            "Escaneja el codi QR que genera Passport"),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
            "El codi QR conté la informació necessària per a que Envoy pugui interactuar de manera segura amb el Passport."),
        "pair_new_device_success_cta1": MessageLookupByLibrary.simpleMessage(
            "Valida l\'adreça de recepció"),
        "pair_new_device_success_cta2": MessageLookupByLibrary.simpleMessage(
            "Continueu a la pantalla d\'inici"),
        "pair_new_device_success_heading":
            MessageLookupByLibrary.simpleMessage("Connexió satisfactòria"),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy està connectat al teu Passport."),
        "passport_welcome_screen_cta1":
            MessageLookupByLibrary.simpleMessage("Configurar un Passport nou"),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Connecteu un Passport existent"),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
            "No tinc Passport. [[Més informació.]]"),
        "passport_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Benvingut a Passport"),
        "passport_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy ofereix una configuració segura de Passport, actualitzacions fàcils de programari i una experiència zen de cartera Bitcoin."),
        "prime_info_color": m12,
        "prime_info_firmware": m13,
        "prime_info_serialNumber": m14,
        "privacySetting_nodeConnected":
            MessageLookupByLibrary.simpleMessage("Node Connectat"),
        "privacy_applicationLock_title":
            MessageLookupByLibrary.simpleMessage("Bloqueig de l\'aplicació"),
        "privacy_applicationLock_unlock": MessageLookupByLibrary.simpleMessage(
            "Desbloqueja amb biometria o PIN"),
        "privacy_explorer_configure": MessageLookupByLibrary.simpleMessage(
            "Improve your privacy by connecting to your own block explorer. Tap learn more above."),
        "privacy_explorer_explorerAddress":
            MessageLookupByLibrary.simpleMessage("Enter your explorer address"),
        "privacy_explorer_explorerType_personal":
            MessageLookupByLibrary.simpleMessage("Personal Block Explorer"),
        "privacy_explorer_title":
            MessageLookupByLibrary.simpleMessage("Block Explorer"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
            "Millora la teva privacitat executant el teu propi node. Toca per obtenir més informació."),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage("Alçada del bloc:"),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage(
                "Connectat al servidor Esplora"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
                "No s\'ha pogut connectar al servidor Esplora."),
        "privacy_node_connectedTo":
            MessageLookupByLibrary.simpleMessage("Connectat a"),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage(
                "No s\'ha pogut conectar al node."),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
                "Fins i tot amb \"Privacitat millorada\" activa, Envoy no pot evitar interferències de dispositius compromesos a la vostra xarxa local."),
        "privacy_node_nodeAddress": MessageLookupByLibrary.simpleMessage(
            "Introduïu la direcció del vostre node"),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage("Foundation (per defecte)"),
        "privacy_node_nodeType_personal":
            MessageLookupByLibrary.simpleMessage("Node Personal"),
        "privacy_node_nodeType_publicServers":
            MessageLookupByLibrary.simpleMessage("Servidors públics"),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Node"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Millor\nRendiment"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage("Privacitat\nMillorada"),
        "privacy_privacyMode_title":
            MessageLookupByLibrary.simpleMessage("Mode de Privacitat"),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
                "La connexió d\'Envoy serà fiable amb Tor activat [[APAGAT]]. Suggerit per a nous usuaris."),
        "privacy_privacyMode_torSuggestionOn": MessageLookupByLibrary.simpleMessage(
            "Tor s\'activarà [[ACTIVAT]] per millorar la privacitat. És possible que la connexió d\'Envoy no sigui eficient."),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Afegeix Node"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Editar Node"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El teu Node està connectat a través de Clearnet."),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
                "No hem pogut connectar el teu node"),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Connecta\'t"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("Connectant El Vostre Node"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
                "El vostre node està connectat mitjançant Tor."),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage("Tria La Teva Privacitat"),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Com voleu que Envoy es connecti a Internet?"),
        "qrTooBig_warning_subheading": MessageLookupByLibrary.simpleMessage(
            "The scanned QR code contains a large amount of data and could make Envoy unstable. Are you sure you want to continue?"),
        "ramp_note": MessageLookupByLibrary.simpleMessage("Compra Ramp"),
        "ramp_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Compra Ramp Pendent"),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage(
                "Utilitzeu una Adreça Taproot"),
        "receive_mobileWallet_multiplePassportContent":
            MessageLookupByLibrary.simpleMessage(
                "Funds sent to this address can be spent using only your phone. To secure funds offline, choose a Passport account here."),
        "receive_mobileWallet_singlePassportContent":
            MessageLookupByLibrary.simpleMessage(
                "Funds sent to this address can be spent using only your phone. To secure funds offline with Passport  tap here."),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("REBRE"),
        "receive_qr_copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "receive_qr_rescanAccount":
            MessageLookupByLibrary.simpleMessage("Rescan Account"),
        "receive_qr_share": MessageLookupByLibrary.simpleMessage("Share"),
        "receive_qr_signMessage":
            MessageLookupByLibrary.simpleMessage("Sign Message"),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("Pendent de confirmació"),
        "receive_tx_list_change":
            MessageLookupByLibrary.simpleMessage("Change"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Rebre"),
        "receive_tx_list_scan": MessageLookupByLibrary.simpleMessage("Scan"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "receive_tx_list_transfer":
            MessageLookupByLibrary.simpleMessage("Transfer"),
        "receive_verifyModalCore_content": m15,
        "receive_verifyModalPrime_content": m16,
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Inicia sessió a Google i restaura les teves dades de la teva còpia de seguretat"),
        "recovery_scenario_heading":
            MessageLookupByLibrary.simpleMessage("Com es Recupera?"),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
            "Instal·la Envoy i toca \"Configura la Cartera d\'Envoy\""),
        "recovery_scenario_ios_instruction1": MessageLookupByLibrary.simpleMessage(
            "Inicia sessió a iCloud i restaura la teva còpia de seguretat d\'iCloud"),
        "recovery_scenario_ios_instruction3": MessageLookupByLibrary.simpleMessage(
            "Envoy restaurarà automàticament la vostra Còpia de Seguretat Màgica"),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
            "Per recuperar la teva cartera d\'Envoy, segueix aquestes instruccions senzilles."),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
                "La tarifa escollida només es pot aconseguir afegint més monedes. Envoy ho fa automàticament i mai inclourà cap moneda bloquejada. "),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage("Aumenta la transacció"),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
            "No s\'ha pogut acelerar la teva transacció"),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage(
                "Revisa la selecció de monedes"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
                "La teva transacció s\'ha acelerat"),
        "replaceByFee_boost_tx_boostFee":
            MessageLookupByLibrary.simpleMessage("Tarifa d\'Augment"),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
            "La vostra transacció està a punt per ser impulsada"),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage("Cap"),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La tarifa de xarxa per cancel·lar aquesta transacció significa que no s\'enviaran fons a la cartera.\n\nEstàs segur que vols cancel·lar?"),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage(
                "S\'està cancel·lant la transacció"),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No s\'ha pogut cancel·lar la teva transacció"),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Quota de Cancel·lació"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage(
                "Continueu amb la Cancel·lació"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Import de Recepció"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Substituïu la transacció no confirmada per una que contingui una tarifa més alta i que torni els fons a la vostra cartera."),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "La teva transacció s\'ha cancel·lat"),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aquest és un intent de cancel·lació. Hi ha una petita possibilitat que la teva transacció original sigui confirmada abans d\'aquest intent de cancel·lació."),
        "replaceByFee_coindetails_overlayNotice":
            MessageLookupByLibrary.simpleMessage(
                "Boost and Cancel functions will be available after transaction has finished being broadcast."),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Aumenta"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Augmenta la Transacció"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Augmenteu la tarifa adjunta a la vostra transacció per accelerar el temps de confirmació."),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Necessari per Augmentar"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transaccions Eliminades"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Les compres incompletes amb els identificadors de Ramp següents s\'han eliminat de l\'activitat al cap de 5 dies."),
        "replaceByFee_modal_deletedInactiveTX_stripe_heading":
            MessageLookupByLibrary.simpleMessage("Transactions Removed"),
        "replaceByFee_modal_deletedInactiveTX_stripe_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Incomplete purchases with the following Stripe IDs were removed from activity after 5 days."),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage("Nova Tarifa de Transacció "),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Per augmentar la vostra transacció original, esteu a punt de pagar una nova tarifa de:"),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
                "Això substituirà la tarifa original de:"),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
                "Les compres incompletes se suprimiran automàticament al cap de 5 dies"),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La tarifa escollida només es pot aconseguir afegint més monedes. L\'enviat ho fa automàticament i mai no inclourà cap moneda bloquejada. \n\nAquesta selecció es pot revisar o editar a la pantalla següent."),
        "rescanAccount_pullToSync_pullToSync":
            MessageLookupByLibrary.simpleMessage("Pull to sync"),
        "rescanAccount_rescanning_rescanningAccount":
            MessageLookupByLibrary.simpleMessage(
                "Rescanning your account. Please do not close Envoy."),
        "rescanAccount_sizeModal_1000Addresses":
            MessageLookupByLibrary.simpleMessage("1000 Addresses (~10 min)"),
        "rescanAccount_sizeModal_300Addresses":
            MessageLookupByLibrary.simpleMessage("300 Addresses (~3 min)"),
        "rescanAccount_sizeModal_500Addresses":
            MessageLookupByLibrary.simpleMessage("500 Addresses (~5 min)"),
        "rescanAccount_sizeModal_content": MessageLookupByLibrary.simpleMessage(
            "100 addresses were previously scanned. If missing funds, try a higher scan value."),
        "rescanAccount_sizeModal_header":
            MessageLookupByLibrary.simpleMessage("Rescan Account"),
        "scv_cameraModalUnexpectedQrFormat_content":
            MessageLookupByLibrary.simpleMessage(
                "Ensure you are scanning a security check QR code from Passport."),
        "scv_cameraModalUnexpectedQrFormat_header":
            MessageLookupByLibrary.simpleMessage("Unexpected QR Format"),
        "scv_checkingDeviceSecurity": MessageLookupByLibrary.simpleMessage(
            "Comprovació de la Seguretat del Dispositiu"),
        "send_QrReview_viewDetails":
            MessageLookupByLibrary.simpleMessage("View Details"),
        "send_QrScan_saveToFile":
            MessageLookupByLibrary.simpleMessage("Save to File"),
        "send_QuantumReview_transactionTransferred":
            MessageLookupByLibrary.simpleMessage("Transaction transfered"),
        "send_build_amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "send_build_header":
            MessageLookupByLibrary.simpleMessage("Check Transaction Details"),
        "send_build_subheader": MessageLookupByLibrary.simpleMessage(
            "Confirm the transaction details are correct before continuing."),
        "send_build_viewEditDetails":
            MessageLookupByLibrary.simpleMessage("View and Edit Details"),
        "send_editTxDetailsSubsatModal_content":
            MessageLookupByLibrary.simpleMessage(
                "Check that the connected node can facilitate fee rates below 1 sat/vb before continuing."),
        "send_editTxDetailsSubsatModal_header":
            MessageLookupByLibrary.simpleMessage("Sub 1 sat/vb Fee Rates"),
        "send_editTxDetails_addNoteExample":
            MessageLookupByLibrary.simpleMessage("i.e. Bought P2P Bitcoin"),
        "send_editTxDetails_applyChangeTag":
            MessageLookupByLibrary.simpleMessage("Apply Change Tag"),
        "send_editTxDetails_applyChanges":
            MessageLookupByLibrary.simpleMessage("Apply Changes"),
        "send_editTxDetails_changeAddress":
            MessageLookupByLibrary.simpleMessage("Change Address"),
        "send_editTxDetails_changeAmount":
            MessageLookupByLibrary.simpleMessage("Change Amount"),
        "send_editTxDetails_feeNoEstimatePossible":
            MessageLookupByLibrary.simpleMessage("No estimate possible"),
        "send_editTxDetails_spendingFromAccount":
            MessageLookupByLibrary.simpleMessage("Spending from Account"),
        "send_editTxDetails_spentFrom":
            MessageLookupByLibrary.simpleMessage("Spent from"),
        "send_editTxDetails_tagDetails":
            MessageLookupByLibrary.simpleMessage("Tag Details"),
        "send_keyboard_address_confirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "send_keyboard_address_loading":
            MessageLookupByLibrary.simpleMessage("Carregant…"),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage(
                "Introdueix una adreça vàlida"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Fons insuficients"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage("Quantitat massa baixa"),
        "send_keyboard_enterAddress":
            MessageLookupByLibrary.simpleMessage("Enter address"),
        "send_keyboard_send_max":
            MessageLookupByLibrary.simpleMessage("Enviar Màxim"),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("Per a:"),
        "send_qrReview_scanSignedTransaction":
            MessageLookupByLibrary.simpleMessage("Scan signed Transaction"),
        "send_qrReview_viewDetails":
            MessageLookupByLibrary.simpleMessage("View Details"),
        "send_qrScan_header":
            MessageLookupByLibrary.simpleMessage("Scan this QR with Passport"),
        "send_qrScan_scanQrWithPassportFirst":
            MessageLookupByLibrary.simpleMessage("Scan QR with Passport first"),
        "send_qrScan_subheader": MessageLookupByLibrary.simpleMessage(
            "It contains the transaction for you to sign on your Passport."),
        "send_qrScan_verifyOnPassport":
            MessageLookupByLibrary.simpleMessage("Verify on Passport"),
        "send_qrSend_header": MessageLookupByLibrary.simpleMessage(
            "Transaction ready to be sent"),
        "send_qrSend_subheader": MessageLookupByLibrary.simpleMessage(
            "Envoy will send the transaction to the Bitcoin network."),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
            "Escaneja el QR amb el teu Passport"),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
            "Conté la transacció per signar el vostre Passport."),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
            "Ara podeu escanejar el codi QR que es mostra al vostre Passport amb la càmera del telèfon."),
        "send_quantumBuildOutOfRange_makeSureInRangeUnlocked":
            MessageLookupByLibrary.simpleMessage(
                "To continue make sure your Passport Prime is powered on, in range and unlocked."),
        "send_quantumBuildOutOfRange_waitingForPassport":
            MessageLookupByLibrary.simpleMessage("Waiting for Passport"),
        "send_quantumBuild_signWithPassport":
            MessageLookupByLibrary.simpleMessage("Sign with Passport"),
        "send_quantumReview_connectedToPassport":
            MessageLookupByLibrary.simpleMessage("Connected to Passport"),
        "send_quantumReview_transactionTransferred":
            MessageLookupByLibrary.simpleMessage("Transaction transferred"),
        "send_quantumReview_transferringTransaction":
            MessageLookupByLibrary.simpleMessage("Transferring Transaction "),
        "send_quantumReview_waitForSigning":
            MessageLookupByLibrary.simpleMessage("Wait for Signing "),
        "send_quantumReview_waitingForSigning":
            MessageLookupByLibrary.simpleMessage("Waiting for Signing "),
        "send_quantumSend_transactionready":
            MessageLookupByLibrary.simpleMessage("Transaction ready"),
        "send_reviewScreen_sendMaxWarning": MessageLookupByLibrary.simpleMessage(
            "Enviar el Màxim:\nLes tarifes es dedueixen de l\'import enviat."),
        "send_review_header":
            MessageLookupByLibrary.simpleMessage("Verify Transaction Details"),
        "send_review_subheader": MessageLookupByLibrary.simpleMessage(
            "Check these details match those being displayed by your Passport."),
        "settings_advanced":
            MessageLookupByLibrary.simpleMessage("Opcions Avançades"),
        "settings_advancedModalReceiveSegwit_content":
            MessageLookupByLibrary.simpleMessage(
                "With this toggle off, Native Segwit addresses will be generated when you tap receive. This is the default address type used by most Bitcoin wallets."),
        "settings_advancedModalReceiveSegwit_title":
            MessageLookupByLibrary.simpleMessage("Receive to Segwit"),
        "settings_advancedModalReceiveTaproot_content":
            MessageLookupByLibrary.simpleMessage(
                "With this toggle on, Taproot addresses will be generated when you tap receive. Ensure entities sending you Bitcoin are Taproot compatible before proceeding."),
        "settings_advancedModalReceiveTaproot_title":
            MessageLookupByLibrary.simpleMessage("Receive to Taproot"),
        "settings_advanced_enableBuyRamp":
            MessageLookupByLibrary.simpleMessage("Compra a Envoy"),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Obteniu més informació sobre Signet [[aquí]]."),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si activeu Signet, s\'afegeix una versió Signet de l\'Envoy Wallet. Aquesta funció és utilitzada principalment per desenvolupadors o provadors i té un valor zero."),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage("Apreneu a fer-ho [[aqui]] ."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si activeu Testnet, s\'afegeix una versió de Testnet4 del vostre Envoy Wallet i us permet connectar comptes de Testnet des del vostre Passport."),
        "settings_advanced_receiveToTaproot":
            MessageLookupByLibrary.simpleMessage("Receive to Taproot"),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activa"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Taproot és una funció avançada i el suport de cartera encara és limitat.\n\nProcediu amb precaució."),
        "settings_advanced_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "settings_amount":
            MessageLookupByLibrary.simpleMessage("Veure Quantitat en Sats"),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Divisa"),
        "settings_show_fiat":
            MessageLookupByLibrary.simpleMessage("Mostra els valors en Fiat"),
        "settings_viewEnvoyLogs": MessageLookupByLibrary.simpleMessage(
            "Veure els registres d\'Envoy"),
        "signMessage_mainSignedQr_scanQr":
            MessageLookupByLibrary.simpleMessage("Scan the QR"),
        "signMessage_mainSignedQr_scanQrSubheader":
            MessageLookupByLibrary.simpleMessage(
                "It contains the signed message."),
        "signMessage_mainSigned_copySignature":
            MessageLookupByLibrary.simpleMessage("Copy Signature"),
        "signMessage_mainSigned_header":
            MessageLookupByLibrary.simpleMessage("Message Signed"),
        "signMessage_mainSigned_saveSignatureToFile":
            MessageLookupByLibrary.simpleMessage("Save Signature to File"),
        "signMessage_main_addressDoesNotBelong":
            MessageLookupByLibrary.simpleMessage(
                "Address does not belong to this account.\nPlease enter another address."),
        "signMessage_main_enterPasteMessage":
            MessageLookupByLibrary.simpleMessage("Enter or paste the message"),
        "signMessage_main_messageHeader":
            MessageLookupByLibrary.simpleMessage("Message"),
        "signMessage_main_signatureHeader":
            MessageLookupByLibrary.simpleMessage("Signature"),
        "signMessage_qr_header":
            MessageLookupByLibrary.simpleMessage("Scan the QR with Passport"),
        "signMessage_qr_saveToFile":
            MessageLookupByLibrary.simpleMessage("Save to File"),
        "signMessage_qr_scannedSignedByPassport":
            MessageLookupByLibrary.simpleMessage(
                "Scanned and signed by Passport"),
        "signMessage_qr_subheader": MessageLookupByLibrary.simpleMessage(
            "It contains the message for your Passport to sign."),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("No gràcies"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Les notes de transacció poden ser útils per fer despeses futures."),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No s\'ha pogut enviar la teva transacció"),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si us plau, comprovi la connexió i provi de nou."),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "La teva transacció s\'ha enviat correctament"),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Revisa els detalls fent clic a la transacció des de la pantalla de detalls del compte."),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("Enviant transacció"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Això pot trigar uns quants segons"),
        "stripe_note": MessageLookupByLibrary.simpleMessage("Stripe Purchase"),
        "stripe_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Pending Stripe Purchase"),
        "tagDetails_EditTagName": MessageLookupByLibrary.simpleMessage(
            "Editar el nom de l\'etiqueta"),
        "tagSelection_example1":
            MessageLookupByLibrary.simpleMessage("Despeses"),
        "tagSelection_example2":
            MessageLookupByLibrary.simpleMessage("Personal"),
        "tagSelection_example3":
            MessageLookupByLibrary.simpleMessage("Estalvis"),
        "tagSelection_example4":
            MessageLookupByLibrary.simpleMessage("Donacions"),
        "tagSelection_example5":
            MessageLookupByLibrary.simpleMessage("Viatges"),
        "tagged_coin_details_inputs_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Descarta els Canvis"),
        "tagged_coin_details_menu_cta1":
            MessageLookupByLibrary.simpleMessage("EDITA EL NOM DE L\'ETIQUETA"),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
                "No hi ha monedes assignades a aquesta etiqueta."),
        "tagged_tagDetails_sheet_cta1":
            MessageLookupByLibrary.simpleMessage("Envia la Selecció"),
        "tagged_tagDetails_sheet_cta2":
            MessageLookupByLibrary.simpleMessage("Etiqueta Seleccionada"),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage(
                "Torneu a Etiquetar Seleccionat"),
        "tagged_tagDetails_sheet_transferSelected":
            MessageLookupByLibrary.simpleMessage("Transfer Selected"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Manteniu premut per arrossegar i reordenar els vostres comptes."),
        "taproot_passport_dialog_heading":
            MessageLookupByLibrary.simpleMessage("Taproot a Passport"),
        "taproot_passport_dialog_later":
            MessageLookupByLibrary.simpleMessage("Fes-ho Més Tard"),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage("Torneu a connectar Passport"),
        "taproot_passport_dialog_subheading": MessageLookupByLibrary.simpleMessage(
            "Per habilitar un compte de Passport Taproot, assegureu-vos que esteu executant el firmware 2.3.0 o posterior i torneu a connectar el vostre Passport."),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
            "No es pot accedir als servidors de Foundation"),
        "toast_newEnvoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Nova actualització d\'Envoy disponible"),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage("Reintentar Tor"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage("Desactiva Temporalment Tor"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
            "És possible que experimenteu un rendiment de l\'aplicació degradat fins que Envoy pugui restablir una connexió amb Tor. La desactivació de Tor establirà una connexió directa amb el servidor Envoy, però inclou privacitat [[tradeoffs]] ."),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
            "Problema per establir la connectivitat amb Tor"),
        "transfer_fromTo_transferFrom":
            MessageLookupByLibrary.simpleMessage("Transfer from"),
        "transfer_fromTo_transferTo":
            MessageLookupByLibrary.simpleMessage("Transfer to"),
        "video_connectingToTorNetwork": MessageLookupByLibrary.simpleMessage(
            "Connecting to the Tor Network"),
        "video_loadingTorText": MessageLookupByLibrary.simpleMessage(
            "Envoy is loading your video over the Tor Network"),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy fa una còpia de seguretat automàtica i segura de la llavor de la cartera amb [[Còpia de Seguretat Automàtica d\'Android]]. La vostra llavor sempre està xifrada d\'extrem a extrem i mai és visible per a Google."),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy fa una còpia de seguretat automàtica i segura de la llavor de la cartera a [[Clauer iCloud.]] La teva llavor sempre està xifrada d\'extrem a extrem i mai no és visible per a Apple."),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Les dades de la vostra cartera, incloses etiquetes, notes, comptes i configuració, es fa una còpia de seguretat automàtica als servidors de Foundation.\n\nAquesta còpia de seguretat es xifra primer amb la clau privada de la vostra cartera, assegurant-vos que Foundation mai no pugui accedir a les vostres dades."),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Per recuperar la cartera, només cal que inicieu sessió al vostre compte de Google. Envoy baixarà automàticament les dades de còpia de seguretat i la clau privada de la cartera.\n\nUs recomanem que protegiu el vostre compte de Google amb una contrasenya segura i 2FA."),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Per recuperar la cartera, només cal que inicieu sessió al vostre compte d\'iCloud. Envoy baixarà automàticament les dades de còpia de seguretat i la clau privada de la cartera.\n\nUs recomanem que protegiu el vostre compte d\'iCloud amb una contrasenya segura i 2FA."),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage(
                "Com Es Protegeixen Les Vostres Dades"),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si preferiu desactivar Magic Backups i, en canvi, protegir manualment la clau privada i les dades de la vostra cartera, cap problema!\n\nNomés cal que torneu a la pantalla de configuració i trieu Configura Manualment La Clau Privada."),
        "wallet_security_modal_HowToRecoverYourWallet":
            MessageLookupByLibrary.simpleMessage("How to Recover Your Wallet"),
        "wallet_security_modal_HowYourDatatIsSecured":
            MessageLookupByLibrary.simpleMessage("How Your Data is Secured"),
        "wallet_security_modal_HowYourSeedIsSecured":
            MessageLookupByLibrary.simpleMessage("How Your Seed is Secured"),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Com es Protegeix la Teva Cartera"),
        "wallet_security_modal_WantToOptOut":
            MessageLookupByLibrary.simpleMessage("Want to Opt Out?"),
        "wallet_security_modal__heading":
            MessageLookupByLibrary.simpleMessage("Consell de Seguretat"),
        "wallet_security_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy emmagatzema més de la quantitat recomanada de Bitcoin per a una cartera mòbil connectada a Internet.\n\nPer a un emmagatzematge ultra segur i fora de línia, Foundation suggereix la cartera de  Passport."),
        "wallet_setup_success_heading":
            MessageLookupByLibrary.simpleMessage("La Teva Cartera Està A Punt"),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy està configurat i preparat per al vostre Bitcoin!"),
        "welcome_screen_ctA1": MessageLookupByLibrary.simpleMessage(
            "Configura la Cartera de l\'Envoy"),
        "welcome_screen_cta2":
            MessageLookupByLibrary.simpleMessage("Gestionar Passport"),
        "welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Benvingut a Envoy")
      };
}
