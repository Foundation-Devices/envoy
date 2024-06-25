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

  static String m0(period) =>
      "Este vale expirou a ${period}.\n\n\nPor favor entra em contacto com o emissor para quaisquer questões relacionadas com o vale.";

  static String m1(AccountName) =>
      "Acede a ${AccountName} no Passport, escolhe \"Verificar Endereço\" e digitaliza o código QR.";

  static String m2(tagName) =>
      "A tua etiqueta ${tagName} está vazia. Pretendes eliminá-la?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_": MessageLookupByLibrary.simpleMessage("30,493.93"),
        "about_appVersion":
            MessageLookupByLibrary.simpleMessage("Versão da Aplicação"),
        "about_openSourceLicences":
            MessageLookupByLibrary.simpleMessage("Licenças de Código Aberto"),
        "about_privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacidade"),
        "about_show": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "about_termsOfUse":
            MessageLookupByLibrary.simpleMessage("Termos de Uso"),
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
        "activity_boosted": MessageLookupByLibrary.simpleMessage("Reforçada"),
        "activity_canceling":
            MessageLookupByLibrary.simpleMessage("A cancelar"),
        "activity_emptyState_label": MessageLookupByLibrary.simpleMessage(
            "Não existe actividade para apresentar."),
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
        "azteco_redeem_modal__voucher_code":
            MessageLookupByLibrary.simpleMessage("CÓDIGO DO VALE"),
        "azteco_redeem_modal_cta1":
            MessageLookupByLibrary.simpleMessage("Resgatar"),
        "azteco_redeem_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Erro ao Resgatar"),
        "azteco_redeem_modal_fail_subheading": MessageLookupByLibrary.simpleMessage(
            "Por favor confirma se o teu vale ainda está válido.\n\nContacta o support@azte.co para quaisquer questões relacionadas com o vale."),
        "azteco_redeem_modal_heading":
            MessageLookupByLibrary.simpleMessage("Resgatar Vale?"),
        "azteco_redeem_modal_success_heading":
            MessageLookupByLibrary.simpleMessage("Vale Resgatado"),
        "azteco_redeem_modal_success_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Em breve irá aparecer uma transacção a receber na tua conta."),
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
        "bottomNav_accounts": MessageLookupByLibrary.simpleMessage("Contas"),
        "bottomNav_activity":
            MessageLookupByLibrary.simpleMessage("Actividade"),
        "bottomNav_devices":
            MessageLookupByLibrary.simpleMessage("Dispositivos"),
        "bottomNav_learn": MessageLookupByLibrary.simpleMessage("Aprender"),
        "bottomNav_privacy":
            MessageLookupByLibrary.simpleMessage("Privacidade"),
        "btcpay_connection_modal_expired_subheading": m0,
        "btcpay_connection_modal_fail_heading":
            MessageLookupByLibrary.simpleMessage("Vale Expirado"),
        "btcpay_connection_modal_fail_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A Envoy não consegue ligar-se à loja BTCPay do emissor.\n\nPor favor entra em contacto com o emissor ou tenta novamente mais tarde."),
        "btcpay_connection_modal_onchainOnly_subheading":
            MessageLookupByLibrary.simpleMessage(
                "O vale digitalizado não foi criado com suporte onchain.\n\nPor favor entra em contacto com o criador do vale."),
        "btcpay_pendingVoucher":
            MessageLookupByLibrary.simpleMessage("Vale BYCPay Pendente"),
        "btcpay_redeem_modal_description":
            MessageLookupByLibrary.simpleMessage("Descrição:"),
        "btcpay_redeem_modal_name":
            MessageLookupByLibrary.simpleMessage("Nome:"),
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
        "buy_bitcoin_accountSelection_verify_modal_heading": m1,
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
        "coindetails_overlay_heading":
            MessageLookupByLibrary.simpleMessage("DETALHES DA MOEDA"),
        "coindetails_overlay_noBoostNoFunds_heading":
            MessageLookupByLibrary.simpleMessage(
                "Não é possível Reforçar a Transacção"),
        "coindetails_overlay_noBoostNoFunds_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Isto deve-se ao facto de não existirem moedas confirmadas ou desbloqueadas suficientes para escolher. \n\nSempre que possível permite que as moedas pendentes sejam confirmadas ou deslobqueia algumas moedas e tenta novamente."),
        "coindetails_overlay_notes":
            MessageLookupByLibrary.simpleMessage("Nota"),
        "coindetails_overlay_paymentID":
            MessageLookupByLibrary.simpleMessage("ID de Pagamento"),
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
        "component_Apply": MessageLookupByLibrary.simpleMessage("Aplicar"),
        "component_back": MessageLookupByLibrary.simpleMessage("Voltar"),
        "component_cancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
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
        "empty_tag_modal_subheading": m2,
        "envoy_account_tos_cta": MessageLookupByLibrary.simpleMessage("Aceito"),
        "envoy_account_tos_heading": MessageLookupByLibrary.simpleMessage(
            "Por favor revê e aceita as Condições de Utilização do Passport"),
        "envoy_account_tos_subheading": MessageLookupByLibrary.simpleMessage(
            "Last updated: May 16, 2021.\r\n\r\nBy purchasing, using or continuing to use a Passport hardware wallet (“Passport“), you, the purchaser of Passport, agree to be bound by these terms of and use (the “Passport Terms of Use” or “Terms”).\r\n\r\n1. Use of Passport\n\nPassport includes functionality to store and facilitate the transfer of bitcoin (“Bitcoin”) and which may be used to facilitate various types of transactions and other activities (“Transactions”). You understand and agree that Foundation Devices (“Foundation”, “We”, or “Us“) is not responsible for, and has no obligation or liability to you or others in respect of any Transactions. You agree to comply with all applicable laws in your use of Products (including all Transactions), including without limitation any anti-money laundering laws or regulations.\r\n\r\n2. Security\n\r\nYou understand and agree that control and access to Bitcoin stored on any Product is based upon physical possession and control of such Product and that any person given physical possession of the Product may remove or transfer any or all Bitcoin stored on such Product.\r\n\r\n3. BACKUPS\r\nYou are solely responsible for generating and making backups of your recovery phrase and for preserving and maintaining the security and confidentiality of your recovery phrase and your PIN. You acknowledge and agree that failure to do so may result in the complete loss of all Bitcoin stored on Passport and that we have no obligation to liability whatsoever for any such loss.\r\n\r\n4. MODIFICATIONS\r\nYou acknowledge and agree that any modifications to Passport, the installation of any additional software or firmware on a Passport or the use of Passport in connection with any other software or equipment are at your sole risk, and that we have no obligation or liability in respect thereof or in respect of any resulting loss of Bitcoin, damage to Passport, failure of the Passport or errors in storing Bitcoin or processing Transactions;\r\n\r\n5. OPEN SOURCE LICENSES\r\nPassport includes software licensed under the GNU General Public License v3 and other open source licenses, as identified in documentation provided with Passport. Your use of such software is subject to the applicable open source licenses and, to the extent such open source licenses conflicts with this Agreement, the terms of such licenses will prevail.\r\n\r\n6. ACKNOWLEDGEMENT AND ASSUMPTION OF RISK\r\nYou understand and agree that:\r\n\r\n(a) there are risks associated with the use and holding of Bitcoin and you represent and warrant that you are knowledgeable and/or experienced in matters relating to the use of Bitcoin and are capable of evaluating the benefits and risks of using and holding Bitcoin and fully understand the nature of Bitcoin, the limitations and restrictions on its liquidity and transferability and are capable of bearing the economic risk of holding and transacting using Bitcoin;\r\n\r\n(b) the continued ability to use Bitcoin is dependent on many elements beyond our control, including without limitation the publication of blocks, network connectivity, hacking or changes in the technical and other standards, policies and procedures applicable to Bitcoin;\r\n\r\n(c) no regulatory authority has reviewed or passed on the merits, legality or fungibility of Bitcoin;\r\n\r\n(d) there is no government or other insurance covering Bitcoin, the loss or theft of Bitcoin, or any loss in the value of Bitcoin;\r\n\r\n(e) the use of Bitcoin or the Products may become subject to regulatory controls that limit, restrict, prohibit or otherwise impose conditions on your use of same;\r\n\r\n(f) Bitcoin do not constitute a currency, asset, security, negotiable instrument, or other form of property and do not have any intrinsic or inherent value;\r\n\r\n(g) the value of and/or exchange rates for Bitcoin may fluctuate significantly and may result in you incurring significant losses;\r\n\r\n(h) Transactions may have tax consequences (including obligations to report, collect or remit taxes) and you are solely responsible for understanding and complying with all applicable tax laws and regulations; and\r\n\r\n(i) the use of Bitcoin or Products may be illegal or subject to regulation in certain jurisdictions, and it is your responsibility to ensure that you comply with the laws of any jurisdiction in which you use Bitcoin or Products.\r\n\r\n7. TRANSFER OF PASSPORT\r\nYou may transfer or sell Passport to others on the condition that you ensure that the transferee or purchaser agrees to be bound by the then-current form of these Terms available on our website at the time of transfer.\r\n\r\n8. RESTRICTIONS\r\nYou shall not:\r\n\r\n(a) use Passport in a manner or for a purpose that: (i) is illegal or otherwise contravenes applicable law (including the facilitation or furtherance of any criminal or fraudulent activity or the violation of any anti-money laundering legislation); or (ii) infringes upon the lawful rights of others;\r\n\r\n(b) interfere with the security or integrity of Passport;\r\n\r\n(c) remove, destroy, cover, obfuscate or alter in any manner any notices, legends, trademarks, branding or logos appearing on or contained in Passport; or\r\n\r\n(d) attempt, or cause, permit or encourage any other person, to do any of the foregoing.\r\n\r\nNotwithstanding the foregoing, you may investigate security and other vulnerabilities, provided you do so in a reasonable and responsible manner in compliance with applicable law and our responsible disclosure policy and otherwise use good faith efforts to minimize or avoid contravention of any of the foregoing.\r\n\r\n9. REPRESENTATIONS AND WARRANTIES\r\nYou represent, warrant and covenant that:\r\n\r\n(a) you have the capacity to, and are and will be free to, enter into and to fully perform your obligations under these Terms and that no agreement or understanding with any other person exists or will exist which would interfere with such obligations; and\r\n\r\n(b) these Terms constitute a legal, valid and binding obligation upon you.\r\n\r\n10. OWNERSHIP\r\nExcept for the limited rights of use expressly granted to you under these Terms, all right, title and interest (including all copyrights, trademarks, service marks, patents, inventions, trade secrets, intellectual property rights and other proprietary rights) in and to Passport are and shall remain exclusively owned by us and our licensors. All trade names, company names, trademarks, service marks and other names and logos are the proprietary marks of us or our licensors, and are protected by law and may not be copied, imitated or used, in whole or in part, without the consent of their respective owners. These Terms do not grant you any rights in respect of any such marks. You understand and agree that any feedback, input, suggestions, recommendations, improvements, changes, specifications, test results, or other data or information that you provide or make available to us arising from or related to your use of the Products or Software shall become our exclusive property and may be used by us to modify, enhance, maintain and improve Passport without any obligation or payment to you whatsoever.\r\n\r\n11. THIRD PARTY PRODUCTS\r\nYou acknowledge and agree that you will require certain third party equipment, products, software and services in order to use the Products and may also use optional third party equipment, products, software and services that enhance or complement such use (collectively, “Third Party Products”). You acknowledge and agree that failure to use or procure Third Party Products that meet the minimum requirements for Products, or failure to properly configure or setup Third Party Products may result in the inability to use the Products and/or processing failures or errors. Third Party Products include, without limitation, computers, mobile devices, networking equipment, operating system software, web browsers and internet connectivity. We may also identify, recommend, reference or link to optional Third Party Products on our website. You acknowledge and agree that: (a) Third Party Products are be governed by separate licenses, agreements or terms and conditions and we have no obligation or liability to you in respect thereof; and (b) you are solely responsible for procuring any Third Party Products at your cost and expense, and are solely responsible for compliance with any applicable licenses, agreements or terms and conditions governing same. \r\n\r\n12. INDEMNITY\r\nYou agree to indemnify and hold Foundation Devices (and our officers, employees, and agents) harmless, including costs and attorneys’ fees, from any claim or demand due to or arising out of (a) your use of Passport, (b) your violation of this Agreement or (c) your violation of applicable laws or regulations. We reserve the right, at your expense, to assume the exclusive defense and control of any matter for which you are required to indemnify us and you agree to cooperate with our defense of these claims. You agree not to settle any matter without our prior written consent. We will use reasonable efforts to notify you of any such claim, action or proceeding upon becoming aware of it.\r\n\r\n13. DISCLAIMERS\r\nPASSPORT IS PROVIDED “AS-IS” AND “AS AVAILABLE” AND WE (AND OUR SUPPLIERS) EXPRESSLY DISCLAIM ANY WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, QUIET ENJOYMENT, ACCURACY, OR NON-INFRINGEMENT. WE (AND OUR SUPPLIERS) MAKE NO WARRANTY THAT PASSPORT: (A) WILL MEET YOUR REQUIREMENTS; (B) WILL BE AVAILABLE ON AN UNINTERRUPTED, TIMELY, SECURE, OR ERROR-FREE BASIS; OR (C) WILL BE ACCURATE, RELIABLE, FREE OF VIRUSES OR OTHER HARMFUL CODE, COMPLETE, LEGAL, OR SAFE.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n14. LIMITATION ON LIABILITY\r\nYOU AGREE THAT, TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, OUR AGGREGATE LIABILITY ARISING FROM OR RELATED TO THESE TERMS OR PASSPORT IN ANY MANNER WILL BE LIMITED TO DIRECT DAMAGES NOT TO EXCEED THE PURCHASE PRICE YOU HAVE PAID TO US FOR PASSPORT (EXCLUDING SHIPPING CHARGES AND TAXES). TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL WE (AND OUR SUPPLIERS) BE LIABLE FOR ANY CONSEQUENTIAL, INCIDENTAL, INDIRECT, SPECIAL, PUNITIVE, OR OTHER DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF REVENUE, PROFITS, OR EXPECTED SAVINGS, BUSINESS INTERRUPTION, PERSONAL INJURY, LOSS OF PRIVACY, LOSS OF DATA OR INFORMATION OR OTHER PECUNIARY OR INTANGIBLE LOSS) ARISING OUT OF THESE TERMS OR THE USE OF OR INABILITY TO USE PASSPORT, EVEN IF WE FORESEE OR HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\r\n\r\nSOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OF CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY NOT APPLY TO YOU.\r\n\r\n15. RELEASE\r\nYou hereby release and forever discharge us (and our officers, employees, agents, successors, and assigns) from, and hereby waive and relinquish, each and every past, present and future dispute, claim, controversy, demand, right, obligation, liability, action and cause of action of every kind and nature (including personal injuries, death, and property damage), that has arisen or arises directly or indirectly out of, or relates directly or indirectly to, use of Passport. IF YOU ARE A CALIFORNIA RESIDENT, YOU HEREBY WAIVE CALIFORNIA CIVIL CODE SECTION 1542 IN CONNECTION WITH THE FOREGOING, WHICH STATES: “A GENERAL RELEASE DOES NOT EXTEND TO CLAIMS WHICH THE CREDITOR DOES NOT KNOW OR SUSPECT TO EXIST IN HIS OR HER FAVOR AT THE TIME OF EXECUTING THE RELEASE, WHICH IF KNOWN BY HIM OR HER MUST HAVE MATERIALLY AFFECTED HIS OR HER SETTLEMENT WITH THE DEBTOR.”\r\n\r\n16. SURVIVAL\r\nNeither the expiration nor the earlier termination of your account will release you from any obligation or liability that accrued prior to such expiration or termination. The provisions of these Terms requiring performance or fulfilment after the expiration or earlier termination of your account and any other provisions hereof, the nature and intent of which is to survive termination or expiration, will survive.\r\n\r\n17. PRIVACY POLICY\r\nPlease review our Privacy Policy, located at https://foundationdevices.com/privacy, which governs the use of personal information.\r\n\r\n18. DISPUTE RESOLUTION\r\nPlease read the following arbitration agreement in this section (“Arbitration Agreement”) carefully. It requires U.S. users to arbitrate disputes with Foundation Devices and limits the manner in which you can seek relief from us.\r\n\r\n(a) Applicability of Arbitration Agreement. You agree that any dispute, claim, or request for relief relating in any way to your use of Passport will be resolved by binding arbitration, rather than in court, except that (a) you may assert claims or seek relief in small claims court if your claims qualify; and (b) you or we may seek equitable relief in court for infringement or other misuse of intellectual property rights (such as trademarks, trade dress, domain names, trade secrets, copyrights, and patents). This Arbitration Agreement shall apply, without limitation, to all disputes or claims and requests for relief that arose or were asserted before the effective date of this Agreement or any prior version of this Agreement.\r\n\r\n(b) Arbitration Rules and Forum. The Federal Arbitration Act governs the interpretation and enforcement of this Arbitration Agreement. To begin an arbitration proceeding, you must send a letter requesting arbitration and describing your dispute or claim or request for relief to our registered agent. The arbitration will be conducted by JAMS, an established alternative dispute resolution provider. Disputes involving claims, counterclaims, or request for relief under \$250,000, not inclusive of attorneys’ fees and interest, shall be subject to JAMS’s most current version of the Streamlined Arbitration Rules and procedures available at https://jamsadr.com/rules-streamlined-arbitration/; all other disputes shall be subject to JAMS’s most current version of the Comprehensive Arbitration Rules and Procedures, available at https://jamsadr.com/rules-comprehensive-arbitration/. JAMS’s rules are also available at https://jamsadr.com or by calling JAMS at 800-352-5267. If JAMS is not available to arbitrate, the parties will select an alternative arbitral forum. If the arbitrator finds that you cannot afford to pay JAMS’s filing, administrative, hearing and/or other fees and cannot obtain a waiver from JAMS, Company will pay them for you. In addition, Company will reimburse all such JAMS’s filing, administrative, hearing and/or other fees for disputes, claims, or requests for relief totaling less than \$10,000 unless the arbitrator determines the claims are frivolous.\r\n\r\nYou may choose to have the arbitration conducted by telephone, based on written submissions, or in person in the country where you live or at another mutually agreed location. Any judgment on the award rendered by the arbitrator may be entered in any court of competent jurisdiction.\r\n\r\n(c) Authority of Arbitrator. The arbitrator shall have exclusive authority to (a) determine the scope and enforceability of this Arbitration Agreement and (b) resolve any dispute related to the interpretation, applicability, enforceability or formation of this Arbitration Agreement including, but not limited to, any assertion that all or any part of this Arbitration Agreement is void or voidable. The arbitration will decide the rights and liabilities, if any, of you and Company. The arbitration proceeding will not be consolidated with any other matters or joined with any other cases or parties. The arbitrator shall have the authority to grant motions dispositive of all or part of any claim. The arbitrator shall have the authority to award monetary damages and to grant any non-monetary remedy or relief available to an individual under applicable law, the arbitral forum’s rules, and the Agreement (including the Arbitration Agreement). The arbitrator shall issue a written award and statement of decision describing the essential findings and conclusions on which the award is based, including the calculation of any damages awarded. The arbitrator has the same authority to award relief on an individual basis that a judge in a court of law would have. The award of the arbitrator is final and binding upon you and us.\r\n\r\n(d) Waiver of Jury Trial. YOU AND COMPANY HEREBY WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO SUE IN COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY. You and Company are instead electing that all disputes, claims, or requests for relief shall be resolved by arbitration under this Arbitration Agreement, except as specified in Section 10(a) (Application of Arbitration Agreement) above. An arbitrator can award on an individual basis the same damages and relief as a court and must follow this Agreement as a court would. However, there is no judge or jury in arbitration, and court review of an arbitration award is subject to very limited review.\r\n\r\n(e) Waiver of Class or Other Non-Individualized Relief. ALL DISPUTES, CLAIMS, AND REQUESTS FOR RELIEF WITHIN THE SCOPE OF THIS ARBITRATION AGREEMENT MUST BE ARBITRATED ON AN INDIVIDUAL BASIS AND NOT ON A CLASS OR COLLECTIVE BASIS, ONLY INDIVIDUAL RELIEF IS AVAILABLE, AND CLAIMS OF MORE THAN ONE CUSTOMER OR USER CANNOT BE ARBITRATED OR CONSOLIDATED WITH THOSE OF ANY OTHER CUSTOMER OR USER. If a decision is issued stating that applicable law precludes enforcement of any of this section’s limitations as to a given dispute, claim, or request for relief, then such aspect must be severed from the arbitration and brought into the State or Federal Courts located in the Commonwealth of Massachusetts. All other disputes, claims, or requests for relief shall be arbitrated.\r\n\r\n(f) 30-Day Right to Opt Out. You have the right to opt out of the provisions of this Arbitration Agreement by sending written notice of your decision to opt out to: hello@foundationdevices.com, within thirty (30) days after first becoming subject to this Arbitration Agreement. Your notice must include your name and address, your Company username (if any), the email address you used to set up your Company account (if you have one), and an unequivocal statement that you want to opt out of this Arbitration Agreement. If you opt out of this Arbitration Agreement, all other parts of this Agreement will continue to apply to you. Opting out of this Arbitration Agreement has no effect on any other arbitration agreements that you may currently have, or may enter in the future, with us.\r\n\r\n(g) Severability. Except as provided in Section 10(e)(Waiver of Class or Other Non-Individualized Relief), if any part or parts of this Arbitration Agreement are found under the law to be invalid or unenforceable, then such specific part or parts shall be of no force and effect and shall be severed and the remainder of the Arbitration Agreement shall continue in full force and effect.\r\n\r\n(h) Survival of Agreement. This Arbitration Agreement will survive the termination of your relationship with Company.\r\n\r\nModification. Notwithstanding any provision in this Agreement to the contrary, we agree that if Company makes any future material change to this Arbitration Agreement, you may reject that change within thirty (30) days of such change becoming effective by writing Company at the following address: Foundation Devices, Inc., 6 Liberty Square #6018, Boston, MA 02109, Attn: CEO.\r\n\r\n19. GENERAL\r\n(a) Changes to Terms of Use. This Agreement is subject to occasional revision, and if we make any substantial changes, we may notify you by sending you an e-mail to the last e-mail address you provided to us (if any) and/or by prominently posting notice of the changes on our website. Any changes to this agreement will be effective upon the earlier of thirty (30) calendar days following our dispatch of an e-mail notice to you (if applicable) or thirty (30) calendar days following our posting of notice of the changes on our website. These changes will be effective immediately for new users of our website. You are responsible for providing us with your most current e-mail address. In the event that the last e-mail address that you have provided us is not valid, or for any reason is not capable of delivering to you the notice described above, our dispatch of the e-mail containing such notice will nonetheless constitute effective notice of the changes described in the notice. Continued use of Passport following notice of such changes will indicate your acknowledgement of such changes and agreement to be bound by the terms and conditions of such changes.\r\n\r\nChoice Of Law. The Agreement is made under and will be governed by and construed in accordance with the laws of the Commonwealth of Massachusetts, consistent with the Federal Arbitration Act, without giving effect to any principles that provide for the application of the law of another jurisdiction.\r\n\r\n(b) Entire Agreement. This Agreement constitutes the entire agreement between you and us regarding the use of Passport. Our failure to exercise or enforce any right or provision of this Agreement will not operate as a waiver of such right or provision. The section titles in this Agreement are for convenience only and have no legal or contractual effect. The word including means including without limitation. If any provision of this Agreement is, for any reason, held to be invalid or unenforceable, the other provisions of this Agreement will be unimpaired and the invalid or unenforceable provision will be deemed modified so that it is valid and enforceable to the maximum extent permitted by law. Your relationship to us is that of an independent contractor, and neither party is an agent or partner of the other. This Agreement, and your rights and obligations herein, may not be assigned, subcontracted, delegated, or otherwise transferred by you without our prior written consent, and any attempted assignment, subcontract, delegation, or transfer in violation of the foregoing will be null and void. The terms of this Agreement will be binding upon assignees.\r\n\r\n(c) Copyright/Trademark Information. Copyright © 2020, Foundation Devices, Inc. All rights reserved. All trademarks, logos and service marks displayed on the Site are our property or the property of other third parties. You are not permitted to use such trademarks, logos and service marks without our prior written consent or the consent of such third party which may own the Marks.\r\n\r\nContact Information:\r\n\r\nFoundation Devices, Inc.\r\n6 Liberty Square #6018\r\nBoston, MA 02109\r\nhello@foundationdevices.com"),
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
            "Yes! From v1.7 you can now purchase Bitcoin within Envoy and have it automatically deposited to your mobile account, or any connected Passport accounts. Just click on the buy button from the main Accounts screen."),
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
        "envoy_faq_question_24":
            MessageLookupByLibrary.simpleMessage("Can I buy Bitcoin in Envoy?"),
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
        "menu_about": MessageLookupByLibrary.simpleMessage("SOBRE"),
        "menu_backups":
            MessageLookupByLibrary.simpleMessage("CÓPIAS DE SEGURANÇA"),
        "menu_heading": MessageLookupByLibrary.simpleMessage("ENVOY"),
        "menu_settings": MessageLookupByLibrary.simpleMessage("DEFINIÇÕES"),
        "menu_support": MessageLookupByLibrary.simpleMessage("APOIO TÉCNICO"),
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
        "privacy_node_title": MessageLookupByLibrary.simpleMessage("Nó"),
        "privacy_privacyMode_betterPerformance":
            MessageLookupByLibrary.simpleMessage("Desempenho\nMelhorado"),
        "privacy_privacyMode_improvedPrivacy":
            MessageLookupByLibrary.simpleMessage("Privacidade Melhorada"),
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
        "replaceByFee_coindetails_overlay_boost":
            MessageLookupByLibrary.simpleMessage("Reforçar"),
        "replaceByFee_coindetails_overlay_modal_heading":
            MessageLookupByLibrary.simpleMessage("Reforçar Transacção"),
        "replaceByFee_coindetails_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "Aumenta a taxa associada à tua transacção para acelerares o tempo de confirmação."),
        "replaceByFee_edit_transaction_requiredAmount":
            MessageLookupByLibrary.simpleMessage("Necessário para Reforçar"),
        "replaceByFee_ramp_incompleteTransactionAutodeleteWarning":
            MessageLookupByLibrary.simpleMessage(
                "Compras incompletas serão automaticamente removidas após 5 dias"),
        "replaceByFee_warning_extraUTXO_overlay_modal_subheading":
            MessageLookupByLibrary.simpleMessage(
                "A taxa escolhida só pode ser atingida adicionando mais moedas. A Envoy faz essa operação automaticamente e nunca irá incluir moedas bloqueadas. \n\nEsta seleção pode ser revista ou editada no ecrã seguinte."),
        "scv_checkingDeviceSecurity":
            MessageLookupByLibrary.simpleMessage("Checking Device Security"),
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
                "A activação do Testnet adiciona uma versão Testnet à tua Carteira Envoy, permitindo que estabeleças ligações com contas Testnet a partir do teu Passport."),
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
            MessageLookupByLibrary.simpleMessage("Bem-vindo ao Envoy"),
        "welcome_screen_subheading": MessageLookupByLibrary.simpleMessage(
            "Recupera a tua soberania com a Envoy, uma carteira de Bitcoin simples com poderosas ferramentas de gestão de contas e de privacidade.")
      };
}
