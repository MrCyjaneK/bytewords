import 'dart:ffi';
import 'dart:typed_data';

import 'package:bytewords/src/external/crc32.dart';
import 'package:bytewords/src/wordlist.dart';

typedef ByteWords = String;

ByteWords uint8ListToBytewords(Uint8List list_) {
  List<int> list = [];
  list.addAll(list_.toList());
  final crc32 = hexToUint8List(Crc32.calculate(list).toRadixString(16));
  print(crc32.length);
  String str = '';
  for (var elm in list) {
    str += words[elm];
  }
  return str;
}

ByteWords uint8ListToBytewordsShort(Uint8List list) {
  String str = '';
  for (var elm in list) {
    str += words[elm][0] + words[elm][3];
  }
  return str;
}

Uint8List bytewordsToUint8List(ByteWords byteWords) {
  List<int> retList = [];

  for (var i = 0; i < byteWords.length;) {
    for (var j = 0; j < words.length; j++) {
      if (byteWords.substring(i, i + 4) == words[j]) {
        retList.add(j);
        break;
      } else if (byteWords.substring(i, i + 2) == words[j][0] + words[j][3]) {
        retList.add(j);
        break;
      }
    }
  }

  final checksum = hexToUint8List(
      Crc32.calculate(retList.take(retList.length - 5)).toRadixString(16));
  if (checksum[0] != retList[byteWords.length - 4] ||
      checksum[1] != retList[byteWords.length - 3] ||
      checksum[2] != retList[byteWords.length - 2] ||
      checksum[3] != retList[byteWords.length - 1]) {
    throw Exception("invalid bytewords");
  }
  return Uint8List.fromList(retList.take(retList.length - 4).toList());
}

Uint8List hexToUint8List(String hexString) {
  hexString = hexString.replaceAll(' ', '');
  final length = hexString.length;
  final result = Uint8List(length ~/ 2);
  for (var i = 0; i < length; i += 2) {
    final hex = hexString.substring(i, i + 2);
    final byte = int.parse(hex, radix: 16);
    result[i ~/ 2] = byte;
  }
  return result;
}

// ur:xmr-keyimage/1-2/lpad....ediao

List<String> uint8ListToURQR(Uint8List list, String tag,
    {int fragLenth = 130}) {
  List<String> retList = [];
  final frames = (list.length % fragLenth).ceil();
  int frame = 0;
  for (var i = 0; i < list.length; i += fragLenth) {
    var end = (i + fragLenth < list.length) ? i + fragLenth : list.length;
    var chunk = list.sublist(i, end);
    retList.add('ur:$tag/$frame-$frames/${uint8ListToBytewordsShort(chunk)}');
    frame++;
  }
  return retList;
}
