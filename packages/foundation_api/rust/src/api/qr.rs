// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::Context;
use flutter_rust_bridge::for_generated::anyhow;
use foundation_api::bc_envelope::prelude::*;
use foundation_api::bc_xid::XIDDocument;
use foundation_api::message::{PassportMessage, QuantumLinkMessage, PROTOCOL_VERSION};
use foundation_api::pairing::PairingResponse;
use foundation_api::passport::{
    PassportColor, PassportFirmwareVersion, PassportModel, PassportSerial,
};
use foundation_api::status::DeviceStatus;
use foundation_ur::{Decoder, UR};
use std::sync::{Arc, Mutex};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn get_qr_decoder() -> Arc<Mutex<Decoder>> {
    Arc::new(Mutex::new(Decoder::default()))
}

pub struct QrDecoderStatus {
    pub progress: f64,
    pub payload: Option<XIDDocument>,
}

pub async fn decode_qr(
    qr: String,
    decoder: &Arc<Mutex<Decoder>>,
) -> anyhow::Result<QrDecoderStatus> {
    let ur = UR::parse(&qr)?;
    let mut decoder = decoder.lock().unwrap();
    decoder.receive(ur)?;

    register_tags();
    if decoder.is_complete() {
        let decoded = decoder.message()?.unwrap();
        // TODO: convert raw data to CBoR

        let xid_cbor = CBOR::try_from_data(decoded).context("invalid xid cbor")?;
        let xid_document = XIDDocument::try_from(xid_cbor)?;

        return Ok(QrDecoderStatus {
            progress: 1.0,
            payload: Some(xid_document),
        });
    }

    Ok(QrDecoderStatus {
        progress: decoder.estimated_percent_complete(),
        payload: None,
    })
}

