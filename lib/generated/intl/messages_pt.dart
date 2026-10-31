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

  static String m0(MB_name) =>
      "Cópia Mágica de Segurança do Passport Prime\n”${MB_name}”";

  static String m1(period) =>
      "Este vale expirou a ${period}.\n\n\nPor favor entra em contacto com o emissor para quaisquer questões relacionadas com o vale.";

  static String m2(AccountName) =>
      "Acede a ${AccountName} no Passport, escolhe ‘Account Tools’ > ‘Verify Address’ e digitaliza o código QR abaixo.";

  static String m3(number) => "A taxa é ${number}% do total";

  static String m4(tagName) =>
      "A tua etiqueta ${tagName} está vazia. Pretendes eliminá-la?";

  static String m5(number) => "ENDEREÇO #${number}";

  static String m6(searchSpace) =>
      "Endereço não encontrado nos primeiros ${searchSpace} endereços.";

  static String m7(time_remaining) => "${time_remaining} restante";

  static String m8(current_keyOS_version) =>
      "O teu Passport Prime está atualmente na versão ${current_keyOS_version}.\n\nAtualiza agora para as últimas correções e funcionalidades.";

  static String m9(est_upd_time) =>
      "Tempo Estimado da Atualização: ${est_upd_time}";

  static String m10(new_keyOS_version) => "Novidades em ${new_keyOS_version}";

  static String m11(new_keyOS_version) =>
      "O Passport Prime foi atualizado com sucesso \npara ${new_keyOS_version}";

  static String m12(amount, total_amount) =>
      "Migração em curso.\nNão feches a Envoy.\n\n${amount} de ${total_amount} processados.";

  static String m13(passport_color) => "Cor: ${passport_color}";

  static String m14(firmware_version) => "Firmware: ${firmware_version}";

  static String m15(serial_number) => "Número de Série: ${serial_number}";

  static String m16(AccountName) =>
      "No Passport, vai a ${AccountName}, escolhe ‘Account Tools’ e depois ‘Verify Address’, e digitaliza o código QR abaixo.";

  static String m17(AccountName) =>
      "No Passport, abre ${AccountName} > ‘Verify Address’ e digitaliza o código QR abaixo.";

  static String m18(accoutname) => "Falha ao reanalisar ${accoutname} ";

  static String m19(accoutname) => "Reanálise concluída para ${accoutname} ";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage(
            "https://blockstream.info/api/"),
        "about_appVersion": MessageLookupByLibrary.simpleMessage(
          "Versão da Aplicação",
        ),
        "about_openSourceLicences": MessageLookupByLibrary.simpleMessage(
          "Licenças de Código Aberto",
        ),
        "about_privacyPolicy": MessageLookupByLibrary.simpleMessage(
          "Política de Privacidade",
        ),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Termos de Uso"),
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
            MessageLookupByLibrary.simpleMessage("Segwit Encapsulado"),
        "account_details_filter_tags_sortBy":
            MessageLookupByLibrary.simpleMessage(
          "Ordem",
        ),
        "account_details_untagged_card": MessageLookupByLibrary.simpleMessage(
          "Sem etiqueta",
        ),
        "account_emptyTxHistoryTextExplainer_FilteredView":
            MessageLookupByLibrary.simpleMessage(
          "Os filtros aplicados escondem todas as transacções.\nActualiza ou repõe os filtros para ver as transacções.",
        ),
        "account_empty_tx_history_text_explainer":
            MessageLookupByLibrary.simpleMessage(
          "Não existem transacções nesta conta.\nRecebe a tua primeira transacção abaixo.",
        ),
        "account_type_label_taproot": MessageLookupByLibrary.simpleMessage(
          "Taproot",
        ),
        "account_type_sublabel_testnet": MessageLookupByLibrary.simpleMessage(
          "Testnet",
        ),
        "accounts_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
          "Cria uma carteira móvel com Cópias Mágicas.",
        ),
        "accounts_empty_text_learn_more": MessageLookupByLibrary.simpleMessage(
          "Começar",
        ),
        "accounts_forceUpdate_cta": MessageLookupByLibrary.simpleMessage(
          "Actualizar Envoy",
        ),
        "accounts_forceUpdate_heading": MessageLookupByLibrary.simpleMessage(
          "Necessário Actualizar a Envoy",
        ),
        "accounts_forceUpdate_subheading": MessageLookupByLibrary.simpleMessage(
          "Está disponível uma nova actualização para a Envoy que contém melhorias e correcções importantes.\n\nPara continuares a usar a Envoy por favor actualiza para a versão mais recente. Obrigado.",
        ),
        "accounts_loading_loadingAccount": MessageLookupByLibrary.simpleMessage(
          "A Carregar Conta…",
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
            MessageLookupByLibrary.simpleMessage("Carteira Móvel"),
        "accounts_switchDefault":
            MessageLookupByLibrary.simpleMessage("Padrão"),
        "accounts_switchPassphrase": MessageLookupByLibrary.simpleMessage(
          "Frase-passe",
        ),
        "accounts_toastNewUpdate_content": MessageLookupByLibrary.simpleMessage(
          "Nova Atualização - Vê as novidades.",
        ),
        "accounts_toast_newUpdate": MessageLookupByLibrary.simpleMessage(
          "Nova Atualização - Vê as novidades.",
        ),
        "accounts_toast_paymentCopied": MessageLookupByLibrary.simpleMessage(
          "ID do pagamento copiado.",
        ),
        "accounts_toast_txidCopied": MessageLookupByLibrary.simpleMessage(
          "ID da transacção copiado.",
        ),
        "accounts_upgradeBdkSignetModal_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy passa agora a usar Global Signet em vez de Mutinynet. As tuas contas Signet anteriores foram removidas. \n\nPara começares a usar Global Signet, vai a Definições e ativa o interruptor Signet.",
        ),
        "accounts_upgradeBdkSignetModal_header":
            MessageLookupByLibrary.simpleMessage("Global Signet"),
        "accounts_upgradeBdkTestnetModal_content":
            MessageLookupByLibrary.simpleMessage(
          "‘Testnet3’ foi descontinuado e a Envoy usa agora ‘testnet4’. As tuas contas testnet3 anteriores foram removidas. \n\nPara começares a usar testnet4, vai a Definições e ativa o interruptor Testnet.",
        ),
        "accounts_upgradeBdkTestnetModal_header":
            MessageLookupByLibrary.simpleMessage("Apresentamos a testnet4"),
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Reforçada"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("A cancelar"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
          "Não existe atividade para apresentar.",
        ),
        "activity_envoyUpdate": MessageLookupByLibrary.simpleMessage(
          "Aplicação Envoy Actualizada",
        ),
        "activity_envoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
          "Nova versão da Envoy",
        ),
        "activity_firmwareUpdate": MessageLookupByLibrary.simpleMessage(
          "Actualização de firmware disponível",
        ),
        "activity_incomingPurchase": MessageLookupByLibrary.simpleMessage(
          "Compra a Receber",
        ),
        "activity_listHeader_Today":
            MessageLookupByLibrary.simpleMessage("Hoje"),
        "activity_passportUpdate": MessageLookupByLibrary.simpleMessage(
          "Novo firmware do Passport",
        ),
        "activity_pending": MessageLookupByLibrary.simpleMessage("Pendente"),
        "activity_received": MessageLookupByLibrary.simpleMessage("Recebido"),
        "activity_sent": MessageLookupByLibrary.simpleMessage("Enviado"),
        "activity_sent_boosted": MessageLookupByLibrary.simpleMessage(
          "Enviada (Reforçada)",
        ),
        "activity_sent_canceled":
            MessageLookupByLibrary.simpleMessage("Cancelada"),
        "add_note_modal_heading": MessageLookupByLibrary.simpleMessage(
          "Adicionar Nota",
        ),
        "add_note_modal_ie_text_field": MessageLookupByLibrary.simpleMessage(
          "Compra da carteira física Passport",
        ),
        "add_note_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "Regista alguns detalhes sobre esta transacção.",
        ),
        "android_backup_info_heading": MessageLookupByLibrary.simpleMessage(
          "O Android Realiza Cópias de Segurança a Cada 24h",
        ),
        "android_backup_info_subheading": MessageLookupByLibrary.simpleMessage(
          "O Android faz uma cópia de segurança automática dos dados da Envoy a cada 24 horas.\n\nPara garantires que a tua primeira Cópia Mágica de Segurança foi concluída com sucesso, recomendamos que faças uma cópia de segurança manual nas [[Definições]] do teu dispositivo. ",
        ),
        "appstore_description": MessageLookupByLibrary.simpleMessage(
          "A Envoy é uma carteira Bitcoin simples com funções poderosas de gestão de contas e de privacidade.\n\nUsa a Envoy com a tua carteira física Passport para configuração, actualizações de firmware e mais.\n\nA Envoy oferece as seguintes funções:\n\n1. Cópia Mágica de Segurança. Auto-custódia em apenas 60 segundos com cópias de segurança automáticas encriptadas. Palavras semente opcionais.\n\n2. Gere a tua carteira móvel e as contas da carteira física Passport na mesma aplicação.\n\n3. Envia e recebe Bitcoin de uma forma serena.\n\n4. Liga a tua carteira física Passport para configuração, actualizações de firmware e vídeos de apoio. Usa a Envoy como a tua carteira de software ligada ao teu Passport.\n\n5. Código aberto na íntegra, preservando a privacidade. Como opção, a Envoy liga-se à Internet via Tor para máxima privacidade.\n\n6. Em alternativa liga-te ao teu próprio nó Bitcoin.",
        ),
        "azteco_account_tx_history_pending_voucher":
            MessageLookupByLibrary.simpleMessage("Vale Azteco pendente"),
        "azteco_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Não Foi Possível Ligar"),
        "azteco_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não consegue estabelecer ligação com a Azteco.\n\nPor favor entra em contacto com support@azte.co ou tenta novamente mais tarde.",
        ),
        "azteco_note": MessageLookupByLibrary.simpleMessage("Vale Azteco"),
        "azteco_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Vale Azteco Pendente",
        ),
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage(
          "CÓDIGO DO VALE",
        ),
        "azteco_redeem_modal_amount": MessageLookupByLibrary.simpleMessage(
          "Quantia",
        ),
        "azteco_redeem_modal_cta1": MessageLookupByLibrary.simpleMessage(
          "Resgatar",
        ),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não Foi Possível Resgatar",
        ),
        "azteco_redeem_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Por favor confirma se o teu vale ainda está válido.\n\nContacta o support@azte.co para quaisquer questões relacionadas com o vale.",
        ),
        "azteco_redeem_modal_heading": MessageLookupByLibrary.simpleMessage(
          "Resgatar Vale?",
        ),
        "azteco_redeem_modal_saleDate": MessageLookupByLibrary.simpleMessage(
          "Data de Venda",
        ),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "Vale Resgatado",
        ),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Em breve irá aparecer uma transacção a receber na tua conta.",
        ),
        "backup_toast_envoyBackupComplete":
            MessageLookupByLibrary.simpleMessage(
          "Cópia de Segurança da Envoy concluída.",
        ),
        "backups_advancedBackups": MessageLookupByLibrary.simpleMessage(
          "Cópias de Segurança Avançadas",
        ),
        "backups_downloadBIP329BackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Exportar Etiquetas (BIP-329)",
        ),
        "backups_downloadSettingsDataBackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Descarregar Cópia de Segurança de Definições & Dados",
        ),
        "backups_downloadSettingsMetadataBackupFile":
            MessageLookupByLibrary.simpleMessage(
          "Descarregar Cópia de Definições & Metadados",
        ),
        "backups_erase_mobile_wallet": MessageLookupByLibrary.simpleMessage(
          "Apagar Carteira Móvel",
        ),
        "backups_erase_wallets_and_backups":
            MessageLookupByLibrary.simpleMessage(
          "Apagar Carteira Móvel e Cópias",
        ),
        "backups_erase_wallets_and_backups_modal_1_2_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estás prestes a eliminar permanentemente a tua carteira Envoy. \n\nSe estiveres a usar Cópias Mágicas de Segurança, a tua semente do Envoy também será eliminada da Cópia de Segurança do Android. ",
        ),
        "backups_erase_wallets_and_backups_modal_1_2_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estás prestes a eliminar permanentemente a tua Carteira Envoy.\n\nSe estiveres a usar Cópias Mágicas de Segurança, a tua Semente da Envoy também será eliminada do Porta-chaves iCloud. ",
        ),
        "backups_erase_wallets_and_backups_modal_2_2_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Nenhuma conta Passport associada será removida neste processo.\n\nAntes de eliminares a Carteira Envoy, confirma que a Semente e o Ficheiro de Cópia de Segurança estão guardados.\n",
        ),
        "backups_erase_wallets_and_backups_show_seed_CTA":
            MessageLookupByLibrary.simpleMessage("Mostrar Semente"),
        "backups_erase_wallets_and_backups_show_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Mantém a Tua Semente Privada"),
        "backups_erase_wallets_and_backups_show_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Mantém sempre privadas as tuas palavras semente. Quem tiver acesso a esta semente pode gastar as tuas Bitcoin!",
        ),
        "backups_magicToManualErrorModal_header":
            MessageLookupByLibrary.simpleMessage("Não Foi Possível Continuar"),
        "backups_magicToManualErrorModal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "A Cópia Mágica de Segurança da Envoy não pode ser desativada enquanto uma Cópia Mágica de Segurança do Passport Prime estiver ativa.\n\nPara continuar, desativa primeiro a Cópia Mágica de Segurança do Passport Prime no dispositivo.",
        ),
        "backups_manualToMagicrModal_header":
            MessageLookupByLibrary.simpleMessage(
          "A Ativar Cópias Mágicas de Segurança",
        ),
        "backups_manualToMagicrModal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "Isto vai ativar uma Cópia Mágica de Segurança da tua carteira Envoy. A tua semente da Envoy vai ser encriptada e copiada para a tua conta Apple ou Google. Os dados da Envoy vão ser encriptados e enviados para o servidor da Foundation.",
        ),
        "backups_primeMagicBackups": m0,
        "backups_primeMasterKeyBackup": MessageLookupByLibrary.simpleMessage(
          "Cópia da Chave Mestra (1 de 3 partes)",
        ),
        "backups_settingsAndData": MessageLookupByLibrary.simpleMessage(
          "Definições & Dados",
        ),
        "backups_settingsAndMetadata": MessageLookupByLibrary.simpleMessage(
          "Definições & Metadados",
        ),
        "backups_toggle_envoy_magic_backups":
            MessageLookupByLibrary.simpleMessage(
          "Cópias Mágicas de Segurança da Envoy",
        ),
        "backups_toggle_envoy_mobile_wallet_key":
            MessageLookupByLibrary.simpleMessage("Chave da Carteira Móvel"),
        "backups_viewMobileWalletSeed": MessageLookupByLibrary.simpleMessage(
          "Ver Semente da Carteira Móvel",
        ),
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Contas"),
        "bottomNav_activity": MessageLookupByLibrary.simpleMessage("Atividade"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositivos"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprender"),
        "bottomNav_privacy":
            MessageLookupByLibrary.simpleMessage("Privacidade"),
        "bottomNav_transfer":
            MessageLookupByLibrary.simpleMessage("Transferir"),
        "btcpay_connection_modal_expired_subheading": m1,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Vale Expirado"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não consegue ligar-se à loja BTCPay do emissor.\n\nPor favor entra em contacto com o emissor ou tenta novamente mais tarde.",
        ),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O vale digitalizado não foi criado com suporte onchain.\n\nPor favor entra em contacto com o criador do vale.",
        ),
        "btcpay_note": MessageLookupByLibrary.simpleMessage("Vale BTCPay"),
        "btcpay_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Vale BTCPay Pendente",
        ),
        "btcpay_redeem_modal_description": MessageLookupByLibrary.simpleMessage(
          "Descrição:",
        ),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nome:"),
        "btcpay_redeem_modal_wrongNetwork_heading":
            MessageLookupByLibrary.simpleMessage("Rede Errada"),
        "btcpay_redeem_modal_wrongNetwork_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Este é um vale on-chain. Não pode ser resgatado para uma conta Testnet ou Signet.",
        ),
        "btn_firmware_version":
            MessageLookupByLibrary.simpleMessage("Firmware"),
        "buy_bitcoin_accountSelection_chooseAccount":
            MessageLookupByLibrary.simpleMessage(
                "Escolher uma conta diferente"),
        "buy_bitcoin_accountSelection_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O teu Bitcoin vai ser enviado para este endereço:",
        ),
        "buy_bitcoin_accountSelection_verify":
            MessageLookupByLibrary.simpleMessage(
          "Verificar Endereço no Passport",
        ),
        "buy_bitcoin_accountSelection_verify_modal_heading": m2,
        "camera_toast_couldntDecodeUr": MessageLookupByLibrary.simpleMessage(
          "Falha ao descodificar UR.",
        ),
        "camera_toast_invalidPairPayload": MessageLookupByLibrary.simpleMessage(
          "Payload de Emparelhamento Inválido.",
        ),
        "camera_toast_notAValidAddress": MessageLookupByLibrary.simpleMessage(
          "Endereço inválido.",
        ),
        "camera_toast_notAValidSeed": MessageLookupByLibrary.simpleMessage(
          "Semente inválida.",
        ),
        "card_coin_locked":
            MessageLookupByLibrary.simpleMessage("Moeda Bloqueada"),
        "card_coin_selected": MessageLookupByLibrary.simpleMessage(
          "Moeda Seleccionada",
        ),
        "card_coin_unselected": MessageLookupByLibrary.simpleMessage("Moeda"),
        "card_coins_locked": MessageLookupByLibrary.simpleMessage(
          "Moedas Bloqueadas",
        ),
        "card_coins_selected": MessageLookupByLibrary.simpleMessage(
          "Moedas Seleccionadas",
        ),
        "card_coins_unselected": MessageLookupByLibrary.simpleMessage("Moedas"),
        "card_label_of": MessageLookupByLibrary.simpleMessage("de"),
        "change_output_from_multiple_tags_modal_heading":
            MessageLookupByLibrary.simpleMessage("Escolhe uma Etiqueta"),
        "change_output_from_multiple_tags_modal_subehading":
            MessageLookupByLibrary.simpleMessage(
          "Esta transacção gasta moedas de várias etiquetas. De que forma gostarias de etiquetar o teu troco?",
        ),
        "coinDetails_tagDetails": MessageLookupByLibrary.simpleMessage(
          "DETALHES DA ETIQUETA",
        ),
        "coincontrol_coin_change_spendable_tate_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O ID da transacção será copiado para a área de transferência e pode ser visível a outras aplicações do telemóvel.",
        ),
        "coincontrol_edit_transaction_available_balance":
            MessageLookupByLibrary.simpleMessage("Saldo disponível"),
        "coincontrol_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Quantia Necessária"),
        "coincontrol_edit_transaction_selectedAmount":
            MessageLookupByLibrary.simpleMessage("Quantia Seleccionada"),
        "coincontrol_lock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage(
          "Bloquear",
        ),
        "coincontrol_lock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O bloqueio das moedas impossibilita o seu uso em transacções",
        ),
        "coincontrol_subsat_selectorWarning":
            MessageLookupByLibrary.simpleMessage(
          "Menos de 1 sat/vb é uma funcionalidade avançada.",
        ),
        "coincontrol_switchActivity": MessageLookupByLibrary.simpleMessage(
          "Atividade",
        ),
        "coincontrol_switchTags":
            MessageLookupByLibrary.simpleMessage("Etiquetas"),
        "coincontrol_txDetail_ReviewTransaction":
            MessageLookupByLibrary.simpleMessage("Rever Transacção"),
        "coincontrol_txDetail_cta1_passport":
            MessageLookupByLibrary.simpleMessage(
          "Assinar com o Passport",
        ),
        "coincontrol_txDetail_heading_passport":
            MessageLookupByLibrary.simpleMessage(
          "A tua transacção está pronta\npara ser assinada",
        ),
        "coincontrol_txDetail_subheading_passport":
            MessageLookupByLibrary.simpleMessage(
          "Confirma se os dados da transacção estão correctos antes de assinar com o Passport.",
        ),
        "coincontrol_tx_add_note_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Guarda alguns detalhes da tua transacção.",
        ),
        "coincontrol_tx_detail_amount_details":
            MessageLookupByLibrary.simpleMessage("Ver detalhes"),
        "coincontrol_tx_detail_amount_to_sent":
            MessageLookupByLibrary.simpleMessage("Quantia a enviar"),
        "coincontrol_tx_detail_change": MessageLookupByLibrary.simpleMessage(
          "Troco recebido",
        ),
        "coincontrol_tx_detail_cta1": MessageLookupByLibrary.simpleMessage(
          "Enviar Transacção",
        ),
        "coincontrol_tx_detail_cta2": MessageLookupByLibrary.simpleMessage(
          "Editar Transacção",
        ),
        "coincontrol_tx_detail_custom_fee_cta":
            MessageLookupByLibrary.simpleMessage("Confirmar Taxa"),
        "coincontrol_tx_detail_custom_fee_insufficients_funds_25_prompt":
            MessageLookupByLibrary.simpleMessage("Acima de 25%"),
        "coincontrol_tx_detail_destination":
            MessageLookupByLibrary.simpleMessage(
          "Destino",
        ),
        "coincontrol_tx_detail_destination_details":
            MessageLookupByLibrary.simpleMessage("Mostrar endereço"),
        "coincontrol_tx_detail_expand_changeReceived":
            MessageLookupByLibrary.simpleMessage("Troco recebido"),
        "coincontrol_tx_detail_expand_coin":
            MessageLookupByLibrary.simpleMessage(
          "moeda",
        ),
        "coincontrol_tx_detail_expand_coins":
            MessageLookupByLibrary.simpleMessage(
          "moedas",
        ),
        "coincontrol_tx_detail_expand_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DA TRANSACÇÃO"),
        "coincontrol_tx_detail_expand_spentFrom":
            MessageLookupByLibrary.simpleMessage("Gasto de"),
        "coincontrol_tx_detail_fee":
            MessageLookupByLibrary.simpleMessage("Taxa"),
        "coincontrol_tx_detail_feeChange_information":
            MessageLookupByLibrary.simpleMessage(
          "Ao actualizares a tua taxa podes ter alterado a selecção das moedas. Por favor revê.",
        ),
        "coincontrol_tx_detail_fee_alert": m3,
        "coincontrol_tx_detail_fee_custom":
            MessageLookupByLibrary.simpleMessage(
          "Personalizada",
        ),
        "coincontrol_tx_detail_fee_fast": MessageLookupByLibrary.simpleMessage(
          "Rápida",
        ),
        "coincontrol_tx_detail_fee_faster":
            MessageLookupByLibrary.simpleMessage(
          "Rápida",
        ),
        "coincontrol_tx_detail_fee_slow": MessageLookupByLibrary.simpleMessage(
          "Lenta",
        ),
        "coincontrol_tx_detail_fee_standard":
            MessageLookupByLibrary.simpleMessage(
          "Padrão",
        ),
        "coincontrol_tx_detail_heading": MessageLookupByLibrary.simpleMessage(
          "A tua transacção está pronta\na enviar",
        ),
        "coincontrol_tx_detail_high_fee_info_overlay_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Algumas moedas mais pequenas foram excluídas desta transacção. Com a taxa de comissão escolhida, o custo da sua inclusão é superior ao seu valor.",
        ),
        "coincontrol_tx_detail_newFee": MessageLookupByLibrary.simpleMessage(
          "Nova Taxa",
        ),
        "coincontrol_tx_detail_no_change": MessageLookupByLibrary.simpleMessage(
          "Sem troco",
        ),
        "coincontrol_tx_detail_passport_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Anular Transacção",
        ),
        "coincontrol_tx_detail_passport_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Ao cancelar irás perder todo o progresso da transacção.",
        ),
        "coincontrol_tx_detail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Confirma se os dados da transacção estão correctos antes do envio.",
        ),
        "coincontrol_tx_detail_total": MessageLookupByLibrary.simpleMessage(
          "Total",
        ),
        "coincontrol_tx_history_tx_detail_note":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coincontrol_unlock_coin_modal_cta1":
            MessageLookupByLibrary.simpleMessage(
          "Desbloquear",
        ),
        "coincontrol_unlock_coin_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O desbloqueio das moedas torna-as disponíveis para uso em transacções.",
        ),
        "coindetails_overlay_address": MessageLookupByLibrary.simpleMessage(
          "Endereço",
        ),
        "coindetails_overlay_at": MessageLookupByLibrary.simpleMessage("às"),
        "coindetails_overlay_block":
            MessageLookupByLibrary.simpleMessage("Bloco"),
        "coindetails_overlay_boostedFees": MessageLookupByLibrary.simpleMessage(
          "Taxa de Reforço",
        ),
        "coindetails_overlay_confirmation":
            MessageLookupByLibrary.simpleMessage(
          "Confirmação em",
        ),
        "coindetails_overlay_confirmationIn":
            MessageLookupByLibrary.simpleMessage(
          "Confirmação em",
        ),
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
        "coindetails_overlay_confirmations":
            MessageLookupByLibrary.simpleMessage(
          "Confirmações",
        ),
        "coindetails_overlay_date":
            MessageLookupByLibrary.simpleMessage("Data"),
        "coindetails_overlay_explorer": MessageLookupByLibrary.simpleMessage(
          "Explorador",
        ),
        "coindetails_overlay_heading": MessageLookupByLibrary.simpleMessage(
          "SOBRE A MOEDA",
        ),
        "coindetails_overlay_modal_explorer_heading":
            MessageLookupByLibrary.simpleMessage("Abrir no Explorador"),
        "coindetails_overlay_modal_explorer_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Estás prestes a deixar a Envoy e consultar esta transacção num explorador de blocos alojado pela Foundation. Certifica-te de que compreendes os compromissos de privacidade antes de continuar.",
        ),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não É Possível Reforçar a Transacção",
        ),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Isto deve-se ao facto de não existirem moedas confirmadas ou desbloqueadas suficientes para escolher. \n\nSempre que possível, permite que as moedas pendentes sejam confirmadas ou desbloqueia algumas moedas e tenta novamente.",
        ),
        "coindetails_overlay_noCancelNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Impossível Cancelar Transacção"),
        "coindetails_overlay_noCanceltNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Não estão disponíveis moedas confirmadas ou desbloqueadas suficientes para cancelar esta transacção. \n\nSempre que possível, deixa que as moedas pendentes sejam confirmadas ou desbloqueia algumas moedas e tenta novamente.",
        ),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coindetails_overlay_paymentID": MessageLookupByLibrary.simpleMessage(
          "ID de Pagamento",
        ),
        "coindetails_overlay_rampFee": MessageLookupByLibrary.simpleMessage(
          "Taxas Ramp",
        ),
        "coindetails_overlay_rampID": MessageLookupByLibrary.simpleMessage(
          "ID da Ramp",
        ),
        "coindetails_overlay_status": MessageLookupByLibrary.simpleMessage(
          "Estado",
        ),
        "coindetails_overlay_status_confirmed":
            MessageLookupByLibrary.simpleMessage("Confirmada"),
        "coindetails_overlay_status_pending":
            MessageLookupByLibrary.simpleMessage(
          "Pendente",
        ),
        "coindetails_overlay_tag":
            MessageLookupByLibrary.simpleMessage("Etiqueta"),
        "coindetails_overlay_transactionID":
            MessageLookupByLibrary.simpleMessage(
          "ID de Transacção",
        ),
        "common_button_contactSupport": MessageLookupByLibrary.simpleMessage(
          "Contactar Apoio Técnico",
        ),
        "common_button_retry": MessageLookupByLibrary.simpleMessage(
          "Tentar novamente",
        ),
        "component_12WordSeed": MessageLookupByLibrary.simpleMessage(
          "Semente de 12 Palavras",
        ),
        "component_24WordSeed": MessageLookupByLibrary.simpleMessage(
          "Semente de 24 Palavras",
        ),
        "component_Apply": MessageLookupByLibrary.simpleMessage("Aplicar"),
        "component_advanced": MessageLookupByLibrary.simpleMessage("Avançado"),
        "component_apply": MessageLookupByLibrary.simpleMessage("Aplicar"),
        "component_areYouSure": MessageLookupByLibrary.simpleMessage(
          "Tens a certeza?",
        ),
        "component_back": MessageLookupByLibrary.simpleMessage("Voltar"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "component_confirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
        "component_content": MessageLookupByLibrary.simpleMessage("Conteúdo"),
        "component_continue": MessageLookupByLibrary.simpleMessage("Continuar"),
        "component_delete": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "component_device": MessageLookupByLibrary.simpleMessage("Dispositivo"),
        "component_dismiss": MessageLookupByLibrary.simpleMessage("Dispensar"),
        "component_done": MessageLookupByLibrary.simpleMessage("Concluído"),
        "component_dontShowAgain": MessageLookupByLibrary.simpleMessage(
          "Não mostrar novamente",
        ),
        "component_exit": MessageLookupByLibrary.simpleMessage("Sair"),
        "component_filter": MessageLookupByLibrary.simpleMessage("Filtrar"),
        "component_filter_button_all":
            MessageLookupByLibrary.simpleMessage("Tudo"),
        "component_goToSettings": MessageLookupByLibrary.simpleMessage(
          "Ir para Definições",
        ),
        "component_learnMore":
            MessageLookupByLibrary.simpleMessage("Saber mais"),
        "component_minishield_buy":
            MessageLookupByLibrary.simpleMessage("Comprar"),
        "component_next": MessageLookupByLibrary.simpleMessage("Próximo"),
        "component_no": MessageLookupByLibrary.simpleMessage("Não"),
        "component_notificationText": MessageLookupByLibrary.simpleMessage(
          "Erro ao estabelecer ligação à rede Tor",
        ),
        "component_ok": MessageLookupByLibrary.simpleMessage("OK"),
        "component_recover": MessageLookupByLibrary.simpleMessage("Recuperar"),
        "component_recoverWithQR": MessageLookupByLibrary.simpleMessage(
          "Recuperar com Código QR",
        ),
        "component_redeem": MessageLookupByLibrary.simpleMessage("Resgatar"),
        "component_reset": MessageLookupByLibrary.simpleMessage("Repor"),
        "component_resetFilter": MessageLookupByLibrary.simpleMessage(
          "Repor filtro",
        ),
        "component_resetSorting": MessageLookupByLibrary.simpleMessage(
          "Repor ordenação",
        ),
        "component_retry":
            MessageLookupByLibrary.simpleMessage("Tentar novamente"),
        "component_save": MessageLookupByLibrary.simpleMessage("Guardar"),
        "component_searching":
            MessageLookupByLibrary.simpleMessage("A procurar"),
        "component_skip": MessageLookupByLibrary.simpleMessage("Saltar"),
        "component_sortBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "component_tryAgain": MessageLookupByLibrary.simpleMessage(
          "Tentar Novamente",
        ),
        "component_unpair":
            MessageLookupByLibrary.simpleMessage("Desemparelhar"),
        "component_update": MessageLookupByLibrary.simpleMessage("Actualizar"),
        "component_warning": MessageLookupByLibrary.simpleMessage("Aviso"),
        "component_yes": MessageLookupByLibrary.simpleMessage("Sim"),
        "componet_disconnect": MessageLookupByLibrary.simpleMessage("Desligar"),
        "contactRampForSupport": MessageLookupByLibrary.simpleMessage(
          "Contacta a Ramp para apoio",
        ),
        "copyToClipboard_address": MessageLookupByLibrary.simpleMessage(
          "O teu endereço será copiado para a área de transferência e poderá ficar visível para outras aplicações no teu telemóvel.",
        ),
        "copyToClipboard_txid": MessageLookupByLibrary.simpleMessage(
          "O ID da transacção será copiado para a área de transferência e pode ser visível a outras aplicações do telemóvel.",
        ),
        "create_first_tag_modal_1_2_subheading":
            MessageLookupByLibrary.simpleMessage(
          "As etiquetas são uma forma útil de organizares as tuas moedas.",
        ),
        "create_first_tag_modal_2_2_ie_text_field":
            MessageLookupByLibrary.simpleMessage(
                "Nova etiqueta, ex.: Exchange"),
        "create_first_tag_modal_2_2_suggest":
            MessageLookupByLibrary.simpleMessage(
          "Sugestões",
        ),
        "create_second_tag_modal_2_2_mostUsed":
            MessageLookupByLibrary.simpleMessage("Mais usadas"),
        "delete_emptyTag_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Queres mesmo eliminar esta etiqueta?",
        ),
        "delete_tag_modal_cta2": MessageLookupByLibrary.simpleMessage(
          "Eliminar Etiqueta",
        ),
        "delete_tag_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "A eliminação desta etiqueta marcará automaticamente estas moedas como sem etiqueta.",
        ),
        "delete_wallet_for_good_error_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não conseguiu contactar o servidor da Foundation para eliminar os teus dados de carteira encriptados. Tenta novamente ou contacta o suporte.",
        ),
        "delete_wallet_for_good_error_title":
            MessageLookupByLibrary.simpleMessage(
          "Não Foi Possível Eliminar",
        ),
        "delete_wallet_for_good_instant_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O Android faz uma cópia de segurança automática dos dados da Envoy a cada 24 horas.\n\nPara removeres imediatamente a tua Semente Envoy da Cópia de Segurança do Android, podes fazer uma cópia de segurança manual nas [[Definições]] do teu dispositivo.",
        ),
        "delete_wallet_for_good_loading_heading":
            MessageLookupByLibrary.simpleMessage(
                "A eliminar a tua Carteira Envoy"),
        "delete_wallet_for_good_modal_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Eliminar Carteira",
        ),
        "delete_wallet_for_good_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Tens a certeza que pretendes ELIMINAR a tua Carteira Envoy?",
        ),
        "delete_wallet_for_good_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "A tua carteira foi eliminada com sucesso",
        ),
        "descriptor_toast_descriptorCopied":
            MessageLookupByLibrary.simpleMessage(
          "Descritor copiado.",
        ),
        "descriptor_toast_signatureCopied":
            MessageLookupByLibrary.simpleMessage(
          "Assinatura copiada.",
        ),
        "device_deviceDetailsPrimeRemoved_accessoryRemoved":
            MessageLookupByLibrary.simpleMessage(
          "Acessório removido, religa o Passport.",
        ),
        "device_deviceDetailsPrimeRemoved_completeAccessorySetup":
            MessageLookupByLibrary.simpleMessage(
          "Concluir Configuração do Acessório",
        ),
        "device_deviceDetailsPrimeRemoved_pairPassportAgain":
            MessageLookupByLibrary.simpleMessage("Emparelhar Passport"),
        "device_deviceDetailsPrimeRemoved_reconnectPassport":
            MessageLookupByLibrary.simpleMessage("Voltar a Ligar o Passport"),
        "device_deviceDetailsPrime_connected":
            MessageLookupByLibrary.simpleMessage(
          "Ligado",
        ),
        "device_deviceDetailsPrime_connection":
            MessageLookupByLibrary.simpleMessage("Ligação"),
        "device_deviceDetailsPrime_disconnected":
            MessageLookupByLibrary.simpleMessage("Desligado"),
        "device_deviceDetailsPrime_securityCheck":
            MessageLookupByLibrary.simpleMessage("Verificação de Segurança"),
        "devices_connectingToPrime_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantém os dois dispositivos perto.",
        ),
        "devices_connectingToPrime_header":
            MessageLookupByLibrary.simpleMessage(
          "A Ligar ao Passport",
        ),
        "devices_connectionFailedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não conseguiu ligar ao Passport Prime. Garante que o Passport Prime está ligado, que o Bluetooth está activo e que não está já ligado a outro dispositivo.",
        ),
        "devices_connectionFailedModal_header":
            MessageLookupByLibrary.simpleMessage("Ligação Falhou"),
        "devices_empty_modal_video_cta1": MessageLookupByLibrary.simpleMessage(
          "Comprar o Passport",
        ),
        "devices_empty_modal_video_cta2": MessageLookupByLibrary.simpleMessage(
          "Ver Mais Tarde",
        ),
        "devices_empty_text_explainer": MessageLookupByLibrary.simpleMessage(
          "Protege a tua Bitcoin com o Passport.",
        ),
        "devices_firmwareUpdateModal_content":
            MessageLookupByLibrary.simpleMessage(
          "As actualizações de firmware do Passport Prime devem ser iniciadas no dispositivo. Vai a Settings > Update.",
        ),
        "devices_firmwareUpdateModal_header":
            MessageLookupByLibrary.simpleMessage(
          "Começar no Passport Prime",
        ),
        "devices_reconnectedSuccess_content":
            MessageLookupByLibrary.simpleMessage(
          "O dispositivo está pronto.",
        ),
        "devices_reconnectedSuccess_header":
            MessageLookupByLibrary.simpleMessage(
          "Dispositivo Religado!",
        ),
        "devices_reconnecting_content": MessageLookupByLibrary.simpleMessage(
          "A Ligar ao Passport Prime",
        ),
        "devices_reconnecting_header": MessageLookupByLibrary.simpleMessage(
          "A religar",
        ),
        "empty_tag_modal_subheading": m4,
        "envoy_account_tos_cta": MessageLookupByLibrary.simpleMessage("Aceito"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
          "Por favor revê e aceita as Condições de Utilização do Passport",
        ),
        "envoy_cameraPermissionRequest": MessageLookupByLibrary.simpleMessage(
          "A Envoy requer acesso à câmara para digitalizar códigos QR. Acede às definições e autoriza o acesso à câmara.",
        ),
        "envoy_cameraPermissionRequest_Header":
            MessageLookupByLibrary.simpleMessage("Autorização necessária"),
        "envoy_faq_answer_1": MessageLookupByLibrary.simpleMessage(
          "A Envoy é uma carteira móvel de Bitcoin e uma aplicação complementar ao Passport, disponível em iOS e Android.",
        ),
        "envoy_faq_answer_10": MessageLookupByLibrary.simpleMessage(
          "Não, qualquer pessoa é livre de descarregar, verificar e instalar manualmente o novo firmware. Podes ver mais informações [[aqui]].",
        ),
        "envoy_faq_answer_11": MessageLookupByLibrary.simpleMessage(
          "Sem dúvida, não existe limite para o número de Passports que podes gerir e interagir na Envoy.",
        ),
        "envoy_faq_answer_12": MessageLookupByLibrary.simpleMessage(
          "Sim, a Envoy simplifica a gestão de várias contas.",
        ),
        "envoy_faq_answer_13": MessageLookupByLibrary.simpleMessage(
          "A Envoy comunica maioritariamente através de códigos QR, apesar de as actualizações de firmware serem transferidas a partir do teu telemóvel através de um cartão microSD. Por defeito cada Passport vem com um adaptador microSD para utilizares no teu telemóvel.",
        ),
        "envoy_faq_answer_14": MessageLookupByLibrary.simpleMessage(
          "Sim, apenas tem em conta que qualquer informação específica da carteira, como por exemplo etiquetas de endereços ou de UTXO, não será copiada de ou para a Envoy.",
        ),
        "envoy_faq_answer_15": MessageLookupByLibrary.simpleMessage(
          "Isso pode ser possível uma vez que a maioria das carteiras físicas com funcionalidades de leitura de códigos QR comunicam de formas muito semelhantes, no entanto, isso não é uma forma explicitamente suportada. Uma vez que todo o código da Envoy é aberto, damos as boas-vindas a que outros fabricantes de carteiras físicas baseadas em leitura de códigos QR adicionem suporte!",
        ),
        "envoy_faq_answer_16": MessageLookupByLibrary.simpleMessage(
          "De momento, a Envoy apenas funciona com Bitcoin \'on-chain\'. Planeamos suportar Lightning no futuro.",
        ),
        "envoy_faq_answer_17": MessageLookupByLibrary.simpleMessage(
          "Qualquer pessoa que encontre o teu telemóvel precisaria primeiro de passar pelo PIN do sistema operativo ou pela autenticação biométrica para aceder à Envoy. No caso improvável de conseguirem isso, o atacante poderia enviar fundos da tua carteira móvel Envoy e ver a quantidade de Bitcoin armazenada em qualquer conta Passport ligada. Estes fundos do Passport não estão em risco porque quaisquer transacções devem ser autorizadas pelo dispositivo Passport emparelhado.",
        ),
        "envoy_faq_answer_18": MessageLookupByLibrary.simpleMessage(
          "Quando usada em conjunto com um Passport, a Envoy actua como uma carteira \'apenas de leitura\' ligada à tua carteira física. Isto significa que a Envoy pode elaborar transacções, mas são inúteis sem a autorização devida, a qual só pode ser fornecida pelo Passport. O Passport é um \'armazenamento frio\' enquanto que a Envoy é simplesmente uma interface ligada à Internet! Se usares a Envoy para criar uma carteira móvel, onde as tuas chaves são armazenadas de forma segura no teu telemóvel, essa carteira não pode ser considerada como um armazenamento frio. A segurança do Passport e das contas associadas não é impactada.",
        ),
        "envoy_faq_answer_19": MessageLookupByLibrary.simpleMessage(
          "Sim, a Envoy liga-se a nós pessoais através do protocolo de servidor Electrum ou Esplora. Para te ligares ao teu próprio servidor, digitaliza o código QR ou introduz o endereço fornecido nas definições de rede da Envoy.",
        ),
        "envoy_faq_answer_2": MessageLookupByLibrary.simpleMessage(
          "A Envoy foi concebida para oferecer a experiência mais fácil de usar de qualquer carteira Bitcoin, sem comprometer a tua privacidade. Com a Cópia Mágica de Segurança é possível configurar uma carteira móvel Bitcoin auto-custodiada em 60 segundos, sem palavras semente! Os utilizadores do Passport podem ligar os seus dispositivos à Envoy para uma configuração fácil, actualizações de firmware e uma experiência simples de carteira Bitcoin.",
        ),
        "envoy_faq_answer_20": MessageLookupByLibrary.simpleMessage(
          "Descarregar e instalar a Envoy não requer nenhuma informação pessoal e a Envoy pode ligar-se à Internet via Tor, um protocolo de preservação da privacidade. Isto significa que a Foundation não tem como saber quem tu és. A Envoy também permite aos utilizadores mais avançados a capacidade de se ligarem ao seu próprio nó Bitcoin para remover completamente qualquer dependência dos servidores da Foundation.",
        ),
        "envoy_faq_answer_21": MessageLookupByLibrary.simpleMessage(
          "Sim. A partir da versão 1.4.0, a Envoy suporta a selecção completa de moedas, bem como a \"etiquetagem\" de moedas.",
        ),
        "envoy_faq_answer_22": MessageLookupByLibrary.simpleMessage(
          "De momento a Envoy não suporta gastos em lote.",
        ),
        "envoy_faq_answer_23": MessageLookupByLibrary.simpleMessage(
          "Sim. A partir da versão 1.4.0, a Envoy permite personalizar na íntegra as taxas de envio e disponibiliza também duas opções de taxa para selecção rápida - \'Padrão\' e \'Rápida\'. A opção \'Padrão\' tem como objectivo finalizar a tua transacção em 60 minutos e a opção \'Rápida\' em 10 minutos. Estas taxas são estimativas baseadas no congestionamento da rede no momento em que a transacção é construída e ser-te-á sempre mostrado o custo de ambas as opções antes de finalizares a transacção.",
        ),
        "envoy_faq_answer_3": MessageLookupByLibrary.simpleMessage(
          "A Envoy é uma carteira simples de Bitcoin com poderosas funcionalidades de gestão de contas e privacidade, incluindo as Cópias Mágicas de Segurança.Utiliza a Envoy em conjunto com a carteira física Passport para questões relacionadas com configurações, actualizações de firmware e muito mais.",
        ),
        "envoy_faq_answer_4": MessageLookupByLibrary.simpleMessage(
          "A Cópia Mágica de Segurança é a forma mais fácil de configurar e efectuar uma cópia de segurança da carteira móvel Bitcoin. A Cópia Mágica de Segurança armazena a semente da tua carteira móvel, encriptada ponta a ponta, no Porta-chaves iCloud ou na Cópia de Segurança do Android. Todos os dados da aplicação são encriptados pela tua semente e armazenados nos Servidores da Foundation. Configura a tua carteira em 60 segundos e recupera-a automaticamente se perderes o teu telemóvel!",
        ),
        "envoy_faq_answer_5": MessageLookupByLibrary.simpleMessage(
          "As Cópias Mágicas de Segurança são completamente opcionais para os utilizadores que pretendem utilizar a Envoy como uma carteira móvel. Se preferes gerir as palavras semente da tua carteira móvel e a respectiva cópia de segurança, escolhe \"Configuração Manual das Palavras Semente\" na etapa inicial de configuração da carteira.",
        ),
        "envoy_faq_answer_6": MessageLookupByLibrary.simpleMessage(
          "A Cópia de Segurança da Envoy contém definições da aplicação, informações da conta e etiquetas de transacção. O ficheiro é encriptado com as palavras semente da tua carteira móvel. Para os utilizadores da Cópia Mágica de Segurança, a mesma é armazenada totalmente encriptada no servidor da Foundation. Os utilizadores da Envoy que decidam gerir as palavras semente de uma forma manual, podem descarregar e armazenar a sua própria cópia de segurança em qualquer lugar que achem por conveniente. Este local pode ser uma das seguintes combinações - telemóvel, um servidor de nuvem pessoal ou algo físico como um cartão microSD ou uma unidade flash USB.",
        ),
        "envoy_faq_answer_7": MessageLookupByLibrary.simpleMessage(
          "Não, as funcionalidades principais da Envoy serão sempre de utilização gratuita. No futuro, poderemos introduzir serviços pagos opcionais ou subscrições.",
        ),
        "envoy_faq_answer_8": MessageLookupByLibrary.simpleMessage(
          "Sim, à semelhança de tudo o que fazemos na Foundation, o código da Envoy é completamente aberto. A Envoy está licenciada sob a mesma licença [[GPLv3]] que o Firmware do nosso Passport. Para aqueles que desejam verificar o nosso código-fonte, podem fazê-lo [[aqui]].",
        ),
        "envoy_faq_answer_9": MessageLookupByLibrary.simpleMessage(
          "Não, orgulhamo-nos de garantir que o Passport é compatível com o maior número possível de carteiras de software diferentes. Vê a nossa lista completa, incluindo tutoriais [[aqui]].",
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
          "O que é a Envoy?",
        ),
        "envoy_faq_question_10": MessageLookupByLibrary.simpleMessage(
          "Tenho de usar a Envoy para fazer actualizações de firmware no Passport?",
        ),
        "envoy_faq_question_11": MessageLookupByLibrary.simpleMessage(
          "Posso gerir mais do que um Passport na Envoy?",
        ),
        "envoy_faq_question_12": MessageLookupByLibrary.simpleMessage(
          "Posso gerir várias contas a partir do mesmo Passport?",
        ),
        "envoy_faq_question_13": MessageLookupByLibrary.simpleMessage(
          "Como é que a Envoy comunica com o Passport?",
        ),
        "envoy_faq_question_14": MessageLookupByLibrary.simpleMessage(
          "Posso usar a Envoy em paralelo com outro programa como, por exemplo, a Sparrow Wallet?",
        ),
        "envoy_faq_question_15": MessageLookupByLibrary.simpleMessage(
          "Posso gerir outras carteiras físicas com a Envoy?",
        ),
        "envoy_faq_question_16": MessageLookupByLibrary.simpleMessage(
          "A Envoy é compatível com a Rede Lightning?",
        ),
        "envoy_faq_question_17": MessageLookupByLibrary.simpleMessage(
          "O que é que acontece se eu perder o meu telemóvel com a Envoy instalada?",
        ),
        "envoy_faq_question_18": MessageLookupByLibrary.simpleMessage(
          "A Envoy é considerada um ‘Armazenamento Frio’?",
        ),
        "envoy_faq_question_19": MessageLookupByLibrary.simpleMessage(
          "Posso ligar a Envoy ao meu nó de Bitcoin?",
        ),
        "envoy_faq_question_2": MessageLookupByLibrary.simpleMessage(
          "Porque é que deverei usar a Envoy?",
        ),
        "envoy_faq_question_20": MessageLookupByLibrary.simpleMessage(
          "De que forma é que a Envoy protege a minha privacidade?",
        ),
        "envoy_faq_question_21": MessageLookupByLibrary.simpleMessage(
          "A Envoy oferece controlo de moeda?",
        ),
        "envoy_faq_question_22": MessageLookupByLibrary.simpleMessage(
          "A Envoy é compatível com gastos em Lote?",
        ),
        "envoy_faq_question_23": MessageLookupByLibrary.simpleMessage(
          "A Envoy permite a selecção personalizada das taxas de envio?",
        ),
        "envoy_faq_question_3": MessageLookupByLibrary.simpleMessage(
          "O que é que a Envoy pode fazer?",
        ),
        "envoy_faq_question_4": MessageLookupByLibrary.simpleMessage(
          "Em que consiste a Cópia Mágica de Segurança da Envoy?",
        ),
        "envoy_faq_question_5": MessageLookupByLibrary.simpleMessage(
          "Tenho de utilizar as Cópias Mágicas de Segurança da Envoy?",
        ),
        "envoy_faq_question_6": MessageLookupByLibrary.simpleMessage(
          "O que é a Cópia de Segurança da Envoy?",
        ),
        "envoy_faq_question_7": MessageLookupByLibrary.simpleMessage(
          "Tenho de pagar para utilizar a Envoy?",
        ),
        "envoy_faq_question_8": MessageLookupByLibrary.simpleMessage(
          "A Envoy É uma Aplicação de Código Aberto?",
        ),
        "envoy_faq_question_9": MessageLookupByLibrary.simpleMessage(
          "Tenho de usar a Envoy para fazer transacções com o Passport?",
        ),
        "envoy_fw_fail_heading": MessageLookupByLibrary.simpleMessage(
          "A Envoy não foi capaz de copiar o firmware para o cartão microSD.",
        ),
        "envoy_fw_fail_subheading": MessageLookupByLibrary.simpleMessage(
          "Verifica se o cartão microSD está inserido corretamente no telemóvel e tenta novamente. Em alternativa, o firmware pode ser descarregado no nosso [[GitHub]].",
        ),
        "envoy_fw_intro_cta": MessageLookupByLibrary.simpleMessage(
          "Descarregar Firmware",
        ),
        "envoy_fw_intro_heading": MessageLookupByLibrary.simpleMessage(
          "De seguida, vamos actualizar o firmware do Passport",
        ),
        "envoy_fw_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "A Envoy permite-te actualizar o teu Passport a partir do teu telemóvel utilizando o adaptador microSD incluído.\n\nOs utilizadores avançados podem [[tocar aqui]] para descarregar e verificar o seu próprio firmware num computador.",
        ),
        "envoy_fw_ios_instructions_heading":
            MessageLookupByLibrary.simpleMessage(
          "Permitir que a Envoy aceda ao cartão microSD",
        ),
        "envoy_fw_ios_instructions_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Permite que a Envoy copie ficheiros para o cartão microSD. Toca em Procurar, depois em PASSPORT-SD e Abrir.",
        ),
        "envoy_fw_microsd_fails_cta2": MessageLookupByLibrary.simpleMessage(
          "Descarregar do Github",
        ),
        "envoy_fw_microsd_fails_heading": MessageLookupByLibrary.simpleMessage(
          "Desculpa, não foi possível obter a actualização de firmware neste momento.",
        ),
        "envoy_fw_microsd_heading": MessageLookupByLibrary.simpleMessage(
          "Introduz o cartão microSD no teu Telemóvel",
        ),
        "envoy_fw_microsd_subheading": MessageLookupByLibrary.simpleMessage(
          "Insere o adaptador microSD fornecido no teu telemóvel e, de seguida, insere o cartão microSD no adaptador.",
        ),
        "envoy_fw_passport_heading": MessageLookupByLibrary.simpleMessage(
          "Remove o cartão microSD e insere-o no teu Passport",
        ),
        "envoy_fw_passport_onboarded_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Insere o cartão microSD no Passport e vai a Settings -> Firmware -> Update Firmware.\n\nGarante que o Passport tem bateria suficiente antes de iniciar esta operação.",
        ),
        "envoy_fw_passport_subheading": MessageLookupByLibrary.simpleMessage(
          "Insere o cartão microSD no Passport e segue as instruções.\n\nGarante que o Passport tem bateria suficiente antes de iniciar esta operação.",
        ),
        "envoy_fw_progress_heading": MessageLookupByLibrary.simpleMessage(
          "A Envoy está a copiar o firmware para o\ncartão microSD",
        ),
        "envoy_fw_progress_subheading": MessageLookupByLibrary.simpleMessage(
          "Isto poderá demorar alguns segundos. Por favor não removas o cartão microSD.",
        ),
        "envoy_fw_success_heading": MessageLookupByLibrary.simpleMessage(
          "O firmware foi copiado com sucesso para o\ncartão microSD",
        ),
        "envoy_fw_success_subheading": MessageLookupByLibrary.simpleMessage(
          "Certifica-te de que carregas no botão Ejectar Cartão SD no Gestor de Ficheiros antes de removeres o cartão microSD do teu telemóvel.",
        ),
        "envoy_fw_success_subheading_ios": MessageLookupByLibrary.simpleMessage(
          "O firmware mais recente foi copiado para o cartão microSD e está pronto para ser instalado no Passport.",
        ),
        "envoy_pin_intro_heading": MessageLookupByLibrary.simpleMessage(
          "Introduz um código PIN de 6-12 dígitos no teu Passport",
        ),
        "envoy_pin_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "O Passport irá sempre pedir o PIN quando for iniciado. Recomendamos a utilização de um PIN único e anotá-lo num local seguro.\n\nSe te esqueceres do PIN, não há forma de recuperar o Passport e o dispositivo ficará permanentemente desactivado.",
        ),
        "envoy_pp_new_seed_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Agora, cria uma cópia de segurança encriptada da tua semente",
        ),
        "envoy_pp_new_seed_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O Passport vai fazer uma cópia de segurança da tua semente e definições do dispositivo para um cartão microSD encriptado.",
        ),
        "envoy_pp_new_seed_heading": MessageLookupByLibrary.simpleMessage(
          "No Passport selecciona\nCriar Nova Semente",
        ),
        "envoy_pp_new_seed_subheading": MessageLookupByLibrary.simpleMessage(
          "A Avalanche Noise Source do Passport, um verdadeiro gerador de números aleatórios de código aberto, ajuda a criar uma semente forte.",
        ),
        "envoy_pp_new_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "Parabéns, a tua nova semente foi criada",
        ),
        "envoy_pp_new_seed_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "De seguida, vamos ligar a Envoy ao Passport.",
        ),
        "envoy_pp_restore_backup_heading": MessageLookupByLibrary.simpleMessage(
          "No Passport, selecciona\nRestaurar Cópia de Segurança",
        ),
        "envoy_pp_restore_backup_password_heading":
            MessageLookupByLibrary.simpleMessage(
          "Desencriptar a tua Cópia de Segurança",
        ),
        "envoy_pp_restore_backup_password_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para desencriptar a cópia de segurança, introduz o código de 20 dígitos que foi apresentado aquando da criação da cópia de segurança.\n\nSe perdeste ou te esqueceste do código, podes, em alternativa, restaurar através das palavras semente.",
        ),
        "envoy_pp_restore_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Utiliza esta funcionalidade para restaurares o Passport através de uma cópia de segurança microSD encriptada proveniente de outro Passport.\n\nVais precisar da senha para desencriptares a cópia de segurança.",
        ),
        "envoy_pp_restore_backup_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "A tua Cópia de Segurança foi restaurada com sucesso",
        ),
        "envoy_pp_restore_seed_heading": MessageLookupByLibrary.simpleMessage(
          "No Passport, selecciona\nRestaurar Semente",
        ),
        "envoy_pp_restore_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Restaura uma semente existente de 12 ou 24 palavras.",
        ),
        "envoy_pp_restore_seed_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "A tua semente foi restaurada com sucesso",
        ),
        "envoy_pp_setup_intro_cta1": MessageLookupByLibrary.simpleMessage(
          "Criar Nova Semente",
        ),
        "envoy_pp_setup_intro_cta2": MessageLookupByLibrary.simpleMessage(
          "Restaurar Semente",
        ),
        "envoy_pp_setup_intro_cta3": MessageLookupByLibrary.simpleMessage(
          "Restaurar Cópia de Segurança",
        ),
        "envoy_pp_setup_intro_heading": MessageLookupByLibrary.simpleMessage(
          "De que forma gostarias de configurar o teu Passport?",
        ),
        "envoy_pp_setup_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Podes criar uma nova semente, restaurar uma carteira com palavras semente ou uma cópia de segurança de outro Passport.",
        ),
        "envoy_scv_intro_heading": MessageLookupByLibrary.simpleMessage(
          "Primeiro, vamos garantir que o teu Passport é seguro",
        ),
        "envoy_scv_intro_subheading": MessageLookupByLibrary.simpleMessage(
          "Esta verificação de segurança irá garantir que o teu Passport não foi adulterado durante o envio.",
        ),
        "envoy_scv_result_fail_cta1": MessageLookupByLibrary.simpleMessage(
          "Entrar em Contacto",
        ),
        "envoy_scv_result_fail_heading": MessageLookupByLibrary.simpleMessage(
          "O teu Passport pode ser inseguro",
        ),
        "envoy_scv_result_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não conseguiu validar a segurança do teu Passport. Por favor contacta-nos para assistência.",
        ),
        "envoy_scv_result_ok_heading": MessageLookupByLibrary.simpleMessage(
          "O teu Passport é seguro",
        ),
        "envoy_scv_result_ok_subheading": MessageLookupByLibrary.simpleMessage(
          "De seguida, cria um PIN para proteger o teu Passport",
        ),
        "envoy_scv_scan_qr_heading": MessageLookupByLibrary.simpleMessage(
          "De seguida, digitaliza o código QR no ecrã do teu Passport",
        ),
        "envoy_scv_scan_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "Este código QR termina o processo de validação e partilha alguma informação do Passport com a Envoy.",
        ),
        "envoy_scv_show_qr_heading": MessageLookupByLibrary.simpleMessage(
          "No Passport, selecciona Aplicação Envoy e digitaliza o Código QR",
        ),
        "envoy_scv_show_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "Este código QR fornece informação para validação e configuração.",
        ),
        "envoy_support_community": MessageLookupByLibrary.simpleMessage(
          "COMUNIDADE",
        ),
        "envoy_support_documentation": MessageLookupByLibrary.simpleMessage(
          "Documentação",
        ),
        "envoy_support_email": MessageLookupByLibrary.simpleMessage("E-mail"),
        "envoy_support_telegram":
            MessageLookupByLibrary.simpleMessage("Telegram"),
        "envoy_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
          "Permitir Cópia Mágica de Segurança",
        ),
        "envoy_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Configuração Manual das Palavras Semente",
        ),
        "envoy_welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Criar Nova Carteira",
        ),
        "envoy_welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
          "Para uma configuração sem problemas, recomendamos que seja activada a opção [[Cópia Mágica de Segurança]].\n\nUtilizadores experientes podem criar manualmente ou restaurar a semente da carteira.",
        ),
        "erase_wallet_with_balance_modal_CTA1":
            MessageLookupByLibrary.simpleMessage("Voltar às minhas Contas"),
        "erase_wallet_with_balance_modal_CTA2":
            MessageLookupByLibrary.simpleMessage("Eliminar Contas na mesma"),
        "erase_wallet_with_balance_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Antes de eliminares a tua Carteira Envoy, esvazia as tuas Contas. \nVai a Cópias de segurança > Apagar Carteiras e Cópias de Segurança quando terminares.",
        ),
        "exploreAddresses_listFilter_unused":
            MessageLookupByLibrary.simpleMessage(
          "Não usado",
        ),
        "exploreAddresses_listFilter_used":
            MessageLookupByLibrary.simpleMessage(
          "Usado",
        ),
        "exploreAddresses_listFilter_zeroBalance":
            MessageLookupByLibrary.simpleMessage("Saldo 0"),
        "exploreAddresses_listModal_backToList":
            MessageLookupByLibrary.simpleMessage("Voltar à Lista"),
        "exploreAddresses_listModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Este endereço já foi usado pelo menos uma vez. Ao receber Bitcoin, é recomendado usar um novo endereço por privacidade.",
        ),
        "exploreAddresses_listModal_showAddress":
            MessageLookupByLibrary.simpleMessage("Mostrar Endereço"),
        "exploreAddresses_list_header": MessageLookupByLibrary.simpleMessage(
          "Explorar Endereços",
        ),
        "exploreAddresses_qr_derivationPath":
            MessageLookupByLibrary.simpleMessage(
          "Caminho de Derivação",
        ),
        "exploreAddresses_qr_header": m5,
        "exploreAddresses_qr_warningReused":
            MessageLookupByLibrary.simpleMessage(
          "Este endereço já foi utilizado. Evita reutilizar endereços, por privacidade. ",
        ),
        "exploreAddresses_searchError_continueSearching":
            MessageLookupByLibrary.simpleMessage("Continuar Pesquisa"),
        "exploreAddresses_searchError_notFound": m6,
        "exploreAdresses_activityOptions_deleteAccount":
            MessageLookupByLibrary.simpleMessage("Eliminar Conta"),
        "exploreAdresses_activityOptions_editAccountName":
            MessageLookupByLibrary.simpleMessage("Editar Nome da Conta"),
        "exploreAdresses_activityOptions_exploreAddresses":
            MessageLookupByLibrary.simpleMessage("Explorar Endereços"),
        "exploreAdresses_activityOptions_showDescriptor":
            MessageLookupByLibrary.simpleMessage("Mostrar Descritor"),
        "exploreAdresses_activityOptions_signMessage":
            MessageLookupByLibrary.simpleMessage("Assinar Mensagem"),
        "export_backup_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "Este ficheiro encriptado contém dados úteis da carteira, como etiquetas, contas e definições.\nEstá encriptado com a Semente da Carteira Móvel. Garante que a semente tem uma cópia segura.",
        ),
        "export_backup_send_CTA1": MessageLookupByLibrary.simpleMessage(
          "Descarregar Cópia de Segurança",
        ),
        "export_backup_send_CTA2": MessageLookupByLibrary.simpleMessage(
          "Descartar",
        ),
        "export_seed_modal_12_words_CTA2": MessageLookupByLibrary.simpleMessage(
          "Ver Como Código QR",
        ),
        "export_seed_modal_QR_code_CTA2": MessageLookupByLibrary.simpleMessage(
          "Ver Semente",
        ),
        "export_seed_modal_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para utilizar este código QR na Envoy de um novo telemóvel, vai a Configurar a Carteira Envoy > Recuperar Cópia Mágica de Segurança > Recuperar através de Código QR",
        ),
        "export_seed_modal_QR_code_subheading_passphrase":
            MessageLookupByLibrary.simpleMessage(
          "Semente protegida por frase-passe. Para recuperares os teus fundos, precisas das palavras semente e da frase-passe.",
        ),
        "export_seed_modal_subheading": MessageLookupByLibrary.simpleMessage(
          "O ecrã seguinte irá apresentar informações altamente sensíveis.\n\nQualquer pessoa com acesso a estes dados pode roubar o teu Bitcoin. Procede com extrema cautela.",
        ),
        "filter_sortBy_aToZ": MessageLookupByLibrary.simpleMessage("De A a Z"),
        "filter_sortBy_highest": MessageLookupByLibrary.simpleMessage(
          "Valor mais elevado",
        ),
        "filter_sortBy_lowest": MessageLookupByLibrary.simpleMessage(
          "Valor mais baixo",
        ),
        "filter_sortBy_newest": MessageLookupByLibrary.simpleMessage(
          "Mais recentes primeiro",
        ),
        "filter_sortBy_oldest": MessageLookupByLibrary.simpleMessage(
          "Mais antigos primeiro",
        ),
        "filter_sortBy_zToA": MessageLookupByLibrary.simpleMessage("De Z a A"),
        "finalize_catchAll_backUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
          "Fazer Cópia da Chave Mestra",
        ),
        "finalize_catchAll_backingUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
                "A Fazer Cópia da Chave Mestra"),
        "finalize_catchAll_connectAccount":
            MessageLookupByLibrary.simpleMessage(
          "Associar Conta",
        ),
        "finalize_catchAll_connectingAccount":
            MessageLookupByLibrary.simpleMessage(
          "A Associar Conta",
        ),
        "finalize_catchAll_creatingPin": MessageLookupByLibrary.simpleMessage(
          "A Criar PIN",
        ),
        "finalize_catchAll_header": MessageLookupByLibrary.simpleMessage(
          "Continuar no Passport Prime",
        ),
        "finalize_catchAll_masterKeyBackedUp":
            MessageLookupByLibrary.simpleMessage(
          "Cópia da Chave Mestra Feita",
        ),
        "finalize_catchAll_masterKeySetUp":
            MessageLookupByLibrary.simpleMessage(
          "Chave Mestra Configurada",
        ),
        "finalize_catchAll_pinCreated": MessageLookupByLibrary.simpleMessage(
          "PIN criado",
        ),
        "finalize_catchAll_setUpMasterKey":
            MessageLookupByLibrary.simpleMessage(
          "Configurar Chave Mestra",
        ),
        "finalize_catchAll_settingUpMasterKey":
            MessageLookupByLibrary.simpleMessage("A Configurar Chave Mestra"),
        "finish_connectedSuccess_content": MessageLookupByLibrary.simpleMessage(
          "A Envoy está configurada e pronta para a tua Bitcoin!",
        ),
        "finish_connectedSuccess_header": MessageLookupByLibrary.simpleMessage(
          "Carteira Ligada com Sucesso",
        ),
        "firmware_connectionModalCancelUpdate_cancelUpdate":
            MessageLookupByLibrary.simpleMessage("Cancelar Actualização"),
        "firmware_connectionModalCancelUpdate_content":
            MessageLookupByLibrary.simpleMessage(
          "Isto cancelará a actualização do firmware. O Passport Prime ficará na versão actual.",
        ),
        "firmware_connectionModalCancelUpdate_header":
            MessageLookupByLibrary.simpleMessage("Cancelar Actualização?"),
        "firmware_downloadingUpdate_aboutOneMin":
            MessageLookupByLibrary.simpleMessage("Falta cerca de 1 min"),
        "firmware_downloadingUpdate_downloaded":
            MessageLookupByLibrary.simpleMessage("Atualização Descarregada"),
        "firmware_downloadingUpdate_estimating":
            MessageLookupByLibrary.simpleMessage("A estimar tempo restante…"),
        "firmware_downloadingUpdate_header":
            MessageLookupByLibrary.simpleMessage(
          "A Descarregar Atualização",
        ),
        "firmware_downloadingUpdate_timeRemaining": m7,
        "firmware_downloadingUpdate_transferring":
            MessageLookupByLibrary.simpleMessage(
                "A Enviar para o Passport Prime"),
        "firmware_updateAvailable_content2": m8,
        "firmware_updateAvailable_estimatedUpdateTime": m9,
        "firmware_updateAvailable_header": MessageLookupByLibrary.simpleMessage(
          "Atualização Disponível",
        ),
        "firmware_updateAvailable_whatsNew": m10,
        "firmware_updateError_downloadFailed":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao Descarregar",
        ),
        "firmware_updateError_header": MessageLookupByLibrary.simpleMessage(
          "Falha na Atualização",
        ),
        "firmware_updateError_installFailed":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao Instalar",
        ),
        "firmware_updateError_receivingFailed":
            MessageLookupByLibrary.simpleMessage("Falha ao Transferir"),
        "firmware_updateError_verifyFailed":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao Verificar",
        ),
        "firmware_updateModalConnectionLostToast_unableToReconnect":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível religar ao Passport Prime.",
        ),
        "firmware_updateModalConnectionLost_exit":
            MessageLookupByLibrary.simpleMessage("Sair da Configuração"),
        "firmware_updateModalConnectionLost_header":
            MessageLookupByLibrary.simpleMessage("Ligação Perdida"),
        "firmware_updateModalConnectionLost_reconnecting":
            MessageLookupByLibrary.simpleMessage("A ligar de novo…"),
        "firmware_updateModalConnectionLost_tryToReconnect":
            MessageLookupByLibrary.simpleMessage("Tentar Ligar de Novo"),
        "firmware_updateSuccess_content1": m11,
        "firmware_updateSuccess_content2": MessageLookupByLibrary.simpleMessage(
          "Continua a configuração no Passport Prime.",
        ),
        "firmware_updateSuccess_header": MessageLookupByLibrary.simpleMessage(
          "Atualização com Sucesso",
        ),
        "firmware_updatingDownload_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantém os dois dispositivos perto.",
        ),
        "firmware_updatingDownload_downloading":
            MessageLookupByLibrary.simpleMessage("A Descarregar Atualização"),
        "firmware_updatingDownload_header":
            MessageLookupByLibrary.simpleMessage(
          "A atualizar",
        ),
        "firmware_updatingDownload_transfer":
            MessageLookupByLibrary.simpleMessage(
          "Transferir para o Passport Prime",
        ),
        "firmware_updatingPrime_content2": MessageLookupByLibrary.simpleMessage(
          "A configuração retoma depois de o Prime reiniciar.",
        ),
        "firmware_updatingPrime_installUpdate":
            MessageLookupByLibrary.simpleMessage("Instalar Atualização"),
        "firmware_updatingPrime_installingUpdate":
            MessageLookupByLibrary.simpleMessage("A Instalar Atualização"),
        "firmware_updatingPrime_primeRestarting":
            MessageLookupByLibrary.simpleMessage("Passport Prime a reiniciar"),
        "firmware_updatingPrime_restartPrime":
            MessageLookupByLibrary.simpleMessage(
          "Reiniciar Passport Prime",
        ),
        "firmware_updatingPrime_updateInstalled":
            MessageLookupByLibrary.simpleMessage("Atualização Instalada"),
        "firmware_updatingPrime_verified": MessageLookupByLibrary.simpleMessage(
          "Atualização Verificada",
        ),
        "firmware_updatingPrime_verifying":
            MessageLookupByLibrary.simpleMessage(
          "A Verificar Atualização",
        ),
        "header_chooseAccount": MessageLookupByLibrary.simpleMessage(
          "ESCOLHE UMA CONTA",
        ),
        "hide_amount_first_time_text": MessageLookupByLibrary.simpleMessage(
          "Desliza para mostrar e esconder o teu saldo.",
        ),
        "hot_wallet_accounts_creation_done_text_explainer":
            MessageLookupByLibrary.simpleMessage(
          "Toca no cartão representado para receberes Bitcoin.",
        ),
        "hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt":
            MessageLookupByLibrary.simpleMessage(
          "Toca num dos cartões acima para receber Bitcoin.",
        ),
        "invalid_qr_heading": MessageLookupByLibrary.simpleMessage(
          "Código QR Inválido",
        ),
        "invalid_qr_subheading": MessageLookupByLibrary.simpleMessage(
          "O código QR não contém uma transacção Bitcoin válida (PSBT). Verifica e tenta novamente.",
        ),
        "launch_screen_faceID_fail_CTA": MessageLookupByLibrary.simpleMessage(
          "Tentar Novamente",
        ),
        "launch_screen_faceID_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Falha na Autenticação",
        ),
        "launch_screen_faceID_fail_subheading":
            MessageLookupByLibrary.simpleMessage("Tenta novamente"),
        "launch_screen_lockedout_heading": MessageLookupByLibrary.simpleMessage(
          "Bloqueado",
        ),
        "launch_screen_lockedout_wait_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Autenticação biométrica desactivada. Por favor fecha a Envoy, espera 30 segundos e tenta novamente.",
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
          "Os filtros ocultam todos os resultados.\nMuda ou repõe os filtros para ver mais.",
        ),
        "learning_center_filter_all":
            MessageLookupByLibrary.simpleMessage("Tudo"),
        "learning_center_results_title": MessageLookupByLibrary.simpleMessage(
          "Resultados",
        ),
        "learning_center_search_input": MessageLookupByLibrary.simpleMessage(
          "Pesquisar...",
        ),
        "learning_center_title_blog": MessageLookupByLibrary.simpleMessage(
          "Blogue",
        ),
        "learning_center_title_faq": MessageLookupByLibrary.simpleMessage(
          "Perguntas Frequentes",
        ),
        "learning_center_title_video": MessageLookupByLibrary.simpleMessage(
          "Vídeos",
        ),
        "learningcenter_status_read":
            MessageLookupByLibrary.simpleMessage("Lido"),
        "learningcenter_status_watched": MessageLookupByLibrary.simpleMessage(
          "Visualizado",
        ),
        "magic_setup_generate_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "A Encriptar a Tua Cópia de Segurança",
        ),
        "magic_setup_generate_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a encriptar a cópia de segurança da tua carteira.\n\nEsta cópia de segurança contém dados úteis da carteira, tais como etiquetas, notas, contas e definições.",
        ),
        "magic_setup_generate_envoy_key_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a criar uma semente segura da carteira Bitcoin, que será armazenada e encriptada ponta a ponta na cópia de segurança do Android.",
        ),
        "magic_setup_generate_envoy_key_heading":
            MessageLookupByLibrary.simpleMessage("A Criar a Tua Semente Envoy"),
        "magic_setup_generate_envoy_key_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a criar uma semente segura da carteira Bitcoin, que será armazenada e encriptada ponta a ponta no Porta-chaves iCloud.",
        ),
        "magic_setup_recovery_fail_Android_CTA1":
            MessageLookupByLibrary.simpleMessage("Tentar novamente"),
        "magic_setup_recovery_fail_Android_CTA2":
            MessageLookupByLibrary.simpleMessage("Recuperar com Código QR"),
        "magic_setup_recovery_fail_Android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não foi capaz de encontrar uma Cópia Mágica de Segurança. \n\nPor favor confirma que iniciaste sessão com a conta Google correcta e que restauraste a tua cópia de segurança mais recente do teu dispositivo.",
        ),
        "magic_setup_recovery_fail_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Cópia Mágica de Segurança Não Encontrada",
        ),
        "magic_setup_recovery_fail_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não foi capaz de localizar a Cópia Mágica de Segurança no servidor da Foundation.\n\nPor favor verifica que estás a recuperar uma carteira que utilizava anteriormente a Cópia Mágica de Segurança.",
        ),
        "magic_setup_recovery_fail_connectivity_heading":
            MessageLookupByLibrary.simpleMessage("Erro de Ligação"),
        "magic_setup_recovery_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não consegue ligar-se ao servidor da Foundation para recolher a tua Cópia Mágica de Segurança.\n\nPodes tentar novamente, importar a tua própria Cópia de Segurança da Envoy ou continuar sem uma.",
        ),
        "magic_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Recuperação Sem Sucesso",
        ),
        "magic_setup_recovery_fail_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não foi capaz de encontrar uma Cópia Mágica de Segurança.\n\nPor favor confirma que iniciaste sessão com a conta Apple correcta e que restauraste a tua cópia de segurança do iCloud mais recente.",
        ),
        "magic_setup_recovery_retry_header":
            MessageLookupByLibrary.simpleMessage(
          "A recuperar a tua carteira Envoy",
        ),
        "magic_setup_send_backup_to_envoy_server_heading":
            MessageLookupByLibrary.simpleMessage(
          "A Enviar a Tua Cópia de Segurança",
        ),
        "magic_setup_send_backup_to_envoy_server_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a enviar a tua cópia de segurança encriptada para os servidores da Foundation.\n\nUma vez que a tua cópia de segurança é encriptada ponta a ponta, a Foundation não tem acesso à mesma nem ao seu conteúdo.",
        ),
        "magic_setup_tutorial_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A forma mais fácil de criar uma carteira Bitcoin mantendo a tua soberania.\n\nA Cópia Mágica de Segurança guarda a tua carteira e definições na Cópia de Segurança do Android, 100 % encriptada ponta a ponta.\n\n[[Saber mais]].",
        ),
        "magic_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
          "Cópia Mágica de Segurança",
        ),
        "magic_setup_tutorial_ios_CTA1": MessageLookupByLibrary.simpleMessage(
          "Criar Cópia Mágica de Segurança",
        ),
        "magic_setup_tutorial_ios_CTA2": MessageLookupByLibrary.simpleMessage(
          "Recuperar Cópia Mágica de Segurança",
        ),
        "magic_setup_tutorial_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A forma mais fácil de criar uma carteira Bitcoin mantendo a tua soberania.\n\nA Cópia Mágica de Segurança faz automaticamente uma cópia de segurança da tua carteira e definições utilizando o Porta-chaves iCloud, 100 % encriptado ponta a ponta.\n\n[[Mais informação]].",
        ),
        "manage_account_address_card_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy gerará um novo endereço após o uso do endereço abaixo.",
        ),
        "manage_account_address_heading": MessageLookupByLibrary.simpleMessage(
          "DETALHES DA CONTA",
        ),
        "manage_account_descriptor_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Não partilhes este descritor, a menos que aceites que as tuas transacções fiquem públicas.",
        ),
        "manage_account_menu_editAccountName":
            MessageLookupByLibrary.simpleMessage(
          "EDITAR NOME DA CONTA",
        ),
        "manage_account_menu_showDescriptor":
            MessageLookupByLibrary.simpleMessage(
          "MOSTRAR DESCRITOR",
        ),
        "manage_account_remove_heading": MessageLookupByLibrary.simpleMessage(
          "Tens a certeza?",
        ),
        "manage_account_remove_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Esta acção apenas remove a conta da Envoy.",
        ),
        "manage_account_rename_heading": MessageLookupByLibrary.simpleMessage(
          "Renomear Conta",
        ),
        "manage_deviceDetailsModalDisconnectExistingPassport_content":
            MessageLookupByLibrary.simpleMessage(
          "Na versão actual, a Envoy só suporta uma ligação ao Passport Prime.\nIsto mudará numa próxima actualização, mas por agora tens de desligar o Passport Prime existente antes de configurares outro.",
        ),
        "manage_deviceDetailsModalDisconnectExistingPassport_disconnect":
            MessageLookupByLibrary.simpleMessage("Desligar"),
        "manage_deviceDetailsModalDisconnectExistingPassport_header":
            MessageLookupByLibrary.simpleMessage(
                "Desemparelhar Prime Existente"),
        "manage_deviceDetailsReconnectQL_reconnect":
            MessageLookupByLibrary.simpleMessage("Religar QuantumLink"),
        "manage_deviceDetailsUnpairedModalWarning_content":
            MessageLookupByLibrary.simpleMessage(
          "A ligação QuantumLink do teu Passport Prime {0} já não está disponível. Se apagaste o dispositivo ou desemparelhaste a Envoy recentemente, isto é esperado. Se não, contacta o apoio.\nA Envoy vai remover este dispositivo da lista de acessórios Bluetooth do teu telemóvel.",
        ),
        "manage_deviceDetailsUnpairedModalWarning_header":
            MessageLookupByLibrary.simpleMessage("QuantumLink Desligado"),
        "manage_deviceDetailsUnpairedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "O Passport Prime {0} foi desemparelhado. A Envoy vai removê-lo da lista de acessórios Bluetooth do teu telemóvel.",
        ),
        "manage_deviceDetailsUnpairedModal_header":
            MessageLookupByLibrary.simpleMessage("Passport Desemparelhado"),
        "manage_deviceDetailsUnpaired_pairAgain":
            MessageLookupByLibrary.simpleMessage("Emparelhar de Novo"),
        "manage_device_deletePassportWarning":
            MessageLookupByLibrary.simpleMessage(
          "Tens a certeza que queres desemparelhar o Passport?\nEsta operação vai remover o dispositivo da Envoy bem como qualquer conta associada.",
        ),
        "manage_device_details_QuantumLink":
            MessageLookupByLibrary.simpleMessage(
          "QuantumLink",
        ),
        "manage_device_details_active": MessageLookupByLibrary.simpleMessage(
          "Activo",
        ),
        "manage_device_details_devicePaired":
            MessageLookupByLibrary.simpleMessage(
          "Emparelhado",
        ),
        "manage_device_details_deviceSerial":
            MessageLookupByLibrary.simpleMessage(
          "Número de Série",
        ),
        "manage_device_details_disconnected":
            MessageLookupByLibrary.simpleMessage(
          "Desligado",
        ),
        "manage_device_details_heading": MessageLookupByLibrary.simpleMessage(
          "DETALHES DO DISPOSITIVO",
        ),
        "manage_device_details_inactive": MessageLookupByLibrary.simpleMessage(
          "Inactivo",
        ),
        "manage_device_details_menu_disconnectDevice":
            MessageLookupByLibrary.simpleMessage("Desligar"),
        "manage_device_details_menu_editDevice":
            MessageLookupByLibrary.simpleMessage("Editar Nome do Dispositivo"),
        "manage_device_details_menu_unpairPassport":
            MessageLookupByLibrary.simpleMessage("Desemparelhar Passport"),
        "manage_device_details_unpaired": MessageLookupByLibrary.simpleMessage(
          "Desemparelhado",
        ),
        "manage_device_rename_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Altera o nome do Passport",
        ),
        "manualToggleOnSeed_toastHeading_failedText":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível fazer a cópia de segurança. Por favor tenta novamente mais tarde.",
        ),
        "manual_coin_preselection_dialog_description":
            MessageLookupByLibrary.simpleMessage(
          "Isto anulará quaisquer alterações na selecção de moedas. Desejas continuar?",
        ),
        "manual_onboardDisableMB_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage("Carteira Existente"),
        "manual_onboardDisableMB_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy encontrou uma carteira na tua nuvem pessoal e vai recuperá-la agora. Para desactivar a Cópia Mágica de Segurança ou apagar permanentemente esta carteira, visita o menu Cópias de Segurança.",
        ),
        "manual_setup_change_from_magic_header":
            MessageLookupByLibrary.simpleMessage(
          "Cópias Mágicas de Segurança desativadas",
        ),
        "manual_setup_change_from_magic_modal_subheader":
            MessageLookupByLibrary.simpleMessage(
          "A tua Cópia Mágica de Segurança está prestes a ser apagada permanentemente. Garante que tens a tua semente bem guardada e que descarregas o teu ficheiro de cópia de segurança da Envoy.\n\nEsta ação vai eliminar permanentemente a tua semente Envoy da tua conta Apple ou Google e os teus dados Envoy encriptados dos servidores da Foundation após um período de espera de 24h.",
        ),
        "manual_setup_change_from_magic_subheaderApple":
            MessageLookupByLibrary.simpleMessage(
          "Os teus dados da Cópia Mágica de Segurança da Envoy foram eliminados com sucesso da tua conta Apple e dos servidores da Foundation.",
        ),
        "manual_setup_change_from_magic_subheaderGoogle":
            MessageLookupByLibrary.simpleMessage(
          "Os teus dados da Cópia Mágica de Segurança da Envoy foram eliminados com sucesso da tua conta Google e dos servidores da Foundation.",
        ),
        "manual_setup_create_and_store_backup_CTA":
            MessageLookupByLibrary.simpleMessage("Escolher Destino"),
        "manual_setup_create_and_store_backup_heading":
            MessageLookupByLibrary.simpleMessage(
          "Guardar Cópia de Segurança da Envoy",
        ),
        "manual_setup_create_and_store_backup_modal_CTA":
            MessageLookupByLibrary.simpleMessage("Compreendi"),
        "manual_setup_create_and_store_backup_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A tua Cópia de Segurança da Envoy é encriptada com as tuas palavras semente.\n\nSe perdes o acesso às mesmas, não será possível recuperar a tua cópia de segurança.",
        ),
        "manual_setup_create_and_store_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy gerou uma cópia de segurança encriptada da tua carteira. Esta cópia de segurança contém dados úteis da carteira, tais como Etiquetas, Notas, contas e definições.\n\nPodes escolher armazená-la na nuvem, num outro dispositivo ou numa opção de armazenamento externo como, por exemplo, um cartão microSD.",
        ),
        "manual_setup_generate_seed_CTA": MessageLookupByLibrary.simpleMessage(
          "Gerar Semente",
        ),
        "manual_setup_generate_seed_heading":
            MessageLookupByLibrary.simpleMessage(
          "Mantém a Semente Privada",
        ),
        "manual_setup_generate_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Mantém sempre privadas as tuas palavras semente. Quem tiver acesso a esta semente pode gastar as tuas Bitcoin!",
        ),
        "manual_setup_generate_seed_verify_seed_again_quiz_infotext":
            MessageLookupByLibrary.simpleMessage("Escolhe uma palavra"),
        "manual_setup_generate_seed_verify_seed_heading":
            MessageLookupByLibrary.simpleMessage(
                "Vamos Verificar a Tua Semente"),
        "manual_setup_generate_seed_verify_seed_quiz_1_4_heading":
            MessageLookupByLibrary.simpleMessage("Verifica a Semente"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_invalid":
            MessageLookupByLibrary.simpleMessage("Entrada Inválida"),
        "manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não foi capaz de verificar a tua semente. Por favor confirma que registaste correctamente a tua semente e tenta novamente.",
        ),
        "manual_setup_generate_seed_verify_seed_quiz_question":
            MessageLookupByLibrary.simpleMessage(
          "Qual é a tua palavra semente número",
        ),
        "manual_setup_generate_seed_verify_seed_quiz_success_correct":
            MessageLookupByLibrary.simpleMessage("Correcto"),
        "manual_setup_generate_seed_verify_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy irá fazer algumas questões para verificar que registaste correctamente a tua semente.",
        ),
        "manual_setup_generate_seed_write_words_24_heading":
            MessageLookupByLibrary.simpleMessage("Escreve Estas 24 Palavras"),
        "manual_setup_generate_seed_write_words_heading":
            MessageLookupByLibrary.simpleMessage("Escreve Estas 12 Palavras"),
        "manual_setup_generatingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("A Gerar a Semente"),
        "manual_setup_import_backup_CTA1": MessageLookupByLibrary.simpleMessage(
          "Criar Cópia de Segurança da Envoy",
        ),
        "manual_setup_import_backup_CTA2": MessageLookupByLibrary.simpleMessage(
          "Importar Cópia de Segurança da Envoy",
        ),
        "manual_setup_import_backup_fails_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível ler a Cópia de Segurança da Envoy",
        ),
        "manual_setup_import_backup_fails_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Certifica-te de que seleccionaste o ficheiro correcto.",
        ),
        "manual_setup_import_backup_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Gostarias de restaurar uma Cópia de Segurança da Envoy existente?\n\nEm caso negativo, a Envoy vai criar uma nova cópia de segurança encriptada.",
        ),
        "manual_setup_import_seed_12_words_fail_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Essa semente parece ser inválida. Por favor verifica as palavras introduzidas, incluindo a ordem em que se encontram e tenta novamente.",
        ),
        "manual_setup_import_seed_12_words_heading":
            MessageLookupByLibrary.simpleMessage("Introduz a Tua Semente"),
        "manual_setup_import_seed_CTA1": MessageLookupByLibrary.simpleMessage(
          "Importar através de código QR",
        ),
        "manual_setup_import_seed_CTA2": MessageLookupByLibrary.simpleMessage(
          "Semente de 24 Palavras",
        ),
        "manual_setup_import_seed_CTA3": MessageLookupByLibrary.simpleMessage(
          "Semente de 12 Palavras",
        ),
        "manual_setup_import_seed_checkbox":
            MessageLookupByLibrary.simpleMessage(
          "A minha semente tem frase-passe",
        ),
        "manual_setup_import_seed_heading":
            MessageLookupByLibrary.simpleMessage(
          "Importar a Tua Semente",
        ),
        "manual_setup_import_seed_passport_warning":
            MessageLookupByLibrary.simpleMessage(
          "Nunca importes a tua semente do Passport nos ecrãs seguintes.",
        ),
        "manual_setup_import_seed_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Escolhe uma das seguintes opções para importar uma semente existente.\n\nIrá ser possível importar uma Cópia de Segurança da Envoy mais tarde.",
        ),
        "manual_setup_importingSeedLoadingInfo":
            MessageLookupByLibrary.simpleMessage("A Importar a Semente"),
        "manual_setup_magicBackupDetected_heading":
            MessageLookupByLibrary.simpleMessage(
          "Cópia Mágica de Segurança Detectada",
        ),
        "manual_setup_magicBackupDetected_ignore":
            MessageLookupByLibrary.simpleMessage("Ignorar"),
        "manual_setup_magicBackupDetected_restore":
            MessageLookupByLibrary.simpleMessage("Restaurar"),
        "manual_setup_magicBackupDetected_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Foi encontrada uma Cópia Mágica de Segurança no servidor. \nRestaurar a tua cópia de segurança?",
        ),
        "manual_setup_recovery_fail_cta2": MessageLookupByLibrary.simpleMessage(
          "Importar Palavras Semente",
        ),
        "manual_setup_recovery_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível digitalizar o Código QR",
        ),
        "manual_setup_recovery_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Tenta digitalizar novamente ou, em alternativa, importa manualmente as tuas palavras semente.",
        ),
        "manual_setup_recovery_import_backup_modal_fail_connectivity_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Se continuares sem uma cópia de segurança, as definições da tua carteira, contas adicionais, Etiquetas e Notas não serão restauradas.",
        ),
        "manual_setup_recovery_import_backup_modal_fail_cta1":
            MessageLookupByLibrary.simpleMessage("Reintroduz a frase-passe"),
        "manual_setup_recovery_import_backup_modal_fail_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Escolher outra Cópia de Segurança",
        ),
        "manual_setup_recovery_import_backup_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao abrir esta Cópia de Segurança da Envoy",
        ),
        "manual_setup_recovery_import_backup_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Isto pode acontecer porque importaste um ficheiro de cópia de segurança de outra carteira Envoy, ou porque introduziste a frase-passe incorretamente.",
        ),
        "manual_setup_recovery_import_backup_re_enter_passphrase_heading":
            MessageLookupByLibrary.simpleMessage(
                "Reintroduz a tua\nfrase-passe"),
        "manual_setup_recovery_import_backup_re_enter_passphrase_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Reintroduz a tua frase-passe com cuidado para a Envoy abrir a cópia de segurança da Envoy.",
        ),
        "manual_setup_recovery_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Introduz a tua frase-passe"),
        "manual_setup_recovery_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Semente protegida por frase-passe. Introduz a frase-passe para importar a tua carteira Envoy.",
        ),
        "manual_setup_recovery_success_heading":
            MessageLookupByLibrary.simpleMessage("A importar a tua Semente"),
        "manual_setup_tutorial_CTA1": MessageLookupByLibrary.simpleMessage(
          "Gerar Nova Semente",
        ),
        "manual_setup_tutorial_CTA2": MessageLookupByLibrary.simpleMessage(
          "Importar Semente",
        ),
        "manual_setup_tutorial_heading": MessageLookupByLibrary.simpleMessage(
          "Configuração Manual da Semente",
        ),
        "manual_setup_tutorial_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Se preferes gerir as tuas próprias palavras semente, continua para importar ou criar uma nova semente.\n\nAtenção: és o único responsável pela gestão das cópias de segurança. Não serão utilizados serviços na nuvem.",
        ),
        "manual_setup_verify_enterYourPassphrase":
            MessageLookupByLibrary.simpleMessage("Introduz a tua frase-passe"),
        "manual_setup_verify_seed_12_words_enter_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Maiúsculas, minúsculas e espaços contam. Introduz com cuidado.",
        ),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_heading_2":
            MessageLookupByLibrary.simpleMessage(
          "As [[frases-passe]] são uma opção avançada.",
        ),
        "manual_setup_verify_seed_12_words_passphrase_warning_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Se não percebes as implicações de usar uma frase-passe, fecha esta caixa e continua sem ela.\n\nA Foundation não tem forma de recuperar uma frase-passe perdida ou incorreta.",
        ),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_heading":
            MessageLookupByLibrary.simpleMessage("Confirma a tua frase-passe"),
        "manual_setup_verify_seed_12_words_verify_passphrase_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Reintroduz a tua frase-passe com cuidado.",
        ),
        "manual_toggle_off_disabled_for_manual_seed_configuration":
            MessageLookupByLibrary.simpleMessage(
          "Desactivada para Configuração Manual da Semente",
        ),
        "manual_toggle_off_download_wallet_data":
            MessageLookupByLibrary.simpleMessage(
          "Descarregar Cópia de Segurança da Envoy",
        ),
        "manual_toggle_off_view_wallet_seed":
            MessageLookupByLibrary.simpleMessage(
          "Ver Semente da Envoy",
        ),
        "manual_toggle_on_seed_backedup_android_stored":
            MessageLookupByLibrary.simpleMessage(
          "Armazenada na Cópia de Segurança do Android",
        ),
        "manual_toggle_on_seed_backedup_android_wallet_data":
            MessageLookupByLibrary.simpleMessage("Cópia de Segurança da Envoy"),
        "manual_toggle_on_seed_backedup_android_wallet_seed":
            MessageLookupByLibrary.simpleMessage("Semente da Envoy"),
        "manual_toggle_on_seed_backedup_iOS_backup_now":
            MessageLookupByLibrary.simpleMessage("Executar"),
        "manual_toggle_on_seed_backedup_iOS_stored_in_cloud":
            MessageLookupByLibrary.simpleMessage(
          "Cópia feita no Porta-chaves iCloud",
        ),
        "manual_toggle_on_seed_backedup_iOS_toFoundationServers":
            MessageLookupByLibrary.simpleMessage(
                "para Servidores da Foundation"),
        "manual_toggle_on_seed_backingup": MessageLookupByLibrary.simpleMessage(
          "A fazer cópia…",
        ),
        "manual_toggle_on_seed_backup_in_progress_ios_backup_in_progress":
            MessageLookupByLibrary.simpleMessage("Cópia em Curso"),
        "manual_toggle_on_seed_backup_in_progress_toast_heading":
            MessageLookupByLibrary.simpleMessage(
          "A Cópia de Segurança da Envoy foi concluída.",
        ),
        "manual_toggle_on_seed_backup_now_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "A Enviar a Cópia de Segurança da Envoy",
        ),
        "manual_toggle_on_seed_backup_now_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Esta cópia de segurança contém dispositivos e contas ligados, etiquetas e definições da aplicação. Não contém informações relativas à chave privada.\n\nAs Cópias de Segurança da Envoy são encriptadas ponta a ponta e a Foundation não tem acesso ou conhecimento do seu conteúdo. \n\nA Envoy notificar-te-á quando o envio estiver concluído.",
        ),
        "manual_toggle_on_seed_not_backedup_android_open_settings":
            MessageLookupByLibrary.simpleMessage("Definições"),
        "manual_toggle_on_seed_not_backedup_pending_android_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
          "Cópia de Segurança do Android pendente (uma vez por dia)",
        ),
        "manual_toggle_on_seed_not_backedup_pending_iOS_seed_pending_backup":
            MessageLookupByLibrary.simpleMessage(
          "Cópia pendente no Porta-chaves iCloud",
        ),
        "manual_toggle_on_seed_uploading_foundation_servers":
            MessageLookupByLibrary.simpleMessage(
          "A Enviar para Servidores da Foundation",
        ),
        "menu_about": MessageLookupByLibrary.simpleMessage("Sobre"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("Cópias de segurança"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_privacy": MessageLookupByLibrary.simpleMessage("Privacidade"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("Definições"),
        "menu_support": MessageLookupByLibrary.simpleMessage("Apoio técnico"),
        "menu_toast_accountAlreadyConnected":
            MessageLookupByLibrary.simpleMessage(
          "Conta já associada.",
        ),
        "menu_toast_couldntDeleteEnvoySeed":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao eliminar a semente da Envoy.",
        ),
        "menu_toast_developerModeEnabled": MessageLookupByLibrary.simpleMessage(
          "Modo Programador Activo.",
        ),
        "menu_toast_envoySeedDeleted": MessageLookupByLibrary.simpleMessage(
          "Semente da Envoy eliminada.",
        ),
        "menu_toast_logsCopied": MessageLookupByLibrary.simpleMessage(
          "Registos copiados.",
        ),
        "menu_toast_securityCheckDisabled":
            MessageLookupByLibrary.simpleMessage(
          "Verificação de segurança desactivada",
        ),
        "menu_toast_unexpectedError": MessageLookupByLibrary.simpleMessage(
          "Ocorreu um erro inesperado. Tenta novamente.",
        ),
        "onboardin_unifiedAccountsModal_content":
            MessageLookupByLibrary.simpleMessage(
          "A partir da versão 2.0.0, todos os tipos de endereço estão agora acessíveis num único cartão de conta.\n\nO tipo de endereço de receção predefinido pode ser alterado em Definições.",
        ),
        "onboardin_unifiedAccountsModal_tilte":
            MessageLookupByLibrary.simpleMessage(
                "Tipos de Endereço Unificados"),
        "onboarding_advancedModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Se continuares sem Cópias Mágicas de Segurança, ficas responsável por guardar as tuas palavras semente e os dados da cópia de segurança.",
        ),
        "onboarding_advancedModal_header": MessageLookupByLibrary.simpleMessage(
          "Tens a certeza?",
        ),
        "onboarding_advanced_magicBackupSwitchText":
            MessageLookupByLibrary.simpleMessage(
          "Cópia e recuperação simples e seguras",
        ),
        "onboarding_advanced_magicBackups":
            MessageLookupByLibrary.simpleMessage(
          "Cópia Mágica de Segurança",
        ),
        "onboarding_advanced_magicBackupsContent":
            MessageLookupByLibrary.simpleMessage(
          "Cópias de segurança encriptadas automáticas dos teus dados, para recuperação imediata e sem stress.",
        ),
        "onboarding_advanced_title": MessageLookupByLibrary.simpleMessage(
          "Avançado",
        ),
        "onboarding_appclip_header": MessageLookupByLibrary.simpleMessage(
          "Bem-Vindo ao Passport",
        ),
        "onboarding_appclip_subheaderCore":
            MessageLookupByLibrary.simpleMessage(
          "Instala a Envoy para configurar o Passport Core.",
        ),
        "onboarding_appclip_subheaderPrime":
            MessageLookupByLibrary.simpleMessage(
          "Instala a Envoy para configurar o Passport Prime.",
        ),
        "onboarding_bluetoothDisabled_content":
            MessageLookupByLibrary.simpleMessage(
          "O Passport Prime precisa de Bluetooth para a configuração inicial com o QuantumLink. Isto permite sincronizar data e hora, atualizações de firmware, verificações de segurança, cópias de segurança e muito mais.\n\nAtiva as permissões de Bluetooth nas Definições da Envoy.",
        ),
        "onboarding_bluetoothDisabled_enable":
            MessageLookupByLibrary.simpleMessage(
          "Ativar em Definições",
        ),
        "onboarding_bluetoothDisabled_header":
            MessageLookupByLibrary.simpleMessage(
          "Ativa o Bluetooth para Ligar por QuantumLink",
        ),
        "onboarding_bluetoothIntro_connect":
            MessageLookupByLibrary.simpleMessage(
          "Ligar via QuantumLink",
        ),
        "onboarding_bluetoothIntro_content":
            MessageLookupByLibrary.simpleMessage(
          "O Passport Prime usa um novo protocolo seguro, baseado em Bluetooth, para comunicação em tempo real com a Envoy.\n\nO QuantumLink cria um túnel encriptado ponta a ponta entre o Passport e a Envoy, garantindo uma ligação segura.",
        ),
        "onboarding_bluetoothIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Protege o Bluetooth com\nQuantumLink",
        ),
        "onboarding_connectionChecking_SecurityPassed":
            MessageLookupByLibrary.simpleMessage("Verificação de Segurança OK"),
        "onboarding_connectionChecking_forUpdates":
            MessageLookupByLibrary.simpleMessage("A Procurar Atualizações"),
        "onboarding_connectionIntroError2_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy não conseguiu ligar aos servidores da Foundation. Verifica a ligação à Internet.",
        ),
        "onboarding_connectionIntroErrorInternet_content":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível comunicar com o servidor de segurança. Verifica a Internet e tenta novamente.",
        ),
        "onboarding_connectionIntroErrorInternet_securityCheckIncomplete":
            MessageLookupByLibrary.simpleMessage(
          "Verificação de Segurança Incompleta",
        ),
        "onboarding_connectionIntroErrorInternet_securityCheckPending":
            MessageLookupByLibrary.simpleMessage(
          "Verificação de Segurança Pendente",
        ),
        "onboarding_connectionIntroErrorSecurityIncomplete_content":
            MessageLookupByLibrary.simpleMessage(
          "Mantém o Passport por perto, verifica a tua ligação à internet e certifica-te de que a data e a hora do teu telemóvel estão definidas automaticamente. Depois, tenta novamente.",
        ),
        "onboarding_connectionIntroError_content":
            MessageLookupByLibrary.simpleMessage(
          "Este dispositivo pode não ser autêntico ou pode ter sido manipulado durante o envio. Contacta o suporte para obter ajuda.",
        ),
        "onboarding_connectionIntroError_exitSetup":
            MessageLookupByLibrary.simpleMessage("Sair da Configuração"),
        "onboarding_connectionIntroError_securityCheckFailed":
            MessageLookupByLibrary.simpleMessage(
          "Verificação de Segurança Falhada",
        ),
        "onboarding_connectionIntroError_securityCheckPending":
            MessageLookupByLibrary.simpleMessage(
          "Verificação de Segurança Pendente",
        ),
        "onboarding_connectionIntroWarning_content":
            MessageLookupByLibrary.simpleMessage(
          "Garante que o Passport Prime está ligado e perto do teu telemóvel.",
        ),
        "onboarding_connectionIntroWarning_header":
            MessageLookupByLibrary.simpleMessage("Configuração em Pausa"),
        "onboarding_connectionIntro_checkForUpdates":
            MessageLookupByLibrary.simpleMessage("Procurar Atualizações"),
        "onboarding_connectionIntro_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage(
          "A Verificar Segurança do Dispositivo",
        ),
        "onboarding_connectionIntro_connectedToPrime":
            MessageLookupByLibrary.simpleMessage("Ligado ao Passport Prime"),
        "onboarding_connectionIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Passport Prime Ligado",
        ),
        "onboarding_connectionModalAbort_content":
            MessageLookupByLibrary.simpleMessage(
          "Continua só se quiseres perder todo o progresso e reiniciar a configuração do Passport.",
        ),
        "onboarding_connectionModalAbort_header":
            MessageLookupByLibrary.simpleMessage("Sair da Configuração?"),
        "onboarding_connectionModalExitOnboarding_content":
            MessageLookupByLibrary.simpleMessage(
          "Isto apagará todo o progresso. Terás de iniciar a configuração do Passport Prime do início.",
        ),
        "onboarding_connectionModalExitOnboarding_header":
            MessageLookupByLibrary.simpleMessage("Sair da Configuração?"),
        "onboarding_connectionNoUpdates_noUpdates":
            MessageLookupByLibrary.simpleMessage(
                "Sem Atualizações Disponíveis"),
        "onboarding_connectionUpdatesAvailable_updatesAvailable":
            MessageLookupByLibrary.simpleMessage("Nova Atualização Disponível"),
        "onboarding_magicUserMobileCreating_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a criar uma chave segura para usar com a tua Carteira Móvel de Bitcoin, que será guardada encriptada de ponta a ponta na tua conta Apple ou Google.",
        ),
        "onboarding_magicUserMobileCreating_header":
            MessageLookupByLibrary.simpleMessage(
                "A Criar Chave da Carteira Móvel"),
        "onboarding_magicUserMobileEncrypting_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a encriptar a cópia de segurança da tua carteira.\n\nEsta cópia de segurança contém dados úteis da carteira, tais como etiquetas, notas, contas e definições.",
        ),
        "onboarding_magicUserMobileEncrypting_header":
            MessageLookupByLibrary.simpleMessage(
          "A Encriptar a Cópia de Segurança",
        ),
        "onboarding_magicUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
          "Também conhecida como uma “hot wallet”. Gastar a partir desta carteira só requer o teu telemóvel para autorizar.",
        ),
        "onboarding_magicUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
          "A Chave da Carteira Móvel fica no enclave seguro do telemóvel, encriptada e copiada para a tua conta Apple ou Google.",
        ),
        "onboarding_magicUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage(
          "Configurar Carteira Móvel com Cópias Mágicas de Segurança",
        ),
        "onboarding_magicUserMobileIntro_learnMoreMagicBackups":
            MessageLookupByLibrary.simpleMessage(
          "Mais informação sobre Cópias Mágicas",
        ),
        "onboarding_magicUserMobileSuccess_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está configurada e pronta para a tua Bitcoin!",
        ),
        "onboarding_magicUserMobileSuccess_header":
            MessageLookupByLibrary.simpleMessage(
          "A Tua Carteira Móvel Está Pronta",
        ),
        "onboarding_magicUserMobileUploading_content":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a enviar a tua cópia de segurança encriptada para os servidores da Foundation.\n\nUma vez que a tua cópia de segurança é encriptada ponta a ponta, a Foundation não tem acesso à mesma nem ao seu conteúdo.",
        ),
        "onboarding_magicUserMobileUploading_header":
            MessageLookupByLibrary.simpleMessage(
          "A Enviar a Tua Cópia de Segurança",
        ),
        "onboarding_migrating_xOfYSynced": m12,
        "onboarding_modalBluetoothUnableConnect_content":
            MessageLookupByLibrary.simpleMessage(
          "Garante que o Bluetooth está activo no Passport e no telemóvel, e que ambos estão perto.",
        ),
        "onboarding_modalBluetoothUnableConnect_header":
            MessageLookupByLibrary.simpleMessage("Não Foi Possível Ligar"),
        "onboarding_passpportSelectCamera_sub235VersionAlert":
            MessageLookupByLibrary.simpleMessage(
          "Estás a configurar um Passport Core com firmware v2.3.5 ou anterior?",
        ),
        "onboarding_passpportSelectCamera_tapHere":
            MessageLookupByLibrary.simpleMessage("Toca aqui"),
        "onboarding_primeIntroError_content":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível ligar à Internet. Verifica a ligação.",
        ),
        "onboarding_primeIntro_content": MessageLookupByLibrary.simpleMessage(
          "Parabéns por dares o primeiro passo para proteger toda a tua vida digital.\n\nConfigurar o teu Passport Prime demora só 5-10 minutos. Pega no dispositivo e vamos começar!",
        ),
        "onboarding_primeIntro_header": MessageLookupByLibrary.simpleMessage(
          "Configura o Teu Passport Prime",
        ),
        "onboarding_sovereignUserMobileIntro_content1":
            MessageLookupByLibrary.simpleMessage(
          "Também conhecida como uma “hot wallet”. Gastar a partir desta carteira só requer o teu telemóvel para autorizar.",
        ),
        "onboarding_sovereignUserMobileIntro_content2":
            MessageLookupByLibrary.simpleMessage(
          "As tuas chaves de Bitcoin serão guardadas no enclave seguro do teu telemóvel. Só tu és responsável por manter uma cópia de segurança da tua semente.",
        ),
        "onboarding_sovereignUserMobileIntro_header":
            MessageLookupByLibrary.simpleMessage("Configurar Carteira Móvel"),
        "onboarding_tutorialColdWallet_content":
            MessageLookupByLibrary.simpleMessage(
          "Também conhecida como uma “cold wallet”. Gastar desta carteira requer autorização do teu dispositivo Passport. \n\nA Chave Mestra do teu Passport é sempre guardada em segurança, offline.\n\nUsa esta carteira para proteger a maior parte das tuas poupanças em Bitcoin.",
        ),
        "onboarding_tutorialColdWallet_header":
            MessageLookupByLibrary.simpleMessage("Carteira Passport"),
        "onboarding_tutorialHotWallet_content":
            MessageLookupByLibrary.simpleMessage(
          "Também conhecida como uma “hot wallet.” Gastar desta carteira requer apenas o teu telemóvel para autorização.\n\nComo a tua Carteira Móvel está ligada à Internet, usa esta carteira para guardar pequenas quantias de Bitcoin para transacções frequentes.",
        ),
        "onboarding_tutorialHotWallet_header":
            MessageLookupByLibrary.simpleMessage(
          "Carteira Móvel",
        ),
        "onboarding_welcome_content": MessageLookupByLibrary.simpleMessage(
          "Recupera o controlo com a Envoy, uma carteira de Bitcoin simples com poderosa gestão de contas e funcionalidades de privacidade.",
        ),
        "onboarding_welcome_createMobileWallet":
            MessageLookupByLibrary.simpleMessage("Criar uma \nCarteira Móvel"),
        "onboarding_welcome_header": MessageLookupByLibrary.simpleMessage(
          "Bem-Vindo à Envoy",
        ),
        "onboarding_welcome_setUpPassport":
            MessageLookupByLibrary.simpleMessage(
          "Configurar um \nDispositivo Passport",
        ),
        "pair_existing_device_intro_heading":
            MessageLookupByLibrary.simpleMessage(
          "Ligar o Passport\nà Envoy",
        ),
        "pair_existing_device_intro_subheading":
            MessageLookupByLibrary.simpleMessage(
          "No Passport, selecciona Gerir Conta > Ligar Carteira > Envoy.",
        ),
        "pair_new_device_QR_code_heading": MessageLookupByLibrary.simpleMessage(
          "Digitaliza este código QR com o Passport para validar",
        ),
        "pair_new_device_QR_code_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Este endereço Bitcoin pertence ao teu Passport.",
        ),
        "pair_new_device_address_cta2": MessageLookupByLibrary.simpleMessage(
          "Contactar Apoio Técnico",
        ),
        "pair_new_device_address_heading": MessageLookupByLibrary.simpleMessage(
          "Endereço validado?",
        ),
        "pair_new_device_address_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Se recebeste uma mensagem de sucesso no Passport, a configuração está concluída.\n\nSe o Passport não conseguiu validar o endereço, por favor tenta novamente ou entra em contacto com o apoio técnico.",
        ),
        "pair_new_device_intro_connect_envoy_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Este passo permite à Envoy gerar endereços de recepção para o Passport e propor transacções para envio que o Passport tem de autorizar.",
        ),
        "pair_new_device_scan_heading": MessageLookupByLibrary.simpleMessage(
          "Digitaliza o código QR que o Passport gerou",
        ),
        "pair_new_device_scan_subheading": MessageLookupByLibrary.simpleMessage(
          "O código QR contém a informação necessária para a Envoy interagir de forma segura com o Passport.",
        ),
        "pair_new_device_success_cta1": MessageLookupByLibrary.simpleMessage(
          "Validar endereço de recepção",
        ),
        "pair_new_device_success_cta2": MessageLookupByLibrary.simpleMessage(
          "Continuar para o ecrã principal",
        ),
        "pair_new_device_success_heading": MessageLookupByLibrary.simpleMessage(
          "Ligação bem-sucedida",
        ),
        "pair_new_device_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está ligada ao teu Passport.",
        ),
        "passport_welcome_screen_cta1": MessageLookupByLibrary.simpleMessage(
          "Configurar um novo Passport",
        ),
        "passport_welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Ligar a um Passport existente",
        ),
        "passport_welcome_screen_cta3": MessageLookupByLibrary.simpleMessage(
          "Não tenho Passport. [[Mais informação.]]",
        ),
        "passport_welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Bem-Vindo ao Passport",
        ),
        "passport_welcome_screen_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy oferece configuração segura do Passport, actualizações fáceis de firmware e uma carteira Bitcoin serena.",
        ),
        "prime_info_color": m13,
        "prime_info_firmware": m14,
        "prime_info_serialNumber": m15,
        "privacySetting_nodeConnected": MessageLookupByLibrary.simpleMessage(
          "Nó Ligado",
        ),
        "privacy_applicationLock_title": MessageLookupByLibrary.simpleMessage(
          "Bloqueio da aplicação",
        ),
        "privacy_applicationLock_unlock": MessageLookupByLibrary.simpleMessage(
          "Desbloquear com biometria ou PIN",
        ),
        "privacy_blockExplorer_couldNotReachBlockExplorer":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível ligar ao Explorador de Blocos",
        ),
        "privacy_blockExplorer_success": MessageLookupByLibrary.simpleMessage(
          "Ligação ao Explorador de Blocos concluída",
        ),
        "privacy_blockExplorer_urlError": MessageLookupByLibrary.simpleMessage(
          "Falta prefixo http:// ou https:// no URL",
        ),
        "privacy_explorer_configure": MessageLookupByLibrary.simpleMessage(
          "Melhora a tua privacidade ao ligares-te ao teu próprio explorador de blocos. Toca em Mais informação acima.",
        ),
        "privacy_explorer_explorerAddress":
            MessageLookupByLibrary.simpleMessage(
          "Endereço do explorador",
        ),
        "privacy_explorer_explorerType_personal":
            MessageLookupByLibrary.simpleMessage(
                "Explorador de Blocos Pessoal"),
        "privacy_explorer_title": MessageLookupByLibrary.simpleMessage(
          "Explorador de Blocos",
        ),
        "privacy_invalidCertificateModal_connectAnyway":
            MessageLookupByLibrary.simpleMessage("Ligar Mesmo Assim"),
        "privacy_invalidCertificateModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Este nó tem um certificado inválido ou autoassinado. A ligação pode não ser segura.\nQueres ligar mesmo assim?",
        ),
        "privacy_invalidCertificateModal_header":
            MessageLookupByLibrary.simpleMessage("Certificado Inválido"),
        "privacy_node_configure": MessageLookupByLibrary.simpleMessage(
          "Aumenta a tua privacidade ao correres o teu próprio nó. Toca em mais informação acima. ",
        ),
        "privacy_node_configure_blockHeight":
            MessageLookupByLibrary.simpleMessage(
          "Altura do bloco:",
        ),
        "privacy_node_configure_connectedToEsplora":
            MessageLookupByLibrary.simpleMessage("Ligado ao servidor Esplora"),
        "privacy_node_configure_noConnectionEsplora":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível ligar ao servidor Esplora.",
        ),
        "privacy_node_connectedTo": MessageLookupByLibrary.simpleMessage(
          "Ligado a",
        ),
        "privacy_node_connection_couldNotReach":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível estabelecer uma ligação ao nó.",
        ),
        "privacy_node_connection_localAddress_warning":
            MessageLookupByLibrary.simpleMessage(
          "Mesmo com a opção ‘Privacidade Melhorada’ activada, a Envoy não pode impedir a interferência de dispositivos comprometidos na tua rede local.",
        ),
        "privacy_node_nodeAddress": MessageLookupByLibrary.simpleMessage(
          "Introduz o endereço do teu nó",
        ),
        "privacy_node_nodeType_foundation":
            MessageLookupByLibrary.simpleMessage(
          "Foundation (Predefinido)",
        ),
        "privacy_node_nodeType_personal": MessageLookupByLibrary.simpleMessage(
          "Nó Pessoal",
        ),
        "privacy_node_nodeType_publicServers":
            MessageLookupByLibrary.simpleMessage(
          "Servidores públicos",
        ),
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Nó"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Desempenho\nMelhorado"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage(
          "Privacidade\nMelhorada",
        ),
        "privacy_privacyMode_title": MessageLookupByLibrary.simpleMessage(
          "Modo de privacidade",
        ),
        "privacy_privacyMode_torSuggestionOff":
            MessageLookupByLibrary.simpleMessage(
          "A ligação da Envoy vai ser estável com o Tor [[DESLIGADO]]. Recomendado para novos utilizadores.",
        ),
        "privacy_privacyMode_torSuggestionOn":
            MessageLookupByLibrary.simpleMessage(
          "O Tor será [[LIGADO]] para melhorar a privacidade. A ligação da Envoy poderá ficar instável.",
        ),
        "privacy_setting_add_node_modal_heading":
            MessageLookupByLibrary.simpleMessage("Adicionar Nó"),
        "privacy_setting_clearnet_node_edit_note":
            MessageLookupByLibrary.simpleMessage("Editar Nó"),
        "privacy_setting_clearnet_node_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O teu Nó está ligado via Clearnet.",
        ),
        "privacy_setting_connecting_node_fails_modal_failed":
            MessageLookupByLibrary.simpleMessage(
                "Não conseguimos ligar ao teu nó"),
        "privacy_setting_connecting_node_modal_cta":
            MessageLookupByLibrary.simpleMessage("Ligar"),
        "privacy_setting_connecting_node_modal_loading":
            MessageLookupByLibrary.simpleMessage("A Ligar ao Teu Nó"),
        "privacy_setting_onion_node_sbheading":
            MessageLookupByLibrary.simpleMessage(
                "O teu Nó está ligado via Tor."),
        "privacy_setting_perfomance_heading":
            MessageLookupByLibrary.simpleMessage(
          "Escolhe a Tua Privacidade",
        ),
        "privacy_setting_perfomance_subheading":
            MessageLookupByLibrary.simpleMessage(
          "De que forma é que gostarias que a Envoy se ligasse à Internet?",
        ),
        "qrTooBig_warning_subheading": MessageLookupByLibrary.simpleMessage(
          "O código QR digitalizado contém uma grande quantidade de dados e pode tornar a Envoy instável. Tens a certeza de que desejas continuar?",
        ),
        "ramp_note": MessageLookupByLibrary.simpleMessage("Compra da Ramp"),
        "ramp_pendingVoucher": MessageLookupByLibrary.simpleMessage(
          "Compra da Ramp Pendente",
        ),
        "receive_QR_code_receive_QR_code_taproot_on_taproot_toggle":
            MessageLookupByLibrary.simpleMessage("Usar Endereço Taproot"),
        "receive_mobileWallet_multiplePassportContent":
            MessageLookupByLibrary.simpleMessage(
          "Fundos enviados para este endereço só podem ser gastos pelo teu telemóvel. Para os proteger offline, escolhe uma conta Passport [[aqui]].",
        ),
        "receive_mobileWallet_singlePassportContent":
            MessageLookupByLibrary.simpleMessage(
          "Fundos enviados para este endereço só podem ser gastos pelo teu telemóvel. Para os proteger offline com o Passport, [[toca aqui]].",
        ),
        "receive_qr_code_heading":
            MessageLookupByLibrary.simpleMessage("RECEBER"),
        "receive_qr_copy": MessageLookupByLibrary.simpleMessage("Copiar"),
        "receive_qr_rescanAccount": MessageLookupByLibrary.simpleMessage(
          "Reanalisar Conta",
        ),
        "receive_qr_share": MessageLookupByLibrary.simpleMessage("Partilhar"),
        "receive_qr_signMessage": MessageLookupByLibrary.simpleMessage(
          "Assinar Mensagem",
        ),
        "receive_toast_addressCopied": MessageLookupByLibrary.simpleMessage(
          "Endereço copiado.",
        ),
        "receive_tx_list_awaitingConfirmation":
            MessageLookupByLibrary.simpleMessage("A aguardar confirmação"),
        "receive_tx_list_change": MessageLookupByLibrary.simpleMessage("Troco"),
        "receive_tx_list_receive":
            MessageLookupByLibrary.simpleMessage("Receber"),
        "receive_tx_list_scan": MessageLookupByLibrary.simpleMessage("Ler QR"),
        "receive_tx_list_send": MessageLookupByLibrary.simpleMessage("Enviar"),
        "receive_tx_list_transfer":
            MessageLookupByLibrary.simpleMessage("Mover"),
        "receive_verifyModalCore_content": m16,
        "receive_verifyModalPrime_content": m17,
        "recovery_scenario_Android_instruction1":
            MessageLookupByLibrary.simpleMessage(
          "Inicia sessão no Google e restaura os dados da tua cópia de segurança",
        ),
        "recovery_scenario_heading": MessageLookupByLibrary.simpleMessage(
          "Como Recuperar?",
        ),
        "recovery_scenario_instruction2": MessageLookupByLibrary.simpleMessage(
          "Instala a Envoy e carrega em “Configurar a Carteira Envoy”",
        ),
        "recovery_scenario_ios_instruction1":
            MessageLookupByLibrary.simpleMessage(
          "Inicia sessão no iCloud e restaura a tua cópia de segurança",
        ),
        "recovery_scenario_ios_instruction3":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy irá restaurar automaticamente a tua Cópia Mágica de Segurança",
        ),
        "recovery_scenario_subheading": MessageLookupByLibrary.simpleMessage(
          "Para recuperar a tua carteira Envoy, segue estas simples instruções.",
        ),
        "replaceByFee_boost_chosenFeeAddCoinsWarning":
            MessageLookupByLibrary.simpleMessage(
          "A taxa escolhida só pode ser atingida adicionando mais moedas. A Envoy faz esse processo de forma automática e nunca irá incluir moedas bloqueadas.",
        ),
        "replaceByFee_boost_confirm_heading":
            MessageLookupByLibrary.simpleMessage(
          "A reforçar transacção",
        ),
        "replaceByFee_boost_fail_header": MessageLookupByLibrary.simpleMessage(
          "Não foi possível reforçar a tua transacção",
        ),
        "replaceByFee_boost_reviewCoinSelection":
            MessageLookupByLibrary.simpleMessage("Rever Selecção de Moedas"),
        "replaceByFee_boost_success_header":
            MessageLookupByLibrary.simpleMessage(
          "A tua transacção foi reforçada",
        ),
        "replaceByFee_boost_tx_boostFee": MessageLookupByLibrary.simpleMessage(
          "Taxa de Reforço",
        ),
        "replaceByFee_boost_tx_heading": MessageLookupByLibrary.simpleMessage(
          "A tua transacção está pronta\npara ser reforçada",
        ),
        "replaceByFee_cancelAmountNone_None":
            MessageLookupByLibrary.simpleMessage(
          "Nenhuma",
        ),
        "replaceByFee_cancelAmountNone_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A taxa de rede para cancelar esta transacção significa que não serão devolvidos fundos à tua carteira.\n\nTens a certeza que pretendes cancelar?",
        ),
        "replaceByFee_cancel_confirm_heading":
            MessageLookupByLibrary.simpleMessage(
          "A cancelar a transacção",
        ),
        "replaceByFee_cancel_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível cancelar a tua transacção",
        ),
        "replaceByFee_cancel_overlay_modal_cancelationFees":
            MessageLookupByLibrary.simpleMessage("Taxa de Anulação"),
        "replaceByFee_cancel_overlay_modal_proceedWithCancelation":
            MessageLookupByLibrary.simpleMessage("Proceder com o Cancelamento"),
        "replaceByFee_cancel_overlay_modal_receivingAmount":
            MessageLookupByLibrary.simpleMessage("Quantia a Receber"),
        "replaceByFee_cancel_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Substitui a transacção não confirmada por outra que contenha uma taxa mais elevada e envie os fundos de volta para a tua carteira.",
        ),
        "replaceByFee_cancel_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "A tua transacção foi cancelada",
        ),
        "replaceByFee_cancel_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Esta é uma tentativa de cancelamento. Há uma pequena possibilidade de a transacção original ser confirmada antes de esta tentativa de cancelamento ocorrer.",
        ),
        "replaceByFee_coindetails_overlayNotice":
            MessageLookupByLibrary.simpleMessage(
          "As funções Reforçar e Cancelar vão estar disponíveis depois de a transacção terminar de ser difundida.",
        ),
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Reforçar"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Reforçar Transacção"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Aumenta a taxa associada à tua transacção para acelerares o tempo de confirmação.",
        ),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Exigido para Reforço"),
        "replaceByFee_modal_deletedInactiveTX_ramp_heading":
            MessageLookupByLibrary.simpleMessage("Transacções Removidas"),
        "replaceByFee_modal_deletedInactiveTX_ramp_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Compras incompletas com as seguintes identificações Ramp foram removidas da atividade após 5 dias.",
        ),
        "replaceByFee_newFee_modal_heading":
            MessageLookupByLibrary.simpleMessage(
          "Nova Taxa de Transacção",
        ),
        "replaceByFee_newFee_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para reforçar a transacção original, estás prestes a pagar uma nova taxa de:",
        ),
        "replaceByFee_newFee_modal_subheading_replacing":
            MessageLookupByLibrary.simpleMessage(
          "Isto vai substituir a taxa original de:",
        ),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
          "Compras incompletas serão automaticamente removidas após 5 dias",
        ),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A taxa escolhida só pode ser atingida adicionando mais moedas. A Envoy faz essa operação automaticamente e nunca irá incluir moedas bloqueadas. \n\nEsta selecção pode ser revista ou editada no ecrã seguinte.",
        ),
        "rescanAccount_pullToSync_pullToSync":
            MessageLookupByLibrary.simpleMessage(
          "Puxa p/ sincronizar",
        ),
        "rescanAccount_rescanning_rescanningAccount":
            MessageLookupByLibrary.simpleMessage(
          "A reanalisar a tua conta. Não feches a Envoy.",
        ),
        "rescanAccount_sizeModal_1000Addresses":
            MessageLookupByLibrary.simpleMessage("1000 Endereços (~10 min)"),
        "rescanAccount_sizeModal_300Addresses":
            MessageLookupByLibrary.simpleMessage("300 Endereços (~3 min)"),
        "rescanAccount_sizeModal_500Addresses":
            MessageLookupByLibrary.simpleMessage("500 Endereços (~5 min)"),
        "rescanAccount_sizeModal_content": MessageLookupByLibrary.simpleMessage(
          "100 endereços foram analisados antes. Se faltam fundos, tenta um valor maior.",
        ),
        "rescanAccount_sizeModal_header": MessageLookupByLibrary.simpleMessage(
          "Reanalisar Conta",
        ),
        "rescanAccount_toast_rescanningFailed": m18,
        "rescanAccount_toast_rescanningStarted":
            MessageLookupByLibrary.simpleMessage(
          "Reanálise iniciada. Não feches a Envoy.",
        ),
        "rescanAccount_toast_rescanningSuccessful": m19,
        "scanner_toast_failedConnectPrime":
            MessageLookupByLibrary.simpleMessage(
          "Falha ao ligar ao Passport Prime. Tenta novamente e contacta o apoio se o problema persistir.",
        ),
        "scanner_toast_notValidQr": MessageLookupByLibrary.simpleMessage(
          "QR inválido.",
        ),
        "scv_cameraModalUnexpectedQrFormat_content":
            MessageLookupByLibrary.simpleMessage(
          "Garante que estás a digitalizar um código QR de verificação de segurança do Passport.",
        ),
        "scv_cameraModalUnexpectedQrFormat_header":
            MessageLookupByLibrary.simpleMessage("Formato QR Inesperado"),
        "scv_checkingDeviceSecurity": MessageLookupByLibrary.simpleMessage(
          "A Verificar Segurança do Dispositivo",
        ),
        "send_QrReview_viewDetails": MessageLookupByLibrary.simpleMessage(
          "Ver Detalhes",
        ),
        "send_QrScan_saveToFile": MessageLookupByLibrary.simpleMessage(
          "Guardar em Ficheiro",
        ),
        "send_build_amount": MessageLookupByLibrary.simpleMessage("Quantia"),
        "send_build_header": MessageLookupByLibrary.simpleMessage(
          "Verificar Detalhes da Transacção",
        ),
        "send_build_subheader": MessageLookupByLibrary.simpleMessage(
          "Confirma os detalhes da transacção antes de continuar.",
        ),
        "send_build_viewEditDetails": MessageLookupByLibrary.simpleMessage(
          "Ver e Editar Detalhes",
        ),
        "send_editTxDetailsSubsatModal_activate":
            MessageLookupByLibrary.simpleMessage("Activar"),
        "send_editTxDetailsSubsatModal_content":
            MessageLookupByLibrary.simpleMessage(
          "Verifica se o nó ligado suporta taxas abaixo de 1 sat/vb antes de continuar.",
        ),
        "send_editTxDetailsSubsatModal_header":
            MessageLookupByLibrary.simpleMessage("Taxas Abaixo de 1 sat/vb"),
        "send_editTxDetails_addNoteExample":
            MessageLookupByLibrary.simpleMessage(
          "ex.: Bitcoin P2P comprado",
        ),
        "send_editTxDetails_applyChangeTag":
            MessageLookupByLibrary.simpleMessage(
          "Etiquetar Troco",
        ),
        "send_editTxDetails_applyChanges": MessageLookupByLibrary.simpleMessage(
          "Aplicar Alterações",
        ),
        "send_editTxDetails_changeAddress":
            MessageLookupByLibrary.simpleMessage(
          "Endereço de Troco",
        ),
        "send_editTxDetails_changeAmount": MessageLookupByLibrary.simpleMessage(
          "Quantia do Troco",
        ),
        "send_editTxDetails_feeNoEstimatePossible":
            MessageLookupByLibrary.simpleMessage("Sem estimativa"),
        "send_editTxDetails_spendingFromAccount":
            MessageLookupByLibrary.simpleMessage("A Gastar da Conta"),
        "send_editTxDetails_spentFrom": MessageLookupByLibrary.simpleMessage(
          "Gasto de",
        ),
        "send_editTxDetails_tagDetails": MessageLookupByLibrary.simpleMessage(
          "Detalhes da Etiqueta",
        ),
        "send_keyboard_address_confirm": MessageLookupByLibrary.simpleMessage(
          "Confirmar",
        ),
        "send_keyboard_address_loading": MessageLookupByLibrary.simpleMessage(
          "A carregar...",
        ),
        "send_keyboard_amount_enter_valid_address":
            MessageLookupByLibrary.simpleMessage("Introduz um endereço válido"),
        "send_keyboard_amount_insufficient_funds_info":
            MessageLookupByLibrary.simpleMessage("Fundos Insuficientes"),
        "send_keyboard_amount_too_low_info":
            MessageLookupByLibrary.simpleMessage(
          "Quantia demasiado baixa",
        ),
        "send_keyboard_enterAddress": MessageLookupByLibrary.simpleMessage(
          "Introduzir endereço",
        ),
        "send_keyboard_send_max": MessageLookupByLibrary.simpleMessage(
          "Enviar o Máximo",
        ),
        "send_keyboard_to": MessageLookupByLibrary.simpleMessage("Para:"),
        "send_qrReviewModalCantReadSignedMessage_header":
            MessageLookupByLibrary.simpleMessage(
          "Não conseguimos ler a Mensagem Assinada",
        ),
        "send_qrReviewModalCantReadSignedTx_header":
            MessageLookupByLibrary.simpleMessage(
          "Não conseguimos ler a Transacção Assinada",
        ),
        "send_qrReview_scanSignedTransaction":
            MessageLookupByLibrary.simpleMessage(
          "Digitalizar Transacção assinada",
        ),
        "send_qrReview_viewDetails": MessageLookupByLibrary.simpleMessage(
          "Ver Detalhes",
        ),
        "send_qrScan_header": MessageLookupByLibrary.simpleMessage(
          "Digitaliza este QR com o Passport",
        ),
        "send_qrScan_scanQrWithPassportFirst":
            MessageLookupByLibrary.simpleMessage(
          "Digitaliza QR no Passport primeiro",
        ),
        "send_qrScan_subheader": MessageLookupByLibrary.simpleMessage(
          "Contém a transacção para assinares no teu Passport.",
        ),
        "send_qrScan_verifyOnPassport": MessageLookupByLibrary.simpleMessage(
          "Verificar no Passport",
        ),
        "send_qrSend_header": MessageLookupByLibrary.simpleMessage(
          "Transacção pronta para enviar",
        ),
        "send_qrSend_subheader": MessageLookupByLibrary.simpleMessage(
          "A Envoy vai enviar a transacção para a rede Bitcoin.",
        ),
        "send_qr_code_card_heading": MessageLookupByLibrary.simpleMessage(
          "Digitaliza o código QR com o Passport",
        ),
        "send_qr_code_card_subheading": MessageLookupByLibrary.simpleMessage(
          "Contém a transacção para o teu Passport assinar.",
        ),
        "send_qr_code_subheading": MessageLookupByLibrary.simpleMessage(
          "Podes digitalizar o código QR apresentado no Passport com a câmara do teu telemóvel.",
        ),
        "send_quantumBuildOutOfRange_makeSureInRangeUnlocked":
            MessageLookupByLibrary.simpleMessage(
          "Para continuar, garante que o Passport Prime está ligado, por perto e desbloqueado.",
        ),
        "send_quantumBuildOutOfRange_waitingForPassport":
            MessageLookupByLibrary.simpleMessage("À Espera do Passport"),
        "send_quantumBuild_signWithPassport":
            MessageLookupByLibrary.simpleMessage(
          "Assinar com o Passport",
        ),
        "send_quantumReview_connectedToPassport":
            MessageLookupByLibrary.simpleMessage("Ligado ao Passport"),
        "send_quantumReview_transactionTransferred":
            MessageLookupByLibrary.simpleMessage("Transacção Transferida"),
        "send_quantumReview_transferringTransaction":
            MessageLookupByLibrary.simpleMessage("A Transferir Transacção"),
        "send_quantumReview_waitForSigning":
            MessageLookupByLibrary.simpleMessage(
          "A Aguardar Assinatura",
        ),
        "send_quantumReview_waitingForSigning":
            MessageLookupByLibrary.simpleMessage("À Espera da Assinatura"),
        "send_quantumSend_transactionready":
            MessageLookupByLibrary.simpleMessage(
          "Transacção pronta",
        ),
        "send_reviewScreen_sendMaxWarning":
            MessageLookupByLibrary.simpleMessage(
          "A enviar o Máximo – As taxas são deduzidas da quantia a enviar.",
        ),
        "send_review_header": MessageLookupByLibrary.simpleMessage(
          "Verificar Detalhes da Transacção",
        ),
        "send_review_subheader": MessageLookupByLibrary.simpleMessage(
          "Confirma se estes detalhes coincidem com os apresentados no teu Passport.",
        ),
        "settings_advanced": MessageLookupByLibrary.simpleMessage("Avançado"),
        "settings_advancedModalReceiveSegwit_content":
            MessageLookupByLibrary.simpleMessage(
          "Com este interruptor desativado, serão gerados endereços Native Segwit quando tocares em receber. Este é o tipo de endereço predefinido usado pela maioria das carteiras Bitcoin.",
        ),
        "settings_advancedModalReceiveSegwit_title":
            MessageLookupByLibrary.simpleMessage("Receber para Segwit"),
        "settings_advancedModalReceiveTaproot_content":
            MessageLookupByLibrary.simpleMessage(
          "Com este interruptor ativado, serão gerados endereços Taproot quando tocares em receber. Antes de continuares, garante que quem te envia Bitcoin é compatível com Taproot.",
        ),
        "settings_advancedModalReceiveTaproot_title":
            MessageLookupByLibrary.simpleMessage("Receber para Taproot"),
        "settings_advanced_enableBuyRamp": MessageLookupByLibrary.simpleMessage(
          "Comprar na Envoy",
        ),
        "settings_advanced_enabled_signet_modal_link":
            MessageLookupByLibrary.simpleMessage(
          "Mais informação sobre o Signet [[aqui]].",
        ),
        "settings_advanced_enabled_signet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A activação do Signet adiciona uma versão Signet à tua Carteira Envoy. Esta funcionalidade é usada principalmente por programadores ou para testes e não tem valor.",
        ),
        "settings_advanced_enabled_testnet_modal_link":
            MessageLookupByLibrary.simpleMessage(
                "Aprende a fazer isso [[aqui]]."),
        "settings_advanced_enabled_testnet_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A activação do Testnet adiciona uma versão Testnet4 à tua Carteira Envoy, permitindo que associes contas Testnet a partir do teu Passport.",
        ),
        "settings_advanced_receiveToTaproot":
            MessageLookupByLibrary.simpleMessage(
          "Receber para Taproot",
        ),
        "settings_advanced_resetWarnings": MessageLookupByLibrary.simpleMessage(
          "Repor Avisos",
        ),
        "settings_advanced_signet":
            MessageLookupByLibrary.simpleMessage("Signet"),
        "settings_advanced_taproot": MessageLookupByLibrary.simpleMessage(
          "Taproot",
        ),
        "settings_advanced_taproot_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Activar"),
        "settings_advanced_taproot_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "O Taproot é uma funcionalidade avançada e o suporte para carteiras ainda é limitado.\n\nAvança com cuidado.",
        ),
        "settings_advanced_testnet": MessageLookupByLibrary.simpleMessage(
          "Testnet",
        ),
        "settings_amount": MessageLookupByLibrary.simpleMessage(
          "Ver Quantia em Sats",
        ),
        "settings_currency": MessageLookupByLibrary.simpleMessage("Moeda"),
        "settings_show_fiat": MessageLookupByLibrary.simpleMessage(
          "Exibir Valores Fiat",
        ),
        "settings_viewEnvoyLogs": MessageLookupByLibrary.simpleMessage(
          "Ver Registo de Actividade da Envoy",
        ),
        "signMessage_mainSignedQr_scanQr": MessageLookupByLibrary.simpleMessage(
          "Digitaliza o código QR",
        ),
        "signMessage_mainSignedQr_scanQrSubheader":
            MessageLookupByLibrary.simpleMessage("Contém a mensagem assinada."),
        "signMessage_mainSigned_copySignature":
            MessageLookupByLibrary.simpleMessage("Copiar Assinatura"),
        "signMessage_mainSigned_header": MessageLookupByLibrary.simpleMessage(
          "Mensagem Assinada",
        ),
        "signMessage_mainSigned_saveSignatureToFile":
            MessageLookupByLibrary.simpleMessage(
                "Guardar Assinatura em Ficheiro"),
        "signMessage_mainSigned_signatureInvalid":
            MessageLookupByLibrary.simpleMessage("Assinatura inválida"),
        "signMessage_mainSigned_signatureValid":
            MessageLookupByLibrary.simpleMessage("Assinatura válida"),
        "signMessage_main_addressDoesNotBelong":
            MessageLookupByLibrary.simpleMessage(
          "O endereço não pertence a esta conta.\nIntroduz outro endereço.",
        ),
        "signMessage_main_enterPasteMessage":
            MessageLookupByLibrary.simpleMessage(
          "Insere ou cola a mensagem",
        ),
        "signMessage_main_messageHeader": MessageLookupByLibrary.simpleMessage(
          "Mensagem",
        ),
        "signMessage_main_signatureHeader":
            MessageLookupByLibrary.simpleMessage(
          "Assinatura",
        ),
        "signMessage_qrCamera_importFromFile":
            MessageLookupByLibrary.simpleMessage(
          "Importar de Ficheiro",
        ),
        "signMessage_qr_header": MessageLookupByLibrary.simpleMessage(
          "Digitaliza QR com o Passport",
        ),
        "signMessage_qr_importSignature": MessageLookupByLibrary.simpleMessage(
          "Importar Assinatura",
        ),
        "signMessage_qr_saveToFile": MessageLookupByLibrary.simpleMessage(
          "Guardar em Ficheiro",
        ),
        "signMessage_qr_scannedSignedByPassport":
            MessageLookupByLibrary.simpleMessage(
          "Digitalizado e assinado pelo Passport",
        ),
        "signMessage_qr_subheader": MessageLookupByLibrary.simpleMessage(
          "Contém a mensagem para o Passport assinar.",
        ),
        "stalls_before_sending_tx_add_note_modal_cta2":
            MessageLookupByLibrary.simpleMessage("Dispensar"),
        "stalls_before_sending_tx_add_note_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "As notas da transacção podem ser úteis em gastos futuros.",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_heading":
            MessageLookupByLibrary.simpleMessage(
          "Não foi possível enviar a tua transacção",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Por favor verifica a tua ligação e tenta novamente",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_fail_subsat_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Garante que o nó ligado consegue transmitir transacções com taxas sub-sat.",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_success_heading":
            MessageLookupByLibrary.simpleMessage(
          "A tua transacção foi enviada com sucesso",
        ),
        "stalls_before_sending_tx_scanning_broadcasting_success_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Revê os detalhes tocando na transacção a partir do ecrã de detalhes da conta.",
        ),
        "stalls_before_sending_tx_scanning_heading":
            MessageLookupByLibrary.simpleMessage("A enviar a transacção"),
        "stalls_before_sending_tx_scanning_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Isto pode demorar uns segundos"),
        "tagDetails_EditTagName": MessageLookupByLibrary.simpleMessage(
          "Editar Nome da Etiqueta",
        ),
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
        "tagged_coin_details_menu_cta1": MessageLookupByLibrary.simpleMessage(
          "EDITAR NOME DA ETIQUETA",
        ),
        "tagged_tagDetails_emptyState_explainer":
            MessageLookupByLibrary.simpleMessage(
          "Não existem moedas associadas a esta etiqueta.",
        ),
        "tagged_tagDetails_sheet_cta1": MessageLookupByLibrary.simpleMessage(
          "Enviar Selecção",
        ),
        "tagged_tagDetails_sheet_cta2": MessageLookupByLibrary.simpleMessage(
          "Etiquetar Selecção",
        ),
        "tagged_tagDetails_sheet_retag_cta2":
            MessageLookupByLibrary.simpleMessage(
          "Reetiquetar Selecção",
        ),
        "tagged_tagDetails_sheet_transferSelected":
            MessageLookupByLibrary.simpleMessage("Transferir Seleccionados"),
        "tap_and_drag_first_time_text": MessageLookupByLibrary.simpleMessage(
          "Mantém premido para arrastar e reordenar as contas.",
        ),
        "taproot_passport_dialog_heading": MessageLookupByLibrary.simpleMessage(
          "Taproot no Passport",
        ),
        "taproot_passport_dialog_later": MessageLookupByLibrary.simpleMessage(
          "Mais Tarde",
        ),
        "taproot_passport_dialog_reconnect":
            MessageLookupByLibrary.simpleMessage(
          "Voltar a Ligar o Passport",
        ),
        "taproot_passport_dialog_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para activar uma conta Taproot no Passport, verifica se estás a correr o firmware 2.3.0 ou posterior e volta a ligar o teu Passport.",
        ),
        "toast_foundationServersDown": MessageLookupByLibrary.simpleMessage(
          "Servidores da Foundation indisponíveis",
        ),
        "toast_newEnvoyUpdateAvailable": MessageLookupByLibrary.simpleMessage(
          "Disponível nova actualização para a Envoy",
        ),
        "toast_repairingSuccessful_content":
            MessageLookupByLibrary.simpleMessage(
          "Reemparelhamento com o Prime concluído.",
        ),
        "torToast_learnMore_retryTorConnection":
            MessageLookupByLibrary.simpleMessage(
                "Tentar Novamente Ligação Tor"),
        "torToast_learnMore_temporarilyDisableTor":
            MessageLookupByLibrary.simpleMessage(
                "Desligar Tor Temporariamente"),
        "torToast_learnMore_warningBody": MessageLookupByLibrary.simpleMessage(
          "Podes experienciar um desempenho degradado da aplicação até que a Envoy consiga restabelecer a ligação à rede Tor.\n\nAo desactivares o Tor irás estabelecer uma ligação directa ao servidor da Envoy, mas com [[contrapartidas]] na vertente de privacidade.",
        ),
        "tor_connectivity_toast_warning": MessageLookupByLibrary.simpleMessage(
          "Erro ao estabelecer ligação à rede Tor",
        ),
        "transfer_fromTo_transferFrom": MessageLookupByLibrary.simpleMessage(
          "Transferir de",
        ),
        "transfer_fromTo_transferTo": MessageLookupByLibrary.simpleMessage(
          "Transferir para",
        ),
        "video_connectingToTorNetwork": MessageLookupByLibrary.simpleMessage(
          "A Ligar à Rede Tor",
        ),
        "video_loadingTorText": MessageLookupByLibrary.simpleMessage(
          "A Envoy está a carregar o teu vídeo através da Rede Tor",
        ),
        "wallet_security_modal_1_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy faz cópia automática e segura da semente da carteira móvel com [[Cópia de Segurança do Android]].\n\nA semente está sempre encriptada ponta a ponta e nunca é visível para o Google.",
        ),
        "wallet_security_modal_1_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy faz a cópia de segurança da semente da tua carteira móvel de uma forma segura e automática para o [[Porta-chaves iCloud]].\n\nA tua semente está sempre encriptada ponta a ponta e nunca é tornada visível para a Apple.",
        ),
        "wallet_security_modal_2_4_subheading":
            MessageLookupByLibrary.simpleMessage(
          "É automaticamente feita uma cópia de segurança dos dados da tua carteira - incluindo etiquetas, notas, contas e definições - para os servidores da Foundation.\n\nAntes do envio a cópia de segurança é encriptada com a semente da tua carteira, garantindo que a Foundation nunca terá acesso aos teus dados.",
        ),
        "wallet_security_modal_3_4_android_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para recuperar a tua carteira, basta iniciar sessão na tua conta do Google. A Envoy irá descarregar automaticamente a semente da tua carteira e os dados da cópia de segurança.\n\nRecomendamos que protejas a tua conta Google com uma senha forte e autenticação de dois factores (2FA).",
        ),
        "wallet_security_modal_3_4_ios_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Para recuperar a tua carteira, basta iniciar sessão na tua conta iCloud. A Envoy irá descarregar automaticamente a semente da tua carteira e os dados da cópia de segurança.\n\nRecomendamos que protejas a tua conta iCloud com uma senha forte e autenticação de dois factores (2FA).",
        ),
        "wallet_security_modal_4_4_heading":
            MessageLookupByLibrary.simpleMessage(
          "Como Protegemos os Teus Dados",
        ),
        "wallet_security_modal_4_4_subheading":
            MessageLookupByLibrary.simpleMessage(
          "Se preferires não utilizar a Cópia Mágica de Segurança e, em alternativa, proteger manualmente a semente e os dados da tua carteira, não há problema!\n\nBasta voltar ao ecrã anterior e desactivar a Cópia Mágica de Segurança.",
        ),
        "wallet_security_modal_HowToRecoverYourWallet":
            MessageLookupByLibrary.simpleMessage("Como Recuperar a Carteira"),
        "wallet_security_modal_HowYourDatatIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Como Protegemos os Teus Dados"),
        "wallet_security_modal_HowYourSeedIsSecured":
            MessageLookupByLibrary.simpleMessage(
                "Como a Tua Semente é Protegida"),
        "wallet_security_modal_HowYourWalletIsSecured":
            MessageLookupByLibrary.simpleMessage("A Segurança da Tua Carteira"),
        "wallet_security_modal_WantToOptOut":
            MessageLookupByLibrary.simpleMessage(
          "Queres Desativar?",
        ),
        "wallet_security_modal__heading": MessageLookupByLibrary.simpleMessage(
          "Dica de Segurança",
        ),
        "wallet_security_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
          "A Envoy está a armazenar mais do que a quantidade recomendada de Bitcoin para uma carteira móvel, ligada à internet.\n\nPara armazenamento offline ultra-seguro, a Foundation sugere a carteira física Passport.",
        ),
        "wallet_setup_success_heading": MessageLookupByLibrary.simpleMessage(
          "A Tua Carteira Está Pronta",
        ),
        "wallet_setup_success_subheading": MessageLookupByLibrary.simpleMessage(
          "A Envoy está configurada e pronta para a tua Bitcoin!",
        ),
        "welcome_screen_ctA1": MessageLookupByLibrary.simpleMessage(
          "Configurar a Carteira Envoy",
        ),
        "welcome_screen_cta2": MessageLookupByLibrary.simpleMessage(
          "Gerir o Passport",
        ),
        "welcome_screen_heading": MessageLookupByLibrary.simpleMessage(
          "Bem-Vindo à Envoy",
        ),
      };
}
