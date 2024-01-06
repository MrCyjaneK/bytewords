import 'package:bytewords/bytewords.dart';
import 'package:test/test.dart';

void main() {
  test('encoding (reference)', () {
    final data = hexToUint8List(
        'd99d6ca20150c7098580125e2ab0981253468b2dbc5202c11947da');
    assert(uint8ListToBytewords(data) ==
        'tunanextjazzoboeacidgoodslotaxislimplavabragholydoorpuffmonkbraggurufrogluaudroproofgrimalsosafecheffueltwin');
    assert(uint8ListToBytewordsShort(data) ==
        'tantjzoeadgdstaslplabghydrpfmkbggufgludprfgmaosecffltn');
  });
}
