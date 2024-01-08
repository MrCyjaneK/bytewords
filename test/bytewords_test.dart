import 'dart:convert';

import 'package:bytewords/bytewords.dart';
import 'package:test/test.dart';

void main() {
  test('encoding (reference)', () {
    final data = hexToUint8List(
        'd99d6ca20150c7098580125e2ab0981253468b2dbc5202c11947da');
    assert(uint8ListToBytewords(data) ==
        'tunanextjazzoboeacidgoodslotaxislimplavabragholydoorpuffmonkbraggurufrogluaudroproofgrimalsosafecheffueltwinsoloaquaworkbald');
    assert(uint8ListToBytewordsShort(data) ==
        'tantjzoeadgdstaslplabghydrpfmkbggufgludprfgmaosecffltnsoaawkbd');
  });
  test('encode x decode tiny', () {
    final data = hexToUint8List('4141');
    final dec = uint8ListToBytewords(data);
    assert(dec == "flapflapparthorncolaruby");
    final decShort = uint8ListToBytewordsShort(data);
    assert(decShort == "fpfppthncary");
    final enc = uint8ListToHex(bytewordsToUint8List(dec));
    assert(enc == "4141");
    final encShort = uint8ListToHex(bytewordsToUint8List(decShort));
    assert(encShort == "4141");
  });
  test('decode', () {
    final data =
        'tunanextjazzoboeacidgoodslotaxislimplavabragholydoorpuffmonkbraggurufrogluaudroproofgrimalsosafecheffueltwinsoloaquaworkbald';
    final dec = uint8ListToHex(bytewordsToUint8List(data));
    assert(dec == "d99d6ca20150c7098580125e2ab0981253468b2dbc5202c11947da");
  });
  // test('urqr decode', () {
  // List<String> s = [
  //   'ur:debug/1-2/gsjljpihjncxinjojkkpjncxiejljzjljpcxjkinjycxhsjnihjydwcxiajljtjkihiajyihjykpjpcxhsieinjoinjkiainjtiocxihjzinjydmcxgthskpjpinjkcxinhsiakpjzinjkcxieinhsjncxiniecxjtinidiscxjnhsjzihjkkphsiehsdwcxjtjljtcxhsjzinjskphsjncxieinhsjncxhsjzinjskpihjydmcxgdjphsihjkihjtjy',
  //   'ur:debug/2-2/cxjzkpiajykpjkcxjyinjtiainiekpjtjycxiekpincxkoinjyhsihcxjoishsjpihjyjphsdmcxgdihjzjzihjtjyihjkjskpihcxishsidinjyhsjtjycxjnjljpidincxjyjpinjkjyinjskpihcxjkihjtihiajykpjkcxihjycxjtihjykpjkcxihjycxjnhsjzihjkkphsiehscx'
  // ];
  // final data = URQRToURQRData(s);
  // print(utf8.decode(data.data));
  // Lorem ipsum dolor sit amet, consectetur adimscing elit. Mauris iaculis diam id nibh malesuada, non aliquam diam aliquet. Pra luctus tincidunt dui vitae pharetra. Pellentesque habitant morbi tristique senectus et netus et males
  // });
}
