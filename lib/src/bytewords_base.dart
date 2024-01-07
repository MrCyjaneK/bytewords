import 'dart:typed_data';

import 'package:bytewords/src/external/crc32.dart';
import 'package:bytewords/src/wordlist.dart';

typedef ByteWords = String;

ByteWords uint8ListToBytewords(Uint8List list_) {
  List<int> list = [];
  list.addAll(list_.toList());
  final crc32 = hexToUint8List(Crc32.calculate(list).toRadixString(16));
  list.addAll(crc32);
  String str = '';
  for (var elm in list) {
    str += words[elm];
  }
  return str;
}

ByteWords uint8ListToBytewordsShort(Uint8List list_) {
  List<int> list = [];
  list.addAll(list_.toList());
  final crc32 = hexToUint8List(Crc32.calculate(list).toRadixString(16));
  list.addAll(crc32);
  String str = '';
  for (var elm in list) {
    str += words[elm][0] + words[elm][3];
  }
  return str;
}

Uint8List bytewordsToUint8List(ByteWords byteWords) {
  List<int> retList = [];
  bool isLong = false;
  for (var i = 0; i + (isLong ? 4 : 2) < byteWords.length;) {
    // print("$i ${byteWords.substring(i, i + 4)} or ${byteWords.substring(i, i + 2)}");
    if (wordsRev[byteWords.substring(i, i + 4)] != null) {
      retList.add(wordsRev[byteWords.substring(i, i + 4)]!);
      isLong = true;
      i += 4;
    } else if (wordsRevShort[byteWords.substring(i, i + 2)] != null) {
      isLong = false;
      retList.add(wordsRevShort[byteWords.substring(i, i + 2)]!);
      i += 2;
    }
  }
  // print(retList);
  final checksum = hexToUint8List(
    Crc32.calculate(retList.take(retList.length - 3).toList())
        .toRadixString(16),
  );
  // if (checksum[0] != retList[retList.length - 4] ||
  //     checksum[1] != retList[retList.length - 3] ||
  //     checksum[2] != retList[retList.length - 2] ||
  //     checksum[3] != retList[retList.length - 1]) {
  //   throw Exception("invalid bytewords");
  // }
  return Uint8List.fromList(retList.take(retList.length - 3).toList());
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

String uint8ListToHex(Uint8List uint8List) {
  final length = uint8List.length;
  final result = StringBuffer();
  for (var i = 0; i < length; i++) {
    final byte = uint8List[i];
    result.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return result.toString();
}

// ur:xmr-keyimage/1-2/lpad....ediao

List<String> uint8ListToURQR(Uint8List list, String tag,
    {int fragLength = 130}) {
  List<String> retList = [];
  final bw = uint8ListToBytewordsShort(list);
  int frames = 0;
  for (var i = 0; i < bw.length; i += fragLength) {
    frames++;
  }
  int frame = 1;
  for (var i = 0; i < bw.length; i += fragLength * 2) {
    var end = (i + fragLength < list.length) ? i + fragLength : list.length;
    retList.add('ur:$tag/$frame-$frames/${bw.substring(i, fragLength * 2)}');
    frame++;
  }
  return retList;
}

class URQRData {
  URQRData({
    required this.tag,
    required this.data,
    required this.progress,
    required this.count,
  });
  final String tag;
  final Uint8List data;
  final double progress;
  final int count;
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "data": data,
      "progress": progress,
      "count": count,
    };
  }
}

URQRData URQRToURQRData(List<String> urqr) {
  urqr.sort();
  List<int> data = [];
  String tag = '';
  int count = 0;
  for (var elm in urqr) {
    final s = elm.substring(elm.indexOf(":") + 1); // strip down ur: prefix
    final s2 = s.split("/");
    tag = s2[0];
    final frameStr = s2[1].split("-");
    final curFrame = int.parse(frameStr[0]);
    count = int.parse(frameStr[1]);
    final byteWords = s2[2];
    final bw = bytewordsToUint8List(byteWords);
    data.addAll(bw);
  }
  return URQRData(
      tag: tag,
      data: Uint8List.fromList(data),
      progress: urqr.length / count,
      count: count);
}