pub async fn decode_ble_message(_data: Vec<u8>) -> PassportMessage {
    let msg = QuantumLinkMessage::PairingResponse(PairingResponse {
        passport_model: PassportModel::Gen1,
        passport_firmware_version: PassportFirmwareVersion("1.0.0".to_string()),
        passport_serial: PassportSerial("abc".to_string()),
        passport_color: PassportColor::Dark,
        onboarding_complete: false,
    });
    PassportMessage {
        message: msg,
        status: DeviceStatus {
            version: "1.0.0".to_string(),
            battery_level: 100,
        },
        protocol_version: Some(PROTOCOL_VERSION),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;

    fn get_test_array() -> Vec<String> {
        vec!(
            "ur:envelope/93-24/lpcshlcscscfaymhcygynbmteehdhhplplgmhfkobdieyaqdztkpfefhlbztnljtgycnrlwdrttertdecysabtvdwpeyfninhpisihctuopdpsgepfcpbskbfghgoyndmuhylyhspfwtrkeybgfrehbbsrfrkipdkntluycezonnpshlpylanstyjzdisfislpkewygmyajyhegorloebnzschhdby".to_owned(),
            "ur:envelope/92-24/lpcshhcscscfaymhcygynbmteehdhhrylkssmkjtlahhswieeejkindyfgkspsmotpoeglryrhdtktstgdiofsatkojoahtigdcmttcldalsfwaefrrswpcsvygsjzfwimgheotsfpckiyfnurwmioetamolkktldwsfsptbtogdytzmfsbzjoaedmhkeejkwftnmudlcmaaoslnjllgtbuezczolo".to_owned(),
            "ur:envelope/94-24/lpcshycscscfaymhcygynbmteehdhhdraoenwntelscxaxssgumtcttkpkwswypmhfatrfjppdnnhhlpwyempemhgmpsihqzztfygwenecqzsrfzvlhewldniyjpynqzylrhmhbwkepsneurspvsihbstbgeuygycwgarfgoiyiyaturplpyfnmtsohhcfhsreadosateyehecdtnbyndystlecyre".to_owned(),
            "ur:envelope/95-24/lpcshecscscfaymhcygynbmteehdhhenzegdnbdptiwfsfsaaastrlghetfdguahhtlkrnjtlponjsdyvycyvdrfzonebeaddwgodwwtceoytnplfsbsqdkbcfbnlosgdrvsyahddnmoaymyfpgthfesfdvleoylrlveknwmsnoxmkvwrllgvdzscktddlhtcstebkwkkgmepfhlaobelrnbatsnhy".to_owned(),
            "ur:envelope/96-24/lpcshncscscfaymhcygynbmteehdhhetuyhfnetipeiaaaotcfptsszepksfkofroxkssebysnskcmfpbdfrsrltetzeftiaahmtsguedpnecwzsmhiaroylrlhfykhlhkmhtnrojtfhoyrornbdeedawplarhjkuyvwgmjyrfpasaghfphtparogssowtlyryaatotdtoztswkihfheweeckiwnws".to_owned(),
            "ur:envelope/97-24/lpcshscscscfaymhcygynbmteehdhhflpmbkdndresfriyoxkgkgdrbybbfesrmwlkcnbdfyvdlonsctmodilfieteonmecpgeqzpecfbehyfnflihntwdlbfdltsnemheehhtgmwmmylrfrwngsmyhdfpyafpbwuokgurzctnsfwfdnksotsnwzbbollbiovwsrmezmurhecscmqdadksqdlesbve".to_owned(),
            "ur:envelope/98-24/lpcsidcscscfaymhcygynbmteehdhhswaymdpdecrkieltghasstgaialpjsqdghgdahkgmugddwpaktbnnblyaejzmovdcyhenysbmuetmulrmelgvotysktpjkcaecjtwdenpfhtbgltbyaeynwnspgebdkecegsadzeuedwlfjlttwnswbtdplyzebtlraeaheeatbkkkguvecffzeyiyhlcpas".to_owned(),
            "ur:envelope/99-24/lpcsiacscscfaymhcygynbmteehdhheeielfamiefhsbskuywndrahcwoeteiyimmnehrnmumkswweytstdpttflbzktdylbiymezossmkrkjehyaalyhyahiahtmdynaanbeeptckktiahtjeasvthhghtopkmumnwkrsrdswdpwlmsihmymuaetkfxaoknchbbwfinptgdflkppaenguwdbatshl".to_owned(),
            "ur:envelope/100-24/lpcsiecscscfaymhcygynbmteehdhhuepegdmtrhssjzkpmohdrpmsfsneghincayalrrecatyospyrtfswkcfrfbgionnmydwgrckmwpartykgwbgpfzcuyehdttepkrnpleccfwfldemrnjsmodtadhkeewljotttybehnvsplollaylpaiaiymdjtrolfpsjthsdyztidihlktypetpberysark".to_owned(),
            "ur:envelope/101-24/lpcsihcscscfaymhcygynbmteehdhhjednrtottkaxzetddnprvajtaewmynwzpyfwrpynpmdlpfcasfrowybasfcfwpswdlwkjnfrrnfrgatkylctcmkswkcelrwftbaedybebertosmhdyimhejsqdwpleaxflgsfndetlfwaxsoythdgewppmkewkiekoseswaeclwksewegywnrkynsohpcwnb".to_owned(),
            "ur:envelope/102-24/lpcsiycscscfaymhcygynbmteehdhhgslsqdryryvlglimfxwlehjpjofwtdgoptmnoyhdaotowfonfgrnlrrygrfhcanbvtfmzeinnejouylrgtprtokittrspttdmkjlytdyplpsiycwfpntnthlfxknbzonvykkckldoelpqzqzdkhedtssvacsldgsguwnwklgtnoezsftrtoerptaahmnqzjl".to_owned(),
            "ur:envelope/103-24/lpcsiocscscfaymhcygynbmteehdhhtnryndvodmbavotlmdhkzskiaxdmjemsimgwzewpkginattobyhkcmtdfnesrpzshkrlfmprlrisvtgussmnaygesozehschtefewmjsftcnuouthfztvetsfxeydpgapedniyimtnmohyampltoihdmgstavwknwmwzencxrtlenscalrayhtcnaddrhfsn".to_owned(),
            "ur:envelope/104-24/lpcsiscscscfaymhcygynbmteehdhhfetiqztyvagojewngmbdhtdkytqdldtlbactutqzrffegoctsonyftehiydnynihsniosetkdmveoywepsrdehdnzezsfefduydrhhmudtgykpnssbftmylptafecpbewstkgtnylkcabshdfdenkoeootkoecuowlietbasmkmoaydtssjkdtylwmztetfg".to_owned(),
            "ur:envelope/105-24/lpcsincscscfaymhcygynbmteehdhhiymoeeutcpsrhlztbektjyoetktispstcfzeghqzrktkneihguisjtnepeihwkroykhdiasohpjlsnrltafxhsjnasiojklootchiamuttdnesgscafxlnnlehgygaecftahkbzcjpvyjscagoehtawljehnhelflbrpbwjkneztjnfnnnmdvwlyfzbahskt".to_owned(),
            "ur:envelope/106-24/lpcsimcscscfaymhcygynbmteehdhhwyvopdbkhshybbfnwepfehnspactplrsrptlvolbmhkeynndmhssrkcnghisrkahtnwzpdgtmdfhurbdgafyhfzedywsfpkkasonfrcyoenthlvoykbsrdfsgtammotakikodyjooyzedrgriaghghkijtdwmyghmyjspydygdsnsrvlhkpyenjotkeerdzm".to_owned(),
            "ur:envelope/107-24/lpcsjecscscfaymhcygynbmteehdhhhpdalpismhpfjelgengucnrodkhywdptlnoxhgmtynldjeuohgghpdghkbvsldfgkovtcmvltisrhhdttiwzmyaanbnsktctwybkjpdlskttdprthfeniefnvaisgssnchtighnskgfnlszoonihzeltkoctztiyvlbemtsoeokpjpehwtvolbtpbaztvtam".to_owned(),
            "ur:envelope/108-24/lpcsjzcscscfaymhcygynbmteehdhhuepegdmtrhssjzkpmohdrpmsfsneghincayalrrecatyospyrtfswkcfrfbgionnmydwgrckmwpartykgwbgpfzcuyehdttepkrnpleccfwfldemrnjsmodtadhkeewljotttybehnvsplollaylpaiaiymdjtrolfpsjthsdyztidihlktypetpgupauttb".to_owned(),
            "ur:envelope/109-24/lpcsjncscscfaymhcygynbmteehdhhiymoeeutcpsrhlztbektjyoetktispstcfzeghqzrktkneihguisjtnepeihwkroykhdiasohpjlsnrltafxhsjnasiojklootchiamuttdnesgscafxlnnlehgygaecftahkbzcjpvyjscagoehtawljehnhelflbrpbwjkneztjnfnnnmdvwlylkdywevy".to_owned(),
            "ur:envelope/110-24/lpcsjtcscscfaymhcygynbmteehdhhzswfgebyrnaxaduturfputtdytbyknwlmdckattlmkdscnswwmpmkbtauthsgdlsgyzemtieenetbgtkgynsmymnykptfsbzlodivtmdaabtgolngmvdfxhdvljlaefldpztvaqdfrgahfcaqdfyhkcxkgrkntjsfdgochbdbwlpltrspmmwwypeihietnrh".to_owned(),
            "ur:envelope/111-24/lpcsjlcscscfaymhcygynbmteehdhhlfcfaoaehkaxcxwylrbkwkndjsflldjsbzwlieghtajotbbygrdpmwcxntatkoolrehpoytpcynefekomyvwckdabbctbdjpfslnrketwncflbytlefrynvackfedtdraypykkhtoscsneienbpsfwiscwgomtdrbgpelkvodkmhqziavtoxpszcuywdaoem".to_owned(),
            "ur:envelope/112-24/lpcsjocscscfaymhcygynbmteehdhhpmvoimbbwkvlhfdydsflswsntehyzogulsmkfwimgwhsiyplkototsskztladriyonvdwyfgotvtsavdjyjlnegokebyahheiyiohlldcaftrnykcwhelklnqdchoncwuyltdtfxztsgkocllbmedprtaecwvdwfprqzwyrfoxnyhybzdtemflcwhffzeyin".to_owned(),
            "ur:envelope/113-24/lpcsjscscscfaymhcygynbmteehdhhcywzkscxpykidkluvanyascpmtlsdsidkklsbylatydymecsdlcngllpbafxcptdqzadbtguterehlqddytelfrlksrostbtamyldlgoetgybnytnluouytnhkqzrovtnsmuwksaeedkueaectotldhnuyrteoctjsmsdyinhgtbrtdrsgguimjswkrnrymo".to_owned(),
            "ur:envelope/114-24/lpcsjpcscscfaymhcygynbmteehdhhmhgwglzcttfsfemdwnmhrtwtdmoyjpgauyghsnnywyfyknaykewemdhgaodiytpdvtfzihfhzmzcvlrsnslpbnfdsalslujnahsbdpfxutsbwkkevwtbehmetibgrnzoptfhlbkozmecgyckcmimoyeslneysorpjliodadebbfskofwbsimwlsgenjzwstb".to_owned(),
            "ur:envelope/115-24/lpcsjkcscscfaymhcygynbmteehdhhhfatsbloiynysoeytaesjyfronwdiyzoctltkgylspfxfmgomtnykiwthtksotbnvyplsbmdgdtodmdrbewdeclylomhcfdsidmeontpfxlkmdqdtaplrhpmuedwnevlrscncssocptiadynvyflnydknnkbhhglsnrtfgsrbddeynmelrbegyaxtyprvwfm".to_owned(),
            "ur:envelope/116-24/lpcsjycscscfaymhcygynbmteehdhhcnhswminiyosurpavtttaedsghgldarlnyuemksbzsjtrkbgdybdltfleywpgtrychbzinberhisadhllgoeatdkeeecinveztstlnfpjnjzmorlsteedllacwsbwyjkrnlepfasidwfkskbpldeaxpakpldlbtdrovehncwfhosdemdiaaxgyrndwnsdegw".to_owned(),
            "ur:envelope/117-24/lpcskpcscscfaymhcygynbmteehdhhbycybsemoxahrfcksrcwcluobavwsebkrhksnydtqdwszepaeoyajpkeaohgiolfdlwnrtemjnhfyllbjyaaqdmnrplscxpszoeymhzturrfnyvochiedpcntteygrcydlhtztldiekpjtnlhsmkztcyjppdcmwfvypayncydyolcpfhdndtwzaooniydehl".to_owned(),
            "ur:envelope/118-24/lpcskocscscfaymhcygynbmteehdhhhtgooeolcxbttkpsmhnllaztghasfrgrcerkrllygmclsedmylgrcmsohemesgykleswkpetdndthldrfyaxrsgldweshlsfsswmntmhbzeopdztesurlkotcwfwhegrpmspprhnjkwtmtssbnjpkitnspasiebgprdepfmnbthelrsgpmihpyuykobnseah".to_owned(),
            "ur:envelope/119-24/lpcsktcscscfaymhcygynbmteehdhhrylkssmkjtlahhswieeejkindyfgkspsmotpoeglryrhdtktstgdiofsatkojoahtigdcmttcldalsfwaefrrswpcsvygsjzfwimgheotsfpckiyfnurwmioetamolkktldwsfsptbtogdytzmfsbzjoaedmhkeejkwftnmudlcmaaoslnjllgtbwzcsythy".to_owned(),
            "ur:envelope/120-24/lpcskscscscfaymhcygynbmteehdhhhgcnjtcwgdcpoeflpklpotgaaxcecpytmhfwahgoetjosfctfgtydkcymkcpeoylrhsbdwbzurdeiakshhbbdlzcectdtbgywtmdvwiocavsuodpntqzpmgmfnnnwndkcktpfpgtgtimhpoycsfncsfgaeaeaeaeaeaeaeaeaeaeaeaeaeaeaeaebbjkfhse".to_owned(),
            "ur:envelope/121-24/lpcskkcscscfaymhcygynbmteehdhhftimlgwkdndeihjsgeolwfdwjnsnkgdsjlwshtgsdybelbtkbycmtlgdcydrlrtpflhlotrfdyrhlavokpgtahhpbbahtlosieaxosseenvefzluwnhpvtesksgsykytgtdtmtpmynqdkefdoxclmkteylzesgsevozcvwwdenwzdwamlkhywzveutvshemh".to_owned(),
            "ur:envelope/122-24/lpcskncscscfaymhcygynbmteehdhhwkfzdkurjnsfjofrytfplajytklfgyiobakbgwfdeourlspebwzojtwphdgtlgzmhklbsecaryrlktfrhpdttyvemeiaioryctbkaspmpmbthnamdecwlfgdbkgalrghftfnnyvlprfplymdtbwftbrepeutmdgszovwkiptwemhsovwsohevtnyamjnjope".to_owned(),
            "ur:envelope/123-24/lpcskgcscscfaymhcygynbmteehdhhylkbbyltmeqdzolnaezcgavecasohsjpcnsrmeetdemwghpapkveveroesisfhhginosgthhhtpflaplhddyrkwybwnsolcmmwvemoaddyptenstmyykfmclpydsecsbteettltywfinhevyflnlttiosgskkpyayliysondzooywyyabtbtfmfhuezcfpyl".to_owned(),
            "ur:envelope/124-24/lpcskecscscfaymhcygynbmteehdhhssbzdkpfsftibkfsenfsfmketdcpuytscxoymndedaclknttaaioeeselsgednmugysbwztptocfrskbolrsolecrogtvseevdwmteadolclotcmfpgaotoyskgoptbekkutjturrohkbwghynksrylfwypmykuyuyvodadeynyagywmpfoezcmuctjpfmjo".to_owned(),
            "ur:envelope/125-24/lpcskicscscfaymhcygynbmteehdhhttolgwkgwmpskomoctguuoayahkehturgaynvlolyabgemfdwytigeemihbacfpespkkgamtwztliybdolfpihdtmtwnbtgtatzemdzebauyglfmkiaddslpmhzetlrkdmytkijowynliantpmjodkrsdphsmdtetdpkcsldfsnlrsgschtansonwyskgymy".to_owned(),
            "ur:envelope/126-24/lpcskbcscscfaymhcygynbmteehdhhoxmyfpzebdhhnbdkknjyytidgwremtbyckkolpdyspvewdenlychbyleykfwroehloltkgfhnelentfejepkfnbypfeojsbttekkbsonstvawpoyrknlsohesrtbgelgecehtpbgfnpylowkkgmkcxfrfgehmkcmhllghkeoltdlmyrkpfptcfyttsjetnjz".to_owned(),
            "ur:envelope/127-24/lpcslbcscscfaymhcygynbmteehdhhftrhgevdkkmhdrtiftnlpsmeadsoflfndtfzhhtlpsjlfpvlbautcxwtbgwprywzdegyvokgiyetpmhletolwmrfrsehamioaxchasgwdneciyteesmutsfmpkguiduyjywdcyuttechcmgddefnihrtpffsflpecepdkehdndrlhnuyoewyglfghlnbbyin".to_owned(),
            "ur:envelope/128-24/lpcslacscscfaymhcygynbmteehdhhgdmutlrhcwlghnwtpalrbglbbeyabwvadasbcnwptacfkilofdjnnbfdoygypkgdgobagamegodsuesrstyalppafrgoknzsahzmssjejosnkpemgwlbflqzwkyaldkkzmzmkeqdrosnlbcleysffghptljlglahbyiypfahoesotentpamomyghtksftdmu".to_owned(),
            "ur:envelope/129-24/lpcslycscscfaymhcygynbmteehdhhimatlblusbmuuyntsbryihaehhknwmghasoyonoxgsjobscftenblyiszemywdoxdicffewztsbdlazmiopkztntmkhkrnqddpetvafenswtntssbbueflwlceprfpqdweolctsemtbzmkhdcabatpskyakgeccsftwpwsvlclkilretcpaxztrywnlfosdl".to_owned(),
        )
    }

    #[tokio::test]
    async fn test_decode_qr() -> Result<()> {
        let decoder = get_qr_decoder().await;
        let ur_codes = get_test_array();

        for ur in ur_codes {
            let result = decode_qr(ur, &decoder.clone()).await?;

            println!("Progress: {}", result.progress);

            if result.progress == 1.0 {
                assert!(result.payload.is_some());
                println!("");
            } else {
                assert!(result.payload.is_none());
            }
        }

        Ok(())
    }
}
