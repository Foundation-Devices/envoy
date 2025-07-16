// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::sync::{Arc, Mutex};
use bc_envelope::prelude::*;
use bc_xid::XIDDocument;
use flutter_rust_bridge::for_generated::anyhow;
use foundation_api::message::{PassportMessage, QuantumLinkMessage};
use foundation_api::pairing::PairingResponse;
use foundation_api::passport::{PassportFirmwareVersion, PassportModel, PassportSerial};
use foundation_api::quantum_link::QuantumLinkIdentity;
use foundation_api::status::{DeviceState, DeviceStatus, EnvoyStatus};
use foundation_ur::{Decoder, UR};

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

        let cbor = CBOR::try_from_data(decoded)?;

        let envelope = Envelope::try_from_cbor(cbor)?;
        let xid_document = XIDDocument::from_unsigned_envelope(&envelope)?;

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

pub async fn decode_ble_message(data: Vec<u8>) -> PassportMessage {
    let msg = QuantumLinkMessage::PairingResponse(PairingResponse {
        passport_model: PassportModel::Gen1,
        passport_firmware_version: PassportFirmwareVersion("1.0.0".to_string()),
        passport_serial: PassportSerial("abc".to_string()),
        descriptor: "".to_string(),
    });
    PassportMessage::new(msg, DeviceStatus::new(DeviceState::Normal, 100, 100, "1.0.0".to_string()))
}


