// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
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
  String get localeName => 'pt';

  static String m0(MB_name) => "Passport Prime Magic Backup\n”${MB_name}”";

  static String m1(period) =>
      "Este vale expirou a ${period}.\n\n\nPor favor entra em contacto com o emissor para quaisquer questões relacionadas com o vale.";

  static String m2(AccountName) =>
      "Acede a ${AccountName} no Passport, escolhe ‘Account Tools’ > ‘Verify Address’ e digitaliza o código QR.";

  static String m3(tagName) =>
      "A tua etiqueta ${tagName} está vazia. Pretendes eliminá-la?";

  static String m4(time_remaining) => "${time_remaining} remaining";

  static String m5(current_keyOS_version) =>
      "Your Passport Prime is currently running ${current_keyOS_version}.\n\nUpdate now for the latest bug fixes and features.";

  static String m6(est_upd_time) => "Estimated Update Time: ${est_upd_time}";

  static String m7(new_keyOS_version) => "What’s New in ${new_keyOS_version}";

  static String m8(new_keyOS_version) =>
      "Passport Prime was successfully \nupdated to ${new_keyOS_version}";

  static String m9(amount, total_amount) =>
      "Re-syncing your accounts.\nPlease do not close Envoy.\n\n${amount} of ${total_amount} synced";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage("Skip"),
        "about_appVersion":
            MessageLookupByLibrary.simpleMessage("Versão da Aplicação"),
        "about_openSourceLicences":
            MessageLookupByLibrary.simpleMessage("Licenças de Código Aberto"),
        "about_privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacidade"),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Termos de Uso"),
        "accountDetails_descriptor_legacy":
            MessageLookupByLibrary.simpleMessage("Legacy"),
        "accountDetails_descriptor_segwit":
            MessageLookupByLibrary.simpleMessage("Segwit"),
        "accountDetails_descriptor_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "accountDetails_descriptor_wrappedSegwit":
            MessageLookupByLibrary.simpleMessage("Wrapped Segwit"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "account_details_untagged_card":
            MessageLookupByLibrary.simpleMessage("Sem etiqueta"),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
                "Os filtros aplicados escondem todas as transacções.\nActualiza ou repõe os filtros para ver as transacções."),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Não existem transacções nesta conta.\nRecebe a tua primeira transação abaixo."),
        "account_type_label_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "account_type_sublabel_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Cria uma carteira móvel utilizando a Cópia Mágica de Segurança."),
        "accounts_empty_text_learn_more":
            MessageLookupByLibrary.simpleMessage("Começar"),
        "accounts_forceUpdate_cta":
            MessageLookupByLibrary.simpleMessage("Actualizar Envoy"),
        "accounts_forceUpdate_heading": MessageLookupByLibrary.simpleMessage(
            "Necessário actualizar a Envoy"),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
            "Está disponível uma nova actualização para a Envoy que contém melhorias e correcções importantes.\n\nPara continuares a usar a Envoy por favor actualiza para a versão mais recente. Obrigado."),
        "accounts_screen_walletType_Envoy":
            MessageLookupByLibrary.simpleMessage("Envoy"),
        "accounts_screen_walletType_Passport":
            MessageLookupByLibrary.simpleMessage("Passport"),
        "accounts_screen_walletType_defaultName":
            MessageLookupByLibrary.simpleMessage("Carteira Móvel"),
        "accounts_switchDefault":
            MessageLookupByLibrary.simpleMessage("Default"),
        "accounts_switchPassphrase":
            MessageLookupByLibrary.simpleMessage("Passphrase"),
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
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Reforçada"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("A cancelar"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
            "Não existe atividade para apresentar."),
        "activity_envoyUpdate":
            MessageLookupByLibrary.simpleMessage("Aplicação Envoy Actualizada"),
        "activity_envoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Actualização para a Envoy disponível"),
        "activity_firmwareUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualização de firmware disponível"),
        "activity_incomingPurchase":
            MessageLookupByLibrary.simpleMessage("Compra a Receber"),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Hoje"),
        "activity_passportUpdate": MessageLookupByLibrary.simpleMessage(
            "Actualização para o Passport disponível"),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pendente"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Recebido"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Enviado"),
        "activity_sent_boosted":
            MessageLookupByLibrary.simpleMessage("Enviado (Reforçada)"),
        "activity_sent_canceled":
            MessageLookupByLibrary.simpleMessage("Cancelada"),
        "add_note_modal_heading":
            MessageLookupByLibrary.simpleMessage("Adicionar Nota"),
        "add_note_modal_ie_text_field": MessageLookupByLibrary.simpleMessage(
            "Compra da carteira física Passport"),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Regista alguns detalhes sobre esta transacção."),
        "android_backup_info_heading": MessageLookupByLibrary.simpleMessage(
            "O Android realiza Cópias de Segurança a Cada 24h"),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
            "O Android faz uma cópia de segurança automática dos dados da Envoy a cada 24 horas.\n\nPara garantires que a tua primeira Cópia Mágica de Segurança foi concluída com sucesso, recomendamos que faças uma cópia de segurança manual nas [[Definições]] do teu dispositivo. "),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
            "A Envoy é uma carteira Bitcoin simples com funcionalidades poderosas de gestão de contas e de privacidade.\n\nUtiliza o Envoy em conjunto com a tua carteira física Passport para configuração, actualizações de firmware e muito mais.\n\nA Envoy oferece as seguintes funcionalidades:\n\n1. Cópia Mágica de Segurança. Atinge a auto-custódia em apenas 60 segundos com cópias de segurança encriptadas e automáticas. As palavras semente são opcionais.\n\n2. Faz a gestão da tua carteira móvel e as contas da carteira associadas à carteira física Passport na mesma aplicação.\n\n3. Envia e recebe Bitcoin de uma forma serena.\n\n4. Liga à tua carteira física Passport para efeitos de configuração, atualizações de firmware e vídeos de apoio técnico. Utiliza a Envoy como a tua carteira de software conectada ao teu Passport.\n\n5. Aplicação de código aberto na íntegra, preservando a privacidade. Como opção, a Envoy pode conectar-se à Internet através da Rede Tor para a máxima privacidade.\n\n6. Em alternativa liga-te ao teu próprio nó Bitcoin."),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Vale Azteco pendente"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Não foi possível Ligar"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não consegue estabelecer ligação com a Azteco.\n\nPor favor entra em contacto com support@azte.co ou tenta novamente mais tarde."),
        "azteco_note": MessageLookupByLibrary.simpleMessage("Voucher Azteco"),
        "azteco_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Voucher Azteco Pendente"),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage("CÓDIGO DO VALE"),
        "azteco_redeem_modal_amount":
            MessageLookupByLibrary.simpleMessage("Quantia"),
        "azteco_redeem_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Resgatar"),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Erro ao Resgatar"),
        "azteco_redeem_modal_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Por favor confirma se o teu vale ainda está válido.\n\nContacta o support@azte.co para quaisquer questões relacionadas com o vale."),
        "azteco_redeem_modal_heading":
            MessageLookupByLibrary.simpleMessage("Resgatar Vale?"),
        "azteco_redeem_modal_saleDate":
            MessageLookupByLibrary.simpleMessage("Data de Venda"),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage("Vale Resgatado"),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Em breve irá aparecer uma transacção a receber na tua conta."),
        "backups_advancedBackups":
            MessageLookupByLibrary.simpleMessage("Advanced Backups"),
        "backups_downloadBIP329BackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Descarregar Cópia de Segurança BIP-329"),
        "backups_downloadSettingsDataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Download Settings & Data Backup File"),
        "backups_downloadSettingsMetadataBackupFile":
            MessageLookupByLibrary.simpleMessage(
                "Download Settings & Metadata Backup File"),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage(
                "Apagar Carteiras e Cópias de Segurança"),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás prestes a eliminar permanentemente a tua Carteira Envoy.\n\nSe estás a utilizar a Cópia Mágica de Segurança, a tua Semente Envoy também vai ser eliminada da Cópia de Segurança do Android."),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás prestes a eliminar permanentemente a tua Carteira Envoy.\n\nSe estás a utilizar a Cópia Mágica de Segurança, a tua Semente Envoy também vai ser eliminada do Porta-chaves iCloud."),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Qualquer conta Passport associada não será removida como parte deste processo.\n\nAntes de eliminares a tua Carteira Envoy, vamos garantir que a tua Semente e Cópia de Segurança são guardadas."),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Mostrar Semente"),
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
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Contas"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Atividade"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositivos"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprender"),
        "bottomNav_privacy":
            MessageLookupByLibrary.simpleMessage("Privacidade"),
        "btcpay_connection_modal_expired_subheading": m1,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Vale Expirado"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não consegue ligar-se à loja BTCPay do emissor.\n\nPor favor entra em contacto com o emissor ou tenta novamente mais tarde."),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O vale digitalizado não foi criado com suporte onchain.\n\nPor favor entra em contacto com o criador do vale."),
        "btcpay_note": MessageLookupByLibrary.simpleMessage("Voucher BTCPay"),
        "btcpay_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Vale BYCPay Pendente"),
        "btcpay_redeem_modal_description":
            MessageLookupByLibrary.simpleMessage("Descrição:"),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nome:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Rede Errada"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este é um voucher on-chain. Não pode ser resgatado para uma conta Testnet ou Signet."),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage(
                "Escolher uma conta diferente"),
        "buy_bitcoin_accountSelection_heading":
            MessageLookupByLibrary.simpleMessage(
                "Para onde deverá ser enviada a Bitcoin?"),
        "buy_bitcoin_accountSelection_modal_heading":
            MessageLookupByLibrary.simpleMessage("A sair da Envoy"),
        "buy_bitcoin_accountSelection_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás prestes a deixar a Envoy para o serviço do nosso parceiro para comprar Bitcoin. A Foundation nunca terá acesso a nenhuma informação de compra."),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O teu Bitcoin vai ser enviado para este endereço:"),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
                "Verificar o Endereço com o Passport"),
        "buy_bitcoin_accountSelection_verify_modal_heading": m2,
        "buy_bitcoin_buyOptions_atms_heading":
            MessageLookupByLibrary.simpleMessage(
                "Como é que gostarias de comprar?"),
        "buy_bitcoin_buyOptions_atms_map_modal_openingHours":
            MessageLookupByLibrary.simpleMessage("Horário de Funcionamento:"),
        "buy_bitcoin_buyOptions_atms_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Os diferentes fornecedores de Caixas Automáticas requerem quantidades variáveis de informações pessoais. Estas informações nunca são partilhadas com a Foundation."),
        "buy_bitcoin_buyOptions_atms_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Encontra uma Caixa Automática de Bitcoin na tua área local para comprares Bitcoin com dinheiro."),
        "buy_bitcoin_buyOptions_card_atms":
            MessageLookupByLibrary.simpleMessage("Caixas Automáticas"),
        "buy_bitcoin_buyOptions_card_commingSoon":
            MessageLookupByLibrary.simpleMessage("Brevemente na tua área."),
        "buy_bitcoin_buyOptions_card_disabledInSettings":
            MessageLookupByLibrary.simpleMessage("Desactivado nas definições."),
        "buy_bitcoin_buyOptions_card_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage("Comprar na Envoy"),
        "buy_bitcoin_buyOptions_card_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra Bitcoin em segundos, directamente para as contas do teu Passport ou carteira móvel."),
        "buy_bitcoin_buyOptions_card_peerToPeer":
            MessageLookupByLibrary.simpleMessage("Entre Particulares"),
        "buy_bitcoin_buyOptions_card_vouchers":
            MessageLookupByLibrary.simpleMessage("Vales"),
        "buy_bitcoin_buyOptions_inEnvoy_heading":
            MessageLookupByLibrary.simpleMessage(
                "Como é que gostarias de comprar?"),
        "buy_bitcoin_buyOptions_inEnvoy_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Informação partilhada com a Ramp aquando a compra de Bitcoin utilizando este método. Esta informação nunca é partilhada com a Foundation."),
        "buy_bitcoin_buyOptions_inEnvoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra com cartão de crédito, Apple Pay, Google Pay ou transferência bancária, diretamente nas tuas contas do Passport ou carteira móvel."),
        "buy_bitcoin_buyOptions_modal_address":
            MessageLookupByLibrary.simpleMessage("Endereço"),
        "buy_bitcoin_buyOptions_modal_bankingInfo":
            MessageLookupByLibrary.simpleMessage("Dados Bancários"),
        "buy_bitcoin_buyOptions_modal_email":
            MessageLookupByLibrary.simpleMessage("E-mail"),
        "buy_bitcoin_buyOptions_modal_identification":
            MessageLookupByLibrary.simpleMessage("Identificação"),
        "buy_bitcoin_buyOptions_modal_poweredBy":
            MessageLookupByLibrary.simpleMessage("Em parceria com"),
        "buy_bitcoin_buyOptions_notSupported_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Explora outras formas de comprar Bitcoin."),
        "buy_bitcoin_buyOptions_peerToPeer_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A maioria das transacções não requer a partilha de informações, mas o teu parceiro comercial pode ser informado das tuas informações bancárias. Esta informação nunca é partilhada com a Foundation."),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk":
            MessageLookupByLibrary.simpleMessage("AgoraDesk"),
        "buy_bitcoin_buyOptions_peerToPeer_options_agoraDesk_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra de Bitcoin sem custódia e entre particulares."),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq":
            MessageLookupByLibrary.simpleMessage("Bisq"),
        "buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra de Bitcoin sem custódia e entre particulares."),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl":
            MessageLookupByLibrary.simpleMessage("Hodl Hodl"),
        "buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra de Bitcoin sem custódia e entre particulares."),
        "buy_bitcoin_buyOptions_peerToPeer_options_heading":
            MessageLookupByLibrary.simpleMessage("Seleciona uma opção"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach":
            MessageLookupByLibrary.simpleMessage("Peach"),
        "buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra de Bitcoin sem custódia e entre particulares."),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats":
            MessageLookupByLibrary.simpleMessage("Robosats"),
        "buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra de Bitcoin sem custódia, nativas em Lightning e entre particulares."),
        "buy_bitcoin_buyOptions_peerToPeer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra Bitcoin fora da Envoy, sem intermediários. Requer mais passos, mas pode ser mais privado."),
        "buy_bitcoin_buyOptions_vouchers_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Diferentes vendedores exigirão quantidades variáveis de informações pessoais. Estas informações nunca são partilhadas com a Foundation."),
        "buy_bitcoin_buyOptions_vouchers_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compra vales de Bitcoin online ou fisicamente. Resgata através do scanner dentro de qualquer conta."),
        "buy_bitcoin_defineLocation_heading":
            MessageLookupByLibrary.simpleMessage("A tua Região"),
        "buy_bitcoin_defineLocation_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Selecciona a tua região para que a Envoy possa apresentar as opções de compra disponíveis para ti. Esta informação nunca sairá da Envoy."),
        "buy_bitcoin_details_menu_editRegion":
            MessageLookupByLibrary.simpleMessage("EDITAR A REGIÃO"),
        "buy_bitcoin_exit_modal_heading": MessageLookupByLibrary.simpleMessage(
            "Cancelar o Processo de Compra"),
        "buy_bitcoin_exit_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Estás prestes a cancelar o processo de compra. Tens a certeza?"),
        "buy_bitcoin_mapLoadingError_header":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível carregar o mapa"),
        "buy_bitcoin_mapLoadingError_subheader":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não consegue actualmente carregar os dados do mapa. Verifica a tua ligação ou tenta novamente mais tarde."),
        "buy_bitcoin_purchaseComplete_heading":
            MessageLookupByLibrary.simpleMessage("Compra Concluída"),
        "buy_bitcoin_purchaseComplete_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O término da compra pode demorar algum tempo dependendo do\nmétodo de pagamento e congestionamento da rede."),
        "buy_bitcoin_purchaseError_contactRamp":
            MessageLookupByLibrary.simpleMessage(
                "Por favor entra em contacto com a Ramp para assistência técnica."),
        "buy_bitcoin_purchaseError_heading":
            MessageLookupByLibrary.simpleMessage("Algo Correu Mal"),
        "buy_bitcoin_purchaseError_purchaseID":
            MessageLookupByLibrary.simpleMessage("ID de Compra:"),
        "card_coin_locked":
            MessageLookupByLibrary.simpleMessage("Moeda Bloqueada"),
        "card_coin_selected":
            MessageLookupByLibrary.simpleMessage("Moeda Seleccionada"),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Moeda"),
        "card_coins_locked":
            MessageLookupByLibrary.simpleMessage("Moedas Bloqueadas"),
        "card_coins_selected":
            MessageLookupByLibrary.simpleMessage("Moedas Seleccionadas"),
        "card_coins_unselected": MessageLookupByLibrary.simpleMessage("Moedas"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("de"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Escolhe uma Etiqueta"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
                "Esta transação gasta moedas de várias etiquetas. De que forma gostarias de etiquetar o teu troco?"),
        "coinDetails_tagDetails":
            MessageLookupByLibrary.simpleMessage("DETALHES DA ETIQUETA"),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O teu ID de transacção vai ser copiado para a tua área de transferência e poderá ser visível para outras aplicações no teu telemóvel."),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Saldo disponível"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Quantia Necessária"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Quantia Seleccionada"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Bloquear"),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O bloqueio das moedas impossibilita o seu uso em transacções"),
        "coincontrol_switchActivity":
            MessageLookupByLibrary.simpleMessage("Atividade"),
        "coincontrol_switchTags":
            MessageLookupByLibrary.simpleMessage("Etiquetas"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Rever Transacção"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage("Assinar com o Passport"),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
                "A tua transacção está pronta\npara ser assinada"),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
                "Confirma se os dados da transacção estão correctos antes de assinar com o Passport."),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Guarda alguns detalhes da tua transacção."),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Mostrar detalhes"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Quantidade a enviar"),
        "coincontrol_tx_detail_change":
            MessageLookupByLibrary.simpleMessage("Troco recebido"),
        "coincontrol_tx_detail_cta1":
            MessageLookupByLibrary.simpleMessage("Enviar Transacção"),
        "coincontrol_tx_detail_cta2":
            MessageLookupByLibrary.simpleMessage("Editar Transacção"),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Confirmar Taxa"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_cta":
            MessageLookupByLibrary.simpleMessage("Acima de 25%"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Acima de 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage("Destino"),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Mostrar endereço"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Troco recebido"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage("moeda"),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage("moedas"),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DA TRANSACÇÃO"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Gasto de"),
        "coincontrol_tx_detail_fee":
            MessageLookupByLibrary.simpleMessage("Taxa"),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
                "Ao actualizares a tua taxa podes ter alterado\na selecção das moedas. Por favor revê."),
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage("Personalizar"),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage("Rápida"),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage("Padrão"),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
            "A tua transacção está pronta\npara ser enviada"),
        "coincontrol_tx_detail_high_fee_info_overlay_learnMore":
            MessageLookupByLibrary.simpleMessage("[[Mais informações]]"),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Algumas moedas mais pequenas foram excluídas desta transação. Com a taxa de comissão escolhida, o custo da sua inclusão é superior ao seu valor."),
        "coincontrol_tx_detail_newFee":
            MessageLookupByLibrary.simpleMessage("Nova Taxa"),
        "coincontrol_tx_detail_no_change":
            MessageLookupByLibrary.simpleMessage("Sem troco"),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage("Cancelar Transacção"),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Ao cancelar irás perder todo o progresso da transacção."),
        "coincontrol_tx_detail_subheading": MessageLookupByLibrary.simpleMessage(
            "Confirma se os dados da transacção estão correctos antes do envio."),
        "coincontrol_tx_detail_total":
            MessageLookupByLibrary.simpleMessage("Total"),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Desbloquear"),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O desbloqueio das moedas torna-as disponíveis para uso em transacções."),
        "coindetails_overlay_address":
            MessageLookupByLibrary.simpleMessage("Endereço"),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("às"),
        "coindetails_overlay_boostedFees":
            MessageLookupByLibrary.simpleMessage("Taxa de Reforço"),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage("Confirmação em"),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage("Confirmação em"),
        "coindetails_overlay_confirmationIn_day":
            MessageLookupByLibrary.simpleMessage("dia"),
        "coindetails_overlay_confirmationIn_days":
            MessageLookupByLibrary.simpleMessage("dias"),
        "coindetails_overlay_confirmationIn_month":
            MessageLookupByLibrary.simpleMessage("mês"),
        "coindetails_overlay_confirmationIn_week":
            MessageLookupByLibrary.simpleMessage("semana"),
        "coindetails_overlay_confirmationIn_weeks":
            MessageLookupByLibrary.simpleMessage("semanas"),
        "coindetails_overlay_confirmation_boost":
            MessageLookupByLibrary.simpleMessage("Reforçar"),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Data"),
        "coindetails_overlay_explorer":
            MessageLookupByLibrary.simpleMessage("Explorador"),
        "coindetails_overlay_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DA MOEDA"),
        "coindetails_overlay_modal_explorer_heading":
            MessageLookupByLibrary.simpleMessage("Abrir no Explorador"),
        "coindetails_overlay_modal_explorer_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Estás prestes a deixar a Envoy e consultar esta transacção num explorador de blocos alojado pela Foundation. Certifica-te que compreendes os compromissos de privacidade antes de continuar."),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível Reforçar a Transacção"),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Isto deve-se ao facto de não existirem moedas confirmadas ou desbloqueadas suficientes para escolher. \n\nSempre que possível permite que as moedas pendentes sejam confirmadas ou deslobqueia algumas moedas e tenta novamente."),
        "coindetails_overlay_noCancelNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Impossível Cancelar Transacção"),
        "coindetails_overlay_noCanceltNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Não estão disponíveis moedas confirmadas ou desbloqueadas suficientes para cancelar esta transação. \n\nSempre que possível, deixa que as moedas pendentes sejam confirmadas ou desbloqueia algumas moedas e tenta novamente."),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coindetails_overlay_paymentID":
            MessageLookupByLibrary.simpleMessage("ID de Pagamento"),
        "coindetails_overlay_rampFee":
            MessageLookupByLibrary.simpleMessage("Taxas de Ramp"),
        "coindetails_overlay_rampID":
            MessageLookupByLibrary.simpleMessage("ID de Ramp"),
        "coindetails_overlay_status":
            MessageLookupByLibrary.simpleMessage("Estado"),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmada"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage("Pendente"),
        "coindetails_overlay_tag":
            MessageLookupByLibrary.simpleMessage("Etiqueta"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage("ID de Transacção"),
        "common_button_contactSupport":
            MessageLookupByLibrary.simpleMessage("Contact Support"),
        "component_Apply": MessageLookupByLibrary.simpleMessage("Aplicar"),
        "component_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
        "component_back": MessageLookupByLibrary.simpleMessage("Voltar"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "component_confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "component_content": MessageLookupByLibrary.simpleMessage("Conteúdo"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "component_device": MessageLookupByLibrary.simpleMessage("Dispositivo"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Dispensar"),
        "component_done": MessageLookupByLibrary.simpleMessage("Concluído"),
        "component_dontShowAgain":
            MessageLookupByLibrary.simpleMessage("Não mostrar novamente"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
        "component_filter_button_all":
            MessageLookupByLibrary.simpleMessage("Tudo"),
        "component_goToSettings":
            MessageLookupByLibrary.simpleMessage("Ir para Definições"),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Mais informações"),
        "component_minishield_buy":
            MessageLookupByLibrary.simpleMessage("Comprar"),
        "component_next": MessageLookupByLibrary.simpleMessage("Próximo"),
        "component_no": MessageLookupByLibrary.simpleMessage("Não"),
        "component_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "component_recover": MessageLookupByLibrary.simpleMessage("Recover"),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Resgatar"),
        "component_reset": MessageLookupByLibrary.simpleMessage("Repor"),
        "component_retry":
            MessageLookupByLibrary.simpleMessage("Tentar novamente"),
        "component_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Saltar"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "component_tryAgain":
            MessageLookupByLibrary.simpleMessage("Tentar Novamente"),
        "component_update": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "component_warning": MessageLookupByLibrary.simpleMessage("AVISO"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Sim"),
        "contactRampForSupport": MessageLookupByLibrary.simpleMessage(
            "Contacta a Ramp para assistência"),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
            "O teu endereço será copiado para a área de transferência e poderá ficar visível para outras aplicações no teu telemóvel."),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
            "O teu ID de transacção vai ser copiado para a tua área de transferência e poderá ser visível para outras aplicações no teu telemóvel."),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
                "As etiquetas são uma forma útil de organizares as tuas moedas."),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage("Sugestões"),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Mais usadas"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tens a certeza que queres eliminar esta etiqueta?"),
        "delete_tag_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Eliminar Etiqueta"),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "A eliminação desta etiqueta marcará automaticamente estas moedas como sem etiqueta."),
        "delete_wallet_for_good_error_content":
            MessageLookupByLibrary.simpleMessage(
                "Envoy was unable to contact the Foundation server to delete your encrypted wallet data. Please try again or contact support."),
        "delete_wallet_for_good_error_title":
            MessageLookupByLibrary.simpleMessage("Unable to Delete"),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O Android faz uma cópia de segurança automática dos dados da Envoy a cada 24 horas.\n\nPara removeres imediatamente a tua Semente Envoy da Cópia de Segurança do Android, podes fazer uma cópia de segurança manual nas [[Definições]] do teu dispositivo."),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage(
                "A eliminar a tua Carteira Envoy"),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Eliminar Carteira"),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tens a certeza que pretendes ELIMINAR a tua Carteira Envoy?"),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "A tua carteira foi eliminada com sucesso"),
        "devices_empty_modal_video_cta1":
            MessageLookupByLibrary.simpleMessage("Comprar o Passport"),
        "devices_empty_modal_video_cta2":
            MessageLookupByLibrary.simpleMessage("Ver Mais Tarde"),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
            "Protege a tua Bitcoin com o Passport."),
        "empty_tag_modal_subheading": m3,
        "envoy_account_tos_cta": MessageLookupByLibrary.simpleMessage("Aceito"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
            "Por favor revê e aceita as Condições de Utilização do Passport"),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
            "O Envoy requer acesso à câmera para ler códigos QR. Acede às definições e autoriza o acesso à câmera."),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Autorização necessária"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
            "A Envoy é uma carteira móvel de Bitcoin e uma aplicação complementar ao Passport, disponível em iOS e Android."),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
            "Não, qualquer pessoa é livre de descarregar, verificar e instalar manualmente o novo firmware. Podes ver mais informações [[aqui]]."),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
            "Sem dúvida, não existe limite para o número de Passports que podes gerir e interagir na Envoy."),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
            "Sim, a Envoy simplifica a gestão de várias contas."),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
            "A Envoy comunica maioritariamente através de códigos QR, apesar de as actualizações de firmware serem transferidas para o teu telemóel através de um cartão microSd. Por defeito cada Passport vem com um adaptador microSD para utilizares no teu telemóvel."),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
            "Sim, apenas tem em conta que qualquer informação específica da carteira, como por exemplo endereços ou notas de transacções, não serão copiadas de ou para a Envoy."),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
            "Isso pode ser possível uma vez que a maioria das carteiras físicas com funcionalidades de leitura de códigos QR comunicam de formas muito semelhantes, no entanto, isso não é uma forma explicitamente suportada. Uma vez que todo o código da Envoy é aberto, damos as boas vindas a que outros fabricantes de carteiras físicas baseadas em leitura de códigos QR adicionem suporte!"),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
            "De momento, a Envoy apenas funciona com Bitcoin \'on-chain\'. Planeamos suportar Lightning no futuro."),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
            "Qualquer pessoa que encontre o teu telefone precisaria primeiro de passar pelo PIN do sistema operativo ou pela autenticação biométrica para aceder à Envoy. No caso improvável de conseguirem isso, o atacante poderia enviar fundos da tua carteira móvel Envoy e ver a quantidade de Bitcoin armazenada em qualquer conta Passport conectada. Estes fundos do Passport não estão em risco porque quaisquer transacções devem ser autorizadas pelo dispositivo Passport emparelhado."),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
            "Quando usado em conjunto com um Passport, a Envoy actua como uma carteira \'apenas de leitura\' ligada à tua carteira física. Isto significa que a Envoy pode elaborar transacções, mas são inúteis sem a autorização devida, a qual só pode ser fornecida pelo Passport. O Passport é um \'armazenamento frio\' enquanto que a Envoy é simplesmente uma interface ligada à Internet! Se usares a Envoy para criar uma carteira móvel, onde as tuas chaves são armazenadas de forma segura no teu telemóvel, essa carteira não pode ser considerada como um armazenamento frio. A segurança do Passport e das contas associadas não é impactada."),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
            "Sim, a Envoy liga-se a nós pessoais através do protocolo de servidor Electrum ou Esplora. Para te ligares ao teu próprio servidor, digitaliza o código QR ou introduz o endereço fornecido nas configurações de rede da Envoy."),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
            "A Envoy foi concebida para oferecer a experiência mais fácil de usar de qualquer carteira Bitcoin, sem comprometer a tua privacidade. Com a Cópia Mágica de Segurança é possível configurar uma carteira móvel Bitcoin auto-custodiada em 60 segundos, sem palavras semente! Os utilizadores do Passport podem ligar os seus dispositivos à Envoy para uma configuração fácil, actualizações de firmware e uma experiência simples de carteira Bitcoin."),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
            "Descarregar e instalar a Envoy não requer nenhuma informação pessoal e a Envoy pode conectar-se à Internet via Tor, um protocolo de preservação da privacidade. Isto significa que a Foundation não tem como saber quem tu és. A Envoy também permite aos utilizadores mais avançados a capacidade de se ligarem ao seu próprio nó Bitcoin para remover completamente qualquer dependência dos servidores da Foundation."),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
            "Sim. A partir da versão 1.4.0, a Envoy suporta a seleção completa de moedas, bem como a \"etiquetagem\" de moedas."),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
            "De momento a Envoy não suporta gastos em lote."),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
            "Sim. A partir da versão 1.4.0, a Envoy permite personalizar na íntegra as taxas de envio e disponibiliza também duas opções de taxa para seleção rápida - \'Padrão\' e \'Rápida\'. A opção \'Padrão\' tem como objetivo finalizar a tua transação em 60 minutos e a opção \'Rápida\' em 10 minutos. Estas taxas são estimativas baseadas no congestionamento da rede no momento em que a transacção é construída e ser-te-á sempre mostrado o custo de ambas as opções antes de finalizares a transação."),
        "envoy_faq_answer_24": MessageLookupByLibrary.simpleMessage(
            "Sim! A partir da versão 1.7.0 podes comprar Bitcoin directamente na Envoy e tê-lo automaticamente depositado na tua conta móvel ou em qualquer conta Passport associada. Basta clicar no botão comprar no menu principal de Contas."),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
            "A Envoy é uma carteira simples de Bitcoin com poderosas funcionalidades de gestão de contas e privacidade, incluindo as Cópias Mágicas de Segurança.Utiliza a Envoy em conjunto com a carteira física Passport para questões relacionadas com configurações, actualizações de firmware e muito mais."),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
            "A Cópia Mágica de Segurança é a forma mais fácil de configurar e efectuar uma cópia de segurança da carteira móvel Bitcoin. A Cópia Mágica de Segurança armazena a semente da tua carteira móvel, encriptada ponta a ponta, no Porta-chaves iCloud ou na Cópia de Segurança do Android. Todos os dados da aplicação são encriptados pela tua semente e armazenados nos Servidores da Foundation. Configura a tua carteira em 60 segundos e recupera-a automaticamente se perderes o teu telemóvel!"),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
            "As Cópias Mágica de Segurança são completamente opcionais para os utilizadores que pretendem utilizar a Envoy apenas como uma carteira móvel. Se preferes gerir as palavras semente da tua carteira móvel e a respectiva cópia de segurança, escolhe \"Configuração Manual das Palavras Semente\" na etapa inicial de configuração da carteira."),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
            "A Cópia de Segurança da Envoy contém definições da aplicação, informações da conta e etiquetas de transacção. O ficheiro é encriptado com as palavras semente da tua carteira móvel. Para os utilizadores da Cópia Mágica de Segurança, a mesma é armazenada totalmente encriptada no servidor da Foundation. Os utilizadores da Envoy que decidam gerir as palavras semente de uma forma manual, podem descarregar e armazenar a sua própria cópia de segurança em qualquer lugar que achem por conveniente. Este local pode ser uma das seguintes combinações - telemóvel, um servidor de nuvem pessoal ou algo físico como um cartão microSD ou uma unidade flash USB."),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
            "Não, as funcionalidades principais da Envoy serão sempre de utilização gratuita. No futuro, poderemos introduzir serviços pagos opcionais ou subscrições."),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
            "Sim, à semelhança de tudo o que fazemos na Foundation, o código da Envoy é completamente aberto. A Envoy está licenciada sob a mesma licença [[GPLv3]] que o Firmware do nosso Passport. Para aqueles que desejam verificar o nosso código-fonte, podem fazê-lo [[aqui]]."),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
            "Não, orgulhamo-nos de garantir de que o Passport é compatível com o maior número possível de carteiras de software diferentes. Vê a nossa lista completa, incluindo tutoriais [[aqui]]."),
        "envoy_faq_link_10": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/firmware-updates/passport/"),
        "envoy_faq_link_8_1": MessageLookupByLibrary.simpleMessage(
            "https://www.gnu.org/licenses/gpl-3.0.en.html"),
        "envoy_faq_link_8_2": MessageLookupByLibrary.simpleMessage(
            "https://github.com/Foundation-Devices/envoy"),
        "envoy_faq_link_9": MessageLookupByLibrary.simpleMessage(
            "https://docs.foundation.xyz/passport/connect/"),
        "envoy_faq_question_1":
            MessageLookupByLibrary.simpleMessage("O que é a Envoy?"),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
            "Tenho de usar a Envoy para fazer actualizações de firmware no Passport?"),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
            "Posso gerir mais do que um Passport na Envoy?"),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
            "Posso gerir várias contas a partir do mesmo Passport?"),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
            "Como é que a Envoy comunica com o Passport?"),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
            "Posso usar a Envoy em paralelo com outro programa como, por exemplo, a Sparrow Wallet?"),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
            "Posso gerir outras carteiras físicas com a Envoy?"),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
            "A Envoy é compatível com a Rede Lightning?"),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
            "O que é que acontece se eu perder o meu telemóvel com a Envoy instalada?"),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
            "A Envoy é considerado um \'Armazenamento Frio\'?"),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
            "Posso ligar a Envoy ao meu nó de Bitcoin?"),
        "envoy_faq_question_2": MessageLookupByLibrary.simpleMessage(
            "Porque é que deverei usar a Envoy?"),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
            "De que forma é que a Envoy protege a minha privacidade?"),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
            "A Envoy oferece controlo de moeda?"),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
            "A Envoy é compatível com gastos em Lote?"),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
            "A Envoy permite a selecção personalizada das taxas de envio?"),
        "envoy_faq_question_24": MessageLookupByLibrary.simpleMessage(
            "Posso comprar Bitcoin na Envoy?"),
        "envoy_faq_question_3": MessageLookupByLibrary.simpleMessage(
            "O que é que a Envoy pode fazer?"),
        "envoy_faq_question_4": MessageLookupByLibrary.simpleMessage(
            "Em que consiste a Cópia Mágica de Segurança da Envoy?"),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
            "Tenho de utilizar as Cópias Mágicas de Segurança da Envoy?"),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
            "O que é a Cópia de Segurança da Envoy?"),
        "envoy_faq_question_7": MessageLookupByLibrary.simpleMessage(
            "Tenho de pagar para utilizar a Envoy?"),
        "envoy_faq_question_8": MessageLookupByLibrary.simpleMessage(
            "A Envoy é uma aplicação de Código Aberto?"),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
            "Tenho de usar a Envoy para fazer transacções com o Passport?"),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
            "A Envoy não foi capaz de copiar o firmware para o cartão microSD."),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Verifica se o cartão microSD está inserido correctamente no teu telemível e tenta novamente.\nEm alternativa o firmware pode ser descarregado através da nossa página do [[GitHub]]."),
        "envoy_fw_intro_cta":
            MessageLookupByLibrary.simpleMessage("Descarregar Firmware"),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
            "De seguida, vamos actualizar o firmware do Passport"),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "O Envoy permite-te actualizar o teu Passport a partir do teu telemóvel utilizando o adaptador microSD incluído.\n\nOs utilizadores avançados podem [[tocar aqui]] para descarregar e verificar o seu próprio firmware num computador."),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
                "Permitir que Envoy aceda ao cartão microSD"),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Permite que a Envoy copie dos ficheiros do cartão microSD. Toca em Procurar, depois em PASSPORT-SD e Abrir."),
        "envoy_fw_microsd_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Descarregar do Github"),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
            "Desculpa, não foi possível fazer a actualização de firmware."),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
            "Introduz o cartão microSD no teu Telemóvel"),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
            "Insere o adaptador microSD fornecido no teu telemóvel e, de seguida, insere o cartão microSD no adaptador."),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
            "Remove o cartão microSD e insere-o no teu Passport"),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Insere o cartão microSD no Passport e vai a Definições -> Firmware -> Actualizar Firmware.\n\nGarante que o Passport tem bateria suficiente antes de iniciar esta operação."),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
            "Insere o cartão microSD no Passport e segue as instruções.\n\nGarante que o Passport tem bateria suficiente antes de iniciar esta operação."),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
            "A Envoy está a copiar o firmware para o\ncartão microSD"),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
            "Isto poderá demorar alguns segundos. Por favor não removas o cartão microSD."),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
            "O firmware foi copiado com sucesso para o\ncartão microSD"),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
            "Certifica-te que carregas no botão Ejectar Cartão SD no Gestor de Ficheiros antes de removeres o cartão microSD do teu telemóvel."),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
            "O firmware mais recente foi copiado para o cartão microSD e está pronto para ser instalado no Passport."),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Introduz um código PIN de 6-12 dígitos no teu Passport"),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "O Passport irá sempre pedir o PIN quando for iniciado. Recomendamos a utilização de um PIN único e anotá-lo num local seguro.\n\nSe se esquecer do PIN, não há forma de recuperar o Passport e o dispositivo ficará permanentemente desativado."),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Agora, cria uma cópia de segurança encriptada da tua semente"),
        "envoy_pp_new_seed_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "O Passport vai fazer uma cópia de segurança da tua semente e definições do dispositivo para um cartão microSD encriptado."),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
            "No Passport seleccionar\nCriar Nova Semente"),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "A Avalanche Noise Source do Passport, um verdadeiro gerador de números aleatórios de código aberto, ajuda a criar uma semente forte."),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "Parabéns, a tua nova semente foi criada"),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "De seguida, vamos ligar a Envoy ao Passport."),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
            "No Passport, selecciona\nRestaurar Cópia de Segurança"),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage(
                "Desencriptar a tua Cópia de Segurança"),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para desencriptar a cópia de segurança, introduz o código de 20 dígitos que foi apresentado aquando a criação da cópia de segurança.\n\nSe perdeste ou esqueceste-te do código podes, em alternativa, restaurar através das palavras semente."),
        "envoy_pp_restore_backup_subheading": MessageLookupByLibrary.simpleMessage(
            "Utiliza esta funcionalidade para restaurares o Passport através de um cartão microSD encriptado proveniente de outro Passport.\n\nVais precisar da senha para desencriptares a cópia de segurança."),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "A tua Cópia de Segurança foi restaurada com sucesso"),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
            "No Passport, selecciona\nRestaurar Semente"),
        "envoy_pp_restore_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Utiliza esta funcionalidade para restaurar sementes existentes de 12 ou 24 palavras."),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "A tua semente foi restaurada com sucesso"),
        "envoy_pp_setup_intro_cta1":
            MessageLookupByLibrary.simpleMessage("Criar Nova Semente"),
        "envoy_pp_setup_intro_cta2":
            MessageLookupByLibrary.simpleMessage("Restaurar Semente"),
        "envoy_pp_setup_intro_cta3": MessageLookupByLibrary.simpleMessage(
            "Restaurar Cópia de Segurança"),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
            "De que forma gostarias de configurar o teu Passport?"),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Como novo proprietário de um Passport, podes criar uma nova semente, restaurar uma carteira utilizando palavras semente ou restaurar uma cópia de segurança de um Passport existente."),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
            "Primeiro, vamos garantir que o teu Passport é seguro"),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
            "Este teste de segurança irá garantir que o teu Passport não foi adulterado durante o envio."),
        "envoy_scv_result_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Entrar em Contacto"),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
            "O teu Passport pode ser inseguro"),
        "envoy_scv_result_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "A Envoy não conseguiu validar a segurança do teu Passport. Por favor contacta-nos para assistência."),
        "envoy_scv_result_ok_heading":
            MessageLookupByLibrary.simpleMessage("O Teu Passport é seguro"),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
            "De seguida, cria um PIN para proteger o teu Passport"),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
            "De seguida, digitaliza o código QR no ecrã do teu Passport"),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Este código QR termina o processo de validação e partilha alguma informação do Passport com a Envoy."),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
            "No teu Passport, seleciona Aplicação Envoy e digitaliza este Código QR"),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
            "Este código QR fornece informação para validação e configuração."),
        "envoy_support_community":
            MessageLookupByLibrary.simpleMessage("COMUNIDADE"),
        "envoy_support_documentation":
            MessageLookupByLibrary.simpleMessage("Documentação"),
        "envoy_support_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
            "Permitir Cópia Mágica de Segurança"),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Configuração Manual das Palavras Semente"),
        "envoy_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Criar Nova Carteira"),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Para uma configuração sem problemas, recomendamos que seja activada a opção [[Cópia Mágica de Segurança]].\n\nUtilizadores experientes podem criar manualmente ou restaurar a semente da carteira."),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage(
                "Voltar para as minhas Contas"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage("Eliminar Contas mesmo assim"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Antes de eliminares a tua Carteira Envoy por favor esvazia as tuas Contas.\nQuando terminares vai a Cópias de Segurança > Apagar Carteiras e Cópias de Segurança."),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "Este ficheiro encriptado contém dados úteis da carteira, tais como etiquetas, contas e definições.\n\nEste ficheiro é encriptado com a tua Semente da Envoy. Certifica-te que a cópia de segurança da tua semente está armazenada num local seguro."),
        "export_backup_send_CTA1": MessageLookupByLibrary.simpleMessage(
            "Descarregar Cópia de Segurança"),
        "export_backup_send_CTA2":
            MessageLookupByLibrary.simpleMessage("Descartar"),
        "export_seed_modal_12_words_CTA2":
            MessageLookupByLibrary.simpleMessage("Ver como Código QR"),
        "export_seed_modal_QR_code_CTA2":
            MessageLookupByLibrary.simpleMessage("Ver Semente"),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para utilizar este código QR na Envoy de um novo telemóvel, vai a Configurar a Carteira Envoy > Recuperar Cópia Mágica de Segurança > Recuperar através de Código QR"),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
                "This seed is protected by a passphrase. You need these seed words and the passphrase to recover your funds."),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "O ecrã seguinte irá apresentar informações altamente sensíveis.\n\nQualquer pessoa com acesso a estes dados pode roubar o teu Bitcoin. Procede com extrema cautela."),
        "filter_sortBy_aToZ": MessageLookupByLibrary.simpleMessage("De A a Z"),
        "filter_sortBy_highest":
            MessageLookupByLibrary.simpleMessage("Valor mais elevado"),
        "filter_sortBy_lowest":
            MessageLookupByLibrary.simpleMessage("Valor mais baixo"),
        "filter_sortBy_newest":
            MessageLookupByLibrary.simpleMessage("Mais recentes primeiro"),
        "filter_sortBy_oldest":
            MessageLookupByLibrary.simpleMessage("Mais antigos primeiro"),
        "filter_sortBy_zToA": MessageLookupByLibrary.simpleMessage("De Z a A"),
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
        "firmware_downloadingUpdate_timeRemaining": m4,
        "firmware_downloadingUpdate_transferring":
            MessageLookupByLibrary.simpleMessage(
                "Transferring to Passport Prime"),
        "firmware_updateAvailable_content2": m5,
        "firmware_updateAvailable_estimatedUpdateTime": m6,
        "firmware_updateAvailable_header":
            MessageLookupByLibrary.simpleMessage("Update Available"),
        "firmware_updateAvailable_whatsNew": m7,
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
        "firmware_updateModalConnectionLost_exit":
            MessageLookupByLibrary.simpleMessage("Exit Onboarding"),
        "firmware_updateModalConnectionLost_header":
            MessageLookupByLibrary.simpleMessage("Connection Lost"),
        "firmware_updateModalConnectionLost_reconnecting":
            MessageLookupByLibrary.simpleMessage("Reconnecting…"),
        "firmware_updateModalConnectionLost_tryToReconnect":
            MessageLookupByLibrary.simpleMessage("Try to Reconnect"),
        "firmware_updateSuccess_content1": m8,
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
            MessageLookupByLibrary.simpleMessage("COMPRAR BITCOIN"),
        "header_chooseAccount":
            MessageLookupByLibrary.simpleMessage("ESCOLHE UMA CONTA"),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Desliza para mostrar e esconder o teu saldo."),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Toca no cartão representado para receberes Bitcoin."),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
                "Toca em qualquer um dos cartões representados para receber Bitcoin."),
        "launch_screen_faceID_fail_CTA":
            MessageLookupByLibrary.simpleMessage("Tentar Novamente"),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage("Falha na Autenticação"),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage("Por favor tenta novamente"),
        "launch_screen_lockedout_heading":
            MessageLookupByLibrary.simpleMessage("Bloqueado"),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Autenticação Biométrica desactivada. Por favor fecha a Envoy, espera 30 segundos e tenta novamente."),
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
                "Os filtros aplicados estão a esconder todos os resultados da pesquisa.\nActualiza ou repõe os filtros para ver mais resultados."),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("Tudo"),
        "learning_center_results_title":
            MessageLookupByLibrary.simpleMessage("Resultados"),
        "learning_center_search_input":
            MessageLookupByLibrary.simpleMessage("Pesquisar..."),
        "learning_center_title_blog":
            MessageLookupByLibrary.simpleMessage("Blogue"),
        "learning_center_title_faq":
            MessageLookupByLibrary.simpleMessage("Perguntas Frequentes"),
        "learning_center_title_video":
            MessageLookupByLibrary.simpleMessage("Vídeos"),
        "learningcenter_status_read":
            MessageLookupByLibrary.simpleMessage("Ler"),
        "learningcenter_status_watched":
            MessageLookupByLibrary.simpleMessage("Visualizado"),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "A Encriptar a tua Cópia de Segurança"),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy está a encriptar a cópia de segurança da tua carteira.\n\nEsta cópia de segurança contém dados utéis da carteira, tais como etiquetas, notas, contas e definições."),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy está a criar uma semente segura da carteira Bitcoin, que será armazenada e encriptada ponta a ponta na Cópia de Segurança do Android."),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage("A Criar a Tua Semente Envoy"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy está a criar uma semente segura da carteira Bitcoin, que será armazenada e encriptada ponta a ponta no Porta-chaves iCloud."),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage(
                "Recuperar através de Código QR"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não foi capaz de encontrar uma Cópia Mágica de Segurança. \n\nPor favor confirma que iniciaste sessão com a conta Google correcta e que restauraste a tua cópia de segurança mais recente do teu dispositivo."),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Cópia Mágica de Segurança Não Encontrada"),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não foi capaz de localizar a Cópia Mágica de Segurança no servidor da Foundation.\n\nPor favor verifica que estás a recuperar a carteira previamente utilizada na Cópia Mágica de Segurança."),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Erro de Ligação"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não consegue ligar-se ao servidor da Foundation para recolher a tua Cópia Mágica de Segurança.\n\nPodes tentar novamente, importar a tua própria Cópia de Segurança da Envoy ou continuar sem uma."),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage("Recuperação Sem Sucesso"),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não foi capaz de encontrar uma Cópia Mágica de Segurança.\n\nPor favor confirma que iniciaste sessão com a conta Apple correcta e que restauraste a tua cópia de segurança do iCloud mais recente."),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
                "A recuperar a tua carteira Envoy"),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage(
                "A Enviar a tua Cópia de Segurança"),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy está a enviar a tua cópia de segurança encriptada para os servidores da Foundation.\n\nUma vez que a tua cópia de segurança é encriptada ponta a ponta, a Foundation não tem acesso à mesma nem ao seu conteúdo."),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A forma mais fácil de criar uma carteira Bitcoin mantendo a tua soberania.\n\nA Cópia Mágica de Segurança faz automaticamente uma cópia de segurança da tua carteira e definições utilizando a Cópia de Segurança do Android, 100 % encriptado ponta a ponta.\n\n[[Mais informação]]. "),
        "magic_setup_tutorial_heading":
            MessageLookupByLibrary.simpleMessage("Cópia Mágica de Segurança"),
        "magic_setup_tutorial_ios_CTA1": MessageLookupByLibrary.simpleMessage(
            "Criar Cópia Mágica de Segurança"),
        "magic_setup_tutorial_ios_CTA2": MessageLookupByLibrary.simpleMessage(
            "Recuperar Cópia Mágica de Segurança"),
        "magic_setup_tutorial_ios_subheading": MessageLookupByLibrary.simpleMessage(
            "A forma mais fácil de criar uma carteira Bitcoin mantendo a tua soberania.\n\nA Cópia Mágica de Segurança faz automaticamente uma cópia de segurança da tua carteira e definições utilizando o Porta-chaves iCloud, 100 % encriptado ponta a ponta.\n\n[[Mais informação]]."),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para efeitos de privacidade, criamos um novo endereço cada vez que visitas este menu."),
        "manage_account_address_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DA CONTA"),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Certifica-te de que não partilhas este descritor, a menos que te sintas confortável com o facto de as tuas transacções ficarem públicas."),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage("EDITAR NOME DA CONTA"),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage("MOSTRAR DESCRITOR"),
        "manage_account_remove_heading":
            MessageLookupByLibrary.simpleMessage("Tens a certeza?"),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta acção apenas remove a conta do Envoy."),
        "manage_account_rename_heading":
            MessageLookupByLibrary.simpleMessage("Altera o Nome da Conta"),
        "manage_device_deletePassportWarning": MessageLookupByLibrary.simpleMessage(
            "Tens a certeza que queres eliminar o Passport?\nEsta operação vai remover o dispositivo da Envoy bem como qualquer conta associada."),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage("Emparelhado"),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage("Número de Série"),
        "manage_device_details_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DO DISPOSITIVO"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage("EDITAR NOME DO DISPOSITIVO"),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage("Altera o nome do Passport"),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível fazer a cópia de segurança. Por favor tenta novamente mais tarde."),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
                "Isto anulará quaisquer alterações na seleção de moedas. Desejas continuar?"),
        "manual_setup_change_from_magic_header":
            MessageLookupByLibrary.simpleMessage("Magic Backups deactivated"),
        "manual_setup_change_from_magic_modal_subheader":
            MessageLookupByLibrary.simpleMessage(
                "Your Magic backup is about to be permanently erased. Ensure your seed is securely backed up and that you download your Envoy backup file.\n\nThis action will permanently delete your Envoy seed from your Apple or Google account, and your encrypted Envoy data from Foundation Servers."),
        "manual_setup_change_from_magic_subheaderApple":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy Magic Backup data was successfully deleted from your Apple account and Foundation servers."),
        "manual_setup_change_from_magic_subheaderGoogle":
            MessageLookupByLibrary.simpleMessage(
                "Your Envoy Magic Backup data was successfully deleted from your Google account and Foundation servers."),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Escolher Destino"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage(
                "Guardar Cópia de Segurança da Envoy"),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("Compreendi"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A tua Cópia de Segurança da Envoy é encriptada com as tuas palavras semente.\n\nSe perdes o acesso às mesmas, não será possível recuperar a tua cópia de segurança."),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy gerou uma cópia de segurança encriptada da tua carteira. Esta cópia de segurança contém dados úteis da carteira, tais como etiquetas, notas, contas e definições.\n\nPodes escolher armazená-la na nuvem, num outro dispositivo ou numa opção de armazenamento externo como, por exemplo, um cartão microSD."),
        "manual_setup_generate_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Gerar Semente"),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Mantém a Tua Semente Privada"),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Lembra-te de manter sempre privadas as tuas palavras semente. Qualquer pessoa com acesso a esta semente pode gastar as tuas Bitcoin!"),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage(
                "Escolhe uma palavra para continuar"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Vamos Verificar a Tua Semente"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage("Verifica a Tua Semente"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Entrada Inválida"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não foi capaz de verificar a tua semente. Por favor confirma que introduziste correctamente a tua semente e tenta novamente."),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage(
                "Qual é a tua palavra semente número"),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correcto"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy irá fazer algumas questões para verificar que registaste correctamente a tua semente."),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Escreve estas 24 Palavras"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Escreve estas 12 Palavras"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("A Gerar A Semente"),
        "manual_setup_import_backup_CTA1": MessageLookupByLibrary.simpleMessage(
            "Criar Cópia de Segurança da Envoy"),
        "manual_setup_import_backup_CTA2": MessageLookupByLibrary.simpleMessage(
            "Importar Cópia Mágica de Segurança"),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível ler a Cópia de Segurança da Envoy"),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Certifica-te que seleccionaste o ficheiro correcto."),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Gostarias de restaurar uma Cópia de Segurança da Envoy existente?\n\nEm caso negativo, a Envoy vai criar uma nova Cópia de Segurança encriptada."),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Essa semente parece ser inválida. Por favor verifica as palavras introduzidas, incluíndo a ordem em que se encontram e tenta novamente."),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Introduz a Tua Semente"),
        "manual_setup_import_seed_CTA1": MessageLookupByLibrary.simpleMessage(
            "Importar através de código QR"),
        "manual_setup_import_seed_CTA2":
            MessageLookupByLibrary.simpleMessage("Semente de 24 Palavras"),
        "manual_setup_import_seed_CTA3":
            MessageLookupByLibrary.simpleMessage("Semente de 12 Palavras"),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage("My seed has a passphrase"),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage("Importar a Tua Semente"),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
                "Nunca importes a tua semente do Passport nos menus seguintes."),
        "manual_setup_import_seed_subheading": MessageLookupByLibrary.simpleMessage(
            "Escolhe uma das seguintes opções para importar uma semente existente.\n\nIrá ser possível importar uma Cópia de Segurança da Envoy mais tarde."),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("A importar a Semente"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage(
                "Cópia Mágica de Segurança Detectada"),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignorar"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Uma Cópia Mágica de Segurança foi encontrada no servidor.\nRestaurar a tua Cópia de Segurança?"),
        "manual_setup_recovery_fail_cta2":
            MessageLookupByLibrary.simpleMessage("Importar Palavras Semente"),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível digitalizar o Código QR"),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Tenta digitalizar novamente ou, em alternativa, importa manualmente as tuas palavras semente."),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Se continuares sem uma cópia de segurança, as definições da tua carteira, contas adicionais, etiquetas e notas não serão restauradas."),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Re-type Passphrase"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage(
                "Escolher outra Cópia de Segurança"),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não foi capaz de abrir a Cópia de Segurança da Envoy"),
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
            MessageLookupByLibrary.simpleMessage("A importar a tua Semente"),
        "manual_setup_tutorial_CTA1":
            MessageLookupByLibrary.simpleMessage("Gerar Nova Semente"),
        "manual_setup_tutorial_CTA2":
            MessageLookupByLibrary.simpleMessage("Importar Semente"),
        "manual_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
            "Configuração Manual da Semente"),
        "manual_setup_tutorial_subheading": MessageLookupByLibrary.simpleMessage(
            "Se preferes fazer a gestão das tuas próprias palavras semente, continua abaixo para importares ou criares uma nova semente.\n\nTem em atenção que és o único responsável pela gestão das cópias de segurança. Não serão utilizados serviços na nuvem."),
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
                "Desactivada para Configuração Manual da Semente"),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage(
                "Descarregar Cópia de Segurança da Envoy"),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Ver Semente da Envoy"),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
                "Armazenada na Cópia de Segurança do Android"),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Cópia de Segurança da Envoy"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Semente da Envoy"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Executar"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage(
                "Armazenado no Porta-chaves iCloud"),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage(
                "para os Servidores da Foundation"),
        "manual_toggle_on_seed_backingup":
            MessageLookupByLibrary.simpleMessage("Backing up…"),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage("Cópia de Segurança em Curso"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
                "A Cópia de Segurança da Envoy foi concluída."),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage(
                "A Enviar a Cópia de Segurança da Envoy"),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta cópia de segurança contém dispositivos e contas ligados, etiquetas e definições da aplicação. Não contém informações relativas à chave privada.\n\nAs Cópias de Segurança da Envoy são encriptados ponta a ponta e a Foundation não tem acesso ou conhecimento do seu conteúdo. \n\nA Envoy notificar-te-á quando o envio estiver concluído."),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Definições"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Cópia de Segurança do Android pendente (uma vez por dia)"),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
                "Cópia de Segurança para o Porta-chaves iCloud pendente"),
        "manual_toggle_on_seed_uploading_foundation_servers":
            MessageLookupByLibrary.simpleMessage(
                "Uploading to Foundation Servers"),
        "menu_about": MessageLookupByLibrary.simpleMessage("SOBRE"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("CÓPIAS DE SEGURANÇA"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_privacy": MessageLookupByLibrary.simpleMessage("Privacy"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("DEFINIÇÕES"),
        "menu_support": MessageLookupByLibrary.simpleMessage("APOIO TÉCNICO"),
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
                "Also known as a “hot wallet.” Spending from this wallet requires only your phone for authorization."),
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
        "onboarding_migrating_xOfYSynced": m9,
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
            MessageLookupByLibrary.simpleMessage("Ligar o Passport\nà Envoy"),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
                "No Passport, seleciona Gerir Conta > Ligar Carteira > Envoy."),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
            "Digitaliza este Código QR com o Passport para validar"),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este endereço Bitcoin pertence ao teu Passport."),
        "pair_new_device_address_cta2":
            MessageLookupByLibrary.simpleMessage("Contactar Apoio Técnico"),
        "pair_new_device_address_heading":
            MessageLookupByLibrary.simpleMessage("Endereço validado?"),
        "pair_new_device_address_subheading": MessageLookupByLibrary.simpleMessage(
            "Se recebeste uma mensagem de sucesso no Passport, a configuração está concluída.\n\nSe o Passport não conseguiu validar o endereço, por favor tenta novamente ou entra em contacto com o apoio técnico."),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Este passo permite à Envoy gerar endereços de recepção para o Passport e propor transacções para envio que o Passport tem de autorizar."),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
            "Digitaliza o código QR que o Passport gerou"),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
            "O código QR contém a informação necessária para a Envoy interagir de forma segura com o Passport."),
        "pair_new_device_success_cta1": MessageLookupByLibrary.simpleMessage(
            "Validar endereço de recepção"),
        "pair_new_device_success_cta2": MessageLookupByLibrary.simpleMessage(
            "Continuar para o ecrã principal"),
        "pair_new_device_success_heading":
            MessageLookupByLibrary.simpleMessage("Ligação bem sucedida"),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy está ligada ao teu Passport."),
        "passport_welcome_screen_cta1":
            MessageLookupByLibrary.simpleMessage("Configurar um novo Passport"),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
            "Ligar a um Passport existente"),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
            "Não tenho um Passport. [[Mais informação.]]"),
        "passport_welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Bem-Vindo ao Passport"),
        "passport_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "A Envoy oferece uma configuração segura do Passport, actualizações fáceis de firmware e uma experiência de carteira Bitcoin serena."),
        "privacySetting_nodeConnected":
            MessageLookupByLibrary.simpleMessage("Nó Ligado"),
        "privacy_applicationLock_title":
            MessageLookupByLibrary.simpleMessage("Bloqueio da aplicação"),
        "privacy_applicationLock_unlock":
            MessageLookupByLibrary.simpleMessage("Utilizar biometria ou PIN"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
            "Aumenta a tua privacidade ao correres o teu próprio nó. Toca em mais informações no canto superior direito para saber mais."),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage("Altura do bloco:"),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage("Ligado ao servidor Esplora"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível ligar ao servidor Esplora."),
        "privacy_node_connectedTo":
            MessageLookupByLibrary.simpleMessage("Ligado a"),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível estabelecer uma ligação ao nó."),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
                "Mesmo com a opção \"Privacidade Melhorada\" activada, o Envoy não pode impedir a interferência de dispositivos comprometidos na tua rede local."),
        "privacy_node_nodeAddress": MessageLookupByLibrary.simpleMessage(
            "Introduz o endereço do teu nó"),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage("Foundation (Predefinido)"),
        "privacy_node_nodeType_personal":
            MessageLookupByLibrary.simpleMessage("Nó Pessoal"),
        "privacy_node_nodeType_publicServers":
            MessageLookupByLibrary.simpleMessage("Servidores públicos"),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Nó"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Desempenho\nMelhorado"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage("Privacidade\nMelhorada"),
        "privacy_privacyMode_title":
            MessageLookupByLibrary.simpleMessage("Modo de Privacidade"),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
                "A ligação da Envoy vai ser estável com o Tor [[DESLIGADO]]. Recomendado para novos utilizadores."),
        "privacy_privacyMode_torSuggestionOn": MessageLookupByLibrary.simpleMessage(
            "O Tor será [[LIGADO]] para melhorar a privacidade. A ligação da Envoy poderá ficar instável."),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Adicionar Nó"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Editar Nó"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O teu Nó está ligado via Clearnet."),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
                "Não conseguimos ligar ao teu nó"),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Ligar"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("A ligar ao Teu Nó"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
                "O teu Nó está ligado via Tor."),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage("Escolhe a Tua Privacidade"),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
                "De que forma é que gostarias que a Envoy se ligasse à Internet?"),
        "qrTooBig_warning_subheading": MessageLookupByLibrary.simpleMessage(
            "O código QR digitalizado contém uma grande quantidade de dados e pode tornar o Envoy instável. Tens a certeza que desejas continuar?"),
        "ramp_note": MessageLookupByLibrary.simpleMessage("Compra da Ramp"),
        "ramp_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Compra da Ramp Pendente"),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage("Utilizar Endereço Taproot"),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("RECEBER"),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("A aguardar confirmação"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Receber"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Inicia sessão no Google e restaura os dados da tua cópia de segurança"),
        "recovery_scenario_heading":
            MessageLookupByLibrary.simpleMessage("Como Recuperar?"),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
            "Instala a Envoy e carrega em \"Configurar a Carteira Envoy\""),
        "recovery_scenario_ios_instruction1":
            MessageLookupByLibrary.simpleMessage(
                "Inicia sessão no iCloud e restaura a tua cópia de segurança"),
        "recovery_scenario_ios_instruction3": MessageLookupByLibrary.simpleMessage(
            "A Envoy irá restaurar automaticamente a tua Cópia Mágica de Segurança"),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
            "Para recuperar a tua carteira Envoy, segue estas simples instruções."),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
                "A taxa escolhida só pode ser atingida adicionando mais moedas. A Envoy faz esse processo de forma automática e nunca irá incluir moedas bloqueadas."),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage("A reforçar transacção"),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
            "Não foi possível reforçar a tua transacção"),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage("Rever Selecção de Moedas"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
                "A tua transacção foi reforçada"),
        "replaceByFee_boost_tx_boostFee":
            MessageLookupByLibrary.simpleMessage("Taxa de Reforço"),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
            "A tua transacção está pronta\npara ser reforçada"),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage("Nenhuma"),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A taxa de rede para cancelar esta transação significa que não serão devolvidos fundos à tua carteira.\n\nTens a certeza que pretendes cancelar?"),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage("A cancelar a transacção"),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível cancelar a tua transacção"),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Taxa de Cancelamento"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage("Proceder com o Cancelamento"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Quantia a Receber"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Substitui a transação não confirmada por outra que contenha uma taxa mais elevada e envia os fundos de volta para a tua carteira."),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "A tua transacção foi cancelada"),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Esta é uma tentativa de cancelamento. Há uma pequena possibilidade de a transacção original ser confirmada antes desta tentativa de cancelamento ocorrer."),
        "replaceByFee_coindetails_overlayNotice":
            MessageLookupByLibrary.simpleMessage(
                "Boost and Cancel functions will be available after transaction has finished being broadcast."),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Reforçar"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Reforçar Transacção"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aumenta a taxa associada à tua transacção para acelerares o tempo de confirmação."),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Necessário para Reforçar"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transacções Removidas"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Compras incompletas com as seguintes identificações Ramp foram removidas da atividade após 5 dias."),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage("Nova Taxa de Transacção"),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para reforçar a transacção original, estás prestes a pagar uma nova taxa de:"),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
                "Esta operação vai substituir a taxa original de:"),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
                "Compras incompletas serão automaticamente removidas após 5 dias"),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A taxa escolhida só pode ser atingida adicionando mais moedas. A Envoy faz essa operação automaticamente e nunca irá incluir moedas bloqueadas. \n\nEsta seleção pode ser revista ou editada no ecrã seguinte."),
        "scv_checkingDeviceSecurity": MessageLookupByLibrary.simpleMessage(
            "A Verificar Segurança do Dispositivo"),
        "send_keyboard_address_confirm":
            MessageLookupByLibrary.simpleMessage("Confirmar"),
        "send_keyboard_address_loading":
            MessageLookupByLibrary.simpleMessage("A carregar..."),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage("Introduz um endereço válido"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Fundos insuficientes"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage("Quantia demasiado baixa"),
        "send_keyboard_send_max":
            MessageLookupByLibrary.simpleMessage("Enviar o Máximo"),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("Para:"),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
            "Digitaliza o Código QR com o teu Passport"),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
            "Contém a transação para o teu Passport assinar."),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
            "Podes digitalizar o código QR apresentado no Passport com a câmara do teu telemóvel."),
        "send_reviewScreen_sendMaxWarning": MessageLookupByLibrary.simpleMessage(
            "A enviar o Máximo:\nAs taxas são deduzidas da quantia a enviar."),
        "settings_advanced": MessageLookupByLibrary.simpleMessage("Avançado"),
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
            MessageLookupByLibrary.simpleMessage("Compra na Envoy"),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Aprende mais sobre a Signet [[aqui]]."),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A activação do Signet adiciona uma versão Signet à tua Carteira Envoy. Esta funcionalidade é usada principalmente por programadores ou para testes e não tem valor."),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Aprende a fazer isso [[aqui]]."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A activação do Testnet adiciona uma versão Testnet3 à tua Carteira Envoy, permitindo que estabeleças ligações com contas Testnet a partir do teu Passport."),
        "settings_advanced_receiveToTaproot":
            MessageLookupByLibrary.simpleMessage("Receive to Taproot"),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot":
            MessageLookupByLibrary.simpleMessage("Taproot"),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activar"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O Taproot é uma funcionalidade avançada e o suporte para carteiras ainda é limitado.\n\nAvança com cuidado."),
        "settings_advanced_testnet":
            MessageLookupByLibrary.simpleMessage("Testnet"),
        "settings_amount":
            MessageLookupByLibrary.simpleMessage("Ver Quantia em Sats"),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Moeda"),
        "settings_show_fiat":
            MessageLookupByLibrary.simpleMessage("Exibir Valores Fiat"),
        "settings_viewEnvoyLogs": MessageLookupByLibrary.simpleMessage(
            "Ver Registo de Actividade da Envoy"),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Não, obrigado"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "As notas da transacção podem ser úteis em gastos futuros."),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não foi possível enviar a tua transacção"),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Por favor verifica a tua ligação e tenta novamente"),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
                "A tua transacção foi enviada com sucesso"),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Revê os detalhes tocando na transacção a partir do menu de detalhes da conta."),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("A enviar a transacção"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Isto pode demorar uns segundos"),
        "tagDetails_EditTagName":
            MessageLookupByLibrary.simpleMessage("Editar Nome da Etiqueta"),
        "tagSelection_example1": MessageLookupByLibrary.simpleMessage("Gastos"),
        "tagSelection_example2":
            MessageLookupByLibrary.simpleMessage("Pessoal"),
        "tagSelection_example3":
            MessageLookupByLibrary.simpleMessage("Poupança"),
        "tagSelection_example4":
            MessageLookupByLibrary.simpleMessage("Doações"),
        "tagSelection_example5":
            MessageLookupByLibrary.simpleMessage("Viagens"),
        "tagged_coin_details_inputs_fails_cta2":
            MessageLookupByLibrary.simpleMessage("Anular Alterações"),
        "tagged_coin_details_menu_cta1":
            MessageLookupByLibrary.simpleMessage("EDITAR NOME DA ETIQUETA"),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
                "Não existem moedas associadas a esta etiqueta."),
        "tagged_tagDetails_sheet_cta1":
            MessageLookupByLibrary.simpleMessage("Enviar Selecção"),
        "tagged_tagDetails_sheet_cta2":
            MessageLookupByLibrary.simpleMessage("Etiquetar Selecção"),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage("Reetiquetar Selecção"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
            "Mantêm pressionado para arrastar e reordenar as tuas contas."),
        "taproot_passport_dialog_heading":
            MessageLookupByLibrary.simpleMessage("Taproot no Passport"),
        "taproot_passport_dialog_later":
            MessageLookupByLibrary.simpleMessage("Fazer Mais Tarde"),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage("Voltar a ligar o Passport"),
        "taproot_passport_dialog_subheading": MessageLookupByLibrary.simpleMessage(
            "Para activar uma conta Taproot no Passport, verifica por favor se estás a correr o firmware 2.3.0 ou posterior e volta a ligar o teu Passport."),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
            "Servidores da Foundation indisponíveis"),
        "toast_newEnvoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
            "Disponível nova actualização para a Envoy"),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage(
                "Tentar Novamente Ligação Tor"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage(
                "Desactivar Temporariamente o Tor"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
            "Podes experienciar um desempenho degradado da aplicação até que a Envoy consiga restabelecer a ligação à rede Tor.\n\nAo desactivares o Tor irás estabelecer uma ligação directa ao servidor da Envoy, mas com [[contrapartidas]] na vertente de privacidade."),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
            "Erro ao estabelecer ligação à rede Tor"),
        "video_connectingToTorNetwork":
            MessageLookupByLibrary.simpleMessage("A ligar à Rede Tor"),
        "video_loadingTorText": MessageLookupByLibrary.simpleMessage(
            "A Envoy está a carregar o teu vídeo através da Rede Tor"),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy faz a cópia de segurança da semente da tua carteira de uma forma segura e automática através da [[Cópia de Segurança do Android]].\n\nA tua semente está sempre encriptada ponta a ponta e nunca é tornada visível para o Google."),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy faz a cópia de segurança da semente da tua carteira de uma forma segura e automática para o [[Porta-chaves iCloud.]]\n\nA tua semente está sempre encriptada ponta a ponta e nunca é tornada visível para a Apple."),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "É automaticamente feita uma cópia de segurança dos dados da tua carteira - incluindo etiquetas, notas, contas e definições - para os servidores da Foundation.\n\nAntes do envio a cópia de segurança é encriptada com a semente da tua carteira, garantindo que a Foundation nunca terá acesso aos teus dados."),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para recuperar a tua carteira, basta iniciar sessão na tua conta do Google. A Envoy irá descarregar automaticamente a semente da tua carteira e os dados da cópia de segurança.\n\nRecomendamos que protejas a tua conta Google com uma senha forte e autenticação de dois factores (2FA)."),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Para recuperar a tua carteira, basta iniciar sessão na tua conta iCloud. A Envoy irá descarregar automaticamente a semente da tua carteira e os dados da cópia de segurança.\n\nRecomendamos que protejas a tua conta iCloud com uma senha forte e autenticação de dois factores (2FA)."),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage(
                "Como são Protegidos os Teus Dados Pessoais"),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Se preferires optar por não utilizar as Cópias Mágicas de Segurança e, em alternativa, proteger manualmente as sementes e os dados da tua carteira, não há problema!\n\nBasta voltar ao menu de configuração e escolher Configuração Manual das Palavras Semente."),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Como é Que a Tua Carteira é Protegida"),
        "wallet_security_modal__heading":
            MessageLookupByLibrary.simpleMessage("Dica de Segurança"),
        "wallet_security_modal_subheading": MessageLookupByLibrary.simpleMessage(
            "A Envoy está a armazenar mais do que a quantidade recomendada de Bitcoin para uma carteira móvel, ligada à internet.\n\nPara uma solução ultra-segura, de armazenamento offline, a Foundation recomenda a carteira física Passport."),
        "wallet_setup_success_heading":
            MessageLookupByLibrary.simpleMessage("A Tua Carteira Está Pronta"),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
            "A Envoy está configurada e pronta para a tua Bitcoin!"),
        "welcome_screen_ctA1":
            MessageLookupByLibrary.simpleMessage("Configurar a Carteira Envoy"),
        "welcome_screen_cta2":
            MessageLookupByLibrary.simpleMessage("Gerir o Passport"),
        "welcome_screen_heading":
            MessageLookupByLibrary.simpleMessage("Bem-vindo ao Envoy")
      };
}
