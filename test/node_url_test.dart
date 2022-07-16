import 'package:envoy/business/node_url.dart';
import 'package:test/test.dart';

void main() {
  test('Decode Raspiblitz URL test', () {
    var url =
        "ndf5676gpenlkwls2e74vnet7ivf2d6mdbhrs6cxvoixhohyuegnsfid.onion:50002:s";
    var bdkUrl =
        "ssl://ndf5676gpenlkwls2e74vnet7ivf2d6mdbhrs6cxvoixhohyuegnsfid.onion:50002";

    var parsedUrl = parseNodeUrl(url);
    expect(bdkUrl, parsedUrl);
  });

  test('Decode Umbrel Tor URL test', () {
    var url =
        "573odqf4s5y43leqi7cmh3srciwzevetitefwl5w4lvmrmozz6zoe6id.onion:50001:t";
    var bdkUrl =
        "tcp://573odqf4s5y43leqi7cmh3srciwzevetitefwl5w4lvmrmozz6zoe6id.onion:50001";

    var parsedUrl = parseNodeUrl(url);
    expect(bdkUrl, parsedUrl);
  });

  test('Decode Umbrel local URL test', () {
    var url = "pop-os.local:50001:t";
    var bdkUrl = "tcp://pop-os.local:50001";

    var parsedUrl = parseNodeUrl(url);
    expect(bdkUrl, parsedUrl);
  });

  test('Decode myNode URL test', () {
    var url =
        "bbcnewsd73hkzno2ini43t4gblxvycyac5aw4gnv7t2rccijh7745uqd.onion:50002:s";
    var bdkUrl =
        "ssl://bbcnewsd73hkzno2ini43t4gblxvycyac5aw4gnv7t2rccijh7745uqd.onion:50002";

    var parsedUrl = parseNodeUrl(url);
    expect(bdkUrl, parsedUrl);
  });

  test('Decode Start9 URL test', () {
    var url =
        "bbcnewsd73hkzno2ini43t4gblxvycyac5aw4gnv7t2rccijh7745uqd.onion:50002";
    var bdkUrl =
        "ssl://bbcnewsd73hkzno2ini43t4gblxvycyac5aw4gnv7t2rccijh7745uqd.onion:50002";

    var parsedUrl = parseNodeUrl(url);
    expect(bdkUrl, parsedUrl);
  });
}
