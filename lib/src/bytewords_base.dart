import 'dart:convert';
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

  for (var i = 0; i + 2 < byteWords.length;) {
    for (var j = 0; j < words.length; j++) {
      if (byteWords.substring(i, i + 2) == words[j][0] + words[j][3]) {
        i += 2;
        retList.add(j);
        break;
      } else if (byteWords.substring(i, i + 4) == words[j]) {
        i += 4;
        retList.add(j);
        break;
      }
    }
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
  int frames = 0;
  for (var i = 0; i < list.length; i += fragLenth) {
    frames++;
  }
  int frame = 1;
  for (var i = 0; i < list.length; i += fragLenth) {
    var end = (i + fragLenth < list.length) ? i + fragLenth : list.length;
    var chunk = list.sublist(i, end);
    retList.add('ur:$tag/$frame-$frames/${uint8ListToBytewordsShort(chunk)}');
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