#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;
    use tokio::test;

    fn get_test_array() -> Vec<String> {
        vec!(
            "ur:envelope/1-15/lpadbscfaylgcywmzcdpfshdmotpsplftpsotanshdhdcxmwluotgrldhslskgglfgspwschisztecayytpsjtrflsgohpsoadlbfrlkbekgvwoyaylftpsotansgylftanshftanspdlfaohkahcxbwbynslrjpndsthenljystvycsdshfrtnsfxyaswclrdgaylfmknzmtttehyskytfrwmwnuyhfidrtoyottbmweyuyfwmnskpeetchgyiomurfhngycplsdnldeyiywernkedriojpiyrnhslrkstnjymktyfgfplrssylihretngdga".to_owned(),
            "ur:envelope/2-15/lpaobscfaylgcywmzcdpfshdmodlosjygmzoaxqdbecpiywdsbbycsdkdkmdsabzntlnwfsosohnwpwsspcntpfrbnkpsoeeialuvdbebkoxhposesplbyuomtssecynfxcmseldbwwfiddtseadfehkflielgvsutamenzctbctrhetfgbgwetnwnpapedtmuiahlbzbtuooyltbedmhpkgueutwmtivwgmsehhcyhprliypftkbtehmtfgsbwlswdtkbkeaxbslefltdgwemrpaskbgrgajesrhtpsnnjorhjomersgyrtjkrscfgletprft".to_owned(),
            "ur:envelope/3-15/lpaxbscfaylgcywmzcdpfshdmowyjsoywpimeydedrqzchfppmoyfelrfebdpkguonhlsfpyvdiekstbgsotdmfwzttownismhnymocsuyrsidesvsrpidlavwlufgfhbbhhnnvafyiogwtereptbkeomsheaaeydtmdrdcpvwfpvabwfzltdabscmrefmswvdtsidcnmospssvsjefrhnaabgmttisrgojlbbpraemuwehfjpvytokbinfslrdkrkoeswialklajppfadjtyabzbedyurcylnvwonmybkjzclkbfmfreccfrstlqznbrpembw".to_owned(),
            "ur:envelope/4-15/lpaabscfaylgcywmzcdpfshdmowdectnknroheemwzdyrpsnkpgtdmntcfredalocenbbtathdinhflkengmnsaywnnnhgdwuewffryahlftonwfnsbntdwpbegmaefswptoghhyhpvtolmwjzvdvdkobgztvyltwlwyrnayhpcfretpmokgsbvdzodrfssowkjsamutlyishgjpnytatpeowkfmbykburlbwldswsiofeuylezspffyptknroyldllrwdfetnwprladrlpddagljtdylydrcljzkockamcyurdysfotgrnnlgetkbdmhhnnta".to_owned(),
            "ur:envelope/5-15/lpahbscfaylgcywmzcdpfshdmogymtsbfzhpcknstahkpfhfmeetfrprjlkglofmsfnsremefhaxwlvwihgrfsskwdgdmnrdptuepmspglrkamstdrcfoxpteertenzcwywfcheykbtsinleghuyjyssmsssbwayatmtadchqdtklukgndfzstbbhygyluhnrluovacljetbzolnhptyrttikennwlhkyaghfwjzzolksaqdaxnnhsetadjtrsgauyclwzgmjpnswyhlcphewdgozscartflfmidwlynlfeszcgeishdmnsrbznnwkiomkatki".to_owned(),
            "ur:envelope/6-15/lpambscfaylgcywmzcdpfshdmorljkrtweropmgrgoctwshhrpfmlreyonhtmygmtadlhtjeiatyuobkdwdrdmwtvoztcpfdfwahcxprfxmhwzmdlgjziawlsodymkjewleccydkwpzesffgnejeoeynjsfzdtotaachhhmtieiefgcntavswsetceglzsdwimvoiysnenditohkvwmygsaasbkgckfwwybshpmevwfxlbjebwrkjntkvofzdevlrpembedkltcfrydkwnadmuhlwkdmmdcelrrpbdbwtdtdihloispttpdypleefnotwplngu".to_owned(),
            "ur:envelope/7-15/lpatbscfaylgcywmzcdpfshdmoehrnfmurntdpoegwktzctlemvohsgefrgwincytaaaolynjektrpamfekkjyyadwcxgrgwihtdfratzscshlfpgwjtmktofmrotolopfsfpamsglolbwglpslffskewmsblukogtiswtdwbthsmwkpdlbadwemtladwdenqdjnsgfpprrnasplfmsopmsgkgmhbsntmnstdicsylfwhdkbwnuoemsnttfwdlwfplntmscnlocncsdtgabajnhtbwpkdkotmendaojofnzcottdbbemesyaestpmepfaycxdm".to_owned(),
            "ur:envelope/8-15/lpaybscfaylgcywmzcdpfshdmowndyzszmmydtdmlkolmojsjkktdkwekoayfzvojtmnvdiyjnzmmygeksqzqdvlhgykidtekkfxdpstlyrtjzuehemhongupanbamoyihrfetiagmgojpgyvacfzshedrinhybnwzhnksswfpmhbdtpgyatlnmyhnuysbnszmlockwtloutrhtdcpamzmeofprfaefebetbdpvasknyuttotasarymeonaareuttbyapajeseaacagasbkpkbsasamnkgvdgwylpfhgwyfgmurphslbtlvardgwlkwkrdrhlo".to_owned(),
            "ur:envelope/9-15/lpasbscfaylgcywmzcdpfshdmosbuelntosnsbprdpfzdmaeothkfzylaxmopljofsgapfskdkahwlnlenftfscemugwqdlyknwtynfxtsjksbrdimhduepmsnstzomtgdrschosrtsnsgjztylgtodscahnaenbbeecytpsdyvogefzsgfnwdkigrfewdtkcknbfmaxlrckahmdoyqzbtmezsbaglykmdwljtqzjnsrrkaxdklfmhytlthpldesmtnetivastyttohdptgldmiontgwtbuosbckplwmlutljkidhgjlgsvarhhgptkerhlfpy".to_owned(),
            "ur:envelope/10-15/lpbkbscfaylgcywmzcdpfshdmomnfrfnfroyadwepeaaatkownfycyclcftlynwniotptphfktjeiatkfldwtshhdrecntpdlugrryzmlockwpgocfldonhflpcmhdlnoxwswnaarllgmdmkwktansonlfcfaoaehkaxcxlnnbhhvwhfhesemdfgndatihhyoyfhjksbjtaddeoenyrlnezsgrcwpfgroyntvdhyidzoretsmwghbsprpdjkknbnjzlefmwprllawmbdfmleuylyiyhgendadyrhdkfniabbsfjkenskinbkpamwlocwjokgvo".to_owned(),
            "ur:envelope/11-15/lpbdbscfaylgcywmzcdpfshdmoatihceromehkvdgtbygroybkdarhihldluehreaxvyhhfgrpptclhnbekikkceryvwlklnmtlarftofrindmluisesaaihoeeobzzmjodltsjzcyiyihbsrklpdetbaxpeihnldmvtadnnskfxktkegmcpmejkdrpswncnguhtcxgomdmkkbeykowlfwolrdfddlvecscyecemndldtphybbgapewmvtjnchptrfuorfbnhnjolupandmtpsaoosyngeinuteeeyiowlremhetmeehzoattaayoxismoeetb".to_owned(),
            "ur:envelope/12-15/lpbnbscfaylgcywmzcdpfshdmosefxgomutyjsiniypknnlfhglklrfljyihcycsndnemokocabzwlahcyotbznesphkosdafgyatyprfdiofzctbghkfhsemsdnidbdosflrfjnaxfzmniapmtscelssaaydmfdzorhtbemnddtzonnfhpdstctnsenmurpjytswnatatdyjzinvsadadbgltpsjsnevldrjygrosempsiaplghbbfmcljeckotjymwhldkdauovlntdtwdlukpemcmfpzocmkgetgtpsmugagamtlkmwspdpaefgdrfximwp".to_owned(),
            "ur:envelope/13-15/lpbtbscfaylgcywmzcdpfshdmooxdnzokphgfnrsynioishewzflcxdicevyaylafshklgtdvtsoiabbdagdbgpaksnbghbbhdclbduybggdfpbkbzgytkhdhdbawlrklulutajlpsoekkndftlkbtwmdwpmecoxgdcpluksfxlnclfgsbnsrlbswdlybgasjphtpypaetwlnyhnqddepmrytlrswdfnrostrhswoeiapdnsclpkftlkcktoimdtgtzspejzchjttnndkscklolucwtssseofdnbvwuygmcmgrjtjnmdswkbdadeenmtcscwvl".to_owned(),
            "ur:envelope/14-15/lpbabscfaylgcywmzcdpfshdmoaxoxgrtygrclhsecpecypswfbbdpsalnlsaobwrngofxhtkilkkiaofprsoycmamgmjomteomtkggljejpisoxosfxhssstkenjnqzecasyaadoyktfloeotkkbwfhmomtmeadgajtgdmtwmayiyehoxspnlkocxaegobslastrtdioekicyfepmkpdthklsflgsjphhjlpkidbzurwlndamyltkdwtbnylonlhyhsssecampkonzebwkedkaoplbsnblnvlwddwmyqzspongafduecsfrheattodpuoswvd".to_owned(),
            "ur:envelope/15-15/lpbsbscfaylgcywmzcdpfshdmoykpklrynosbymtgoldlorfaomerpoewzvwlyntmofecpwzseperkbzvtaakpaxgaheoniyhkynsajzasremtgtetaaindeeodasbidgupdlkmuoykijylthnvewplobyisrkrfdwcpasecfytaftgrimztlujebdjohtadgyrkbblnbzeclawpetbztbeccpfdqzpdnlnyjomnfgjemuetkolpoerpkghfkbhfcfcpuyglykfprpcsmouruorectfdnetadnspuybyvdbzfgsgbyoycsfncsfgaeeyryqdsw".to_owned(),
            "ur:envelope/16-15/lpbebscfaylgcywmzcdpfshdmoatihceromehkvdgtbygroybkdarhihldluehreaxvyhhfgrpptclhnbekikkceryvwlklnmtlarftofrindmluisesaaihoeeobzzmjodltsjzcyiyihbsrklpdetbaxpeihnldmvtadnnskfxktkegmcpmejkdrpswncnguhtcxgomdmkkbeykowlfwolrdfddlvecscyecemndldtphybbgapewmvtjnchptrfuorfbnhnjolupandmtpsaoosyngeinuteeeyiowlremhetmeehzoattaayoxyndetagl".to_owned(),
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
