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

  static String m0(MB_name) => "Còpia Màgica Passport Prime\n”${MB_name}”";

  static String m1(period) =>
      "Aquest val va caducar el ${period}.\n\n\nContacta amb l\'emissor si tens cap pregunta sobre el val.";

  static String m2(AccountName) =>
      "Ves a ${AccountName} a Passport, selecciona ‘Account Tools’ > ‘Verify Address’ i escaneja el codi QR de sota.";

  static String m3(number) => "Comissió: ${number}% de l\'import total";

  static String m4(tagName) =>
      "La teva etiqueta ${tagName} està buida. Vols eliminar-la?";

  static String m5(number) => "ADREÇA #${number}";

  static String m6(searchSpace) =>
      "Adreça no trobada en les primeres ${searchSpace} adreces.";

  static String m7(time_remaining) => "Queden ${time_remaining}";

  static String m8(current_keyOS_version) =>
      "El teu Passport Prime executa actualment ${current_keyOS_version}.\n\nActualitza ara per obtenir les últimes correccions i funcions.";

  static String m9(est_upd_time) => "Temps Estimat: ${est_upd_time}";

  static String m10(new_keyOS_version) => "Novetats de ${new_keyOS_version}";

  static String m11(new_keyOS_version) =>
      "Passport Prime s\'ha actualitzat correctament a\n${new_keyOS_version}";

  static String m12(amount, total_amount) =>
      "Migració en curs.\nNo tanquis Envoy.\n\n${amount} de ${total_amount} processats.";

  static String m13(passport_color) => "Color: ${passport_color}";

  static String m14(firmware_version) => "Firmware: ${firmware_version}";

  static String m15(serial_number) => "Número de Sèrie: ${serial_number}";

  static String m16(AccountName) =>
      "Ves a ${AccountName} a Passport, tria ‘Account Tools’ i després ‘Verify Address’, i escaneja el codi QR de sota.";

  static String m17(AccountName) =>
      "Toca el compte ${AccountName} a Passport, tria ‘Verify Address’ i escaneja el codi QR de sota.";

  static String m18(accoutname) => "Reescaneig fallit per a ${accoutname} ";

  static String m19(accoutname) => "Reescaneig correcte per a ${accoutname} ";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage(
            "https://blockstream.info/api/"),
        "about_appVersion": MessageLookupByLibrary.simpleMessage(
          "Versió de l\'Aplicació",
        ),
        "about_openSourceLicences": MessageLookupByLibrary.simpleMessage(
          "Llicències de Codi Obert",
        ),
        "about_privacyPolicy": MessageLookupByLibrary.simpleMessage(
          "Política de Privacitat",
        ),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostra"),
        "about_termsOfUse": MessageLookupByLibrary.simpleMessage(
          "Condicions d\'Ús",
        ),
        "accountDetails_descriptor_legacy":
            MessageLookupByLibrary.simpleMessage(
          "Legacy",
        ),
        "accountDetails_descriptor_segwit":
            MessageLookupByLibrary.simpleMessage(
          "Segwit",
        ),
        "accountDetails_descriptor_taproot":
            MessageLookupByLibrary.simpleMessage(
          "Taproot",
        ),
        "accountDetails_descriptor_wrappedSegwit":
            MessageLookupByLibrary.simpleMessage("Segwit Encapsulat"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage(
          "Ordena",
        ),
        "account_details_untagged_card": MessageLookupByLibrary.simpleMessage(
          "Sense etiquetar",
        ),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
          "Els filtres aplicats amaguen totes les transaccions.\nActualitza o reinicia els filtres per veure les transaccions.",
        ),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
          "No hi ha transaccions en aquest compte.\nRep la teva primera transacció a continuació.",
        ),
        "account_type_label_taproot": MessageLookupByLibrary.simpleMessage(
          "Taproot",
        ),
        "account_type_sublabel_testnet": MessageLookupByLibrary.simpleMessage(
          "Testnet",
        ),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
          "Crea una cartera mòbil amb Còpies Màgiques.",
        ),
        "accounts_empty_text_learn_more": MessageLookupByLibrary.simpleMessage(
          "Comença",
        ),
        "accounts_forceUpdate_cta": MessageLookupByLibrary.simpleMessage(
          "Actualitza Envoy",
        ),
        "accounts_forceUpdate_heading": MessageLookupByLibrary.simpleMessage(
          "Es Requereix l\'Actualització d\'Envoy",
        ),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
          "Hi ha disponible una nova actualització d\'Envoy que conté actualitzacions i correccions importants. \n\nPer continuar utilitzant Envoy, actualitza\'l a la versió més recent. Gràcies.",
        ),
        "accounts_loading_loadingAccount": MessageLookupByLibrary.simpleMessage(
          "Carregant Compte…",
        ),
        "accounts_screen_walletType_Envoy":
            MessageLookupByLibrary.simpleMessage(
          "Envoy",
        ),
        "accounts_screen_walletType_Passport":
            MessageLookupByLibrary.simpleMessage(
          "Passport",
        ),
        "accounts_screen_walletType_defaultName":
            MessageLookupByLibrary.simpleMessage("Cartera Mòbil"),
        "accounts_switchDefault": MessageLookupByLibrary.simpleMessage(
          "Per defecte",
        ),
        "accounts_switchPassphrase": MessageLookupByLibrary.simpleMessage(
          "Contrasenya",
        ),
        "accounts_toastNewUpdate_content": MessageLookupByLibrary.simpleMessage(
          "Nova Versió - Mira les novetats.",
        ),
        "accounts_toast_newUpdate": MessageLookupByLibrary.simpleMessage(
          "Nova Versió - Mira les novetats.",
        ),
        "accounts_toast_paymentCopied": MessageLookupByLibrary.simpleMessage(
          "ID de pagament copiat al porta-retalls.",
        ),
        "accounts_toast_txidCopied": MessageLookupByLibrary.simpleMessage(
          "ID de transacció copiat al porta-retalls.",
        ),
        "accounts_upgradeBdkSignetModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy ara utilitza Global Signet en lloc de Mutinynet. Els teus comptes Signet anteriors s\'han eliminat.\n\nPer començar a utilitzar Global Signet, ves a Configuració i activa l\'interruptor Signet.",
        ),
        "accounts_upgradeBdkSignetModal_header":
            MessageLookupByLibrary.simpleMessage("Global Signet"),
        "accounts_upgradeBdkTestnetModal_content":
            MessageLookupByLibrary.simpleMessage(
          "‘Testnet3’ ha quedat obsolet i Envoy ara utilitza ‘testnet4’. Els teus comptes testnet3 anteriors s\'han eliminat.\n\nPer començar a utilitzar testnet4, ves a Configuració i activa l\'interruptor Testnet.",
        ),
        "accounts_upgradeBdkTestnetModal_header":
            MessageLookupByLibrary.simpleMessage("Presentem testnet4"),
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Augmentat"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("Cancel·lant"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
          "No hi ha cap activitat per mostrar.",
        ),
        "activity_envoyUpdate": MessageLookupByLibrary.simpleMessage(
          "S\'Ha Actualitzat l\'Aplicació Envoy",
        ),
        "activity_envoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
          "Envoy es pot actualitzar",
        ),
        "activity_firmwareUpdate": MessageLookupByLibrary.simpleMessage(
          "Actualització del firmware disponible",
        ),
        "activity_incomingPurchase": MessageLookupByLibrary.simpleMessage(
          "Compra Entrant",
        ),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Avui"),
        "activity_passportUpdate": MessageLookupByLibrary.simpleMessage(
          "Passport es pot actualitzar",
        ),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pendent"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Rebut"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Enviat"),
        "activity_sent_boosted": MessageLookupByLibrary.simpleMessage(
          "Enviat (Augmentat)",
        ),
        "activity_sent_canceled": MessageLookupByLibrary.simpleMessage(
          "Cancel·lat",
        ),
        "add_note_modal_heading": MessageLookupByLibrary.simpleMessage(
          "Afegeix una Nota",
        ),
        "add_note_modal_ie_text_field": MessageLookupByLibrary.simpleMessage(
          "He comprat una cartera Passport",
        ),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "Enregistra alguns detalls d\'aquesta transacció.",
        ),
        "android_backup_info_heading": MessageLookupByLibrary.simpleMessage(
          "Android Fa una Còpia de Seguretat Cada 24 h",
        ),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
          "Android fa una còpia de seguretat automàtica de les teves dades d\'Envoy cada 24 hores.\n\nPer assegurar-te que la teva primera Còpia de Seguretat Màgica s\'hagi completat, et recomanem que facis una còpia de seguretat manual a la [[Configuració]] del teu dispositiu.",
        ),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
          "Envoy és una cartera Bitcoin senzilla amb potents funcions de gestió de comptes i privacitat.\n\nUtilitza Envoy amb la teva cartera física Passport per configurar-la, actualitzar el firmware i molt més.\n\nEnvoy ofereix les funcions següents:\n\n1. Còpies de Seguretat Màgiques. Comença amb l\'autocustòdia en només 60 segons amb còpies xifrades automàtiques. Paraules de clau opcionals.\n\n2. Gestiona la teva Cartera Mòbil i els comptes de la cartera física Passport a la mateixa app.\n\n3. Envia i rep Bitcoin amb una interfície clara i tranquil·la.\n\n4. Connecta la teva cartera física Passport per configurar-la, actualitzar el firmware i veure vídeos d\'ajuda. Utilitza Envoy com a cartera de programari connectada al teu Passport.\n\n5. Totalment de codi obert i respectuosa amb la privacitat. Envoy es pot connectar a Internet amb Tor per maximitzar la privacitat.\n\n6. Opcionalment, connecta el teu propi node Bitcoin.",
        ),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Val Azteco pendent"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("No es Pot Connectar"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot connectar amb Azteco.\n\nPosa\'t en contacte amb support@azte.co o torna-ho a provar més tard.",
        ),
        "azteco_note": MessageLookupByLibrary.simpleMessage("Val Azteco"),
        "azteco_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Val Azteco Pendent",
        ),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage(
          "CODI DEL VAL",
        ),
        "azteco_redeem_modal_amount": MessageLookupByLibrary.simpleMessage(
          "Import",
        ),
        "azteco_redeem_modal_cta1": MessageLookupByLibrary.simpleMessage(
          "Bescanvia",
        ),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "No es Pot Bescanviar",
        ),
        "azteco_redeem_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Confirma que el teu val encara és vàlid.\n\nPosa\'t en contacte amb support@azte.co amb qualsevol pregunta relacionada amb el val.",
        ),
        "azteco_redeem_modal_heading": MessageLookupByLibrary.simpleMessage(
          "Bescanviar el Val?",
        ),
        "azteco_redeem_modal_saleDate": MessageLookupByLibrary.simpleMessage(
          "Data de Venda",
        ),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "Val Bescanviat",
        ),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aviat apareixerà una transacció entrant al teu compte.",
        ),
        "backup_toast_envoyBackupComplete":
            MessageLookupByLibrary.simpleMessage(
          "Còpia d\'Envoy completada.",
        ),
        "backups_advancedBackups": MessageLookupByLibrary.simpleMessage(
          "Còpies Avançades",
        ),
        "backups_downloadBIP329BackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Exporta Etiquetes (BIP-329)",
        ),
        "backups_downloadSettingsDataBackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Descarrega Còpia de Configuració i Dades",
        ),
        "backups_downloadSettingsMetadataBackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Descarrega Còpia de Configuració i Metadades",
        ),
        "backups_erase_mobile_wallet": MessageLookupByLibrary.simpleMessage(
          "Esborra Cartera Mòbil",
        ),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage(
          "Esborra Cartera Mòbil i Còpies",
        ),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estàs a punt d\'eliminar permanentment la teva cartera Envoy.\n\nSi uses Còpies Màgiques, la clau d\'Envoy també s\'eliminarà de la Còpia de Seguretat Automàtica d\'Android. ",
        ),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estàs a punt d\'eliminar permanentment la teva cartera Envoy.\n\nSi fas servir Còpies de Seguretat Màgiques, la clau d\'Envoy també s\'eliminarà del Clauer d\'iCloud. ",
        ),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Els comptes Passport connectats no se suprimiran en aquest procés.\n\nAbans de suprimir la cartera Envoy, assegurem-nos que la clau i el fitxer de còpia estiguin desats.\n",
        ),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Mostra la Clau"),
        "backups_erase_wallets_and_backups_show_seed_heading":
            MessageLookupByLibrary.simpleMessage("Mantén la Teva Clau Privada"),
        "backups_erase_wallets_and_backups_show_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Mantén privades les paraules de clau. Qui accedeixi a aquesta clau pot gastar el teu Bitcoin!",
        ),
        "backups_magicToManualErrorModal_header":
            MessageLookupByLibrary.simpleMessage("No es Pot Continuar"),
        "backups_magicToManualErrorModal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "La Còpia de Seguretat Màgica d\'Envoy no es pot desactivar mentre hi hagi una Còpia de Seguretat Màgica de Passport Prime activa.\n\nPer continuar, desactiva primer la Còpia de Seguretat Màgica de Passport Prime al dispositiu.",
        ),
        "backups_manualToMagicrModal_header":
            MessageLookupByLibrary.simpleMessage(
          "Activant Còpies Màgiques",
        ),
        "backups_manualToMagicrModal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "Això activarà una Còpia de Seguretat Màgica de la teva cartera Envoy. La clau d\'Envoy es xifrarà i es copiarà al teu compte d\'Apple o Google. Les dades d\'Envoy es xifraran i s\'enviaran al servidor de Foundation.",
        ),
        "backups_primeMagicBackups": m0,
        "backups_primeMasterKeyBackup": MessageLookupByLibrary.simpleMessage(
          "Còpia de Clau Mestra (1 de 3 parts)",
        ),
        "backups_settingsAndData": MessageLookupByLibrary.simpleMessage(
          "Configuració i Dades",
        ),
        "backups_settingsAndMetadata": MessageLookupByLibrary.simpleMessage(
          "Configuració i Metadades",
        ),
        "backups_toggle_envoy_magic_backups":
            MessageLookupByLibrary.simpleMessage(
          "Còpies Màgiques Envoy",
        ),
        "backups_toggle_envoy_mobile_wallet_key":
            MessageLookupByLibrary.simpleMessage("Clau de Cartera Mòbil"),
        "backups_viewMobileWalletSeed": MessageLookupByLibrary.simpleMessage(
          "Veure Clau de Cartera Mòbil",
        ),
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Comptes"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Activitat"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositius"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprèn"),
        "bottomNav_privacy": MessageLookupByLibrary.simpleMessage("Privacitat"),
        "bottomNav_transfer": MessageLookupByLibrary.simpleMessage("Traspàs"),
        "btcpay_connection_modal_expired_subheading": m1,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Val Caducat"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no es pot connectar amb la botiga BTCPay de l\'emissor.\n\nContacta amb l\'emissor o torna-ho a provar més tard.",
        ),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
          "El val escanejat no s\'ha creat amb suport onchain.\n\nContacta amb el creador del val.",
        ),
        "btcpay_note": MessageLookupByLibrary.simpleMessage("Val BTCPay"),
        "btcpay_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Val BTCPay Pendent",
        ),
        "btcpay_redeem_modal_description": MessageLookupByLibrary.simpleMessage(
          "Descripció:",
        ),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nom:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Xarxa Incorrecta"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquest és un val on-chain. No es pot bescanviar en un compte de Testnet o Signet.",
        ),
        "btn_firmware_version":
            MessageLookupByLibrary.simpleMessage("Firmware"),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage("Tria un altre compte"),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
          "El teu Bitcoin s\'enviarà a aquesta adreça:",
        ),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
          "Verifica l\'Adreça amb Passport",
        ),
        "buy_bitcoin_accountSelection_verify_modal_heading": m2,
        "camera_toast_couldntDecodeUr": MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut descodificar UR.",
        ),
        "camera_toast_invalidPairPayload": MessageLookupByLibrary.simpleMessage(
          "Payload d\'Emparellament No Vàlid.",
        ),
        "camera_toast_notAValidAddress": MessageLookupByLibrary.simpleMessage(
          "Adreça no vàlida.",
        ),
        "camera_toast_notAValidSeed": MessageLookupByLibrary.simpleMessage(
          "Clau no vàlida.",
        ),
        "card_coin_locked": MessageLookupByLibrary.simpleMessage(
          "Moneda Bloquejada",
        ),
        "card_coin_selected": MessageLookupByLibrary.simpleMessage(
          "Moneda Seleccionada",
        ),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Moneda"),
        "card_coins_locked": MessageLookupByLibrary.simpleMessage(
          "Monedes Bloquejades",
        ),
        "card_coins_selected": MessageLookupByLibrary.simpleMessage(
          "Monedes Triades",
        ),
        "card_coins_unselected":
            MessageLookupByLibrary.simpleMessage("Monedes"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("de"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Tria una Etiqueta"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta transacció gasta monedes de diverses etiquetes. Com t\'agradaria etiquetar el teu canvi?",
        ),
        "coinDetails_tagDetails": MessageLookupByLibrary.simpleMessage(
          "DETALLS DE L\'ETIQUETA",
        ),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "L\'identificador de la transacció es copiarà al porta-retalls i pot ser visible per a altres aplicacions del telèfon.",
        ),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Saldo disponible"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Import Requerit"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Import Seleccionat"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage(
          "Bloqueja",
        ),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Bloquejar les monedes evitarà que s\'utilitzin en transaccions",
        ),
        "coincontrol_subsat_selectorWarning":
            MessageLookupByLibrary.simpleMessage(
          "Menys d\'1 sat/vb és una funció avançada.",
        ),
        "coincontrol_switchActivity": MessageLookupByLibrary.simpleMessage(
          "Activitat",
        ),
        "coincontrol_switchTags":
            MessageLookupByLibrary.simpleMessage("Etiquetes"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Revisa la Transacció"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage(
          "Signa amb Passport",
        ),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
          "La teva transacció està a punt\nper signar-se",
        ),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
          "Confirma els detalls de la transacció abans de signar amb Passport.",
        ),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Desa alguns detalls sobre la teva transacció.",
        ),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Mostra detalls"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Import a enviar"),
        "coincontrol_tx_detail_change": MessageLookupByLibrary.simpleMessage(
          "Canvi rebut",
        ),
        "coincontrol_tx_detail_cta1": MessageLookupByLibrary.simpleMessage(
          "Envia la Transacció",
        ),
        "coincontrol_tx_detail_cta2": MessageLookupByLibrary.simpleMessage(
          "Edita la Transacció",
        ),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Valida la Comissió"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Més del 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage(
          "Destinació",
        ),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Mostra l\'adreça"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Canvi rebut"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage(
          "moneda",
        ),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage(
          "monedes",
        ),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("DETALLS DE LA TRANSACCIÓ"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Gastat des de"),
        "coincontrol_tx_detail_fee": MessageLookupByLibrary.simpleMessage(
          "Comissió",
        ),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
          "Actualitzar la comissió pot canviar la selecció de monedes. Revisa-la després.",
        ),
        "coincontrol_tx_detail_fee_alert": m3,
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage(
          "Altres",
        ),
        "coincontrol_tx_detail_fee_fast": MessageLookupByLibrary.simpleMessage(
          "Ràpid",
        ),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage(
          "Ràpid",
        ),
        "coincontrol_tx_detail_fee_slow": MessageLookupByLibrary.simpleMessage(
          "Lent",
        ),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage(
          "Normal",
        ),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
          "La teva transacció està a punt\nper enviar-se",
        ),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Algunes monedes més petites s\'han exclòs d\'aquesta transacció. A la taxa de comissió escollida, costen més d\'incloure del que valen.",
        ),
        "coincontrol_tx_detail_newFee": MessageLookupByLibrary.simpleMessage(
          "Nova Comissió",
        ),
        "coincontrol_tx_detail_no_change": MessageLookupByLibrary.simpleMessage(
          "Sense canvi",
        ),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Anul·la Transacció",
        ),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
          "En cancel·lar, perdràs tot el progrés de la transacció.",
        ),
        "coincontrol_tx_detail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Confirma que la transacció és correcta abans d\'enviar-la.",
        ),
        "coincontrol_tx_detail_total": MessageLookupByLibrary.simpleMessage(
          "Total",
        ),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage(
          "Desbloqueja",
        ),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Desbloquejar les monedes et permetrà utilitzar-les en transaccions.",
        ),
        "coindetails_overlay_address": MessageLookupByLibrary.simpleMessage(
          "Adreça",
        ),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("a"),
        "coindetails_overlay_block":
            MessageLookupByLibrary.simpleMessage("Bloc"),
        "coindetails_overlay_boostedFees": MessageLookupByLibrary.simpleMessage(
          "Comissió Augmentada",
        ),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage(
          "Confirmació en",
        ),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage(
          "Es confirma en",
        ),
        "coindetails_overlay_confirmationIn_day":
            MessageLookupByLibrary.simpleMessage("dia"),
        "coindetails_overlay_confirmationIn_days":
            MessageLookupByLibrary.simpleMessage("dies"),
        "coindetails_overlay_confirmationIn_month":
            MessageLookupByLibrary.simpleMessage("mes"),
        "coindetails_overlay_confirmationIn_week":
            MessageLookupByLibrary.simpleMessage("setmana"),
        "coindetails_overlay_confirmationIn_weeks":
            MessageLookupByLibrary.simpleMessage("setmanes"),
        "coindetails_overlay_confirmation_boost":
            MessageLookupByLibrary.simpleMessage("Augmenta"),
        "coindetails_overlay_confirmations":
            MessageLookupByLibrary.simpleMessage(
          "Confirmacions",
        ),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Data"),
        "coindetails_overlay_explorer": MessageLookupByLibrary.simpleMessage(
          "Explorador",
        ),
        "coindetails_overlay_heading": MessageLookupByLibrary.simpleMessage(
          "DETALLS DE LA MONEDA",
        ),
        "coindetails_overlay_modal_explorer_heading":
            MessageLookupByLibrary.simpleMessage("Obre a l\'Explorador"),
        "coindetails_overlay_modal_explorer_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estàs a punt de deixar Envoy i veure aquesta transacció en un explorador de blockchain allotjat per Foundation. Assegura\'t d\'entendre les compensacions de privacitat abans de continuar. ",
        ),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
          "No es Pot Augmentar la Transacció",
        ),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Això es deu al fet que no hi ha prou monedes confirmades o desbloquejades per triar. \n\nSempre que sigui possible, permet que les monedes pendents es confirmin o desbloqueja algunes monedes i torna-ho a provar.",
        ),
        "coindetails_overlay_noCancelNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
          "No es Pot Cancel·Lar la Transacció",
        ),
        "coindetails_overlay_noCanceltNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
          "No hi ha prou monedes confirmades o desbloquejades per cancel·lar aquesta transacció.\n\nSi pots, espera que les pendents es confirmin o desbloqueja\'n algunes i torna-ho a provar.",
        ),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coindetails_overlay_paymentID": MessageLookupByLibrary.simpleMessage(
          "ID Pagament",
        ),
        "coindetails_overlay_rampFee": MessageLookupByLibrary.simpleMessage(
          "Comissions de Ramp",
        ),
        "coindetails_overlay_rampID": MessageLookupByLibrary.simpleMessage(
          "ID de Ramp",
        ),
        "coindetails_overlay_status":
            MessageLookupByLibrary.simpleMessage("Estat"),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmat"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage(
          "Pendent",
        ),
        "coindetails_overlay_tag":
            MessageLookupByLibrary.simpleMessage("Etiqueta"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage(
          "ID de Transacció",
        ),
        "common_button_contactSupport": MessageLookupByLibrary.simpleMessage(
          "Contacta amb el Suport",
        ),
        "common_button_retry": MessageLookupByLibrary.simpleMessage(
          "Torna-ho a provar",
        ),
        "component_12WordSeed": MessageLookupByLibrary.simpleMessage(
          "Clau de 12 Mots",
        ),
        "component_24WordSeed": MessageLookupByLibrary.simpleMessage(
          "Clau de 24 Mots",
        ),
        "component_Apply": MessageLookupByLibrary.simpleMessage("Aplica"),
        "component_advanced": MessageLookupByLibrary.simpleMessage(
          "Opcions Avançades",
        ),
        "component_apply": MessageLookupByLibrary.simpleMessage("Aplica"),
        "component_areYouSure": MessageLookupByLibrary.simpleMessage(
          "Estàs segur?",
        ),
        "component_back": MessageLookupByLibrary.simpleMessage("Enrere"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancel·la"),
        "component_confirm": MessageLookupByLibrary.simpleMessage("Confirma"),
        "component_content": MessageLookupByLibrary.simpleMessage("Contingut"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Elimina"),
        "component_device": MessageLookupByLibrary.simpleMessage("Dispositiu"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Descarta"),
        "component_done": MessageLookupByLibrary.simpleMessage("Fet"),
        "component_dontShowAgain": MessageLookupByLibrary.simpleMessage(
          "No ho tornis a mostrar",
        ),
        "component_exit": MessageLookupByLibrary.simpleMessage("Surt"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filtra"),
        "component_filter_button_all": MessageLookupByLibrary.simpleMessage(
          "Totes",
        ),
        "component_goToSettings": MessageLookupByLibrary.simpleMessage(
          "Vés a Configuració",
        ),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Aprèn més"),
        "component_minishield_buy":
            MessageLookupByLibrary.simpleMessage("Comprar"),
        "component_next": MessageLookupByLibrary.simpleMessage("Següent"),
        "component_no": MessageLookupByLibrary.simpleMessage("No"),
        "component_notificationText": MessageLookupByLibrary.simpleMessage(
          "Problema de connectivitat amb Tor",
        ),
        "component_ok": MessageLookupByLibrary.simpleMessage("D\'ACORD"),
        "component_recover": MessageLookupByLibrary.simpleMessage("Recupera"),
        "component_recoverWithQR": MessageLookupByLibrary.simpleMessage(
          "Recupera amb Codi QR",
        ),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Bescanvia"),
        "component_reset": MessageLookupByLibrary.simpleMessage("Reinicia"),
        "component_resetFilter": MessageLookupByLibrary.simpleMessage(
          "Restableix filtre",
        ),
        "component_resetSorting": MessageLookupByLibrary.simpleMessage(
          "Restableix ordre",
        ),
        "component_retry": MessageLookupByLibrary.simpleMessage(
          "Torna-ho a provar",
        ),
        "component_save": MessageLookupByLibrary.simpleMessage("Guarda"),
        "component_searching": MessageLookupByLibrary.simpleMessage("Cercant"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Saltar"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Ordena per"),
        "component_tryAgain": MessageLookupByLibrary.simpleMessage(
          "Torna a Provar",
        ),
        "component_unpair":
            MessageLookupByLibrary.simpleMessage("Desemparella"),
        "component_update": MessageLookupByLibrary.simpleMessage("Actualitza"),
        "component_warning":
            MessageLookupByLibrary.simpleMessage("Advertència"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "componet_disconnect":
            MessageLookupByLibrary.simpleMessage("Desconnecta"),
        "contactRampForSupport": MessageLookupByLibrary.simpleMessage(
          "Demana ajuda a Ramp",
        ),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
          "La teva adreça es copiarà al porta-retalls i pot ser que la puguin veure altres aplicacions del teu telèfon.",
        ),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
          "L\'identificador de la transacció es copiarà al porta-retalls i pot ser visible per a altres aplicacions del telèfon.",
        ),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Les etiquetes són una manera útil d\'organitzar les teves monedes.",
        ),
        "create_first_tag_modal_2_2_ie_text_field":
            MessageLookupByLibrary.simpleMessage(
                "Nova etiqueta, p. ex. Exchange"),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage(
          "Suggeriments",
        ),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Més utilitzades"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Segur que vols suprimir aquesta etiqueta?",
        ),
        "delete_tag_modal_cta2": MessageLookupByLibrary.simpleMessage(
          "Suprimeix l\'Etiqueta",
        ),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "En suprimir aquesta etiqueta, aquestes monedes es marcaran automàticament com a sense etiquetar.",
        ),
        "delete_wallet_for_good_error_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no ha pogut contactar amb el servidor de Foundation per suprimir les dades xifrades de la cartera. Torna-ho a provar o contacta amb suport.",
        ),
        "delete_wallet_for_good_error_title":
            MessageLookupByLibrary.simpleMessage(
          "No es Pot Suprimir",
        ),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Android fa una còpia de seguretat automàtica de les teves dades d\'Envoy cada 24 hores.\n\nPer eliminar immediatament la clau d\'Envoy de les Còpies de Seguretat Automàtiques d\'Android, pots fer una còpia de seguretat manual al teu dispositiu des de [[Configuració.]]",
        ),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage(
          "S\'està suprimint la cartera Envoy",
        ),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Suprimeix Cartera",
        ),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Confirmes que vols ELIMINAR la teva cartera Envoy?",
        ),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "La teva cartera s\'ha suprimit correctament",
        ),
        "descriptor_toast_descriptorCopied":
            MessageLookupByLibrary.simpleMessage(
          "Descriptor copiat al porta-retalls.",
        ),
        "descriptor_toast_signatureCopied":
            MessageLookupByLibrary.simpleMessage(
          "Signatura copiada al porta-retalls.",
        ),
        "device_deviceDetailsPrimeRemoved_accessoryRemoved":
            MessageLookupByLibrary.simpleMessage(
          "Accessori eliminat, reconnecta Passport.",
        ),
        "device_deviceDetailsPrimeRemoved_completeAccessorySetup":
            MessageLookupByLibrary.simpleMessage(
          "Acaba de Configurar l\'Accessori",
        ),
        "device_deviceDetailsPrimeRemoved_pairPassportAgain":
            MessageLookupByLibrary.simpleMessage("Torna a Emparellar Passport"),
        "device_deviceDetailsPrimeRemoved_reconnectPassport":
            MessageLookupByLibrary.simpleMessage("Reconnecta Passport"),
        "device_deviceDetailsPrime_connected":
            MessageLookupByLibrary.simpleMessage(
          "Connectat",
        ),
        "device_deviceDetailsPrime_connection":
            MessageLookupByLibrary.simpleMessage("Connexió"),
        "device_deviceDetailsPrime_disconnected":
            MessageLookupByLibrary.simpleMessage("Desconnectat"),
        "device_deviceDetailsPrime_securityCheck":
            MessageLookupByLibrary.simpleMessage("Comprovació de Seguretat"),
        "devices_connectingToPrime_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantén els dispositius a prop.",
        ),
        "devices_connectingToPrime_header":
            MessageLookupByLibrary.simpleMessage(
          "Connectant a Passport",
        ),
        "devices_connectionFailedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no s\'ha pogut connectar a Passport Prime. Assegura\'t que Passport Prime està encès, que Bluetooth està activat i que no està connectat a un altre dispositiu.",
        ),
        "devices_connectionFailedModal_header":
            MessageLookupByLibrary.simpleMessage("Connexió Fallida"),
        "devices_empty_modal_video_cta1": MessageLookupByLibrary.simpleMessage(
          "Compra Passport",
        ),
        "devices_empty_modal_video_cta2": MessageLookupByLibrary.simpleMessage(
          "Mira Després",
        ),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
          "Assegura el teu Bitcoin amb Passport.",
        ),
        "devices_firmwareUpdateModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Les actualitzacions de firmware de Passport Prime s\'han d\'iniciar al dispositiu. Ves a Settings > Update.",
        ),
        "devices_firmwareUpdateModal_header":
            MessageLookupByLibrary.simpleMessage(
          "Comença a Passport Prime",
        ),
        "devices_reconnectedSuccess_content":
            MessageLookupByLibrary.simpleMessage(
          "El dispositiu ja està a punt.",
        ),
        "devices_reconnectedSuccess_header":
            MessageLookupByLibrary.simpleMessage(
          "Dispositiu Reconnectat Correctament!",
        ),
        "devices_reconnecting_content": MessageLookupByLibrary.simpleMessage(
          "Connectant a Passport Prime",
        ),
        "devices_reconnecting_header": MessageLookupByLibrary.simpleMessage(
          "Reconnectant",
        ),
        "empty_tag_modal_subheading": m4,
        "envoy_account_tos_cta":
            MessageLookupByLibrary.simpleMessage("Accepto"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
          "Revisa i accepta les Condicions d\'Ús de Passport",
        ),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
          "Envoy requereix accés a la càmera per escanejar codis QR. Ves a la configuració i concedeix els permisos de la càmera.",
        ),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Permís necessari"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
          "Envoy és una cartera mòbil de Bitcoin i una aplicació complementària de Passport, disponible a iOS i Android.",
        ),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
          "No, tothom pot descarregar, verificar i instal·lar manualment el nou firmware. Consulta [[aquí]] per obtenir més informació.",
        ),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
          "Absolutament, no hi ha límit en el nombre de Passports que pots gestionar i interactuar utilitzant Envoy.",
        ),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
          "Sí, Envoy fa que la gestió de múltiples comptes sigui senzilla.",
        ),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
          "Envoy es comunica principalment mitjançant codis QR, però les actualitzacions de firmware s\'envien des del teu telèfon a través d\'una targeta microSD. Passport inclou adaptadors de microSD per al teu telèfon.",
        ),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
          "Sí, tingues en compte que qualsevol informació específica de la cartera, com ara l\'adreça o l\'etiquetatge de les UTXO, no es copiarà a Envoy ni des d\'Envoy.",
        ),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
          "Això pot ser possible ja que la majoria de carteres físiques habilitades per a QR es comuniquen de maneres molt similars, però això no està explícitament suportat. Com que Envoy és de codi obert, donem la benvinguda a altres carteres físiques basades en QR per afegir suport!",
        ),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
          "En aquest moment, Envoy només funciona amb Bitcoin ‘on-chain’. Tenim previst donar suport a Lightning en el futur.",
        ),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
          "Qualsevol persona que trobi el teu telèfon primer hauria de superar el PIN del sistema operatiu del teu telèfon o l\'autenticació biomètrica per accedir a Envoy. En l\'improbable cas que ho aconseguissin, l\'atacant podria enviar fons des de la teva Cartera Mòbil d\'Envoy i veure la quantitat de Bitcoin emmagatzemada en qualsevol compte de Passport connectat. Aquests fons de Passport no estan en perill perquè qualsevol transacció ha de ser autoritzada pel dispositiu Passport emparellat.",
        ),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
          "Si s\'utilitza amb un Passport, Envoy actua com a cartera ‘només per a visualització’ connectada a la teva cartera física. Això significa que Envoy pot construir transaccions, però són inútils sense l\'autorització pertinent, que només Passport pot proporcionar. Passport és \'emmagatzematge en fred\' i Envoy és simplement la interfície connectada a Internet! Si utilitzes Envoy per crear una cartera mòbil, on les claus es guarden de manera segura al teu telèfon, aquesta cartera mòbil no es consideraria emmagatzematge en fred. Això no té cap efecte sobre la seguretat de cap compte connectat a Passport.",
        ),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
          "Sí, Envoy es pot connectar a nodes personals mitjançant els protocols de servidor Electrum o Esplora. Per connectar amb el teu propi servidor, escaneja el codi QR o introdueix l\'URL proporcionat a la configuració de xarxa en Envoy.",
        ),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
          "Envoy està dissenyat per oferir l\'experiència més fàcil d\'utilitzar de qualsevol cartera Bitcoin, sense comprometre la teva privacitat. Amb les Còpies de Seguretat Màgiques d\'Envoy, configura una cartera mòbil de Bitcoin d\'autocustòdia en 60 segons, sense paraules de clau! Els usuaris de Passport poden connectar els seus dispositius a Envoy per a una fàcil configuració, actualitzacions de firmware i una experiència senzilla de cartera de Bitcoin.",
        ),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
          "Descarregar i instal·lar Envoy no requereix cap informació personal i Envoy pot connectar-se a internet mitjançant Tor, un protocol de preservació de la privacitat. Això significa que Foundation no té cap manera de saber qui ets. Envoy també permet als usuaris més avançats connectar-se al seu propi node de Bitcoin per eliminar qualsevol dependència dels servidors de Foundation completament.",
        ),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
          "Sí. A partir de la versió 1.4.0, Envoy ara suporta una selecció completa de monedes, així com l\'etiquetatge de monedes.",
        ),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
          "En aquest moment, Envoy no admet despeses en lot.",
        ),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
          "Sí. A partir de la versió 1.4.0, Envoy permet personalitzar totalment les comissions dels miners, així com dues opcions ràpides de selecció de comissions: ‘Estàndard’ i ‘Ràpid’. \'Estàndard\' té com a objectiu finalitzar la teva transacció en un termini de 60 minuts i \'Més ràpid\' en 10 minuts. Aquestes són estimacions basades en la congestió de la xarxa en el moment de construir la transacció i sempre et mostrarem el cost de les dues opcions abans de finalitzar la transacció.",
        ),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
          "Envoy és una cartera Bitcoin senzilla amb potents funcions de privacitat i gestió de comptes, com ara les Còpies de Seguretat Màgiques. Utilitza Envoy juntament amb la teva cartera física Passport per a la configuració, actualitzacions de firmware i molt més.",
        ),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
          "Les Còpies de Seguretat Màgiques són la manera més fàcil de configurar i fer una còpia de seguretat d\'una cartera mòbil de Bitcoin. La Còpia de Seguretat Màgica emmagatzema la clau privada de la teva cartera mòbil xifrada d\'extrem a extrem a Clauer d\'iCloud o Còpia de Seguretat Automàtica d\'Android. Totes les dades de l\'aplicació estan xifrades per la teva clau privada i s\'emmagatzemen als Servidors de Foundation. Configura la teva cartera en 60 segons i restaura automàticament si perds el telèfon!",
        ),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
          "Les Còpies de Seguretat Màgiques són completament opcionals per als usuaris que vulguin aprofitar Envoy com a cartera mòbil. Si prefereixes gestionar les teves pròpies paraules de clau de la cartera mòbil i el fitxer de còpia de seguretat, selecciona \'Configura Manualment les Paraules de Clau\' durant la configuració de la cartera.",
        ),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
          "El fitxer de còpia de seguretat d\'Envoy conté la configuració de l\'aplicació, la informació del compte i les etiquetes de les transaccions. El fitxer està xifrat amb les paraules de clau de la teva cartera mòbil. Per als usuaris de Còpia de Seguretat Màgica, això s\'emmagatzema totalment xifrat en el servidor de Foundation. Els usuaris d\'Envoy amb còpia de seguretat manual poden descarregar i emmagatzemar el fitxer de còpia de seguretat on vulguin. Això pot ser qualsevol combinació del teu telèfon, un servidor personal de núvol o alguna cosa física com una targeta microSD o una unitat USB.",
        ),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
          "No, les funcionalitats principals d\'Envoy seran sempre gratuïtes per a ús. En el futur, podríem introduir serveis opcionals de pagament o subscripcions.",
        ),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
          "Sí, com tot el que fem a Foundation, Envoy és completament de codi obert. Envoy està llicenciat sota la mateixa llicència [[GPLv3]] que el nostre Firmware de Passport. Per a aquells que vulguin comprovar el nostre codi font, fes clic [[aquí]].",
        ),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
          "No, ens enorgullim de garantir que Passport sigui compatible amb tantes carteres de programari diferents com sigui possible. Consulta la nostra llista completa, inclosos els tutorials [[aquí]].",
        ),
        "envoy_faq_link_10": MessageLookupByLibrary.simpleMessage(
          "https://docs.foundation.xyz/firmware-updates/passport/",
        ),
        "envoy_faq_link_8_1": MessageLookupByLibrary.simpleMessage(
          "https://www.gnu.org/licenses/gpl-3.0.en.html",
        ),
        "envoy_faq_link_8_2": MessageLookupByLibrary.simpleMessage(
          "https://github.com/Foundation-Devices/envoy",
        ),
        "envoy_faq_link_9": MessageLookupByLibrary.simpleMessage(
          "https://docs.foundation.xyz/passport/connect/",
        ),
        "envoy_faq_question_1": MessageLookupByLibrary.simpleMessage(
          "Què és Envoy?",
        ),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
          "He d\'utilitzar Envoy per actualitzar el firmware de Passport?",
        ),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
          "Puc gestionar més d\'un Passport amb Envoy?",
        ),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
          "Puc gestionar diversos comptes des del mateix Passport?",
        ),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
          "Com es comunica Envoy amb Passport?",
        ),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
          "Puc utilitzar Envoy en paral·lel a un altre programari com Sparrow Wallet?",
        ),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
          "Puc gestionar altres carteres físiques amb Envoy?",
        ),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
          "Envoy és compatible amb Lightning Network?",
        ),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
          "Què passa si perdo el meu telèfon amb Envoy instal·lat?",
        ),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
          "Es considera Envoy un ‘Emmagatzematge en Fred’?",
        ),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
          "Puc connectar Envoy al meu propi node Bitcoin?",
        ),
        "envoy_faq_question_2": MessageLookupByLibrary.simpleMessage(
          "Per què hauria d\'utilitzar Envoy?",
        ),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
          "Com protegeix Envoy la meva privacitat?",
        ),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
          "Envoy ofereix control de monedes?",
        ),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
          "Envoy admet les despeses per lots?",
        ),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
          "Envoy permet la selecció personalitzada de comissions dels miners?",
        ),
        "envoy_faq_question_3": MessageLookupByLibrary.simpleMessage(
          "Què pot fer Envoy?",
        ),
        "envoy_faq_question_4": MessageLookupByLibrary.simpleMessage(
          "Què són les Còpies de Seguretat Màgiques d\'Envoy?",
        ),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
          "He d\'utilitzar les Còpies de Seguretat Màgiques d\'Envoy?",
        ),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
          "Què és el fitxer de Còpia de Seguretat d\'Envoy?",
        ),
        "envoy_faq_question_7": MessageLookupByLibrary.simpleMessage(
          "He de pagar per Envoy?",
        ),
        "envoy_faq_question_8": MessageLookupByLibrary.simpleMessage(
          "Envoy És de Codi Obert?",
        ),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
          "He d\'utilitzar Envoy per fer transaccions amb Passport?",
        ),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
          "Envoy no ha pogut copiar el firmware a la targeta microSD.",
        ),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que la targeta microSD estigui inserida correctament al teu telèfon i torna-ho a provar. Alternativament, el firmware es pot descarregar des del nostre [[GitHub]].",
        ),
        "envoy_fw_intro_cta": MessageLookupByLibrary.simpleMessage(
          "Descarrega el Firmware",
        ),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
          "A continuació, actualitzem el firmware de Passport",
        ),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Envoy et permet actualitzar el teu Passport des del teu telèfon mitjançant l\'adaptador microSD inclòs.\n\nEls usuaris avançats poden [[tocar aquí]] per descarregar i verificar el firmware en un ordinador.",
        ),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
          "Permet que Envoy accedeixi a la targeta microSD",
        ),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Concedeix accés a Envoy per copiar fitxers a la targeta microSD. Toca Navega, després PASSPORT-SD i Obre.",
        ),
        "envoy_fw_microsd_fails_cta2": MessageLookupByLibrary.simpleMessage(
          "Descarrega des de Github",
        ),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
          "Ho sentim, ara mateix no podem obtenir l\'actualització del firmware.",
        ),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
          "Insereix la targeta microSD al teu telèfon",
        ),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
          "Insereix l\'adaptador de la targeta microSD proporcionat al teu telèfon, després insereix la targeta microSD a l\'adaptador.",
        ),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
          "Treu la targeta microSD i insereix-la a Passport",
        ),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Insereix la targeta microSD a Passport i navega a Settings -> Firmware -> Update Firmware.\n\nAssegura\'t que Passport tingui una càrrega de bateria adequada abans de dur a terme aquesta operació.",
        ),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
          "Insereix la targeta microSD a Passport i segueix les instruccions.\n\nAssegura\'t que Passport tingui una càrrega de bateria adequada abans de dur a terme aquesta operació.",
        ),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
          "Envoy està copiant el firmware a la\ntargeta microSD",
        ),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
          "Això pot trigar uns segons. Si us plau, no retiris la targeta microSD.",
        ),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
          "El firmware s\'ha copiat correctament a la\ntargeta microSD",
        ),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
          "Assegura\'t de tocar el botó Desmuntar targeta SD del Gestor de Fitxers abans de treure la targeta microSD del telèfon.",
        ),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
          "L\'últim firmware s\'ha copiat a la targeta microSD i està llest per aplicar-se a Passport.",
        ),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
          "Introdueix un PIN de 6 a 12 dígits al teu Passport",
        ),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Passport sempre demanarà el PIN en iniciar-se. Et recomanem que utilitzis un PIN únic i que l\'anotis.\n\nSi oblides el teu PIN, no hi ha manera de recuperar Passport i el dispositiu es desactivarà permanentment.",
        ),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Ara, crea una còpia de seguretat xifrada de la teva clau",
        ),
        "envoy_pp_new_seed_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Passport farà una còpia de seguretat de la teva clau i de la configuració del dispositiu en una targeta microSD xifrada.",
        ),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
          "A Passport, selecciona\nCrear Nova Clau",
        ),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
          "L\'Avalanche Noise Source de Passport, un generador de nombres veritablement aleatoris de codi obert, ajuda a crear una clau privada forta.",
        ),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "Felicitats, s\'ha creat la teva nova clau",
        ),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A continuació, connectarem Envoy i Passport.",
        ),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
          "A Passport, tria\nRestaura Còpia",
        ),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage(
          "Desxifra la teva Còpia de Seguretat",
        ),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per desxifrar el fitxer de còpia de seguretat, introdueix el codi de còpia de seguretat de 20 dígits que se\'t va mostrar quan vas crear el fitxer de còpia de seguretat.\n\nSi has perdut o oblidat aquest codi, pots fer la restauració amb les paraules de clau.",
        ),
        "envoy_pp_restore_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Utilitza aquesta funció per restaurar Passport mitjançant una còpia de seguretat microSD xifrada d\'un altre Passport.\n\nNecessitaràs la contrasenya per desxifrar la còpia de seguretat.",
        ),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "El teu Fitxer de Còpia de Seguretat s\'ha restaurat correctament",
        ),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
          "A Passport, tria\nRestaura Clau",
        ),
        "envoy_pp_restore_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Usa aquesta funció per restaurar una clau de 12 o 24 paraules.",
        ),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "La teva clau s\'ha restaurat correctament",
        ),
        "envoy_pp_setup_intro_cta1": MessageLookupByLibrary.simpleMessage(
          "Crea una Nova Clau Privada",
        ),
        "envoy_pp_setup_intro_cta2": MessageLookupByLibrary.simpleMessage(
          "Restaura Clau",
        ),
        "envoy_pp_setup_intro_cta3": MessageLookupByLibrary.simpleMessage(
          "Restaura Còpia de Seguretat",
        ),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
          "Com vols configurar el teu Passport?",
        ),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Amb un Passport nou pots crear una clau nova, restaurar una cartera amb paraules de clau o una còpia d\'un Passport existent.",
        ),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
          "Primer, assegurem-nos que el teu Passport estigui segur",
        ),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Aquesta comprovació de seguretat garantirà que el teu Passport no ha estat manipulat durant l\'enviament.",
        ),
        "envoy_scv_result_fail_cta1": MessageLookupByLibrary.simpleMessage(
          "Contacta amb Nosaltres",
        ),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
          "El teu Passport pot ser insegur",
        ),
        "envoy_scv_result_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no ha pogut validar la seguretat del teu Passport. Si us plau, contacta\'ns per rebre assistència.",
        ),
        "envoy_scv_result_ok_heading": MessageLookupByLibrary.simpleMessage(
          "El teu Passport és segur",
        ),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
          "A continuació, crea un PIN per protegir el teu Passport",
        ),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
          "A continuació, escaneja el codi QR a la pantalla de Passport",
        ),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "Aquest codi QR completa la validació i comparteix informació de Passport amb Envoy.",
        ),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
          "A Passport, selecciona l\'aplicació Envoy i escaneja aquest Codi QR",
        ),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "Aquest codi QR dona informació per a la validació i configuració.",
        ),
        "envoy_support_community": MessageLookupByLibrary.simpleMessage(
          "COMUNITAT",
        ),
        "envoy_support_documentation": MessageLookupByLibrary.simpleMessage(
          "Documentació",
        ),
        "envoy_support_email": MessageLookupByLibrary.simpleMessage("Correu"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
          "Activa Còpies Màgiques",
        ),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Configura Manualment la Clau",
        ),
        "envoy_welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Crear Cartera Nova",
        ),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
          "Per a una configuració fàcil, recomanem activar les [[Còpies Màgiques]].\n\nEls usuaris avançats poden crear o restaurar manualment una clau.",
        ),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage("Torna als meus Comptes"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage("Elimina Comptes igualment"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Abans d\'eliminar la teva cartera Envoy, buida els teus Comptes. \nVes a Còpies de Seguretat > Esborra Carteres i Còpies de Seguretat quan hagis acabat.",
        ),
        "exploreAddresses_listFilter_unused":
            MessageLookupByLibrary.simpleMessage(
          "No usada",
        ),
        "exploreAddresses_listFilter_used":
            MessageLookupByLibrary.simpleMessage(
          "Usada",
        ),
        "exploreAddresses_listFilter_zeroBalance":
            MessageLookupByLibrary.simpleMessage("Saldo 0"),
        "exploreAddresses_listModal_backToList":
            MessageLookupByLibrary.simpleMessage("Torna a la Llista"),
        "exploreAddresses_listModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta adreça s\'ha utilitzat almenys una vegada. En rebre Bitcoin, és una bona pràctica de privacitat utilitzar una adreça nova.",
        ),
        "exploreAddresses_listModal_showAddress":
            MessageLookupByLibrary.simpleMessage("Mostra Adreça"),
        "exploreAddresses_list_header": MessageLookupByLibrary.simpleMessage(
          "Explora Adreces",
        ),
        "exploreAddresses_qr_derivationPath":
            MessageLookupByLibrary.simpleMessage(
          "Ruta de Derivació",
        ),
        "exploreAddresses_qr_header": m5,
        "exploreAddresses_qr_warningReused":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta adreça ja s\'ha utilitzat. Evita reutilitzar adreces per preservar la privacitat.",
        ),
        "exploreAddresses_searchError_continueSearching":
            MessageLookupByLibrary.simpleMessage("Continua Cercant"),
        "exploreAddresses_searchError_notFound": m6,
        "exploreAdresses_activityOptions_deleteAccount":
            MessageLookupByLibrary.simpleMessage("Suprimeix Compte"),
        "exploreAdresses_activityOptions_editAccountName":
            MessageLookupByLibrary.simpleMessage("Edita el Nom del Compte"),
        "exploreAdresses_activityOptions_exploreAddresses":
            MessageLookupByLibrary.simpleMessage("Explora Adreces"),
        "exploreAdresses_activityOptions_showDescriptor":
            MessageLookupByLibrary.simpleMessage("Mostra Descriptor"),
        "exploreAdresses_activityOptions_signMessage":
            MessageLookupByLibrary.simpleMessage("Signa Missatge"),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "Aquest fitxer xifrat conté dades útils de la cartera, com etiquetes, comptes i configuració.\nAquest fitxer està xifrat amb la clau de la Cartera Mòbil. Assegura\'t que la clau tingui una còpia segura.",
        ),
        "export_backup_send_CTA1": MessageLookupByLibrary.simpleMessage(
          "Descarrega el Fitxer de Còpia",
        ),
        "export_backup_send_CTA2":
            MessageLookupByLibrary.simpleMessage("Descarta"),
        "export_seed_modal_12_words_CTA2": MessageLookupByLibrary.simpleMessage(
          "Veure com a Codi QR",
        ),
        "export_seed_modal_QR_code_CTA2": MessageLookupByLibrary.simpleMessage(
          "Veure Clau Privada",
        ),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per utilitzar aquest codi QR a Envoy en un telèfon nou, ves a Configurar la Cartera d\'Envoy > Recuperar Còpia de Seguretat Màgica > Recuperar amb codi QR",
        ),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta clau té contrasenya. Necessites les paraules de clau i la contrasenya per recuperar els fons.",
        ),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "La pantalla següent mostra informació molt sensible.\n\nQualsevol persona amb accés a aquestes dades pot robar el teu Bitcoin. Procedeix amb extrema precaució.",
        ),
        "filter_sortBy_aToZ": MessageLookupByLibrary.simpleMessage(
          "De la A a la Z",
        ),
        "filter_sortBy_highest": MessageLookupByLibrary.simpleMessage(
          "Valor més alt",
        ),
        "filter_sortBy_lowest": MessageLookupByLibrary.simpleMessage(
          "Valor més baix",
        ),
        "filter_sortBy_newest": MessageLookupByLibrary.simpleMessage(
          "El més nou primer",
        ),
        "filter_sortBy_oldest": MessageLookupByLibrary.simpleMessage(
          "El més antic primer",
        ),
        "filter_sortBy_zToA": MessageLookupByLibrary.simpleMessage(
          "De la Z a la A",
        ),
        "finalize_catchAll_backUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
          "Fes Còpia de la Clau Mestra",
        ),
        "finalize_catchAll_backingUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
                "Fent Còpia de la Clau Mestra"),
        "finalize_catchAll_connectAccount":
            MessageLookupByLibrary.simpleMessage(
          "Connecta Compte",
        ),
        "finalize_catchAll_connectingAccount":
            MessageLookupByLibrary.simpleMessage(
          "Connectant Compte",
        ),
        "finalize_catchAll_creatingPin": MessageLookupByLibrary.simpleMessage(
          "Creant PIN",
        ),
        "finalize_catchAll_header": MessageLookupByLibrary.simpleMessage(
          "Continua a Passport Prime",
        ),
        "finalize_catchAll_masterKeyBackedUp":
            MessageLookupByLibrary.simpleMessage(
          "Còpia de Clau Mestra Feta",
        ),
        "finalize_catchAll_masterKeySetUp":
            MessageLookupByLibrary.simpleMessage(
          "Clau Mestra Configurada",
        ),
        "finalize_catchAll_pinCreated": MessageLookupByLibrary.simpleMessage(
          "PIN creat",
        ),
        "finalize_catchAll_setUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
          "Configura Clau Mestra",
        ),
        "finalize_catchAll_settingUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Configurant Clau Mestra"),
        "finish_connectedSuccess_content": MessageLookupByLibrary.simpleMessage(
          "Envoy està configurat i preparat per al teu Bitcoin!",
        ),
        "finish_connectedSuccess_header": MessageLookupByLibrary.simpleMessage(
          "Cartera Connectada Correctament",
        ),
        "firmware_connectionModalCancelUpdate_cancelUpdate":
            MessageLookupByLibrary.simpleMessage("Cancel·la l\'Actualització"),
        "firmware_connectionModalCancelUpdate_content":
            MessageLookupByLibrary.simpleMessage(
          "Això cancel·larà l\'actualització del firmware. Passport Prime continuarà amb la versió actual.",
        ),
        "firmware_connectionModalCancelUpdate_header":
            MessageLookupByLibrary.simpleMessage("Cancel·la l\'Actualització?"),
        "firmware_downloadingUpdate_aboutOneMin":
            MessageLookupByLibrary.simpleMessage("Queda aproximadament 1 min"),
        "firmware_downloadingUpdate_downloaded":
            MessageLookupByLibrary.simpleMessage("Descarregada"),
        "firmware_downloadingUpdate_estimating":
            MessageLookupByLibrary.simpleMessage("Estimant temps restant…"),
        "firmware_downloadingUpdate_header":
            MessageLookupByLibrary.simpleMessage(
          "Descarregant",
        ),
        "firmware_downloadingUpdate_timeRemaining": m7,
        "firmware_downloadingUpdate_transferring":
            MessageLookupByLibrary.simpleMessage(
                "Transferint a Passport Prime"),
        "firmware_updateAvailable_content2": m8,
        "firmware_updateAvailable_estimatedUpdateTime": m9,
        "firmware_updateAvailable_header": MessageLookupByLibrary.simpleMessage(
          "Actualització Nova",
        ),
        "firmware_updateAvailable_whatsNew": m10,
        "firmware_updateError_downloadFailed":
            MessageLookupByLibrary.simpleMessage(
          "Descàrrega Fallida",
        ),
        "firmware_updateError_header": MessageLookupByLibrary.simpleMessage(
          "Error d\'Actualització",
        ),
        "firmware_updateError_installFailed":
            MessageLookupByLibrary.simpleMessage(
          "Instal·Lació Fallida",
        ),
        "firmware_updateError_receivingFailed":
            MessageLookupByLibrary.simpleMessage("Transferència Fallida"),
        "firmware_updateError_verifyFailed":
            MessageLookupByLibrary.simpleMessage(
          "Verificació Fallida",
        ),
        "firmware_updateModalConnectionLostToast_unableToReconnect":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut reconnectar a Passport Prime.",
        ),
        "firmware_updateModalConnectionLost_exit":
            MessageLookupByLibrary.simpleMessage("Surt de la Configuració"),
        "firmware_updateModalConnectionLost_header":
            MessageLookupByLibrary.simpleMessage("Connexió Perduda"),
        "firmware_updateModalConnectionLost_reconnecting":
            MessageLookupByLibrary.simpleMessage("Reconnectant…"),
        "firmware_updateModalConnectionLost_tryToReconnect":
            MessageLookupByLibrary.simpleMessage("Intenta Reconnectar"),
        "firmware_updateSuccess_content1": m11,
        "firmware_updateSuccess_content2": MessageLookupByLibrary.simpleMessage(
          "Continua la configuració a Passport Prime.",
        ),
        "firmware_updateSuccess_header": MessageLookupByLibrary.simpleMessage(
          "Actualització Correcta",
        ),
        "firmware_updatingDownload_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantén els dispositius a prop.",
        ),
        "firmware_updatingDownload_downloading":
            MessageLookupByLibrary.simpleMessage("Descarregant"),
        "firmware_updatingDownload_header":
            MessageLookupByLibrary.simpleMessage(
          "Actualitzant",
        ),
        "firmware_updatingDownload_transfer":
            MessageLookupByLibrary.simpleMessage(
          "Transferint a Passport Prime",
        ),
        "firmware_updatingPrime_content2": MessageLookupByLibrary.simpleMessage(
          "La configuració continuarà quan Prime es reiniciï.",
        ),
        "firmware_updatingPrime_installUpdate":
            MessageLookupByLibrary.simpleMessage("Instal·la"),
        "firmware_updatingPrime_installingUpdate":
            MessageLookupByLibrary.simpleMessage("Instal·Lant"),
        "firmware_updatingPrime_primeRestarting":
            MessageLookupByLibrary.simpleMessage("Passport Prime es reinicia"),
        "firmware_updatingPrime_restartPrime":
            MessageLookupByLibrary.simpleMessage(
          "Reinicia Passport Prime",
        ),
        "firmware_updatingPrime_updateInstalled":
            MessageLookupByLibrary.simpleMessage("Instal·Lada"),
        "firmware_updatingPrime_verified": MessageLookupByLibrary.simpleMessage(
          "Verificada",
        ),
        "firmware_updatingPrime_verifying":
            MessageLookupByLibrary.simpleMessage(
          "Verificant",
        ),
        "header_chooseAccount": MessageLookupByLibrary.simpleMessage(
          "TRIA UN COMPTE",
        ),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
          "Llisca per mostrar i amagar el teu saldo.",
        ),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
          "Toca la targeta anterior per rebre Bitcoin.",
        ),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
          "Toca qualsevol targeta anterior per rebre Bitcoin.",
        ),
        "invalid_qr_heading": MessageLookupByLibrary.simpleMessage(
          "Codi QR Invàlid",
        ),
        "invalid_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "El codi QR no conté cap transacció Bitcoin vàlida (PSBT). Comprova-ho i torna-ho a provar.",
        ),
        "launch_screen_faceID_fail_CTA": MessageLookupByLibrary.simpleMessage(
          "Torna-Ho a Provar",
        ),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "L\'Autenticació Ha Fallat",
        ),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage("Torna-ho a provar"),
        "launch_screen_lockedout_heading": MessageLookupByLibrary.simpleMessage(
          "Bloquejat",
        ),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
          "L\'autenticació biomètrica està desactivada. Tanca l\'aplicació, espera 30 segons i torna-ho a provar.",
        ),
        "learning_center_device_envoy": MessageLookupByLibrary.simpleMessage(
          "Envoy",
        ),
        "learning_center_device_passport": MessageLookupByLibrary.simpleMessage(
          "Passport",
        ),
        "learning_center_device_passportCore":
            MessageLookupByLibrary.simpleMessage(
          "Passport Core",
        ),
        "learning_center_device_passportPrime":
            MessageLookupByLibrary.simpleMessage("Passport Prime"),
        "learning_center_filterEmpty_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Els filtres aplicats oculten tots els resultats.\nEdita o restableix els filtres per veure\'n més.",
        ),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("Tot"),
        "learning_center_results_title": MessageLookupByLibrary.simpleMessage(
          "Resultats",
        ),
        "learning_center_search_input": MessageLookupByLibrary.simpleMessage(
          "Buscar...",
        ),
        "learning_center_title_blog":
            MessageLookupByLibrary.simpleMessage("Blog"),
        "learning_center_title_faq": MessageLookupByLibrary.simpleMessage(
          "Preguntes freqüents",
        ),
        "learning_center_title_video": MessageLookupByLibrary.simpleMessage(
          "Vídeos",
        ),
        "learningcenter_status_read": MessageLookupByLibrary.simpleMessage(
          "Llegit",
        ),
        "learningcenter_status_watched": MessageLookupByLibrary.simpleMessage(
          "Mirat",
        ),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Xifrant la Teva Còpia de Seguretat",
        ),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està xifrant la còpia de seguretat de la cartera.\n\nAquesta còpia de seguretat conté dades útils de la cartera, com ara etiquetes, notes, comptes i configuració.",
        ),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està creant una clau segura per a la cartera de Bitcoin, que es guardarà xifrada d\'extrem a extrem en la còpia de seguretat del teu Android.",
        ),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage(
                "Creant la Teva Clau d\'Envoy"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està creant una clau segura per a la cartera de Bitcoin, que s\'emmagatzemarà xifrada d\'extrem a extrem en el teu Clauer d\'iCloud.",
        ),
        "magic_setup_recovery_fail_Android_CTA1":
            MessageLookupByLibrary.simpleMessage("Torna-ho a provar"),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage("Recupera amb Codi QR"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot localitzar una Còpia de Seguretat Màgica.\n\nConfirma que has iniciat la sessió amb el compte de Google correcte i que has restaurat la còpia de seguretat del dispositiu més recent.",
        ),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Còpia de Seguretat Màgica No Trobada",
        ),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot trobar cap fitxer de Còpia Màgica al servidor de Foundation.\n\nComprova que estàs recuperant una cartera que abans utilitzava Còpies Màgiques.",
        ),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Problema de Connexió"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no es pot connectar al servidor de Foundation per recuperar les dades de la Còpia de Seguretat Màgica.\n\nPots tornar-ho a provar, importar el teu propi fitxer de còpia de seguretat d\'Envoy o continuar sense cap.",
        ),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Recuperació Sense Èxit",
        ),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot localitzar una Còpia de Seguretat Màgica.\n\nConfirma que has iniciat sessió amb el compte d\'Apple correcte i que has restaurat la teva última còpia de seguretat d\'iCloud.",
        ),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
          "Recuperant la teva cartera Envoy",
        ),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage("Pujant Còpia de Seguretat"),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està pujant la còpia de seguretat xifrada de la teva cartera als servidors de Foundation.\n\nCom que la teva còpia de seguretat està xifrada d\'extrem a extrem, Foundation no hi té accés ni en coneix el contingut.",
        ),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "La manera més senzilla de crear una cartera Bitcoin nova mantenint la teva sobirania.\n\nLa Còpia Màgica desa la cartera i la configuració a la Còpia de Seguretat Automàtica d\'Android, 100% xifrada d\'extrem a extrem.\n\n[[Aprèn més]].",
        ),
        "magic_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
          "Còpies Màgiques",
        ),
        "magic_setup_tutorial_ios_CTA1": MessageLookupByLibrary.simpleMessage(
          "Crea Còpia Màgica",
        ),
        "magic_setup_tutorial_ios_CTA2": MessageLookupByLibrary.simpleMessage(
          "Recupera Còpia Màgica",
        ),
        "magic_setup_tutorial_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "La manera més senzilla de crear una cartera Bitcoin nova mantenint la teva sobirania.\n\nLes Còpies Màgiques fan còpia automàtica de la cartera i la configuració amb el Clauer d\'iCloud, 100% xifrada d\'extrem a extrem.\n\n[[Aprèn més]].",
        ),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy generarà una nova adreça després que s\'utilitzi la següent.",
        ),
        "manage_account_address_heading": MessageLookupByLibrary.simpleMessage(
          "DETALLS DEL COMPTE",
        ),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t de no compartir aquest descriptor tret que et sentis còmode amb el fet que les teves transaccions siguin públiques.",
        ),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage(
          "EDITA NOM DE COMPTE",
        ),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage(
          "MOSTRA DESCRIPTOR",
        ),
        "manage_account_remove_heading": MessageLookupByLibrary.simpleMessage(
          "Estàs segur?",
        ),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Això només elimina el compte d\'Envoy.",
        ),
        "manage_account_rename_heading": MessageLookupByLibrary.simpleMessage(
          "Canvia el Nom del Compte",
        ),
        "manage_deviceDetailsModalDisconnectExistingPassport_content":
            MessageLookupByLibrary.simpleMessage(
          "En la versió actual, Envoy només admet una connexió amb Passport Prime.\nAixò canviarà en una propera actualització, però ara has de desconnectar el Passport Prime existent abans de configurar-ne un de nou.",
        ),
        "manage_deviceDetailsModalDisconnectExistingPassport_disconnect":
            MessageLookupByLibrary.simpleMessage("Desconnecta"),
        "manage_deviceDetailsModalDisconnectExistingPassport_header":
            MessageLookupByLibrary.simpleMessage("Desemparella Prime Existent"),
        "manage_deviceDetailsReconnectQL_reconnect":
            MessageLookupByLibrary.simpleMessage("Reconnecta QuantumLink"),
        "manage_deviceDetailsUnpairedModalWarning_content":
            MessageLookupByLibrary.simpleMessage(
          "La connexió QuantumLink del teu Passport Prime {0} ja no està disponible. Si recentment has esborrat el dispositiu o has desemparellat Envoy, això és normal. Si no, contacta amb suport.\nEnvoy eliminarà aquest dispositiu de la llista d\'accessoris Bluetooth del teu telèfon.",
        ),
        "manage_deviceDetailsUnpairedModalWarning_header":
            MessageLookupByLibrary.simpleMessage("QuantumLink Desconnectat"),
        "manage_deviceDetailsUnpairedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Passport Prime {0} s\'ha desemparellat. Envoy ara eliminarà el dispositiu de la llista d\'accessoris Bluetooth del teu telèfon.",
        ),
        "manage_deviceDetailsUnpairedModal_header":
            MessageLookupByLibrary.simpleMessage("Passport Desemparellat"),
        "manage_deviceDetailsUnpaired_pairAgain":
            MessageLookupByLibrary.simpleMessage("Emparella de Nou"),
        "manage_device_deletePassportWarning":
            MessageLookupByLibrary.simpleMessage(
          "Estàs segur que vols desemparellar Passport?\nAixò eliminarà el dispositiu d\'Envoy juntament amb els comptes connectats.",
        ),
        "manage_device_details_QuantumLink":
            MessageLookupByLibrary.simpleMessage(
          "QuantumLink",
        ),
        "manage_device_details_active": MessageLookupByLibrary.simpleMessage(
          "Actiu",
        ),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage(
          "Emparellat",
        ),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage(
          "Sèrie",
        ),
        "manage_device_details_disconnected":
            MessageLookupByLibrary.simpleMessage(
          "Desconnectat",
        ),
        "manage_device_details_heading": MessageLookupByLibrary.simpleMessage(
          "DETALLS DEL DISPOSITIU",
        ),
        "manage_device_details_inactive": MessageLookupByLibrary.simpleMessage(
          "Inactiu",
        ),
        "manage_device_details_menu_disconnectDevice":
            MessageLookupByLibrary.simpleMessage("Desconnecta"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage("Edita el Nom del Dispositiu"),
        "manage_device_details_menu_unpairPassport":
            MessageLookupByLibrary.simpleMessage("Desemparella Passport"),
        "manage_device_details_unpaired": MessageLookupByLibrary.simpleMessage(
          "Desemparellat",
        ),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Canvia el nom del teu Passport",
        ),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
          "No es pot fer còpia de seguretat. Intenta-ho més tard.",
        ),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
          "Això descartarà qualsevol canvi de selecció de monedes. Vols continuar?",
        ),
        "manual_onboardDisableMB_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage("Cartera Existent Detectada"),
        "manual_onboardDisableMB_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy ha trobat una cartera existent al teu núvol personal i la recuperarà ara. Per desactivar les Còpies Màgiques o esborrar aquesta cartera permanentment, visita el menú de còpies.",
        ),
        "manual_setup_change_from_magic_header":
            MessageLookupByLibrary.simpleMessage(
                "Còpies Màgiques desactivades"),
        "manual_setup_change_from_magic_modal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "La teva Còpia de Seguretat Màgica està a punt d\'esborrar-se permanentment. Assegura\'t que la clau privada està desada de manera segura i que descarregues el fitxer de còpia de seguretat d\'Envoy.\n\nAquesta acció suprimirà permanentment la clau d\'Envoy del teu compte d\'Apple o Google, i les dades xifrades d\'Envoy dels servidors de Foundation després d\'un període d\'espera de 24 h.",
        ),
        "manual_setup_change_from_magic_subheaderApple":
            MessageLookupByLibrary.simpleMessage(
          "Les dades de la Còpia de Seguretat Màgica d\'Envoy s\'han suprimit correctament del teu compte d\'Apple i dels servidors de Foundation.",
        ),
        "manual_setup_change_from_magic_subheaderGoogle":
            MessageLookupByLibrary.simpleMessage(
          "Les dades de la Còpia de Seguretat Màgica d\'Envoy s\'han suprimit correctament del teu compte de Google i dels servidors de Foundation.",
        ),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Tria Destinació"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Desa el Fitxer de Còpia d\'Envoy",
        ),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("Ho entenc"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "El fitxer de còpia d\'Envoy està xifrat amb les teves paraules de clau.\n\nSi perds l\'accés a les paraules de clau, no podràs recuperar la còpia.",
        ),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy ha generat la teva còpia de seguretat xifrada. Aquesta còpia de seguretat conté dades útils de la cartera, com ara Etiquetes, Notes, comptes i configuracions.\n\nPots triar protegir-la al núvol, un altre dispositiu o una opció d\'emmagatzematge extern com una targeta microSD.",
        ),
        "manual_setup_generate_seed_CTA": MessageLookupByLibrary.simpleMessage(
          "Genera Clau",
        ),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage(
          "Mantén la Teva Clau Privada",
        ),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Mantén privades les paraules de clau. Qui accedeixi a aquesta clau pot gastar el teu Bitcoin!",
        ),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage(
                "Tria una paraula per continuar"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Verifiquem la Teva Clau Privada"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage("Verifica la Clau"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Entrada No Vàlida"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot verificar la teva clau. Confirma que has enregistrat correctament la teva clau i torna-ho a provar.",
        ),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage("Paraula de clau número"),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correcte"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy et farà algunes preguntes per verificar que has enregistrat correctament la teva clau.",
        ),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Escriu Aquestes 24 Paraules"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Escriu Aquestes 12 Paraules"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Generant Clau"),
        "manual_setup_import_backup_CTA1": MessageLookupByLibrary.simpleMessage(
          "Crea Fitxer de Còpia d\'Envoy",
        ),
        "manual_setup_import_backup_CTA2": MessageLookupByLibrary.simpleMessage(
          "Importa Fitxer de Còpia d\'Envoy",
        ),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "No podem llegir la Còpia de Seguretat d\'Envoy",
        ),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que has seleccionat el fitxer correcte.",
        ),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Vols restaurar un fitxer de còpia de seguretat d\'Envoy existent?\n\nSi no, Envoy crearà un nou fitxer de còpia de seguretat xifrat.",
        ),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Sembla que aquesta clau no és vàlida. Comprova les paraules introduïdes, inclòs l\'ordre en què es troben, i torna-ho a provar.",
        ),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Introdueix la Teva Clau"),
        "manual_setup_import_seed_CTA1": MessageLookupByLibrary.simpleMessage(
          "Importa amb codi QR",
        ),
        "manual_setup_import_seed_CTA2": MessageLookupByLibrary.simpleMessage(
          "Clau de 24 Mots",
        ),
        "manual_setup_import_seed_CTA3": MessageLookupByLibrary.simpleMessage(
          "Clau de 12 Mots",
        ),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage(
          "La meva clau té contrasenya",
        ),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage(
          "Importa la Teva Clau Privada",
        ),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
          "Mai importis la teva clau privada de Passport en les següents pantalles.",
        ),
        "manual_setup_import_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Continua a continuació per importar una clau existent.\n\nMés endavant tindràs l\'opció d\'importar un fitxer de còpia de seguretat d\'Envoy.",
        ),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Importació de Clau Privada"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage(
                "S\'Ha Detectat una Còpia Màgica"),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignora"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restaura"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
          "S\'ha trobat una Còpia Màgica al servidor. \nVols restaurar-la?",
        ),
        "manual_setup_recovery_fail_cta2": MessageLookupByLibrary.simpleMessage(
          "Importa Clau Privada",
        ),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "No es pot escanejar el Codi QR",
        ),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Prova d\'escanejar de nou o importa manualment la clau privada.",
        ),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si continues sense un fitxer de còpia de seguretat, la configuració de la teva cartera, els comptes addicionals, les Etiquetes i les Notes no es restauraran.",
        ),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Reescriu la contrasenya"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage(
                "Tria un altre Fitxer de Còpia"),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no pot obrir aquest Fitxer de Còpia d\'Envoy",
        ),
        "manual_setup_recovery_import_backup_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Pot ser perquè has importat un fitxer de còpia de seguretat d\'una altra cartera Envoy o perquè la contrasenya s\'ha introduït incorrectament.",
        ),
        "manual_setup_recovery_import_backup_re_enter_passphrase_heading":
            MessageLookupByLibrary.simpleMessage(
                "Reescriu la teva\ncontrasenya"),
        "manual_setup_recovery_import_backup_re_enter_passphrase_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Reescriu amb cura la contrasenya perquè Envoy pugui obrir la còpia d\'Envoy.",
        ),
        "manual_setup_recovery_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Introdueix la teva contrasenya"),
        "manual_setup_recovery_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta clau té contrasenya. Introdueix-la per importar la teva cartera Envoy.",
        ),
        "manual_setup_recovery_success_heading":
            MessageLookupByLibrary.simpleMessage("Important la teva Clau"),
        "manual_setup_tutorial_CTA1": MessageLookupByLibrary.simpleMessage(
          "Genera Clau Nova",
        ),
        "manual_setup_tutorial_CTA2": MessageLookupByLibrary.simpleMessage(
          "Importar Clau",
        ),
        "manual_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
          "Configuració Manual de Claus",
        ),
        "manual_setup_tutorial_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si prefereixes gestionar les teves paraules de clau, continua per importar o crear una clau nova.\n\nNomés tu seràs responsable de gestionar les còpies de seguretat. No s\'utilitzaran serveis de núvol.",
        ),
        "manual_setup_verify_enterYourPassphrase":
            MessageLookupByLibrary.simpleMessage(
                "Introdueix la teva contrasenya"),
        "manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Majúscules, minúscules i espais compten. Escriu-la amb cura.",
        ),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2":
            MessageLookupByLibrary.simpleMessage(
          "Les [[contrasenyes]] són una funció avançada.",
        ),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si no entens les implicacions d\'utilitzar-ne una, tanca aquest quadre i continua sense cap.\n\nFoundation no pot recuperar una contrasenya perduda o incorrecta.",
        ),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Verifica la teva contrasenya"),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Torna a introduir la contrasenya amb cura.",
        ),
        "manual_toggle_off_disabled_for_manual_seed_configuration":
            MessageLookupByLibrary.simpleMessage(
          "Inactiu per Configuració Manual de Clau",
        ),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage(
                "Descarrega la Còpia d\'Envoy"),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage(
          "Veure Clau d\'Envoy",
        ),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
          "A la Còpia Automàtica d\'Android",
        ),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Còpia d\'Envoy"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Clau d\'Envoy"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Fes còpia ara"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage(
          "Còpia desada al Clauer d\'iCloud",
        ),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage("als Servidors de Foundation"),
        "manual_toggle_on_seed_backingup": MessageLookupByLibrary.simpleMessage(
          "Fent còpia…",
        ),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage("Còpia en Progrés"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
          "La còpia de seguretat d\'Envoy s\'ha completat.",
        ),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Pujant Còpia de Seguretat d\'Envoy",
        ),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta còpia de seguretat conté dispositius i comptes connectats, etiquetes i configuració d\'aplicacions. No conté informació de la teva clau privada.\n\nLes còpies de seguretat d\'Envoy estan xifrades d\'extrem a extrem, Foundation no té accés ni coneixement dels seus continguts.\n\nEnvoy et notificarà quan s\'hagi completat la pujada.",
        ),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Configuració d\'Android"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
          "Còpia de Seguretat Automàtica d\'Android Pendent (un cop al dia)",
        ),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
          "Còpia pendent al Clauer d\'iCloud",
        ),
        "manual_toggle_on_seed_uploading_foundation_servers":
            MessageLookupByLibrary.simpleMessage(
          "Pujant als Servidors de Foundation",
        ),
        "menu_about": MessageLookupByLibrary.simpleMessage("Sobre"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("Còpies de Seguretat"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_privacy": MessageLookupByLibrary.simpleMessage("Privacitat"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("Configuració"),
        "menu_support": MessageLookupByLibrary.simpleMessage("Suport"),
        "menu_toast_accountAlreadyConnected":
            MessageLookupByLibrary.simpleMessage(
          "Compte ja connectat.",
        ),
        "menu_toast_couldntDeleteEnvoySeed":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut suprimir la clau d\'Envoy.",
        ),
        "menu_toast_developerModeEnabled": MessageLookupByLibrary.simpleMessage(
          "Mode Desenvolupador Activat.",
        ),
        "menu_toast_envoySeedDeleted": MessageLookupByLibrary.simpleMessage(
          "Clau d\'Envoy suprimida.",
        ),
        "menu_toast_logsCopied": MessageLookupByLibrary.simpleMessage(
          "Registres copiats al porta-retalls.",
        ),
        "menu_toast_securityCheckDisabled":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de seguretat desactivada",
        ),
        "menu_toast_unexpectedError": MessageLookupByLibrary.simpleMessage(
          "S\'ha produït un error inesperat. Torna-ho a provar.",
        ),
        "onboardin_unifiedAccountsModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Des de la versió 2.0.0, tots els tipus d\'adreça són accessibles des d\'una sola targeta de compte.\n\nEl tipus d\'adreça de recepció per defecte es pot canviar a Configuració.",
        ),
        "onboardin_unifiedAccountsModal_tilte":
            MessageLookupByLibrary.simpleMessage("Tipus d\'Adreça Unificats"),
        "onboarding_advancedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Si continues sense Còpies de Seguretat Màgiques, seràs responsable de desar les teves paraules de clau i dades de còpia.",
        ),
        "onboarding_advancedModal_header": MessageLookupByLibrary.simpleMessage(
          "Estàs segur?",
        ),
        "onboarding_advanced_magicBackupSwitchText":
            MessageLookupByLibrary.simpleMessage(
          "Còpia i recuperació simples i segures",
        ),
        "onboarding_advanced_magicBackups":
            MessageLookupByLibrary.simpleMessage(
          "Còpies Màgiques",
        ),
        "onboarding_advanced_magicBackupsContent":
            MessageLookupByLibrary.simpleMessage(
          "Còpies xifrades automàtiques de les teves dades per a una recuperació instantània i sense estrès.",
        ),
        "onboarding_advanced_title": MessageLookupByLibrary.simpleMessage(
          "Opcions Avançades",
        ),
        "onboarding_appclip_header": MessageLookupByLibrary.simpleMessage(
          "Benvingut a Passport",
        ),
        "onboarding_appclip_subheaderCore":
            MessageLookupByLibrary.simpleMessage(
          "Instal·la Envoy per configurar Passport Core.",
        ),
        "onboarding_appclip_subheaderPrime":
            MessageLookupByLibrary.simpleMessage(
          "Instal·la Envoy per configurar Passport Prime.",
        ),
        "onboarding_bluetoothDisabled_content":
            MessageLookupByLibrary.simpleMessage(
          "Passport Prime requereix Bluetooth per a la configuració inicial amb QuantumLink. Això permet sincronitzar data i hora, actualitzacions de firmware, comprovacions de seguretat, còpies i més.\n\nActiva els permisos Bluetooth a la configuració d\'Envoy.",
        ),
        "onboarding_bluetoothDisabled_enable":
            MessageLookupByLibrary.simpleMessage(
          "Activa a Configuració",
        ),
        "onboarding_bluetoothDisabled_header":
            MessageLookupByLibrary.simpleMessage(
          "Activa Bluetooth per a QuantumLink",
        ),
        "onboarding_bluetoothIntro_connect":
            MessageLookupByLibrary.simpleMessage(
          "Connecta amb QuantumLink",
        ),
        "onboarding_bluetoothIntro_content":
            MessageLookupByLibrary.simpleMessage(
          "Passport Prime utilitza un nou protocol segur basat en Bluetooth per comunicar-se en temps real amb Envoy.\n\nQuantumLink crea un túnel xifrat d\'extrem a extrem entre Passport i Envoy per garantir una connexió segura.",
        ),
        "onboarding_bluetoothIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Protegeix Bluetooth amb\nQuantumLink",
        ),
        "onboarding_connectionChecking_SecurityPassed":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de Seguretat Superada",
        ),
        "onboarding_connectionChecking_forUpdates":
            MessageLookupByLibrary.simpleMessage("Cercant Actualitzacions"),
        "onboarding_connectionIntroError2_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy no ha pogut connectar amb els servidors de Foundation. Assegura\'t que tens connexió a Internet.",
        ),
        "onboarding_connectionIntroErrorInternet_content":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut comunicar amb el servidor de seguretat. Comprova la connexió a Internet i torna-ho a provar.",
        ),
        "onboarding_connectionIntroErrorInternet_securityCheckIncomplete":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de Seguretat Incompleta",
        ),
        "onboarding_connectionIntroErrorInternet_securityCheckPending":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de Seguretat Pendent",
        ),
        "onboarding_connectionIntroErrorSecurityIncomplete_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantén Passport a prop, comprova la connexió a internet i assegura\'t que la data i l\'hora del telèfon estiguin configurades automàticament. Després, torna-ho a provar.",
        ),
        "onboarding_connectionIntroError_content":
            MessageLookupByLibrary.simpleMessage(
          "Aquest dispositiu podria no ser genuí o haver estat manipulat durant l\'enviament. Contacta amb el servei tècnic per rebre ajuda.",
        ),
        "onboarding_connectionIntroError_exitSetup":
            MessageLookupByLibrary.simpleMessage("Surt de la Configuració"),
        "onboarding_connectionIntroError_securityCheckFailed":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de Seguretat Fallida",
        ),
        "onboarding_connectionIntroError_securityCheckPending":
            MessageLookupByLibrary.simpleMessage(
          "Comprovació de Seguretat Pendent",
        ),
        "onboarding_connectionIntroWarning_content":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que Passport Prime estigui encès i a prop del telèfon.",
        ),
        "onboarding_connectionIntroWarning_header":
            MessageLookupByLibrary.simpleMessage("Configuració Pausada"),
        "onboarding_connectionIntro_checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Cerca Actualitzacions"),
        "onboarding_connectionIntro_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage("Comprovant la Seguretat"),
        "onboarding_connectionIntro_connectedToPrime":
            MessageLookupByLibrary.simpleMessage("Connectat a Passport Prime"),
        "onboarding_connectionIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Passport Prime Connectat",
        ),
        "onboarding_connectionModalAbort_content":
            MessageLookupByLibrary.simpleMessage(
          "Continua només si vols perdre tot el progrés i reiniciar la configuració de Passport des del principi.",
        ),
        "onboarding_connectionModalAbort_header":
            MessageLookupByLibrary.simpleMessage("Deixar l\'Assistent?"),
        "onboarding_connectionModalExitOnboarding_content":
            MessageLookupByLibrary.simpleMessage(
          "Això esborrarà tot el progrés. Hauràs de començar la configuració de Passport Prime des del principi.",
        ),
        "onboarding_connectionModalExitOnboarding_header":
            MessageLookupByLibrary.simpleMessage("Deixar l\'Assistent?"),
        "onboarding_connectionNoUpdates_noUpdates":
            MessageLookupByLibrary.simpleMessage("Cap Actualització"),
        "onboarding_connectionUpdatesAvailable_updatesAvailable":
            MessageLookupByLibrary.simpleMessage("Nova Actualització"),
        "onboarding_magicUserMobileCreating_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està creant una clau segura per utilitzar-la amb la teva Cartera Mòbil Bitcoin, que es desarà xifrada d\'extrem a extrem al teu compte d\'Apple o Google.",
        ),
        "onboarding_magicUserMobileCreating_header":
            MessageLookupByLibrary.simpleMessage(
                "Creant la Clau de Cartera Mòbil"),
        "onboarding_magicUserMobileEncrypting_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està xifrant la còpia de seguretat de la cartera.\n\nAquesta còpia de seguretat conté dades útils de la cartera, com ara etiquetes, notes, comptes i configuració.",
        ),
        "onboarding_magicUserMobileEncrypting_header":
            MessageLookupByLibrary.simpleMessage("Xifrant Còpia de Cartera"),
        "onboarding_magicUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
          "També coneguda com a “cartera calenta”. Gastar des d\'aquesta cartera només requereix el teu telèfon per autoritzar.",
        ),
        "onboarding_magicUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
          "La Clau de Cartera Mòbil es desarà xifrada a l\'enclavament segur del telèfon i se\'n farà còpia al teu compte d\'Apple o Google.",
        ),
        "onboarding_magicUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Configura una Cartera Mòbil amb Còpies Màgiques",
        ),
        "onboarding_magicUserMobileIntro_learnMoreMagicBackups":
            MessageLookupByLibrary.simpleMessage(
                "Aprèn més sobre Còpies Màgiques"),
        "onboarding_magicUserMobileSuccess_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està configurat i preparat per al teu Bitcoin!",
        ),
        "onboarding_magicUserMobileSuccess_header":
            MessageLookupByLibrary.simpleMessage(
          "La Teva Cartera Mòbil Està a Punt",
        ),
        "onboarding_magicUserMobileUploading_content":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està pujant la còpia de seguretat xifrada de la teva cartera als servidors de Foundation.\n\nCom que la teva còpia de seguretat està xifrada d\'extrem a extrem, Foundation no hi té accés ni en coneix el contingut.",
        ),
        "onboarding_magicUserMobileUploading_header":
            MessageLookupByLibrary.simpleMessage("Pujant Còpia de Seguretat"),
        "onboarding_migrating_xOfYSynced": m12,
        "onboarding_modalBluetoothUnableConnect_content":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que Bluetooth està activat a Passport i al telèfon, i que tots dos dispositius són a prop.",
        ),
        "onboarding_modalBluetoothUnableConnect_header":
            MessageLookupByLibrary.simpleMessage("No es Pot Connectar"),
        "onboarding_passpportSelectCamera_sub235VersionAlert":
            MessageLookupByLibrary.simpleMessage(
          "Estàs configurant un Passport Core amb firmware v2.3.5 o anterior?",
        ),
        "onboarding_passpportSelectCamera_tapHere":
            MessageLookupByLibrary.simpleMessage("Toca aquí"),
        "onboarding_primeIntroError_content":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut connectar a Internet. Comprova la connexió.",
        ),
        "onboarding_primeIntro_content": MessageLookupByLibrary.simpleMessage(
          "Enhorabona per fer el primer pas per protegir tota la teva vida digital.\n\nConfigurar el teu Passport Prime només trigarà 5-10 minuts. Agafa el dispositiu i comencem!",
        ),
        "onboarding_primeIntro_header": MessageLookupByLibrary.simpleMessage(
          "Configura el Teu Passport Prime",
        ),
        "onboarding_sovereignUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
          "També coneguda com a “cartera calenta”. Gastar des d\'aquesta cartera només requereix el teu telèfon per autoritzar.",
        ),
        "onboarding_sovereignUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
          "Les teves claus Bitcoin es desaran a l\'enclavament segur del telèfon. Només tu ets responsable de mantenir una còpia de la clau privada.",
        ),
        "onboarding_sovereignUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage("Configura la Cartera Mòbil"),
        "onboarding_tutorialColdWallet_content":
            MessageLookupByLibrary.simpleMessage(
          "També coneguda com a “cartera freda”. Gastar des d\'aquesta cartera requereix l\'autorització del teu dispositiu Passport.\n\nLa Clau Mestra de Passport sempre es desa de manera segura fora de línia.\n\nUtilitza aquesta cartera per protegir la major part dels teus estalvis en Bitcoin.",
        ),
        "onboarding_tutorialColdWallet_header":
            MessageLookupByLibrary.simpleMessage("Cartera Passport"),
        "onboarding_tutorialHotWallet_content":
            MessageLookupByLibrary.simpleMessage(
          "També coneguda com a “cartera calenta”. Gastar des d\'aquesta cartera només requereix el teu telèfon per autoritzar.\n\nCom que la Cartera Mòbil està connectada a Internet, utilitza-la per desar petites quantitats de Bitcoin per a transaccions freqüents.",
        ),
        "onboarding_tutorialHotWallet_header":
            MessageLookupByLibrary.simpleMessage(
          "Cartera Mòbil",
        ),
        "onboarding_welcome_content": MessageLookupByLibrary.simpleMessage(
          "Recupera la teva sobirania amb Envoy, una cartera Bitcoin senzilla amb potents funcions de gestió de comptes i privacitat.",
        ),
        "onboarding_welcome_createMobileWallet":
            MessageLookupByLibrary.simpleMessage("Crea una\nCartera Mòbil"),
        "onboarding_welcome_header": MessageLookupByLibrary.simpleMessage(
          "Benvingut a Envoy",
        ),
        "onboarding_welcome_setUpPassport":
            MessageLookupByLibrary.simpleMessage(
          "Configura un\nDispositiu Passport",
        ),
        "pair_existing_device_intro_heading":
            MessageLookupByLibrary.simpleMessage(
          "Connecta Passport\namb Envoy",
        ),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Passport, selecciona Gestiona el Compte > Connecta la Cartera > Envoy.",
        ),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
          "Escaneja aquest codi QR amb Passport per validar",
        ),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquesta és una adreça de Bitcoin del teu Passport.",
        ),
        "pair_new_device_address_cta2": MessageLookupByLibrary.simpleMessage(
          "Contacta amb el Suport",
        ),
        "pair_new_device_address_heading": MessageLookupByLibrary.simpleMessage(
          "Adreça validada?",
        ),
        "pair_new_device_address_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si reps un missatge d\'èxit a Passport, la configuració ja s\'ha completat.\n\nSi Passport no ha pogut verificar l\'adreça, torna-ho a provar o contacta amb el servei tècnic.",
        ),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquest pas permet a Envoy generar adreces de rebuda per Passport i proposar transaccions que Passport ha d\'autoritzar.",
        ),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
          "Escaneja el codi QR que genera Passport",
        ),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
          "El codi QR conté la informació necessària perquè Envoy pugui interactuar de manera segura amb Passport.",
        ),
        "pair_new_device_success_cta1": MessageLookupByLibrary.simpleMessage(
          "Valida l\'adreça de recepció",
        ),
        "pair_new_device_success_cta2": MessageLookupByLibrary.simpleMessage(
          "Continua a la pantalla d\'inici",
        ),
        "pair_new_device_success_heading": MessageLookupByLibrary.simpleMessage(
          "Connexió satisfactòria",
        ),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy està connectat al teu Passport.",
        ),
        "passport_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
          "Configurar un Passport nou",
        ),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Connecta un Passport existent",
        ),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
          "No tinc Passport. [[Aprèn més.]]",
        ),
        "passport_welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Benvingut a Passport",
        ),
        "passport_welcome_screen_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy ofereix configuració segura de Passport, actualitzacions de firmware fàcils i una cartera Bitcoin zen.",
        ),
        "prime_info_color": m13,
        "prime_info_firmware": m14,
        "prime_info_serialNumber": m15,
        "privacySetting_nodeConnected": MessageLookupByLibrary.simpleMessage(
          "Node Connectat",
        ),
        "privacy_applicationLock_title": MessageLookupByLibrary.simpleMessage(
          "Bloqueig de l\'aplicació",
        ),
        "privacy_applicationLock_unlock": MessageLookupByLibrary.simpleMessage(
          "Desbloqueja amb biometria o PIN",
        ),
        "privacy_blockExplorer_couldNotReachBlockExplorer":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut accedir al Block Explorer",
        ),
        "privacy_blockExplorer_success": MessageLookupByLibrary.simpleMessage(
          "Connexió correcta al Block Explorer",
        ),
        "privacy_blockExplorer_urlError": MessageLookupByLibrary.simpleMessage(
          "Falta el prefix http:// o https:// a l\'URL",
        ),
        "privacy_explorer_configure": MessageLookupByLibrary.simpleMessage(
          "Millora la privacitat connectant el teu propi explorador de blocs. Toca aprèn més a dalt.",
        ),
        "privacy_explorer_explorerAddress":
            MessageLookupByLibrary.simpleMessage(
          "Introdueix l\'adreça de l\'explorador",
        ),
        "privacy_explorer_explorerType_personal":
            MessageLookupByLibrary.simpleMessage("Block Explorer Personal"),
        "privacy_explorer_title": MessageLookupByLibrary.simpleMessage(
          "Block Explorer",
        ),
        "privacy_invalidCertificateModal_connectAnyway":
            MessageLookupByLibrary.simpleMessage("Connecta Igualment"),
        "privacy_invalidCertificateModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Aquest node té un certificat no vàlid o autosignat. La connexió pot no ser segura.\nVols connectar igualment?",
        ),
        "privacy_invalidCertificateModal_header":
            MessageLookupByLibrary.simpleMessage("Certificat No Vàlid"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
          "Millora la teva privacitat executant el teu propi node. Toca aprèn més a dalt. ",
        ),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage(
          "Bloc actual:",
        ),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage(
                "Connectat al servidor Esplora"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut connectar al servidor Esplora.",
        ),
        "privacy_node_connectedTo": MessageLookupByLibrary.simpleMessage(
          "Connectat a",
        ),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut connectar al node.",
        ),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
          "Fins i tot amb ‘Privacitat Millorada’ activa, Envoy no pot evitar interferències de dispositius compromesos a la teva xarxa local.",
        ),
        "privacy_node_nodeAddress": MessageLookupByLibrary.simpleMessage(
          "Introdueix l\'adreça del teu node",
        ),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage(
          "Foundation (per Defecte)",
        ),
        "privacy_node_nodeType_personal": MessageLookupByLibrary.simpleMessage(
          "Node Personal",
        ),
        "privacy_node_nodeType_publicServers":
            MessageLookupByLibrary.simpleMessage(
          "Servidors públics",
        ),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Node"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Millor\nRendiment"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage(
          "Privacitat\nMillorada",
        ),
        "privacy_privacyMode_title": MessageLookupByLibrary.simpleMessage(
          "Mode de privacitat",
        ),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
          "La connexió d\'Envoy serà fiable amb Tor [[APAGAT]]. Suggerit per a nous usuaris.",
        ),
        "privacy_privacyMode_torSuggestionOn":
            MessageLookupByLibrary.simpleMessage(
          "Tor estarà [[ACTIVAT]] per millorar la privacitat. És possible que la connexió d\'Envoy no sigui fiable.",
        ),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Afegeix Node"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Editar Node"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
          "El teu Node està connectat via Clearnet.",
        ),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
          "No hem pogut connectar el teu node",
        ),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Connecta"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("Connectant el Teu Node"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
          "El teu Node està connectat via Tor.",
        ),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage(
          "Tria la Teva Privacitat",
        ),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Com vols que Envoy es connecti a Internet?",
        ),
        "qrTooBig_warning_subheading": MessageLookupByLibrary.simpleMessage(
          "El codi QR escanejat conté moltes dades i podria fer que Envoy es torni inestable. Segur que vols continuar?",
        ),
        "ramp_note": MessageLookupByLibrary.simpleMessage("Compra Ramp"),
        "ramp_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Compra Ramp Pendent",
        ),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage("Usa Adreça Taproot"),
        "receive_mobileWallet_multiplePassportContent":
            MessageLookupByLibrary.simpleMessage(
          "Els fons enviats a aquesta adreça només es poden gastar amb el telèfon. Per protegir-los fora de línia, tria un compte Passport [[aquí]].",
        ),
        "receive_mobileWallet_singlePassportContent":
            MessageLookupByLibrary.simpleMessage(
          "Els fons enviats a aquesta adreça només es poden gastar amb el telèfon. Per protegir-los fora de línia amb Passport, [[toca aquí]].",
        ),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("REBRE"),
        "receive_qr_copy": MessageLookupByLibrary.simpleMessage("Copia"),
        "receive_qr_rescanAccount": MessageLookupByLibrary.simpleMessage(
          "Reescaneja Compte",
        ),
        "receive_qr_share": MessageLookupByLibrary.simpleMessage("Comparteix"),
        "receive_qr_signMessage": MessageLookupByLibrary.simpleMessage(
          "Signa Missatge",
        ),
        "receive_toast_addressCopied": MessageLookupByLibrary.simpleMessage(
          "Adreça copiada al porta-retalls.",
        ),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("Pendent de confirmació"),
        "receive_tx_list_change": MessageLookupByLibrary.simpleMessage("Canvi"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Rebre"),
        "receive_tx_list_scan":
            MessageLookupByLibrary.simpleMessage("Escaneja"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "receive_tx_list_transfer":
            MessageLookupByLibrary.simpleMessage("Traspàs"),
        "receive_verifyModalCore_content": m16,
        "receive_verifyModalPrime_content": m17,
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
          "Inicia sessió a Google i restaura les teves dades de la teva còpia de seguretat",
        ),
        "recovery_scenario_heading": MessageLookupByLibrary.simpleMessage(
          "Com es Recupera?",
        ),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
          "Instal·la Envoy i toca “Configura la Cartera d\'Envoy”",
        ),
        "recovery_scenario_ios_instruction1":
            MessageLookupByLibrary.simpleMessage(
          "Inicia sessió a iCloud i restaura la teva còpia de seguretat d\'iCloud",
        ),
        "recovery_scenario_ios_instruction3":
            MessageLookupByLibrary.simpleMessage(
          "Envoy restaurarà automàticament la teva Còpia de Seguretat Màgica",
        ),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
          "Per recuperar la teva cartera d\'Envoy, segueix aquestes instruccions senzilles.",
        ),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
          "La comissió escollida només es pot aconseguir afegint més monedes. Envoy ho fa automàticament i mai inclourà cap moneda bloquejada. ",
        ),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage(
          "Augmentant la transacció",
        ),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut augmentar la teva transacció",
        ),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage("Revisa les Monedes"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
          "La teva transacció s\'ha augmentat",
        ),
        "replaceByFee_boost_tx_boostFee": MessageLookupByLibrary.simpleMessage(
          "Comissió per Augmentar",
        ),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
          "Ja pots augmentar la teva \ntransacció",
        ),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage(
          "Cap",
        ),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "La comissió de xarxa per cancel·lar aquesta transacció significa que no s\'enviaran fons a la cartera.\n\nEstàs segur que vols cancel·lar?",
        ),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage(
          "S\'està cancel·lant la transacció",
        ),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut cancel·lar la teva transacció",
        ),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Comissió d\'Anul·lació"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage(
                "Continueu amb la Cancel·Lació"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Import de Recepció"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Substitueix la transacció no confirmada per una que contingui una comissió més alta i que torni els fons a la teva cartera.",
        ),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "La teva transacció s\'ha cancel·lat",
        ),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aquest és un intent de cancel·lació. Hi ha una petita possibilitat que la teva transacció original sigui confirmada abans d\'aquest intent de cancel·lació.",
        ),
        "replaceByFee_coindetails_overlayNotice":
            MessageLookupByLibrary.simpleMessage(
          "Les funcions d\'augmentar i cancel·lar estaran disponibles quan la transacció s\'hagi acabat de transmetre.",
        ),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Augmenta"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Augmenta la Transacció"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Augmenta la comissió adjunta a la teva transacció per accelerar el temps de confirmació.",
        ),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Cal per Augmentar"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transaccions Eliminades"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Les compres incompletes amb els ID de Ramp següents s\'han eliminat de l\'activitat al cap de 5 dies.",
        ),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Nova Comissió ",
        ),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per augmentar la transacció original, pagaràs una nova comissió de:",
        ),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
          "Això substituirà la comissió original de:",
        ),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
          "Les compres incompletes se suprimiran automàticament al cap de 5 dies",
        ),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "La comissió escollida només es pot aconseguir afegint més monedes. Envoy ho fa automàticament i mai no inclourà cap moneda bloquejada. \n\nAquesta selecció es pot revisar o editar a la pantalla següent.",
        ),
        "rescanAccount_pullToSync_pullToSync":
            MessageLookupByLibrary.simpleMessage(
          "Estira i sincronitza",
        ),
        "rescanAccount_rescanning_rescanningAccount":
            MessageLookupByLibrary.simpleMessage(
          "Reescanejant el compte. No tanquis Envoy.",
        ),
        "rescanAccount_sizeModal_1000Addresses":
            MessageLookupByLibrary.simpleMessage("1000 Adreces (~10 min)"),
        "rescanAccount_sizeModal_300Addresses":
            MessageLookupByLibrary.simpleMessage("300 Adreces (~3 min)"),
        "rescanAccount_sizeModal_500Addresses":
            MessageLookupByLibrary.simpleMessage("500 Adreces (~5 min)"),
        "rescanAccount_sizeModal_content": MessageLookupByLibrary.simpleMessage(
          "S\'han escanejat 100 adreces abans. Si falten fons, prova un valor més alt.",
        ),
        "rescanAccount_sizeModal_header": MessageLookupByLibrary.simpleMessage(
          "Reescaneja Compte",
        ),
        "rescanAccount_toast_rescanningFailed": m18,
        "rescanAccount_toast_rescanningStarted":
            MessageLookupByLibrary.simpleMessage(
          "Reescaneig iniciat. No tanquis Envoy.",
        ),
        "rescanAccount_toast_rescanningSuccessful": m19,
        "scanner_toast_failedConnectPrime":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut connectar a Passport Prime. Torna-ho a provar i contacta amb suport si persisteix.",
        ),
        "scanner_toast_notValidQr": MessageLookupByLibrary.simpleMessage(
          "QR no vàlid.",
        ),
        "scv_cameraModalUnexpectedQrFormat_content":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que escaneges un codi QR de comprovació de seguretat de Passport.",
        ),
        "scv_cameraModalUnexpectedQrFormat_header":
            MessageLookupByLibrary.simpleMessage("Format QR Inesperat"),
        "scv_checkingDeviceSecurity": MessageLookupByLibrary.simpleMessage(
          "Comprovant la Seguretat",
        ),
        "send_QrReview_viewDetails": MessageLookupByLibrary.simpleMessage(
          "Veure Detalls",
        ),
        "send_QrScan_saveToFile": MessageLookupByLibrary.simpleMessage(
          "Desa a Fitxer",
        ),
        "send_build_amount": MessageLookupByLibrary.simpleMessage("Import"),
        "send_build_header": MessageLookupByLibrary.simpleMessage(
          "Comprova Detalls de Transacció",
        ),
        "send_build_subheader": MessageLookupByLibrary.simpleMessage(
          "Confirma que els detalls de la transacció són correctes abans de continuar.",
        ),
        "send_build_viewEditDetails": MessageLookupByLibrary.simpleMessage(
          "Veure i Editar Detalls",
        ),
        "send_editTxDetailsSubsatModal_activate":
            MessageLookupByLibrary.simpleMessage("Activa"),
        "send_editTxDetailsSubsatModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Comprova que el node connectat pot gestionar comissions per sota d\'1 sat/vb abans de continuar.",
        ),
        "send_editTxDetailsSubsatModal_header":
            MessageLookupByLibrary.simpleMessage("Comissions sota 1 sat/vb"),
        "send_editTxDetails_addNoteExample":
            MessageLookupByLibrary.simpleMessage(
          "p. ex. Bitcoin P2P comprat",
        ),
        "send_editTxDetails_applyChangeTag":
            MessageLookupByLibrary.simpleMessage(
          "Aplica Etiqueta de Canvi",
        ),
        "send_editTxDetails_applyChanges": MessageLookupByLibrary.simpleMessage(
          "Aplica Canvis",
        ),
        "send_editTxDetails_changeAddress":
            MessageLookupByLibrary.simpleMessage(
          "Adreça de Canvi",
        ),
        "send_editTxDetails_changeAmount": MessageLookupByLibrary.simpleMessage(
          "Import de Canvi",
        ),
        "send_editTxDetails_feeNoEstimatePossible":
            MessageLookupByLibrary.simpleMessage("No hi ha estimació"),
        "send_editTxDetails_spendingFromAccount":
            MessageLookupByLibrary.simpleMessage("Gastant des del Compte"),
        "send_editTxDetails_spentFrom": MessageLookupByLibrary.simpleMessage(
          "Gastat des de",
        ),
        "send_editTxDetails_tagDetails": MessageLookupByLibrary.simpleMessage(
          "Detalls de l\'Etiqueta",
        ),
        "send_keyboard_address_confirm": MessageLookupByLibrary.simpleMessage(
          "Confirma",
        ),
        "send_keyboard_address_loading": MessageLookupByLibrary.simpleMessage(
          "Carregant…",
        ),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage("Cal una adreça vàlida"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Fons Insuficients"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage(
          "Import massa baix",
        ),
        "send_keyboard_enterAddress": MessageLookupByLibrary.simpleMessage(
          "Introdueix adreça",
        ),
        "send_keyboard_send_max": MessageLookupByLibrary.simpleMessage(
          "Envia Màxim",
        ),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("A:"),
        "send_qrReviewModalCantReadSignedMessage_header":
            MessageLookupByLibrary.simpleMessage(
          "No podem llegir el Missatge Signat",
        ),
        "send_qrReviewModalCantReadSignedTx_header":
            MessageLookupByLibrary.simpleMessage(
          "No podem llegir la Transacció Signada",
        ),
        "send_qrReview_scanSignedTransaction":
            MessageLookupByLibrary.simpleMessage(
          "Escaneja transacció signada",
        ),
        "send_qrReview_viewDetails": MessageLookupByLibrary.simpleMessage(
          "Veure Detalls",
        ),
        "send_qrScan_header": MessageLookupByLibrary.simpleMessage(
          "Escaneja aquest QR amb Passport",
        ),
        "send_qrScan_scanQrWithPassportFirst":
            MessageLookupByLibrary.simpleMessage(
          "Escaneja primer el QR amb Passport",
        ),
        "send_qrScan_subheader": MessageLookupByLibrary.simpleMessage(
          "Conté la transacció perquè la signis al teu Passport.",
        ),
        "send_qrScan_verifyOnPassport": MessageLookupByLibrary.simpleMessage(
          "Verifica a Passport",
        ),
        "send_qrSend_header": MessageLookupByLibrary.simpleMessage(
          "Transacció a punt per enviar",
        ),
        "send_qrSend_subheader": MessageLookupByLibrary.simpleMessage(
          "Envoy enviarà la transacció a la xarxa Bitcoin.",
        ),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
          "Escaneja el QR amb el teu Passport",
        ),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
          "Conté la transacció perquè el teu Passport la signi.",
        ),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
          "Ara pots escanejar el codi QR que es mostra al teu Passport amb la càmera del telèfon.",
        ),
        "send_quantumBuildOutOfRange_makeSureInRangeUnlocked":
            MessageLookupByLibrary.simpleMessage(
          "Per continuar, assegura\'t que Passport Prime estigui encès, a prop i desbloquejat.",
        ),
        "send_quantumBuildOutOfRange_waitingForPassport":
            MessageLookupByLibrary.simpleMessage("Esperant Passport"),
        "send_quantumBuild_signWithPassport":
            MessageLookupByLibrary.simpleMessage(
          "Signa amb Passport",
        ),
        "send_quantumReview_connectedToPassport":
            MessageLookupByLibrary.simpleMessage("Connectat a Passport"),
        "send_quantumReview_transactionTransferred":
            MessageLookupByLibrary.simpleMessage("Transacció Transferida"),
        "send_quantumReview_transferringTransaction":
            MessageLookupByLibrary.simpleMessage("Transferint Transacció"),
        "send_quantumReview_waitForSigning":
            MessageLookupByLibrary.simpleMessage(
          "Esperant Signatura",
        ),
        "send_quantumReview_waitingForSigning":
            MessageLookupByLibrary.simpleMessage("Esperant Signatura"),
        "send_quantumSend_transactionready":
            MessageLookupByLibrary.simpleMessage(
          "Transacció a punt",
        ),
        "send_reviewScreen_sendMaxWarning":
            MessageLookupByLibrary.simpleMessage(
          "Enviar el màxim: les comissions es dedueixen de l\'import enviat.",
        ),
        "send_review_header": MessageLookupByLibrary.simpleMessage(
          "Verifica Detalls de Transacció",
        ),
        "send_review_subheader": MessageLookupByLibrary.simpleMessage(
          "Comprova que aquests detalls coincideixen amb els que mostra el teu Passport.",
        ),
        "settings_advanced": MessageLookupByLibrary.simpleMessage(
          "Opcions Avançades",
        ),
        "settings_advancedModalReceiveSegwit_content":
            MessageLookupByLibrary.simpleMessage(
          "Amb aquest interruptor desactivat, es generaran adreces Native Segwit quan toquis rebre. Aquest és el tipus d\'adreça per defecte de la majoria de carteres Bitcoin.",
        ),
        "settings_advancedModalReceiveSegwit_title":
            MessageLookupByLibrary.simpleMessage("Rebre a Segwit"),
        "settings_advancedModalReceiveTaproot_content":
            MessageLookupByLibrary.simpleMessage(
          "Amb aquest interruptor activat, es generaran adreces Taproot quan toquis rebre. Assegura\'t que qui t\'envia Bitcoin sigui compatible amb Taproot abans de continuar.",
        ),
        "settings_advancedModalReceiveTaproot_title":
            MessageLookupByLibrary.simpleMessage("Rebre a Taproot"),
        "settings_advanced_enableBuyRamp": MessageLookupByLibrary.simpleMessage(
          "Compra a Envoy",
        ),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
          "Aprèn més sobre Signet [[aquí]].",
        ),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si actives Signet, s\'afegeix una versió Signet de la teva Cartera d\'Envoy. Aquesta funció és utilitzada principalment per desenvolupadors o provadors i té un valor zero.",
        ),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage("Aprèn a fer-ho [[aquí]]."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si actives Testnet, s\'afegeix una versió de Testnet4 de la teva cartera Envoy i et permet connectar comptes de Testnet des del teu Passport.",
        ),
        "settings_advanced_receiveToTaproot":
            MessageLookupByLibrary.simpleMessage(
          "Rebre a Taproot",
        ),
        "settings_advanced_resetWarnings": MessageLookupByLibrary.simpleMessage(
          "Restableix els Avisos",
        ),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot": MessageLookupByLibrary.simpleMessage(
          "Taproot",
        ),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activa"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Taproot és una funció avançada i el suport de cartera encara és limitat.\n\nProcedeix amb precaució.",
        ),
        "settings_advanced_testnet": MessageLookupByLibrary.simpleMessage(
          "Testnet",
        ),
        "settings_amount": MessageLookupByLibrary.simpleMessage(
          "Veure Import en Sats",
        ),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Divisa"),
        "settings_show_fiat": MessageLookupByLibrary.simpleMessage(
          "Mostra els Valors en Fiat",
        ),
        "settings_viewEnvoyLogs": MessageLookupByLibrary.simpleMessage(
          "Veure els Registres d\'Envoy",
        ),
        "signMessage_mainSignedQr_scanQr": MessageLookupByLibrary.simpleMessage(
          "Escaneja el QR",
        ),
        "signMessage_mainSignedQr_scanQrSubheader":
            MessageLookupByLibrary.simpleMessage("Conté el missatge signat."),
        "signMessage_mainSigned_copySignature":
            MessageLookupByLibrary.simpleMessage("Copia Signatura"),
        "signMessage_mainSigned_header": MessageLookupByLibrary.simpleMessage(
          "Missatge Signat",
        ),
        "signMessage_mainSigned_saveSignatureToFile":
            MessageLookupByLibrary.simpleMessage("Desa Signatura a Fitxer"),
        "signMessage_mainSigned_signatureInvalid":
            MessageLookupByLibrary.simpleMessage("Signatura invàlida"),
        "signMessage_mainSigned_signatureValid":
            MessageLookupByLibrary.simpleMessage("Signatura vàlida"),
        "signMessage_main_addressDoesNotBelong":
            MessageLookupByLibrary.simpleMessage(
          "L\'adreça no pertany a aquest compte.\nIntrodueix-ne una altra.",
        ),
        "signMessage_main_enterPasteMessage":
            MessageLookupByLibrary.simpleMessage(
          "Introdueix o enganxa el missatge",
        ),
        "signMessage_main_messageHeader": MessageLookupByLibrary.simpleMessage(
          "Missatge",
        ),
        "signMessage_main_signatureHeader":
            MessageLookupByLibrary.simpleMessage(
          "Signatura",
        ),
        "signMessage_qrCamera_importFromFile":
            MessageLookupByLibrary.simpleMessage(
          "Importa des d\'un Fitxer",
        ),
        "signMessage_qr_header": MessageLookupByLibrary.simpleMessage(
          "Escaneja el QR amb Passport",
        ),
        "signMessage_qr_importSignature": MessageLookupByLibrary.simpleMessage(
          "Importa la Signatura",
        ),
        "signMessage_qr_saveToFile": MessageLookupByLibrary.simpleMessage(
          "Desa a Fitxer",
        ),
        "signMessage_qr_scannedSignedByPassport":
            MessageLookupByLibrary.simpleMessage(
                "Escanejat i signat per Passport"),
        "signMessage_qr_subheader": MessageLookupByLibrary.simpleMessage(
          "Conté el missatge perquè el teu Passport el signi.",
        ),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("No, gràcies"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Les notes de transacció poden ser útils per fer despeses futures.",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "No s\'ha pogut enviar la teva transacció",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Comprova la connexió i torna-ho a provar",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subsat_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Assegura\'t que el node connectat pot transmetre transaccions amb comissions sub-sat.",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "La teva transacció s\'ha enviat correctament",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Revisa els detalls tocant la transacció des de la pantalla de detalls del compte.",
        ),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("Enviant transacció"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Això pot trigar uns quants segons",
        ),
        "tagDetails_EditTagName": MessageLookupByLibrary.simpleMessage(
          "Edita el Nom",
        ),
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
        "tagged_coin_details_menu_cta1": MessageLookupByLibrary.simpleMessage(
          "EDITA EL NOM DE L\'ETIQUETA",
        ),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
          "No hi ha monedes assignades a aquesta etiqueta.",
        ),
        "tagged_tagDetails_sheet_cta1": MessageLookupByLibrary.simpleMessage(
          "Envia la Selecció",
        ),
        "tagged_tagDetails_sheet_cta2": MessageLookupByLibrary.simpleMessage(
          "Etiqueta la Selecció",
        ),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Torna a Etiquetar la Selecció",
        ),
        "tagged_tagDetails_sheet_transferSelected":
            MessageLookupByLibrary.simpleMessage("Transferir Selecció"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
          "Mantén premut per arrossegar i ordenar els comptes.",
        ),
        "taproot_passport_dialog_heading": MessageLookupByLibrary.simpleMessage(
          "Taproot a Passport",
        ),
        "taproot_passport_dialog_later": MessageLookupByLibrary.simpleMessage(
          "Més Tard",
        ),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage(
          "Reconnecta Passport",
        ),
        "taproot_passport_dialog_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per habilitar un compte de Passport Taproot, assegura\'t de tenir el firmware 2.3.0 o posterior i reconnecta el teu Passport.",
        ),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
          "No es pot accedir als servidors de Foundation",
        ),
        "toast_newEnvoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
          "Nova actualització d\'Envoy disponible",
        ),
        "toast_repairingSuccessful_content":
            MessageLookupByLibrary.simpleMessage(
          "El reemparellament amb Prime ha estat correcte.",
        ),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage("Reintenta Tor"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage("Desactiva Temporalment Tor"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
          "Pot ser que l\'app rendeixi pitjor fins que Envoy pugui restablir la connexió amb Tor.\n\nDesactivar Tor establirà una connexió directa amb el servidor d\'Envoy, però comporta [[riscos]] de privacitat.",
        ),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
          "Problema de connectivitat amb Tor",
        ),
        "transfer_fromTo_transferFrom": MessageLookupByLibrary.simpleMessage(
          "Transferir des de",
        ),
        "transfer_fromTo_transferTo": MessageLookupByLibrary.simpleMessage(
          "Transferir a",
        ),
        "video_connectingToTorNetwork": MessageLookupByLibrary.simpleMessage(
          "Connectant a la Xarxa Tor",
        ),
        "video_loadingTorText": MessageLookupByLibrary.simpleMessage(
          "Envoy està carregant el vídeo a través de la Xarxa Tor",
        ),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy desa de forma segura i automàtica la clau de la cartera mòbil amb [[Còpia de Seguretat Automàtica d\'Android]].\n\nLa clau sempre està xifrada d\'extrem a extrem i Google no la veu mai.",
        ),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy fa una còpia de seguretat automàtica i segura de la clau de la cartera mòbil a [[Clauer d\'iCloud]].\n\nLa teva clau sempre està xifrada d\'extrem a extrem i mai no és visible per a Apple.",
        ),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Es fa una còpia de seguretat automàtica de les dades de la teva cartera, incloses etiquetes, notes, comptes i configuració, als servidors de Foundation.\n\nAquesta còpia de seguretat es xifra primer amb la clau privada de la teva cartera, cosa que garanteix que Foundation mai no pugui accedir a les teves dades.",
        ),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per recuperar la cartera, només cal que iniciïs sessió al teu compte de Google. Envoy descarregarà automàticament les dades de còpia de seguretat i la clau privada de la cartera.\n\nEt recomanem que protegeixis el teu compte de Google amb una contrasenya segura i 2FA.",
        ),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Per recuperar la cartera, només cal que iniciïs sessió al teu compte d\'iCloud. Envoy descarregarà automàticament les dades de còpia de seguretat i la clau privada de la cartera.\n\nEt recomanem que protegeixis el teu compte d\'iCloud amb una contrasenya segura i 2FA.",
        ),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage(
          "Com es Protegeixen les Dades",
        ),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Si prefereixes no fer servir la Còpia de Seguretat Màgica i, en canvi, protegir manualment la clau privada i les dades de la teva cartera, cap problema!\n\nNomés cal que tornis a la pantalla anterior i desactivis la Còpia de Seguretat Màgica.",
        ),
        "wallet_security_modal_HowToRecoverYourWallet":
            MessageLookupByLibrary.simpleMessage("Com Recuperar la Cartera"),
        "wallet_security_modal_HowYourDatatIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Com es Protegeixen les Dades"),
        "wallet_security_modal_HowYourSeedIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Com es Protegeix la Teva Clau"),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage(
          "Com es Protegeix la Teva Cartera",
        ),
        "wallet_security_modal_WantToOptOut":
            MessageLookupByLibrary.simpleMessage(
          "Vols Deixar de Participar?",
        ),
        "wallet_security_modal__heading": MessageLookupByLibrary.simpleMessage(
          "Consell de Seguretat",
        ),
        "wallet_security_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Envoy emmagatzema més de la quantitat recomanada de Bitcoin per a una cartera mòbil connectada a Internet.\n\nPer a la màxima seguretat fora de línia, Foundation suggereix la cartera física Passport.",
        ),
        "wallet_setup_success_heading": MessageLookupByLibrary.simpleMessage(
          "La Teva Cartera Està a Punt",
        ),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
          "Envoy està configurat i preparat per al teu Bitcoin!",
        ),
        "welcome_screen_ctA1": MessageLookupByLibrary.simpleMessage(
          "Configura la Cartera",
        ),
        "welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Gestionar Passport",
        ),
        "welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Benvingut a Envoy",
        ),
      };
}
