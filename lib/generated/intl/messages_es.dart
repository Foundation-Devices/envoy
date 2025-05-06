// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  String get localeName => 'es';

  static String m0(MB_name) =>
      "Copia de Seguridad Mágica de Passport Prime\n\"${MB_name}\"";

  static String m1(period) =>
      "Este cupón caducó el ${period}. \n\n\nPonte en contacto con el emisor si tienes alguna pregunta relacionada con el cupón.";

  static String m2(AccountName) =>
      "Navega a ${AccountName} en Passport, selecciona \'Account Tools\'>\'Verify Address\' y, a continuación, escanea el código QR.";

  static String m3(tagName) =>
      "Tu etiqueta ${tagName} ahora está vacía. ¿Quieres eliminarla?";

  static String m4(time_remaining) => "${time_remaining} restante(s)";

  static String m5(current_keyOS_version) =>
      "Tu Passport Prime actualmente utiliza ${current_keyOS_version}.\n\nActualiza ahora para obtener las últimas funcionalidades y correcciones de errores.";

  static String m6(est_upd_time) =>
      "Tiempo Estimado de Actualización: ${est_upd_time}";

  static String m7(new_keyOS_version) => "Novedades en ${new_keyOS_version}";

  static String m8(new_keyOS_version) =>
      "Passport Prime se ha actualizado\ncorrectamente a ${new_keyOS_version}";

  static String m9(amount, total_amount) =>
      "Re-sincronizando tus cuentas.\nPor favor, no cierres Envoy.\n\n${amount} de ${total_amount} sincronizado";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage("USD"),
        "about_appVersion":
            MessageLookupByLibrary.simpleMessage("Versión de Aplicación"),
        "about_openSourceLicences":
            MessageLookupByLibrary.simpleMessage("Licencias de Código Abierto"),
        "about_privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacidad"),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Condiciones de Uso"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "account_details_untagged_card":
            MessageLookupByLibrary.simpleMessage("Sin etiquetar"),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
                "Los filtros aplicados ocultan todas las transacciones.\nActualiza o restablece los filtros para ver las transacciones."),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "No hay transacciones en esta cuenta.\nRecibe tu primera transacción debajo."),
        "account_type_label_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "account_type_sublabel_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Crea una cartera móvil con Copia de Seguridad Mágica."),
        "accounts_empty_text_learn_more":
            MessageLookupByLibrary.simpleMessage("Comenzar"),
        "accounts_forceUpdate_cta":
            MessageLookupByLibrary.simpleMessage("Actualizar Envoy"),
        "accounts_forceUpdate_heading": MessageLookupByLibrary.simpleMessage(
            "Se Requiere Actualizar Envoy"),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
            "Hay disponible una nueva actualización de Envoy que contiene importantes mejoras y arreglos.\n\nPara seguir utilizando Envoy, por favor actualiza a la última versión. Muchas gracias."),
        "accounts_screen_walletType_Envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "accounts_screen_walletType_Passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "accounts_screen_walletType_defaultName":
            MessageLookupByLibrary.simpleMessage("Cartera Móvil"),
        "accounts_switchDefault":
            MessageLookupByLibrary.simpleMessage("Predeterminado"),
        "accounts_switchPassphrase":
            MessageLookupByLibrary.simpleMessage("Passphrase"),
        "accounts_upgradeBdkSignetModal_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy ahora usa Signet Global en lugar de Mutinynet. Se han eliminado tus cuentas de Signet anteriores. \n\nPara empezar a usar Signet Global, ve a Ajustes y activa el botón Signet."),
        "accounts_upgradeBdkSignetModal_header":
            MessageLookupByLibrary.simpleMessage("Signet Global"),
        "accounts_upgradeBdkTestnetModal_content":
            MessageLookupByLibrary.simpleMessage(
                "\'testnet3\' ha quedado obsoleto y Envoy ahora usa \'testnet4\'. Tus cuentas anteriores de testnet3 han sido eliminadas. \n\nPara empezar a usar testnet4, ve a Ajustes y activa el botón Testnet."),
        "accounts_upgradeBdkTestnetModal_header":
            MessageLookupByLibrary.simpleMessage("Presentamos​•​testnet4"),
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Acelerado"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("Cancelando"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
            "No hay ninguna actividad que mostrar."),
        "activity_envoyUpdate": MessageLookupByLibrary.simpleMessage(
            "Aplicación Envoy Actualizada"),
        "activity_envoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Actualización de Envoy disponible"),
        "activity_firmwareUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualización de firmware disponible"),
        "activity_incomingPurchase":
            MessageLookupByLibrary.simpleMessage("Compra Entrante"),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Hoy"),
        "activity_passportUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualización de Passport disponible"),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pendiente"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Recibido"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Enviado"),
        "activity_sent_boosted":
            MessageLookupByLibrary.simpleMessage("Enviado (Acelerado)"),
        "activity_sent_canceled":
            MessageLookupByLibrary.simpleMessage("Cancelado"),
        "add_note_modal_heading":
            MessageLookupByLibrary.simpleMessage("Añadir Nota"),
        "add_note_modal_ie_text_field":
            MessageLookupByLibrary.simpleMessage("Compra de una Passport"),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Registre algunos detalles sobre esta transacción."),
        "android_backup_info_heading": MessageLookupByLibrary.simpleMessage(
            "Android Realiza Copias De Seguridad Cada 24h"),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
            "Android realiza automáticamente una copia de seguridad de tus datos de Envoy cada 24 horas.\n\nPara asegurarte de que tu primera Copia de Seguridad Mágica esté completa, te recomendamos que realices una copia de seguridad manual en los [[Ajustes]] de tu dispositivo."),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
            "Envoy es una cartera Bitcoin simple, pero con funciones potentes de administración de cuentas y privacidad.\n\nEntre muchas otras cosas, también puedes usar Envoy para configurar y actualizar tu cartera física Passport.\n\nEnvoy ofrece las siguientes funciones:\n\n1. Copias de seguridad mágicas. Pónte en marcha con la autocustodia en solo 60 segundos con copias de seguridad cifradas automáticas. Usar palabras semilla es opcional.\n\n2. Gestiona tu cartera móvil y tus cuentas de Passport en la misma aplicación.\n\n3. Envía y recibe Bitcoin con una interfaz totalmente zen.\n\n4. Conecta tu Passport para configuración, actualizaciones de firmware y vídeos de soporte. Utiliza Envoy como la cartera interfaz para tu Passport.\n\n5. Código totalmente abierto y preservación de la privacidad. Envoy se conecta opcionalmente a Internet con Tor para una privacidad máxima.\n\n6. Si quieres, puedes conectar tu propio nodo de Bitcoin."),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Bono Azteco pendiente"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Error de Conexión"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede conectarse con Azteco.\n\nPor favor contacta con support@azte.co o inténtalo de nuevo más tarde."),
        "azteco_note": MessageLookupByLibrary.simpleMessage("Cupón de Azteco"),
        "azteco_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Cupón Azteco pendiente"),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage("CÓDIGO DE CUPÓN"),
        "azteco_redeem_modal_amount":
            MessageLookupByLibrary.simpleMessage("Importe"),
        "azteco_redeem_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Canjear"),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Error al Canjear"),
        "azteco_redeem_modal_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Por favor, confirma que tu cupón sigue siendo válido.\n\nPónte en contacto con support@azte.co si tienes alguna pregunta relacionada con el cupón."),
        "azteco_redeem_modal_heading":
            MessageLookupByLibrary.simpleMessage("¿Canjear Cupón?"),
        "azteco_redeem_modal_saleDate":
            MessageLookupByLibrary.simpleMessage("Fecha de venta"),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage("Cupón Canjeado"),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "En breve aparecerá una transacción entrante en tu cuenta."),
        "backups_advancedBackups": MessageLookupByLibrary.simpleMessage(
            "Copias de Seguridad Avanzadas"),
        "backups_downloadBIP329BackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Exportar Notas y Etiquetas (BIP-329)"),
        "backups_downloadSettingsDataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Descargar Copia de Seguridad de Configuración y Datos"),
        "backups_downloadSettingsMetadataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Descargar Copia de Seguridad de Ajustes y Metadatos"),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage(
                "Eliminar Carteras y Copias de Seguridad"),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás a punto de eliminar permanentemente tu Cartera Envoy. \n\nSi utilizas la Copia de Seguridad Mágica, tu Semilla Envoy también se eliminará de la Copia de Seguridad de Android. "),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás a punto de eliminar permanentemente tu Cartera Envoy.\n\nSi utilizas la Copia de Seguridad Mágica, tu Semilla Envoy también se eliminará del llavero iCloud. "),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Las cuentas de Passport conectadas no se eliminarán como parte de este proceso.\n\nAntes de eliminar tu Cartera Envoy, vamos a asegurarnbos de que tu semilla y de copia de seguridad estén bien guardados.\n"),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Mostrar semilla"),
        "backups_magicToManualErrorModal_header":
            MessageLookupByLibrary.simpleMessage("No Se Puede Continuar"),
        "backups_magicToManualErrorModal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "La Copia de Seguridad Mágica de Envoy no puede desactivarse mientras la Copia de Seguridad de Passport Prime esté activa.\n\nPara continuar, desactiva primero la Copia de Seguridad de Passport Prime en el dispositivo."),
        "backups_manualToMagicrModal_header":
            MessageLookupByLibrary.simpleMessage(
                "Habilitar Copia de Seguridad Mágica"),
        "backups_manualToMagicrModal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Esto habilitará la Copia de Seguridad Mágica de Envoy. Tu semilla de Envoy se encriptará y se hará una Copia de Seguridad en tu cuenta de Apple o Google. Los datos de Envoy se encriptarán y se enviarán a los servidores de Foundation."),
        "backups_primeMagicBackups": m0,
        "backups_primeMasterKeyBackup": MessageLookupByLibrary.simpleMessage(
            "Copia de Seguridad de Clave Maestra (1 parte de 3)"),
        "backups_settingsAndData":
            MessageLookupByLibrary.simpleMessage("Configuración y Datos"),
        "backups_settingsAndMetadata":
            MessageLookupByLibrary.simpleMessage("Ajustes y Metadatos"),
        "backups_toggle_envoy_magic_backups":
            MessageLookupByLibrary.simpleMessage(
                "Copias de Seguridad Mágicas de Envoy"),
        "backups_toggle_envoy_mobile_wallet_key":
            MessageLookupByLibrary.simpleMessage("Clave de Cartera Móvil"),
        "backups_viewMobileWalletSeed": MessageLookupByLibrary.simpleMessage(
            "Ver Semilla de Cartera Móvil"),
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Cuentas"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Actividad"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositivos"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprender"),
        "bottomNav_privacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
        "btcpay_connection_modal_expired_subheading": m1,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Cupón Caducado"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede conectarse con la tienda BTCPay del emisor.\n\nPonte en contacto con el emisor o vuelve a intentarlo más tarde."),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
                "El cupón escaneado no se creó con soporte onchain.\n\nPonte en contacto con el creador del cupón."),
        "btcpay_note": MessageLookupByLibrary.simpleMessage("Cupón de BTCPay"),
        "btcpay_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Cupón BTCPay Pendiente"),
        "btcpay_redeem_modal_description":
            MessageLookupByLibrary.simpleMessage("Descripción:"),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nombre:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Red Incorrecta"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este es un cupón on-chain. No se puede canjear en una cuenta de Testnet o Signet."),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage("Elige otra cuenta"),
        "buy_bitcoin_accountSelection_heading":
            MessageLookupByLibrary.simpleMessage(
                "¿Dónde quieres ingresar tus Bitcoin?"),
        "buy_bitcoin_accountSelection_modal_heading":
            MessageLookupByLibrary.simpleMessage("Saliendo de Envoy"),
        "buy_bitcoin_accountSelection_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás a punto de salir de Envoy y de acceder a la plataforma de nuestro servicio asociado para la compra de Bitcoin. Foundation nunca tendrá acceso a la información facilitada en dicha plataforma."),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tus Bitcoin se enviarán a esta dirección:"),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
                "Verificar Dirección con Passport"),
        "buy_bitcoin_accountSelection_verify_modal_heading": m2,
        "buy_bitcoin_buyOptions_atms_heading":
            MessageLookupByLibrary.simpleMessage("¿Cómo te gustaría comprar?"),
        "buy_bitcoin_buyOptions_atms_map_modal_openingHours":
            MessageLookupByLibrary.simpleMessage("Horario de Apertura:"),
        "buy_bitcoin_buyOptions_atms_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Distintos proveedores de cajeros automáticos podrán exigir distintos grados de información personal. Esta información nunca se comparte con Foundation."),
        "buy_bitcoin_buyOptions_atms_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Encuentra un cajero automático de Bitcoin en tu zona para comprar Bitcoin con dinero en efectivo."),
        "buy_bitcoin_buyOptions_card_atms":
            MessageLookupByLibrary.simpleMessage("Cajeros Automáticos"),
        "buy_bitcoin_buyOptions_card_commingSoon":
            MessageLookupByLibrary.simpleMessage("Próximamente en tu zona."),
        "buy_bitcoin_buyOptions_card_disabledInSettings":
            MessageLookupByLibrary.simpleMessage("Desactivado desde ajustes."),
        "buy_bitcoin_buyOptions_card_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("Comprar en Envoy"),
        "buy_bitcoin_buyOptions_card_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra Bitcoin en segundos, directamente en tus cuentas de Passport o en tu cartera móvil."),
        "buy_bitcoin_buyOptions_card_peerToPeer":
            MessageLookupByLibrary.simpleMessage("Entre Particulares"),
        "buy_bitcoin_buyOptions_card_vouchers":
            MessageLookupByLibrary.simpleMessage("Cupones"),
        "buy_bitcoin_buyOptions_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("¿Cómo te gustaría comprar?"),
        "buy_bitcoin_buyOptions_inEnvoy_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Información compartida con Ramp cuando compras Bitcoin usando este método. Esta información nunca se comparte con Foundation."),
        "buy_bitcoin_buyOptions_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra con tarjeta de crédito, Apple Pay, Google Pay o transferencia bancaria directamente a tu Passport o cartera móvil."),
        "buy_bitcoin_buyOptions_modal_address":
            MessageLookupByLibrary.simpleMessage("Dirección"),
        "buy_bitcoin_buyOptions_modal_bankingInfo":
            MessageLookupByLibrary.simpleMessage("Información Bancaria"),
        "buy_bitcoin_buyOptions_modal_email":
            MessageLookupByLibrary.simpleMessage("Correo Electrónico"),
        "buy_bitcoin_buyOptions_modal_identification":
            MessageLookupByLibrary.simpleMessage("Identificación"),
        "buy_bitcoin_buyOptions_modal_poweredBy":
            MessageLookupByLibrary.simpleMessage("Con tecnología de"),
        "buy_bitcoin_buyOptions_notSupported_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Echa un ojo a estas otras formas de comprar Bitcoin."),
        "buy_bitcoin_buyOptions_peerToPeer_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La mayoría de las transacciones no requieren compartir información, pero la persona con la que hagas el intercambio podrá conocer tu información bancaria. Esta información nunca se comparte con Foundation."),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk":
            MessageLookupByLibrary.simpleMessage("AgoraDesk"),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras de Bitcoin entre particulares, autocustodiado."),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq":
            MessageLookupByLibrary.simpleMessage("Bisq"),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras de Bitcoin entre particulares, autocustodiado."),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl":
            MessageLookupByLibrary.simpleMessage("Hodl Hodl"),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras de Bitcoin entre particulares, autocustodiado."),
        "buy_bitcoin_buyOptions_peerToPeer_options_heading":
            MessageLookupByLibrary.simpleMessage("Selecciona una opción"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach":
            MessageLookupByLibrary.simpleMessage("Peach"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras de Bitcoin entre particulares, autocustodiado."),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats":
            MessageLookupByLibrary.simpleMessage("Robosats"),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras de Bitcoin nativas en Lightning, entre particulares, autocustodiado."),
        "buy_bitcoin_buyOptions_peerToPeer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra Bitcoin fuera de Envoy, sin intermediarios. Requiere más pasos, pero puede ser más privado."),
        "buy_bitcoin_buyOptions_vouchers_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Distintos proveedores podrán exigir distintos grados de información personal. Esta información nunca se comparte con Foundation."),
        "buy_bitcoin_buyOptions_vouchers_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra cupones de Bitcoin online o en persona. Canjéalos utilizando el botón de escáner desde cualquier cuenta en Envoy."),
        "buy_bitcoin_defineLocation_heading":
            MessageLookupByLibrary.simpleMessage("Tu Región"),
        "buy_bitcoin_defineLocation_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Selecciona tu región para que Envoy pueda mostrar las opciones de compra disponibles para ti.  Esta información nunca saldrá de Envoy."),
        "buy_bitcoin_details_menu_editRegion":
            MessageLookupByLibrary.simpleMessage("EDITAR REGIÓN"),
        "buy_bitcoin_exit_modal_heading":
            MessageLookupByLibrary.simpleMessage("Cancelar Proceso de Compra"),
        "buy_bitcoin_exit_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Estás a punto de cancelar el proceso de compra. ¿Estás seguro?"),
        "buy_bitcoin_mapLoadingError_header":
            MessageLookupByLibrary.simpleMessage("Error al cargar el mapa"),
        "buy_bitcoin_mapLoadingError_subheader":
            MessageLookupByLibrary.simpleMessage(
                "En este momento Envoy no puede cargar los datos del mapa. Comprueba la conexión o vuelve a intentarlo más tarde."),
        "buy_bitcoin_purchaseComplete_heading":
            MessageLookupByLibrary.simpleMessage("Compra Realizada"),
        "buy_bitcoin_purchaseComplete_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La finalización puede tardar algún tiempo dependiendo del método de pago utilizado y de la congestión de la red."),
        "buy_bitcoin_purchaseError_contactRamp":
            MessageLookupByLibrary.simpleMessage(
                "Por favor ponte en contacto con Ramp para obtener asistencia."),
        "buy_bitcoin_purchaseError_heading":
            MessageLookupByLibrary.simpleMessage("Se Ha Producido Un Error"),
        "buy_bitcoin_purchaseError_purchaseID":
            MessageLookupByLibrary.simpleMessage("ID de compra:"),
        "card_coin_locked":
            MessageLookupByLibrary.simpleMessage("Moneda Bloqueada"),
        "card_coin_selected":
            MessageLookupByLibrary.simpleMessage("Moneda Seleccionada"),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Moneda"),
        "card_coins_locked":
            MessageLookupByLibrary.simpleMessage("Monedas Bloqueadas"),
        "card_coins_selected":
            MessageLookupByLibrary.simpleMessage("Monedas Seleccionadas"),
        "card_coins_unselected":
            MessageLookupByLibrary.simpleMessage("Monedas"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("de"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Elige una etiqueta"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
                "Esta transacción gasta monedas de múltiples etiquetas. ¿Cómo te gustaría etiquetar tu cambio?"),
        "coinDetails_tagDetails":
            MessageLookupByLibrary.simpleMessage("DETALLES DE ETIQUETA"),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tu ID de transacción se copiará en el portapapeles y podrá ser visible para otras aplicaciones en tu teléfono."),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Saldo disponible"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Cantidad Necesaria"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Cantidad Seleccionada"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Bloquear"),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Bloquear monedas evitará que se utilicen en transacciones."),
        "coincontrol_switchActivity":
            MessageLookupByLibrary.simpleMessage("Actividad"),
        "coincontrol_switchTags":
            MessageLookupByLibrary.simpleMessage("Etiquetas"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Revisar Transacción"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage("Firmar con Passport"),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Transacción lista para ser firmada"),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Confirma que los detalles de la transacción son correctos antes de firmar con Passport."),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Guarda algunos detalles sobre tu transacción."),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Mostrar detalles"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Cantidad a enviar"),
        "coincontrol_tx_detail_change":
            MessageLookupByLibrary.simpleMessage("Cambio recibido"),
        "coincontrol_tx_detail_cta1":
            MessageLookupByLibrary.simpleMessage("Enviar Transacción"),
        "coincontrol_tx_detail_cta2":
            MessageLookupByLibrary.simpleMessage("Editar Transacción"),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Confirmar Tasa"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_cta":
            MessageLookupByLibrary.simpleMessage("Más del 25%"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Más del 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage("Destino"),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Mostrar dirección"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Cambio recibido"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage("moneda"),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage("monedas"),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("DETALLES DE TRANSACCIÓN"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Enviar de"),
        "coincontrol_tx_detail_fee":
            MessageLookupByLibrary.simpleMessage("Tasa"),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
                "Es posible que al actualizar la tasa tu selección de monedas haya cambiado. Revísalo por favor."),
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage("Otro"),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage("Rápido"),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage("Estándar"),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
            "Transacción lista para ser enviada"),
        "coincontrol_tx_detail_high_fee_info_overlay_learnMore":
            MessageLookupByLibrary.simpleMessage("[[Más información]]"),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Algunas de las monedas más pequeñas han sido excluidas de esta transacción. Con el coste de envío seleccionado, cuesta más incluirlas de lo que valen."),
        "coincontrol_tx_detail_newFee":
            MessageLookupByLibrary.simpleMessage("Nueva Tasa"),
        "coincontrol_tx_detail_no_change":
            MessageLookupByLibrary.simpleMessage("Sin cambio"),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage("Cancelar Transacción"),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Al cancelar, perderás todo el progreso de la transacción."),
        "coincontrol_tx_detail_subheading": MessageLookupByLibrary.simpleMessage(
            "Confirma que los detalles de la transacción son correctos antes de enviarla."),
        "coincontrol_tx_detail_total":
            MessageLookupByLibrary.simpleMessage("Total"),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Notas"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Desbloquear"),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Desbloquear monedas hará que estén disponibles para su uso en transacciones."),
        "coindetails_overlay_address":
            MessageLookupByLibrary.simpleMessage("Dirección"),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("a las"),
        "coindetails_overlay_boostedFees":
            MessageLookupByLibrary.simpleMessage("Tasas de Aceleración"),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage("Confirmación en"),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage("Confirma en"),
        "coindetails_overlay_confirmationIn_day":
            MessageLookupByLibrary.simpleMessage("día"),
        "coindetails_overlay_confirmationIn_days":
            MessageLookupByLibrary.simpleMessage("días"),
        "coindetails_overlay_confirmationIn_month":
            MessageLookupByLibrary.simpleMessage("mes"),
        "coindetails_overlay_confirmationIn_week":
            MessageLookupByLibrary.simpleMessage("semana"),
        "coindetails_overlay_confirmationIn_weeks":
            MessageLookupByLibrary.simpleMessage("semanas"),
        "coindetails_overlay_confirmation_boost":
            MessageLookupByLibrary.simpleMessage("Acelerar"),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Fecha"),
        "coindetails_overlay_explorer":
            MessageLookupByLibrary.simpleMessage("Explorar"),
        "coindetails_overlay_heading":
            MessageLookupByLibrary.simpleMessage("DETALLES DE MONEDA"),
        "coindetails_overlay_modal_explorer_heading":
            MessageLookupByLibrary.simpleMessage("Abrir en Explorador"),
        "coindetails_overlay_modal_explorer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás a punto de salir de Envoy y ver esta transacción en un explorador alojado por Foundation. Asegúrate de entender las reprecusiones que esta acción tiene en cuanto a privacidad antes de continuar. "),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Error al Impuslar Transacción"),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esto se debe a que no hay suficientes monedas confirmadas o desbloqueadas de donde elegir. \n\nSi es posible, deja que las monedas pendientes se confirmen o desbloquea algunas monedas e inténtalo de nuevo."),
        "coindetails_overlay_noCancelNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Error al Cancelar la Transacción"),
        "coindetails_overlay_noCanceltNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "No hay suficientes monedas confirmadas o desbloqueadas disponibles para cancelar esta transacción. \n\nSiempre que sea posible, deja que las monedas pendientes se confirmen o desbloquea algunas monedas e inténtalo de nuevo."),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coindetails_overlay_paymentID":
            MessageLookupByLibrary.simpleMessage("ID de pago"),
        "coindetails_overlay_rampFee":
            MessageLookupByLibrary.simpleMessage("Tasas de Ramp"),
        "coindetails_overlay_rampID":
            MessageLookupByLibrary.simpleMessage("ID de Ramp"),
        "coindetails_overlay_status":
            MessageLookupByLibrary.simpleMessage("Estado"),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmado"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage("Pendiente"),
        "coindetails_overlay_tag":
            MessageLookupByLibrary.simpleMessage("Etiqueta"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage("ID de Transacción"),
        "common_button_contactSupport":
            MessageLookupByLibrary.simpleMessage("Contactar Servicio Técnico"),
        "component_Apply":
            MessageLookupByLibrary.simpleMessage("Aplicar Filtro"),
        "component_advanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
        "component_back": MessageLookupByLibrary.simpleMessage("Atrás"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "component_confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "component_content": MessageLookupByLibrary.simpleMessage("Contenido"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "component_device": MessageLookupByLibrary.simpleMessage("Dispositivo"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Cerrar"),
        "component_done": MessageLookupByLibrary.simpleMessage("Hecho"),
        "component_dontShowAgain":
            MessageLookupByLibrary.simpleMessage("No volver a mostrar"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
        "component_filter_button_all":
            MessageLookupByLibrary.simpleMessage("Todo"),
        "component_goToSettings":
            MessageLookupByLibrary.simpleMessage("Ir a Ajustes"),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Más información"),
        "component_minishield_buy":
            MessageLookupByLibrary.simpleMessage("Comprar"),
        "component_next": MessageLookupByLibrary.simpleMessage("Siguiente"),
        "component_no": MessageLookupByLibrary.simpleMessage("No"),
        "component_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "component_recover": MessageLookupByLibrary.simpleMessage("Recuperar"),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Canjear"),
        "component_reset":
            MessageLookupByLibrary.simpleMessage("Restablecer filtro"),
        "component_retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "component_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Saltar"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "component_tryAgain":
            MessageLookupByLibrary.simpleMessage("Intentar de Nuevo"),
        "component_update": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "component_warning":
            MessageLookupByLibrary.simpleMessage("ADVERTENCIA"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Sí"),
        "contactRampForSupport":
            MessageLookupByLibrary.simpleMessage("Atención al cliente de Ramp"),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
            "Tu dirección se copiará en el portapapeles y podrá ser visible para otras aplicaciones en tu teléfono."),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
            "Tu ID de transacción se copiará en el portapapeles y podrá ser visible para otras aplicaciones en tu teléfono."),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Las etiquetas son una forma útil de organizar tus monedas."),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage("Sugerencias"),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Lo más utilizado"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "¿Estás seguro de que quieres eliminar esta etiqueta?"),
        "delete_tag_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Eliminar Etiqueta"),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Al eliminar esta etiqueta, las monedas se marcarán automáticamente como Sin etiquetar."),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Android realiza automáticamente una copia de seguridad de tus datos de Envoy cada 24 horas.\n\nPara eliminar tu Semilla Envoy de la Copia de Seguridad de Android de manera inmediata, puedes realizar una copia de seguridad manual en los [[Ajustes]] de tu dispositivo."),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage("Eliminando tu cartera Envoy"),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Eliminar Cartera"),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "¿Estás seguro de que quieres ELIMINAR tu Cartera Envoy?"),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Tu cartera se ha eliminado con éxito"),
        "devices_empty_modal_video_cta1":
            MessageLookupByLibrary.simpleMessage("Comprar Passport"),
        "devices_empty_modal_video_cta2":
            MessageLookupByLibrary.simpleMessage("Ver Más Tarde"),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Asegura tus Bitcoin con Passport."),
        "empty_tag_modal_subheading": m3,
        "envoy_account_tos_cta": MessageLookupByLibrary.simpleMessage("Acepto"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
            "Por favor, revise y acepte los Términos de Uso de Passport"),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
            "Envoy requiere acceso a la cámara para escanear códigos QR. Vete a Ajustes y concede los permisos de la cámara."),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Permiso necesario"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
            "Envoy es una cartera móvil de Bitcoin y una aplicación complementaria a Passport, disponible en iOS y Android."),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
            "No, cualquiera puede descargar, verificar e instalar manualmente firmware nuevo. Ver [[aquí]] para más información."),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
            "Por supuesto, no hay límite a la cantidad de Passports que puedes gestionar o con las que interactuar utilizando Envoy."),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
            "Sí, Envoy facilita la gestión de múltiples cuentas."),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
            "Envoy se comunica principalmente a través de códigos QR, pero las actualizaciones de firmware se transmiten desde tu teléfono utilizando una tarjeta microSD. Passport incluye adaptadores de microSD para tu teléfono."),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
            "Sí, simplemente ten en cuenta que cualquier información específica de la cartera, como las etiquetas de dirección o notas de transacciones, no se copiarán hacia o desde Envoy."),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
            "Es posible, ya que la mayoría de las carteras hardware que utilizan códigos de QR se comunican de manera muy similar. Sin embargo, no es algo que esté explícitamente soportado. Como Envoy es de código abierto, ¡invitamos a otras carteras hardware basadas en QR que añadan el soporte!"),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
            "De momento, Envoy solo funciona con Bitcoin \'onchain\'. Planeamos soportar Lightning en el futuro."),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
            "Cualquier persona que encuentre tu teléfono, primero tendría que superar el código PIN del sistema operativo de tu teléfono o la autenticación biométrica para acceder a Envoy. En el improbable caso de que logren esto, el atacante podría enviar fondos desde tu Cartera Móvil de Envoy y ver la cantidad de Bitcoin almacenada en cualquier cuenta de Passport conectada. Sin embargo, estos fondos de Passport no estrían en peligro ya que cualquier transacción debe ser autorizada por el dispositivo Passport emparejado."),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
            "Si se utiliza con un Passport, Envoy actúa como una cartera de \'solo lectura\' conectada a tu cartera hardware. Esto significa que Envoy puede preparar transacciones, pero son inútiles sin la autorización relevante, que solo Passport puede proporcionar. Passport es el \'almacenamiento en frío\', ¡y Envoy es simplemente la interfaz conectada a Internet! Si utilizas Envoy para crear una cartera móvil, donde la clave se almacena de forma segura en tu teléfono, esa cartera móvil no se consideraría almacenamiento en frío. Esto no tiene ningún efecto en la seguridad de las cuentas conectadas a Passport."),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
            "Sí, Envoy se conecta utilizando los protocolos de servidor Electrum o Esplora. Para conectarte a tu propio servidor, escanea el código QR o escribe la URL proporcionada en la configuración de red en Envoy."),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
            "Envoy está diseñada para ser la cartera de Bitcoin más fácil de utilizar, sin comprometer tu privacidad. Con las Copias de Seguridad Mágicas de Envoy, puedes configurar una cartera móvil de Bitcoin en 60 segundos, ¡sin palabras semilla y custodiada por ti! Los usuarios de Passport pueden conectar sus dispositivos a Envoy para una configuración fácil, actualizaciones de firmware y una experiencia sencilla de cartera de Bitcoin."),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
            "Descargar e instalar Envoy no requiere ningún dato personal y Envoy puede conectarse a Internet a través de Tor, un protocolo que preserva la privacidad. Esto significa que Foundation no tiene forma de saber quién eres. Envoy también brinda a los usuarios más avanzados la capacidad de conectarse a su propio nodo de Bitcoin para eliminar cualquier dependencia de los servidores de Foundation por completo."),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
            "Sí. A partir de la versión 1.4.0, Envoy permite hacer una selección completa de monedas, así como el \'etiquetado\' de monedas."),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
            "En este momento Envoy no admite gastos por lotes (\"Batch spending\")."),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
            "Sí. A partir de la versión 1.4.0, Envoy permite personalizar la tasa de transacción totalmente, y mantiene dos opciones rápidas de selección de tasa: \'Estándar\' y \'Más rápido\'. \'Estándar\' tiene como objetivo finalizar tu transacción en un plazo de 60 minutos y \'Más rápido\' en unos 10 minutos. Estas son estimaciones basadas en la congestión de la red en el momento en que se construye la transacción y siempre se te mostrará el coste de cada una de las opciones antes de finalizar la transacción."),
        "envoy_faq_answer_24": MessageLookupByLibrary.simpleMessage(
            "¡Sí! A partir de la versión 1.7.0, ya puedes comprar Bitcoin en Envoy y hacer que se depositen automáticamente en tu cuenta móvil o en cualquier cuenta de Passport conectada. Solo tienes que hacer clic en el botón de compra de la pantalla principal de Cuentas."),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
            "Envoy es una cartera de Bitcoin simple con funciones potentes de gestión de cuentas y privacidad, incluyendo Copias de Seguridad Mágicas. Usa Envoy junto con tu Passport para su configuración, actualizaciones de firmware y más."),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
            "La Copia de Seguridad Mágica es la forma más fácil de configurar y hacer una copia de seguridad de una cartera móvil de Bitcoin. La Copia de Seguridad Mágica almacena la semilla de tu cartera móvil encriptada de extremo a extremo en tu llavero iCloud o copia de seguridad de Android. Todos los datos de la aplicación están encriptados por tu semilla y se almacenan en los servidores de Foundation. ¡Configura tu cartera en 60 segundos y restáurala automáticamente si pierdes tu teléfono!"),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
            "Las Copias de Seguridad Mágicas son completamente opcionales para los usuarios que deseen utilizar Envoy como cartera móvil. Si prefieres gestionar tus propias palabras semilla y copias de seguridad de la cartera móvil, elige \'Configurar Semilla Manualmente\' en la etapa de configuración de la cartera."),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
            "La Copia de Seguridad de Envoy contiene la configuración de la aplicación, información sobre la cuenta, etiquetas y notas de las transacciones. El archivo está encriptado con las palabras semilla de tu cartera móvil. Para los usuarios que habiliten la Copia de Seguridad Mágica, toda esta información se almacena completamente encriptada en el servidor de Foundation. Los usuarios de Envoy que hayan decidido gestionar las palabras semilla de forma manual, pueden descargar y almacenar su copia de seguridad donde deseen. Esto podría ser cualquiera, o múltiples, de las siguientes opciones: un teléfono, un servidor de nube personal, o algún dispositivo físico como una tarjeta microSD o un dispositivo de almacenamiento USB."),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
            "No, las características principales de Envoy siempre serán gratuitas. En el futuro es posible que introduzcamos servicios o suscripciones opcionales de pago."),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
            "Sí, al igual que todo lo que hacemos en Foundation, Envoy es completamente de código abierto. Envoy tiene la misma licencia [[GPLv3]] que nuestro Firmware de Passport. Para aquellos que deseen verificar nuestro código fuente, pueden hacer clic [[aquí]]."),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
            "No, nos enorgullecemos de garantizar que Passport sea compatible con tantas carteras de software diferentes como sea posible. Puedes ver nuestra lista completa, incluidos los tutoriales, [[aquí]]."),
        "envoy_faq_link_10": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/firmware-updates/passport/"),
        "envoy_faq_link_8_1": MessageLookupByLibrary.simpleMessage(
            "https://www.gnu.org/licenses/gpl-3.0.en.html"),
        "envoy_faq_link_8_2": MessageLookupByLibrary.simpleMessage(
            "https://github.com/Foundation-Devices/envoy"),
        "envoy_faq_link_9": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/passport/connect/"),
        "envoy_faq_question_1":
            MessageLookupByLibrary.simpleMessage("¿Qué es Envoy?"),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
            "¿Tengo que usar Envoy para actualizar el firmware de Passport?"),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
            "¿Puedo gestionar más de un Passport con Envoy?"),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
            "¿Puedo gestionar varias cuentas desde un único Passport?"),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
            "¿Cómo se comunica Envoy con Passport?"),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
            "¿Puedo usar Envoy en paralelo con otro software como Sparrow Wallet?"),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
            "¿Puedo gestionar otras carteras físicas con Envoy?"),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
            "¿Es Envoy compatible con la Lightning Network?"),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
            "¿Qué pasa si pierdo mi teléfono con Envoy instalado?"),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
            "¿Se considera Envoy \"Almacenamiento en Frío\"?"),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
            "¿Puedo conectar Envoy a mi propio nodo Bitcoin?"),
        "envoy_faq_question_2": MessageLookupByLibrary.simpleMessage(
            "¿Por qué debería utilizar Envoy?"),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
            "¿Cómo protege Envoy mi privacidad?"),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
            "¿Ofrece Envoy un control de monedas?"),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
            "¿Admite Envoy el envío por lotes?"),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
            "¿Permite Envoy la selección de tasas de envío personalizadas?"),
        "envoy_faq_question_24": MessageLookupByLibrary.simpleMessage(
            "¿Puedo comprar Bitcoin en Envoy?"),
        "envoy_faq_question_3":
            MessageLookupByLibrary.simpleMessage("¿Qué puede hacer Envoy?"),
        "envoy_faq_question_4": MessageLookupByLibrary.simpleMessage(
            "¿Qué es la Copia de Seguridad Mágica de Envoy?"),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
            "¿Tengo que utilizar una Copia de Seguridad Mágica de Envoy?"),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
            "¿Qué es la Copia de Seguridad de Envoy?"),
        "envoy_faq_question_7":
            MessageLookupByLibrary.simpleMessage("¿Tengo que pagar por Envoy?"),
        "envoy_faq_question_8": MessageLookupByLibrary.simpleMessage(
            "¿Es Envoy de código abierto?"),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
            "¿Tengo que utilizar Envoy para realizar transacciones con Passport?"),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy no pudo copiar el firmware en la tarjeta microSD."),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Asegúrate de que la tarjeta microSD esté insertada correctamente en el teléfono e inténtalo de nuevo. Si esto no funciona, el firmware puede descargarse desde nuestro [[GitHub]]."),
        "envoy_fw_intro_cta":
            MessageLookupByLibrary.simpleMessage("Descargar Firmware"),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
            "A continuación, actualicemos el firmware de Passport"),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy te permite actualizar Passport desde tu teléfono utilizando el adaptador microSD incluido.\n\nLos usuarios avanzados pueden descargar su propio firmware [[desde aquí]] y verificarlo en un ordenador."),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
                "Permitir que Envoy acceda a la tarjeta microSD"),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Otorgue a Envoy acceso para copiar archivos en la tarjeta microSD. Pulsa Examinar, luego PASSPORT-SD y, a continuación, Abrir."),
        "envoy_fw_microsd_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Descargar desde Github"),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
            "Lo sentimos, no podemos obtener la actualización de firmware en este momento."),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
            "Inserta la tarjeta microSD en el teléfono"),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
            "Mete el adaptador de tarjeta microSD provisto en tu teléfono, y después inserta la tarjeta microSD en el adaptador."),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
            "Extrae la tarjeta microSD e insértala en Passport"),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Mete la tarjeta microSD en Passport y vete a Configuración -> Firmware -> Actualizar firmware.\n\nAsegúrate de que Passport tenga una carga adecuada de la batería antes de realizar esta operación."),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
            "Mete la tarjeta microSD en Passport y luego sigue las instrucciones. \n\nAsegúrate de que Passport tenga una carga adecuada de la batería antes de realizar esta operación."),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
            "Envoy está copiando el firmware en la\ntarjeta microSD"),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
            "Esto puede tardar unos segundos. Por favor, no extraigas la tarjeta microSD."),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
            "El firmware se copió correctamente en la\ntarjeta microSD"),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Asegúrate de utilizar la función de Expulsar tarjeta SD de tu administrador de archivos antes de sacar la tarjeta microSD del teléfono."),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
            "El firmware más reciente se ha copiado en la tarjeta microSD y está listo para aplicarse a Passport."),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Escribe un PIN de 6 a 12 dígitos en tu Passport"),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport siempre te pedirá el PIN al encender. Recomendamos usar un PIN único y anotarlo.\n\nSi olvidas tu PIN, no hay forma de recuperar Passport y el dispositivo quedará permanentemente inutilizable."),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Ahora, crea una copia de seguridad encriptada de tu semilla"),
        "envoy_pp_new_seed_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Passport hará una copia de seguridad de la configuración inicial y del dispositivo en una tarjeta microSD encriptada."),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
            "En Passport, selecciona \nCrear Nueva Semilla"),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Avalanche Noise Source de Passport, un generador de números aleatorios de código abierto, ayuda a crear una semilla fuerte."),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Enhorabuena, tu semilla ha sido creada"),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A continuación, conectaremos Envoy y Passport."),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
            "En Passport, selecciona\nRestaurar Copia de Seguridad"),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage(
                "Desencripta tu Copia de Seguridad"),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para desencriptar la copia de seguridad, introduce el código de 20 dígitos que se mostró al crear la copia de seguridad.\n\nSi has perdido u olvidado este código, puedes recuperar tu cartera utilizando las palabras semilla en su lugar."),
        "envoy_pp_restore_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Utilice esta función para restaurar Passport utilizando una copia de seguridad microSD encriptada de otro Passport.\n\nNecesitarás la contraseña para desencriptar la copia de seguridad."),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Tu copia de seguridad se ha restaurado con éxito"),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
            "En Passport, selecciona\nRestaurar Semilla"),
        "envoy_pp_restore_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Utilice esta función para restaurar una semilla existente de 12 o 24 palabras."),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Tu semilla ha sido restaurada con éxito"),
        "envoy_pp_setup_intro_cta1":
            MessageLookupByLibrary.simpleMessage("Crear Nueva Semilla"),
        "envoy_pp_setup_intro_cta2":
            MessageLookupByLibrary.simpleMessage("Restaurar Semilla"),
        "envoy_pp_setup_intro_cta3": MessageLookupByLibrary.simpleMessage(
            "Restaurar Copia de Seguridad"),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
            "¿Cómo te gustaría configurar tu Passport?"),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Como nuevo propietario de un Passport, puedes crear una nueva semilla, restaurar una cartera usando palabras semilla o restaurar una copia de seguridad de un Passport existente."),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Primero, asegurémonos de que tu Passport es seguro"),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Este test de seguridad garantizará que tu Passport no haya sido manipulado durante el envío."),
        "envoy_scv_result_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Contáctanos"),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
            "Tu Passport puede ser inseguro"),
        "envoy_scv_result_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy no pudo validar la seguridad de tu Passport. Ponte en contacto con nosotros para obtener ayuda."),
        "envoy_scv_result_ok_heading":
            MessageLookupByLibrary.simpleMessage("Tu Passport es seguro"),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
            "A continuación, crea un PIN para proteger tu Passport"),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
            "A continuación, escanea el código QR en la pantalla de Passport"),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Este código QR completa la validación y comparte cierta información del Passport con Envoy."),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
            "En Passport, selecciona la aplicación Envoy y escanea este código QR"),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Este código QR contiene información sobre la validación y configuración."),
        "envoy_support_community":
            MessageLookupByLibrary.simpleMessage("COMUNIDAD"),
        "envoy_support_documentation":
            MessageLookupByLibrary.simpleMessage("Documentación"),
        "envoy_support_email": MessageLookupByLibrary.simpleMessage("Email"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
            "Habilitar Copia de Seguridad Mágica"),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Configurar Semilla Manualmente"),
        "envoy_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Crear Nueva Cartera"),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Para una configuración fluida, recomendamos habilitar la [[Copia de Seguridad Mágica]].\n\nLos usuarios avanzados pueden crear o restaurar manualmente una semilla."),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage("Volver a mis Cuentas"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage(
                "Eliminar Cuentas de todos modos"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Por favor, vacía tus cuentas antes de eliminar la Cartera Envoy. \nVe a Copia de Seguridad > Eliminar Carteras y Copias de Seguridad una vez que lo hayas hecho."),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Este archivo encriptado contiene datos útiles de la cartera, como etiquetas, notas, cuentas y configuración.\n\nEste archivo está encriptado con tu Semilla Envoy. Asegúrate de que tienes copias de seguridad de tu semilla. "),
        "export_backup_send_CTA1": MessageLookupByLibrary.simpleMessage(
            "Descargar Copia de Seguridad"),
        "export_backup_send_CTA2":
            MessageLookupByLibrary.simpleMessage("Descartar"),
        "export_seed_modal_12_words_CTA2":
            MessageLookupByLibrary.simpleMessage("Ver como código QR"),
        "export_seed_modal_QR_code_CTA2":
            MessageLookupByLibrary.simpleMessage("Ver Semilla"),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para usar este código QR en Envoy en un teléfono nuevo, vete a Configurar Cartera Envoy > Restaurar Copia de Seguridad Mágica > Restaurar con código QR"),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
                "Esta semilla está protegida por una Passphrase. Necesitas las palabras semilla y la Passphrase para recuperar tus fondos."),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "La siguiente pantalla muestra información altamente confidencial.\n\nCualquier persona con acceso a estos datos puede robar tus Bitcoin. Procede con extrema precaución."),
        "filter_sortBy_aToZ": MessageLookupByLibrary.simpleMessage("A a Z"),
        "filter_sortBy_highest":
            MessageLookupByLibrary.simpleMessage("Valor más alto"),
        "filter_sortBy_lowest":
            MessageLookupByLibrary.simpleMessage("Valor más bajo"),
        "filter_sortBy_newest":
            MessageLookupByLibrary.simpleMessage("Más recientes primero"),
        "filter_sortBy_oldest":
            MessageLookupByLibrary.simpleMessage("Más antiguos primero"),
        "filter_sortBy_zToA": MessageLookupByLibrary.simpleMessage("Z a A"),
        "finalize_catchAll_backUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
                "Realizar Copia de Seguridad de Clave Maestra"),
        "finalize_catchAll_backingUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
                "Realizando Copia de Seguridad de Clave Maestra"),
        "finalize_catchAll_connectAccount":
            MessageLookupByLibrary.simpleMessage("Conectar Cuenta"),
        "finalize_catchAll_connectingAccount":
            MessageLookupByLibrary.simpleMessage("Conectando Cuenta"),
        "finalize_catchAll_creatingPin":
            MessageLookupByLibrary.simpleMessage("Creando PIN"),
        "finalize_catchAll_header":
            MessageLookupByLibrary.simpleMessage("Continúa en Passport Prime"),
        "finalize_catchAll_masterKeyBackedUp":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad de Clave Maestra Realizada"),
        "finalize_catchAll_masterKeySetUp":
            MessageLookupByLibrary.simpleMessage("Clave Maestra Configurada"),
        "finalize_catchAll_pinCreated":
            MessageLookupByLibrary.simpleMessage("PIN creado"),
        "finalize_catchAll_setUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Configurar Clave Maestra"),
        "finalize_catchAll_settingUpMasterKey":
            MessageLookupByLibrary.simpleMessage("Configurando Clave Maestra"),
        "finish_connectedSuccess_content": MessageLookupByLibrary.simpleMessage(
            "¡Envoy está configurado y listo para tus Bitcoin!"),
        "finish_connectedSuccess_header":
            MessageLookupByLibrary.simpleMessage("Cartera Conectada con Éxito"),
        "firmware_downloadingUpdate_downloaded":
            MessageLookupByLibrary.simpleMessage("Actualización Descargada"),
        "firmware_downloadingUpdate_header":
            MessageLookupByLibrary.simpleMessage("Descargando Actualización"),
        "firmware_downloadingUpdate_timeRemaining": m4,
        "firmware_downloadingUpdate_transferring":
            MessageLookupByLibrary.simpleMessage(
                "Transfiriendo a Passport Prime"),
        "firmware_updateAvailable_content2": m5,
        "firmware_updateAvailable_estimatedUpdateTime": m6,
        "firmware_updateAvailable_header":
            MessageLookupByLibrary.simpleMessage("Actualización Disponible"),
        "firmware_updateAvailable_whatsNew": m7,
        "firmware_updateError_downloadFailed":
            MessageLookupByLibrary.simpleMessage("Error al Descargar"),
        "firmware_updateError_header":
            MessageLookupByLibrary.simpleMessage("Actualización Fallida"),
        "firmware_updateError_installFailed":
            MessageLookupByLibrary.simpleMessage("Error al Instalar"),
        "firmware_updateError_receivingFailed":
            MessageLookupByLibrary.simpleMessage("Error en la Transferencia"),
        "firmware_updateError_verifyFailed":
            MessageLookupByLibrary.simpleMessage("Error en la Verificación"),
        "firmware_updateModalConnectionLost_exit":
            MessageLookupByLibrary.simpleMessage("Salir de Inicialización"),
        "firmware_updateModalConnectionLost_header":
            MessageLookupByLibrary.simpleMessage("Conexión Perdida"),
        "firmware_updateModalConnectionLost_reconnecting":
            MessageLookupByLibrary.simpleMessage("Reconectando..."),
        "firmware_updateModalConnectionLost_tryToReconnect":
            MessageLookupByLibrary.simpleMessage("Reintentar Conexión"),
        "firmware_updateSuccess_content1": m8,
        "firmware_updateSuccess_content2": MessageLookupByLibrary.simpleMessage(
            "Continúa con la inicialización en Passport Prime."),
        "firmware_updateSuccess_header":
            MessageLookupByLibrary.simpleMessage("Actualización Completada"),
        "firmware_updatingDownload_content":
            MessageLookupByLibrary.simpleMessage(
                "Mantén ambos dispositivos cerca."),
        "firmware_updatingDownload_downloading":
            MessageLookupByLibrary.simpleMessage("Descargando Actualización"),
        "firmware_updatingDownload_header":
            MessageLookupByLibrary.simpleMessage("Actualizando"),
        "firmware_updatingDownload_transfer":
            MessageLookupByLibrary.simpleMessage("Transferir a Passport Prime"),
        "firmware_updatingPrime_content2": MessageLookupByLibrary.simpleMessage(
            "La inicialización se reanudará después de que Passport Prime se haya reiniciado."),
        "firmware_updatingPrime_installUpdate":
            MessageLookupByLibrary.simpleMessage("Instalar Actualización"),
        "firmware_updatingPrime_installingUpdate":
            MessageLookupByLibrary.simpleMessage("Instalando Actualización"),
        "firmware_updatingPrime_primeRestarting":
            MessageLookupByLibrary.simpleMessage(
                "Passport Prime se está reiniciando"),
        "firmware_updatingPrime_restartPrime":
            MessageLookupByLibrary.simpleMessage("Reiniciar Passport Prime"),
        "firmware_updatingPrime_updateInstalled":
            MessageLookupByLibrary.simpleMessage("Actualización Instalada"),
        "firmware_updatingPrime_verified":
            MessageLookupByLibrary.simpleMessage("Actualización Verificada"),
        "firmware_updatingPrime_verifying":
            MessageLookupByLibrary.simpleMessage("Verificando Actualización"),
        "header_buyBitcoin":
            MessageLookupByLibrary.simpleMessage("COMPRAR BITCOIN"),
        "header_chooseAccount":
            MessageLookupByLibrary.simpleMessage("ELIGE UNA CUENTA"),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Desliza sobre una cuenta para mostrar u ocultar tu saldo."),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Pulsa la tarjeta de arriba para recibir Bitcoin."),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
                "Pulsa cualquiera de las tarjetas anteriores para recibir Bitcoin."),
        "launch_screen_faceID_fail_CTA":
            MessageLookupByLibrary.simpleMessage("Intentar de Nuevo"),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage("Error de Autenticación"),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Por favor, inténtalo de nuevo"),
        "launch_screen_lockedout_heading":
            MessageLookupByLibrary.simpleMessage("Bloqueado"),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Autenticación biométrica desactivada temporalmente. Cierra Envoy, espera 30 segundos e inténtalo de nuevo."),
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
                "Los filtros aplicados ocultan todos los resultados de búsqueda.\nActualiza o restablece los filtros para ver más resultados."),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("Todos"),
        "learning_center_results_title":
            MessageLookupByLibrary.simpleMessage("Resultados"),
        "learning_center_search_input":
            MessageLookupByLibrary.simpleMessage("Buscar..."),
        "learning_center_title_blog":
            MessageLookupByLibrary.simpleMessage("Blog"),
        "learning_center_title_faq":
            MessageLookupByLibrary.simpleMessage("Preguntas frecuentes"),
        "learning_center_title_video":
            MessageLookupByLibrary.simpleMessage("Vídeos"),
        "learningcenter_status_read":
            MessageLookupByLibrary.simpleMessage("Leído"),
        "learningcenter_status_watched":
            MessageLookupByLibrary.simpleMessage("Visto"),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Encriptando Copia de Seguridad"),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está encriptando tu copia de seguridad.\n\nEsta copia de seguridad contiene datos útiles de la cartera como etiquetas, notas, cuentas y configuración."),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está creando una semilla de cartera Bitcoin de forma segura, que se almacenará encriptada de extremo a extremo en tu copia de seguridad de Android."),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage("Creando Semilla Envoy"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está creando una semilla de cartera Bitcoin de forma segura, que se almacenará encriptada de extremo a extremo en tu llavero iCloud."),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage("Restaurar con código QR"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede encontrar una Copia de Seguridad Mágica.\n\nPor favor confirma que has iniciado sesión con la cuenta de Google correcta y que has restaurado la última copia de seguridad de tu dispositivo."),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad Mágica No Encontrada"),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede localizar una Copia de Seguridad Mágica en los servidores de Foundation.\n\nAsegúrate de que estás restaurando una cartera que anteriormente usaba la Copia de Seguridad Mágica."),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Error de Conexión"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede conectarse a los servidores de Foundation para recuperar los datos de tu Copia de Seguridad Mágica.\n\nPuedes volver a intentarlo, importar tu propio archivo de Copia de Seguridad de Envoy o continuar sin copia de seguridad."),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage("Recuperación Fallida"),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede encontrar una Copia de Seguridad Mágica.\n\nConfirma que has iniciado sesión con la cuenta de Apple correcta y que has restaurado tu última copia de seguridad de iCloud."),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
                "Recuperando tu cartera Envoy"),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage("Cargando Copia de Seguridad"),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está subiendo la copia de seguridad encriptada de tu cartera a los servidores de Foundation.\n\nComo la copia de seguridad está encriptada de extremo a extremo, Foundation no tiene acceso a la copia de seguridad ni conocimiento de su contenido."),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La forma más fácil de crear una cartera nueva de Bitcoin manteniendo tu soberanía.\n\nLa Copia de Seguridad Mágica realiza automáticamente una copia de seguridad de tu cartera y su configuración en la Copia de Seguridad de Android, 100% encriptado de extremo a extremo. \n\n[[Más información]]."),
        "magic_setup_tutorial_heading":
            MessageLookupByLibrary.simpleMessage("Copia de Seguridad Mágica"),
        "magic_setup_tutorial_ios_CTA1": MessageLookupByLibrary.simpleMessage(
            "Crear Copia de Seguridad Mágica"),
        "magic_setup_tutorial_ios_CTA2": MessageLookupByLibrary.simpleMessage(
            "Restaurar Copia de Seguridad Mágica"),
        "magic_setup_tutorial_ios_subheading": MessageLookupByLibrary.simpleMessage(
            "La forma más fácil de crear una cartera nueva de Bitcoin manteniendo tu soberanía.\n\nLa Copia de Seguridad Mágica realiza automáticamente una copia de seguridad de tu cartera y su configuración en tu Llavero iCloud, 100% encriptado de extremo a extremo. \n\n[[Más información]]."),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Por motivos de privacidad, creamos una dirección nueva cada vez que visitas esta pantalla."),
        "manage_account_address_heading":
            MessageLookupByLibrary.simpleMessage("DETALLES DE CUENTA"),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Asegúrate de no compartir este descriptor a menos que quieras que tus transacciones sean públicas."),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage("EDITAR NOMBRE DE CUENTA"),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage("MOSTRAR DESCRIPTOR"),
        "manage_account_remove_heading":
            MessageLookupByLibrary.simpleMessage("¿Estás seguro?"),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esto solo elimina la cuenta de Envoy."),
        "manage_account_rename_heading":
            MessageLookupByLibrary.simpleMessage("Renombrar Cuenta"),
        "manage_device_deletePassportWarning": MessageLookupByLibrary.simpleMessage(
            "¿Estás seguro de que quieres desconectar Passport?\nEsto eliminará el dispositivo de Envoy junto con todas las cuentas conectadas."),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage("Emparejado"),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage("Número de serie"),
        "manage_device_details_heading":
            MessageLookupByLibrary.simpleMessage("DETALLES DE DISPOSITIVO"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage(
                "EDITAR NOMBRE DE DISPOSITIVO"),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage("Renombrar Passport"),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
                "Error al hacer copia de seguridad. Inténtalo de nuevo más tarde."),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
                "Esto descartará cualquier cambio en la selección de monedas. ¿Quieres continuar?"),
        "manual_setup_change_from_magic_header":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad Mágica desactivada"),
        "manual_setup_change_from_magic_modal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Tu Copia de Seguridad de Mágica está a punto de eliminarse de forma permanente. Asegúrate de tener una copia de seguridad segura de tu semilla y de descargar tu Copia de Seguridad de Envoy.\n\nEsta acción eliminará permanentemente tu semilla de Envoy de tu cuenta de Apple o Google, y también eliminará tus datos cifrados de Envoy de los servidores de Foundation."),
        "manual_setup_change_from_magic_subheaderApple":
            MessageLookupByLibrary.simpleMessage(
                "Los datos de tu Copia de Seguridad Mágica de Envoy se han eliminado correctamente de tu cuenta Apple y de los servidores de Foundation."),
        "manual_setup_change_from_magic_subheaderGoogle":
            MessageLookupByLibrary.simpleMessage(
                "Los datos de tu Copia de Seguridad Mágica de Envoy se han eliminado correctamente de tu cuenta Google y de los servidores de Foundation."),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Elegir Destino"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Guardar Copia de Seguridad de Envoy"),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("Entendido"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tu Copia de Seguridad de Envoy está encriptado por tus palabras semilla. \n\nSi pierdes el acceso a tus palabras semilla, no podrás restaurar la copia de seguridad."),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy ha encriptado tu copia de seguridad. Esta copia de seguridad contiene datos útiles de la cartera, como Etiquetas, Notas, cuentas y configuración.\n\nPuedes optar por protegerlo en la nube, en otro dispositivo o en algún almacenamiento externo como una tarjeta microSD."),
        "manual_setup_generate_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Generar Semilla"),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Mantén Tu Semilla En Privado"),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Recuerda mantener siempre tus palabras semilla en privado. ¡Cualquiera que tenga acceso a esta semilla puede gastar tus Bitcoin!"),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage(
                "Elige una palabra para continuar"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage("Verifiquemos Tu Semilla"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage("Verifica Tu Semilla"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Entrada No Válida"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede verificar la semilla. Por favor confirma que hayas escrito correctamente tu semilla e inténtalo de nuevo."),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage(
                "¿Cuál es tu palabra semilla número"),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correcto"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy te hará algunas preguntas para verificar que registraste correctamente tu semilla."),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Escribe Estas 24 Palabras"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Escribe Estas 12 Palabras"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Generando Semilla"),
        "manual_setup_import_backup_CTA1": MessageLookupByLibrary.simpleMessage(
            "Crear Copia de Seguridad de Envoy"),
        "manual_setup_import_backup_CTA2": MessageLookupByLibrary.simpleMessage(
            "Importar Copia de Seguridad de Envoy"),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Error de lectura de Envoy Backup"),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Asegúrate de haber seleccionado el archivo correcto."),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "¿Quieres restaurar una Copia de Seguridad de Envoy existente?\n\nDe lo contrario, Envoy creará una nueva de copia de seguridad encriptada."),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esa semilla parece no ser válida. Compruebe las palabras introducidas, incluido el orden en el que se encuentran, e inténtelo de nuevo."),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Escribe Tu Semilla"),
        "manual_setup_import_seed_CTA1":
            MessageLookupByLibrary.simpleMessage("Importar con código QR"),
        "manual_setup_import_seed_CTA2":
            MessageLookupByLibrary.simpleMessage("24 Palabras Semilla"),
        "manual_setup_import_seed_CTA3":
            MessageLookupByLibrary.simpleMessage("12 Palabras Semilla"),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage(
                "Mi semilla tiene una Passphrase"),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage("Importa Tu Semilla"),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
                "No escribas tu semilla de Passport en las siguientes pantallas."),
        "manual_setup_import_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Continúa debajo para importar una semilla existente.\n\nTendrás la opción de importar una Copia de Seguridad de Envoy más adelante."),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("Importando Semilla"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad Mágica Detectada"),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignorar"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Se ha encontrado una Copia de Seguridad Mágica en el servidor.  \n¿Restaurar tu copia de seguridad?"),
        "manual_setup_recovery_fail_cta2":
            MessageLookupByLibrary.simpleMessage("Importar Palabras Semilla"),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No se puede escanear el código QR"),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Intenta escanear de nuevo o importa manualmente tus palabras semilla."),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si continúas sin una copia de seguridad, la configuración de tu cartera, las cuentas, notas y etiquetas no se restaurarán."),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage(
                "Volver a escribir la Passphrase"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage(
                "Elegir otra Copia de Seguridad"),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy no puede abrir esta Copia de Seguridad de Envoy"),
        "manual_setup_recovery_import_backup_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esto podría deberse a que has importado una copia de seguridad de una Cartera Envoy diferente o a que tu Passphrase era incorrecta."),
        "manual_setup_recovery_import_backup_re_enter_passphrase_heading":
            MessageLookupByLibrary.simpleMessage(
                "Vuelve a escribir tu \nPassphrase"),
        "manual_setup_recovery_import_backup_re_enter_passphrase_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Vuelve a escribir cuidadosamente tu Passphrase para que Envoy pueda abrir tu Copia de Seguridad de Envoy."),
        "manual_setup_recovery_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Escribe tu Passphrase"),
        "manual_setup_recovery_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta semilla está protegida por una Passphrase. Introdúcelo debajo para restaurar tu Cartera Envoy."),
        "manual_setup_recovery_success_heading":
            MessageLookupByLibrary.simpleMessage("Importando tu Semilla"),
        "manual_setup_tutorial_CTA1":
            MessageLookupByLibrary.simpleMessage("Generar Nueva Semilla"),
        "manual_setup_tutorial_CTA2":
            MessageLookupByLibrary.simpleMessage("Importar Semilla"),
        "manual_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
            "Configuración Manual de Semilla"),
        "manual_setup_tutorial_subheading": MessageLookupByLibrary.simpleMessage(
            "Si prefieres gestionar tus propias palabras semilla, continúa debajo para crear o importar una semilla nueva.\n\nTen en cuenta que serás la única persona responsable de administrar las copias de seguridad. No se utilizarán servicios en la nube."),
        "manual_setup_verify_enterYourPassphrase":
            MessageLookupByLibrary.simpleMessage("Escribe tu Passphrase"),
        "manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Las Passphrases son sensibles a mayúsculas, minúsculas y espacios. Escribe con atención."),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2":
            MessageLookupByLibrary.simpleMessage(
                "Las [[Passphrases]] son una función avanzada."),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si no comprende las implicaciones de usar una, cierre este aviso y continúe sin una.\n\nFoundation no tiene forma de recuperar una Passphrase perdida o incorrecta."),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Verifica tu Passphrase"),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Vuelve a escribir cuidadosamente tu Passphrase."),
        "manual_toggle_off_disabled_for_manual_seed_configuration":
            MessageLookupByLibrary.simpleMessage(
                "Deshabilitado para Configuración Manual "),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage(
                "Descargar Copia de Seguridad de Envoy"),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Ver Semilla Envoy"),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
                "Almacenado en la Copia de Seguridad de Android"),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Copia de Seguridad de Envoy"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Semilla Envoy"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Ejecutar"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage(
                "Almacenado en el Llavero iCloud"),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage(
                "a los servidores de Foundation"),
        "manual_toggle_on_seed_backingup": MessageLookupByLibrary.simpleMessage(
            "Realizando copia de seguridad…"),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage("Copia de Seguridad en Curso"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad de Envoy realizada."),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Realizar Copia de Seguridad de Envoy"),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta copia de seguridad contiene información soibre los dispositivos y cuentas vinculadas, etiquetas, notas y configuración. No contiene información sobre la clave privada.\n\nLas copias de seguridad de Envoy están encriptadas de extremo a extremo, Foundation no tiene acceso ni conocimiento de su contenido. \n\nEnvoy te notificará cuando se complete la carga."),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Configuración Android"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Copia de Seguridad de Android pendiente (una vez al día)"),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Copia de seguridad pendiente en el llavero iCloud"),
        "manual_toggle_on_seed_uploading_foundation_servers":
            MessageLookupByLibrary.simpleMessage(
                "Subiendo a los servidores de Foundation"),
        "menu_about": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("COPIAS DE SEGURIDAD"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_privacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("AJUSTES"),
        "menu_support": MessageLookupByLibrary.simpleMessage("AYUDA"),
        "onboarding_advancedModal_content": MessageLookupByLibrary.simpleMessage(
            "Si continúas sin una Copia de Seguridad Mágica, serás responsable de almacenar tu propia semilla y datos de recuperación."),
        "onboarding_advancedModal_header":
            MessageLookupByLibrary.simpleMessage("¿Estás seguro?"),
        "onboarding_advanced_magicBackupSwitchText":
            MessageLookupByLibrary.simpleMessage(
                "Copias de seguridad sencillas y seguras"),
        "onboarding_advanced_magicBackups":
            MessageLookupByLibrary.simpleMessage("Copia de Seguridad Mágica"),
        "onboarding_advanced_magicBackupsContent":
            MessageLookupByLibrary.simpleMessage(
                "Copias de seguridad encriptadas y automáticas de tus datos, para una recuperación instantánea y sin estrés."),
        "onboarding_advanced_title":
            MessageLookupByLibrary.simpleMessage("Avanzado"),
        "onboarding_bluetoothDisabled_content":
            MessageLookupByLibrary.simpleMessage(
                "Passport Prime necesita utilizar Bluetooth para la configuración inicial con QuantumLink. Esto permite sincronizar la fecha y la hora, las actualizaciones de firmware, las comprobaciones de seguridad, las copias de seguridad y más.\n\nPor favor, habilita los permisos de Bluetooth en la configuración del Envoy."),
        "onboarding_bluetoothDisabled_enable":
            MessageLookupByLibrary.simpleMessage("Habilitar en Ajustes"),
        "onboarding_bluetoothDisabled_header":
            MessageLookupByLibrary.simpleMessage(
                "Activar Bluetooth para la conexión QuantumLink"),
        "onboarding_bluetoothIntro_connect":
            MessageLookupByLibrary.simpleMessage("Conectar con QuantumLink"),
        "onboarding_bluetoothIntro_content": MessageLookupByLibrary.simpleMessage(
            "Passport Prime utiliza un nuevo protocolo seguro basado en Bluetooth para la comunicación en tiempo real con Envoy.\n\nQuantumLink crea un túnel cifrado de extremo a extremo entre Passport y Envoy, garantizando una conexión segura."),
        "onboarding_bluetoothIntro_header":
            MessageLookupByLibrary.simpleMessage(
                "Bluetooth Seguro con\nQuantumLink"),
        "onboarding_connectionChecking_SecurityPassed":
            MessageLookupByLibrary.simpleMessage(
                "Comprobación de Seguridad Superada"),
        "onboarding_connectionChecking_forUpdates":
            MessageLookupByLibrary.simpleMessage(
                "Comprobando​•​Actualizaciones"),
        "onboarding_connectionIntroError_content":
            MessageLookupByLibrary.simpleMessage(
                "Es posible que este dispositivo no sea original o que haya sido manipulado durante el envío."),
        "onboarding_connectionIntroError_exitSetup":
            MessageLookupByLibrary.simpleMessage("Cerrar Incialización"),
        "onboarding_connectionIntroError_securityCheckFailed":
            MessageLookupByLibrary.simpleMessage(
                "Comprobación de Seguridad Fallida"),
        "onboarding_connectionIntroWarning_content":
            MessageLookupByLibrary.simpleMessage(
                "Asegúrate de que Passport Prime esté encendido y cerca de tu teléfono."),
        "onboarding_connectionIntroWarning_header":
            MessageLookupByLibrary.simpleMessage("Inicialización Pausada"),
        "onboarding_connectionIntro_checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Buscar Actualizaciones"),
        "onboarding_connectionIntro_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage(
                "Comprobando Seguridad del Dispositivo"),
        "onboarding_connectionIntro_connectedToPrime":
            MessageLookupByLibrary.simpleMessage("Conectado a Passport Prime"),
        "onboarding_connectionIntro_header":
            MessageLookupByLibrary.simpleMessage("Passport Prime Conectado"),
        "onboarding_connectionNoUpdates_noUpdates":
            MessageLookupByLibrary.simpleMessage(
                "No Hay Actualizaciones Disponibles"),
        "onboarding_connectionUpdatesAvailable_updatesAvailable":
            MessageLookupByLibrary.simpleMessage(
                "Nueva Actualización Disponible"),
        "onboarding_magicUserMobileCreating_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está creando una clave segura para utilizar con tu Cartera Móvil de Bitcoin, que se almacenará encriptada de extremo a extremo en tu cuenta de Apple o Google."),
        "onboarding_magicUserMobileCreating_header":
            MessageLookupByLibrary.simpleMessage(
                "Creando Clave de Cartera Móvil"),
        "onboarding_magicUserMobileEncrypting_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está encriptando tu copia de seguridad.\n\nEsta copia de seguridad contiene datos útiles de la cartera como etiquetas, notas, cuentas y configuración."),
        "onboarding_magicUserMobileEncrypting_header":
            MessageLookupByLibrary.simpleMessage(
                "Encriptando Copia de Seguridad de Cartera"),
        "onboarding_magicUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
                "También conocida como \"cartera caliente\". Para poder gastar de esta cartera, solo se requiere la autorización del teléfono."),
        "onboarding_magicUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
                "La Clave de tu Cartera Móvil se almacenará en el enclave seguro de tu teléfono, encriptada y con copia de seguridad en tu cuenta de Apple o Google."),
        "onboarding_magicUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage(
                "Configura una Cartera Móvil con Copias de Seguridad Mágicas"),
        "onboarding_magicUserMobileIntro_learnMoreMagicBackups":
            MessageLookupByLibrary.simpleMessage(
                "Más información sobre las Copias de Seguridad Mágicas"),
        "onboarding_magicUserMobileSuccess_content":
            MessageLookupByLibrary.simpleMessage(
                "¡Envoy está configurado y listo para tus Bitcoin!"),
        "onboarding_magicUserMobileSuccess_header":
            MessageLookupByLibrary.simpleMessage("Tu Cartera Móvil Está Lista"),
        "onboarding_magicUserMobileUploading_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está subiendo la copia de seguridad encriptada de tu cartera a los servidores de Foundation.\n\nComo la copia de seguridad está encriptada de extremo a extremo, Foundation no tiene acceso a ella, ni tiene conocimiento sobre su contenido."),
        "onboarding_magicUserMobileUploading_header":
            MessageLookupByLibrary.simpleMessage("Cargando Copia de Seguridad"),
        "onboarding_migrating_xOfYSynced": m9,
        "onboarding_passpportSelectCamera_sub235VersionAlert":
            MessageLookupByLibrary.simpleMessage(
                "¿Quieres inicializar una Passport Core en la versión 2.3.5 o anterior?"),
        "onboarding_passpportSelectCamera_tapHere":
            MessageLookupByLibrary.simpleMessage("Pulsa aquí"),
        "onboarding_primeIntro_content": MessageLookupByLibrary.simpleMessage(
            "Enhorabuena por dar el primer paso para asegurar toda tu vida digital.\n\nConfigurar tu Passport Prime sólo te llevará entre 5 y 10 minutos. ¡Coge tu dispositivo y empecemos!"),
        "onboarding_primeIntro_header":
            MessageLookupByLibrary.simpleMessage("Configura tu Passport Prime"),
        "onboarding_sovereignUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
                "También conocida como \"cartera caliente\". Para poder gastar de esta cartera, solo se requiere la autorización del teléfono."),
        "onboarding_sovereignUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
                "Tus claves de Bitcoin se almacenarán en el enclave seguro de tu teléfono. Solo tú eres responsable de mantener una copia de seguridad de tu semilla."),
        "onboarding_sovereignUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage("Configurar Cartera Móvil"),
        "onboarding_tutorialColdWallet_content":
            MessageLookupByLibrary.simpleMessage(
                "También conocida como \"cartera fría\". Para autorizar gastos con esta cartera necesitas utilizar tu Passport. \n\nTu Clave Maestra de Passport siempre se guarda de forma segura sin conexión a Internet.\n\nUsa esta cartera para asegurar la mayoría de tus ahorros en Bitcoin."),
        "onboarding_tutorialColdWallet_header":
            MessageLookupByLibrary.simpleMessage("Cartera Passport"),
        "onboarding_tutorialHotWallet_content":
            MessageLookupByLibrary.simpleMessage(
                "También conocida como \"cartera caliente\". Para autorizar gastos desde esta cartera, sólo necesitas tu teléfono.\n\nComo tu Cartera Móvil está conectada a Internet, utilízala para almacenar pequeñas cantidades de Bitcoin para transacciones frecuentes."),
        "onboarding_tutorialHotWallet_header":
            MessageLookupByLibrary.simpleMessage("Cartera Móvil"),
        "onboarding_welcome_content": MessageLookupByLibrary.simpleMessage(
            "Recupera tu soberanía con Envoy, una cartera de Bitcoin sencilla pero con funciones potentes de administración de cuentas y privacidad."),
        "onboarding_welcome_createMobileWallet":
            MessageLookupByLibrary.simpleMessage("Crea una \nCartera Móvil"),
        "onboarding_welcome_header":
            MessageLookupByLibrary.simpleMessage("Bienvenido a Envoy"),
        "onboarding_welcome_setUpPassport":
            MessageLookupByLibrary.simpleMessage("Configura una\nPassport"),
        "pair_existing_device_intro_heading":
            MessageLookupByLibrary.simpleMessage(
                "Conectar Passport\ncon Envoy"),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
                "En Passport, selecciona Administrar cuenta > Conectar Wallet > Envoy."),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
            "Escanea este código QR con Passport para validarlo"),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta es una dirección de Bitcoin que pertenece a tu Passport."),
        "pair_new_device_address_cta2":
            MessageLookupByLibrary.simpleMessage("Contactar Servicio Técnico"),
        "pair_new_device_address_heading":
            MessageLookupByLibrary.simpleMessage("¿Dirección validada?"),
        "pair_new_device_address_subheading": MessageLookupByLibrary.simpleMessage(
            "Si recibes un mensaje de éxito en Passport, significa que la configuración se ha completado.\n\nSi Passport no pudo verificar la dirección, inténtelo de nuevo o póngase en contacto con el servicio de asistencia."),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este paso permite a Envoy generar direcciones de recepción para Passport y proponer transacciones de gasto que Passport debe autorizar. "),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
            "Escanea el código QR que genera Passport"),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
            "El código QR contiene la información necesaria para que Envoy interactúe de forma segura con Passport."),
        "pair_new_device_success_cta1": MessageLookupByLibrary.simpleMessage(
            "Validar dirección de recepción"),
        "pair_new_device_success_cta2": MessageLookupByLibrary.simpleMessage(
            "Continuar a la pantalla de inicio"),
        "pair_new_device_success_heading":
            MessageLookupByLibrary.simpleMessage("Conectado con Éxito"),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy está conectado a tu Passport."),
        "passport_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
            "Configurar un nuevo Passport"),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Conectar un Passport existente"),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
            "No tengo un Passport. [[Más información.]]"),
        "passport_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Bienvenidos a Passport"),
        "passport_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy ofrece una configuración segura de Passport, actualizaciones de firmware sencillas y una experiencia de cartera Bitcoin muy zen."),
        "privacySetting_nodeConnected":
            MessageLookupByLibrary.simpleMessage("Nodo Conectado"),
        "privacy_applicationLock_title":
            MessageLookupByLibrary.simpleMessage("Bloqueo de aplicación"),
        "privacy_applicationLock_unlock":
            MessageLookupByLibrary.simpleMessage("Desbloqueo con Huella o PIN"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
            "Mejora tu privacidad con tu propio nodo. Pulsa Más información arriba. "),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage("Altura de bloque:"),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage(
                "Conectado a servidor Esplora"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
                "No se pudo conectar a servidor Esplora."),
        "privacy_node_connectedTo":
            MessageLookupByLibrary.simpleMessage("Conectado a"),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage(
                "Problema al establecer conexión con el nodo."),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
                "Incluso con la opción \"Mejor Privacidad\" activada, Envoy no puede evitar las interferencias en caso de que haya algún dispositivo comprometido en tu red local."),
        "privacy_node_nodeAddress": MessageLookupByLibrary.simpleMessage(
            "Introduce la dirección de tu nodo"),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage("Foundation (Predeterminado)"),
        "privacy_node_nodeType_personal":
            MessageLookupByLibrary.simpleMessage("Nodo Personal"),
        "privacy_node_nodeType_publicServers":
            MessageLookupByLibrary.simpleMessage("Servidores públicos"),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Nodo"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Mejor \nRendimiento"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage("Mejor\nPrivacidad"),
        "privacy_privacyMode_title":
            MessageLookupByLibrary.simpleMessage("Modo de privacidad"),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
                "La conexión de Envoy será más estable con Tor [[DESACTIVADO]]. Recomendado para nuevos usuarios."),
        "privacy_privacyMode_torSuggestionOn": MessageLookupByLibrary.simpleMessage(
            "Tor se [[ACTIVARÁ]] para mejorar la privacidad. Es posible que la conexión de Envoy no sea del todo estable."),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Añadir Nodo"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Editar Nodo"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tu nodo está conectado a través de Clearnet."),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
                "No hemos podido conectar el nodo"),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Conectar"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("Conectando Tu Nodo"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
                "Tu nodo está conectado a través de Tor."),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage("Elige Tu Privacidad"),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
                "¿Cómo te gustaría que Envoy se conectase a Internet?"),
        "qrTooBig_warning_subheading": MessageLookupByLibrary.simpleMessage(
            "El código QR escaneado contiene una gran cantidad de datos y podría hacer que Envoy fuera inestable. ¿Estás seguro de que quieres continuar?"),
        "ramp_note": MessageLookupByLibrary.simpleMessage("Compra de Ramp"),
        "ramp_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Compra de Ramp Pendiente"),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage("Usar Dirección Taproot"),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("RECIBIR"),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("Esperando confirmación"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Recibir"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Inicia sesión en Google y restaura tus datos de copia de seguridad"),
        "recovery_scenario_heading":
            MessageLookupByLibrary.simpleMessage("¿Cómo Restaurar?"),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
            "Instala Envoy y pulsa \"Configurar Cartera Envoy\""),
        "recovery_scenario_ios_instruction1": MessageLookupByLibrary.simpleMessage(
            "Inicia sesión en iCloud y restaura tu copia de seguridad de iCloud"),
        "recovery_scenario_ios_instruction3": MessageLookupByLibrary.simpleMessage(
            "A continuación, Envoy restaurará automáticamente tu Copia de Seguridad Mágica"),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
            "Para recuperar tu Cartera Envoy, sigue estas sencillas instrucciones."),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
                "La tasa elegida sólo se puede lograr añadiendo más monedas. Envoy lo hace automáticamente y nunca incluirá ninguna moneda bloqueada."),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage("Acelerando transacción"),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
            "Tu transacción no ha podido ser acelerada"),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage(
                "Revisar Selección de Monedas"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
                "Tu transacción ha sido acelerada"),
        "replaceByFee_boost_tx_boostFee":
            MessageLookupByLibrary.simpleMessage("Tasa de Aceleración"),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
            "Tu transacción está lista para ser acelerada"),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage("Nada"),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La tasa por cancelar esta transacción es tan grande que no se enviarán fondos de vuelta a tu cartera.\n\n¿Cancelar de todos modos?"),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage("Cancelando transacción"),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Tu transacción no ha podido ser cancelada"),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Tasa de Cancelación"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage("Proceder con Cancelación"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Cantidad a Recibir"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Reemplaza la transacción no confirmada por una que contenga una tasa más alta y devuelve los fondos a tu cartera."),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Tu transacción ha sido cancelada"),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este es un intento de cancelación. Existe una pequeña posibilidad de que tu transacción original se confirme antes de este intento de cancelación."),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Acelerar"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Acelerar Transacción"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aumenta la tasa asociada a tu transacción para acelerar el tiempo de confirmación."),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Requerido para Acelerar"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transacciones Eliminadas"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Las compras incompletas con los siguientes IDs de Ramp se han eliminado de tu actividad al haber pasado 5 días desde su inicio."),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage("Nueva Tasa de Transacción "),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para acelerar la transacción original, estás a punto de pagar una nueva tasa de:"),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
                "Esto sustituirá la tasa original de:"),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
                "Las compras que no se completen se eliminarán de tu actividad en un plazo de 5 días"),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "La tarifa elegida solo se puede lograr añadiendo más monedas. Envoy lo hace automáticamente y nunca incluirá monedas bloqueadas.\n\nEsta selección se podrá editar en la siguiente pantalla."),
        "scv_checkingDeviceSecurity": MessageLookupByLibrary.simpleMessage(
            "Comprobando la Seguridad del Dispositivo"),
        "send_keyboard_address_confirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "send_keyboard_address_loading":
            MessageLookupByLibrary.simpleMessage("Cargando…"),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage(
                "Introduce una dirección válida"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Fondos insuficientes"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage("Cantidad demasiado baja"),
        "send_keyboard_send_max":
            MessageLookupByLibrary.simpleMessage("Enviar máximo"),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("A:"),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
            "Escanea el QR con tu Passport"),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
            "Contiene la transacción para que tu Passport la firme."),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
            "Ahora puedes escanear el código QR que se muestra en tu Passport con la cámara del teléfono."),
        "send_reviewScreen_sendMaxWarning": MessageLookupByLibrary.simpleMessage(
            "Envío máximo: \nLas tasas se deducen de la cantidad que se envía."),
        "settings_advanced": MessageLookupByLibrary.simpleMessage("Avanzado"),
        "settings_advanced_enableBuyRamp":
            MessageLookupByLibrary.simpleMessage("Comprar en Envoy"),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Más información sobre Signet [[aquí]]."),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Activar Signet añade una versión Signet de tu Cartera Envoy. Esta función es utilizada principalmente por desarrolladores y testers y no tiene ningún valor."),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage("Aprende a hacerlo [[aquí]]."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Al habilitar Testnet, se añade una versión de Testnet3 de tu Cartera Envoy y te permite conectar cuentas de Testnet de tu Passport."),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activar"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Taproot es una función avanzada y el soporte de carteras aún es limitado.\n\nProcede con precaución."),
        "settings_advanced_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "settings_amount":
            MessageLookupByLibrary.simpleMessage("Ver cantidad en Sats"),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Divisa"),
        "settings_show_fiat":
            MessageLookupByLibrary.simpleMessage("Mostrar Valores Fiat"),
        "settings_viewEnvoyLogs":
            MessageLookupByLibrary.simpleMessage("Ver Registros de Envoy"),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("No, gracias"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Las notas de transacción pueden ser útiles a la hora de realizar gastos futuros."),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "No se ha podido enviar la transacción"),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Comprueba tu conexión e inténtalo de nuevo"),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Transacción enviada con éxito"),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Revisa los detalles pulsando sobre la transacción desde la pantalla de detalles de cuenta."),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("Enviando transacción"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esto puede tardar unos segundos"),
        "tagDetails_EditTagName":
            MessageLookupByLibrary.simpleMessage("Editar Nombre de Etiqueta"),
        "tagSelection_example1": MessageLookupByLibrary.simpleMessage("Gastos"),
        "tagSelection_example2":
            MessageLookupByLibrary.simpleMessage("Personal"),
        "tagSelection_example3":
            MessageLookupByLibrary.simpleMessage("Ahorros"),
        "tagSelection_example4":
            MessageLookupByLibrary.simpleMessage("Donaciones"),
        "tagSelection_example5": MessageLookupByLibrary.simpleMessage("Viajes"),
        "tagged_coin_details_inputs_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Descartar Cambios"),
        "tagged_coin_details_menu_cta1":
            MessageLookupByLibrary.simpleMessage("EDITAR NOMBRE DE ETIQUETA"),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
                "No hay monedas asignadas a esta etiqueta."),
        "tagged_tagDetails_sheet_cta1":
            MessageLookupByLibrary.simpleMessage("Enviar Selección"),
        "tagged_tagDetails_sheet_cta2":
            MessageLookupByLibrary.simpleMessage("Etiquetar Selección"),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage("Reetiquetar Selección"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Mantén pulsado y arrastra para reordenar tus cuentas."),
        "taproot_passport_dialog_heading":
            MessageLookupByLibrary.simpleMessage("Taproot en Passport"),
        "taproot_passport_dialog_later":
            MessageLookupByLibrary.simpleMessage("Hazlo Más Tarde"),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage("Volver a Conectar Passport"),
        "taproot_passport_dialog_subheading": MessageLookupByLibrary.simpleMessage(
            "Para habilitar una cuenta de Taproot en Passport, asegúrate de que estás ejecutando el firmware 2.3.0 o posterior y vuelve a conectar tu Passport."),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
            "Servidores de Foundation no accesibles"),
        "toast_newEnvoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Actualización de Envoy disponible"),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage("Reintentar la Conexión Tor"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage(
                "Desactivar Tor temporalmente"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
            "Es posible que experimentes un rendimiento degradado de la aplicación hasta que Envoy pueda restablecer una conexión con Tor.\n\nDesactivando Tor se establecerá una conexión directa con el servidor de Envoy, [[a cambio]] de reducir la privacidad."),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
            "Problema de conectividad Tor"),
        "video_connectingToTorNetwork":
            MessageLookupByLibrary.simpleMessage("Conectando a la Red Tor"),
        "video_loadingTorText": MessageLookupByLibrary.simpleMessage(
            "Envoy está cargando el vídeo seleccionado a través de la red Tor"),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy realiza una copia de seguridad automática de tu semilla en la [[Copia de Seguridad de Android]].\n\nTu semilla siempre está encriptada de extremo a extremo y nunca es visible para Google."),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Envoy realiza una copia de seguridad automática de tu semilla en tu [[llavero iCloud.]]\n\nTu semilla siempre está encriptada de extremo a extremo y nunca es visible para Apple."),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Los datos de tu cartera, incluyendo etiquetas, notas, cuentas y la configuración, se respaldan automáticamente en los servidores de Foundation.\n\nEsta copia de seguridad se encripta primero con la semilla de tu cartera, lo que garantiza que Foundation nunca pueda acceder a tus datos."),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para recuperar tu cartera, inicia sesión en tu cuenta de Google. Envoy descargará automáticamente tu semilla y copia de seguridad.\n\nTe recomendamos que protejas tu cuenta de Google con una contraseña segura y 2FA."),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para recuperar tu cartera, inicia sesión en tu cuenta de iCloud. Envoy descargará automáticamente tu semilla y copia de seguridad.\n\nTe recomendamos que protejas tu cuenta de iCloud con una contraseña segura y 2FA."),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage(
                "Cómo Están Protegidos tus Datos"),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Si prefieres no tener Copia de Seguridad Mágica, y en su lugar proteger manualmente la semilla y los datos de tu cartera, ¡no hay problema!\n\nSimplemente vuleve a la pantalla de configuración y selecciona \"Configurar Semilla Manualmente\"."),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Cómo Está Protegida tu Cartera"),
        "wallet_security_modal__heading":
            MessageLookupByLibrary.simpleMessage("Consejo Se Seguridad"),
        "wallet_security_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Envoy está almacenando más Bitcoin que la cantidad máxima recomendada una cartera móvil conectada a Internet.\n\nPara un almacenamiento ultraseguro y offline, Foundation sugiere utilizar una Passport."),
        "wallet_setup_success_heading":
            MessageLookupByLibrary.simpleMessage("Tu Cartera Está Lista"),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
            "¡Envoy está configurado y listo para tus Bitcoin!"),
        "welcome_screen_ctA1":
            MessageLookupByLibrary.simpleMessage("Configurar Cartera Envoy"),
        "welcome_screen_cta2":
            MessageLookupByLibrary.simpleMessage("Configurar Passport"),
        "welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Bienvenidos a Envoy")
      };
}
