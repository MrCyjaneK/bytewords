import 'dart:math';
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
    str += words[elm]!;
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
    str += wordsShort[elm]!;
  }
  return str;
}

Uint8List bytewordsToUint8List(ByteWords byteWords, {required bool isLong}) {
  List<int> retList = [];
  for (var i = 0; i + (isLong ? 4 : 2) <= byteWords.length;) {
    if (!isLong) {
      if (wordsRevShort[byteWords.substring(i, i + 2)] != null) {
        retList.add(wordsRevShort[byteWords.substring(i, i + 2)]!);
        i += 2;
        continue;
      }
    } else {
      if (byteWords.length >= i + 4) {
        if (wordsRev[byteWords.substring(i, i + 4)] != null) {
          retList.add(wordsRev[byteWords.substring(i, i + 4)]!);
          i += 4;
          continue;
        }
      }
    }
  }
  if (retList.length < 4) return Uint8List.fromList([]);
  final checksum = hexToUint8List(
    Crc32.calculate(retList.take(retList.length - 4).toList())
        .toRadixString(16),
  );
  if (checksum[0] != retList[retList.length - 4] ||
      checksum[1] != retList[retList.length - 3] ||
      checksum[2] != retList[retList.length - 2] ||
      checksum[3] != retList[retList.length - 1]) {
    //throw Exception("invalid bytewords.");
    print("invalid bytewords");
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
  for (var i = 0; i < bw.length; i += fragLength) {
    retList.add(
        'ur:$tag/$frame-$frames/${bw.substring(i, min(i + fragLength, bw.length))}');
    frame++;
  }
  return retList;
}

class URQRData {
  URQRData(
      {required this.tag,
      required this.data,
      required this.str,
      required this.progress,
      required this.count,
      required this.error,
      required this.inputs});
  final String tag;
  final Uint8List data;
  final String str;
  final double progress;
  final int count;
  final String error;
  final List<String> inputs;
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "str": str,
      "data": data,
      "progress": progress,
      "count": count,
      "error": error,
      "inputs": inputs,
    };
  }
}

URQRData URQRToURQRData(List<String> urqr_) {
  final urqr = urqr_.toSet().toList();
  urqr.sort((s1, s2) {
    final s1s = s1.split("/");
    final s1frameStr = s1s[1].split("-");
    final s1curFrame = int.parse(s1frameStr[0]);
    final s2s = s2.split("/");
    final s2frameStr = s2s[1].split("-");
    final s2curFrame = int.parse(s2frameStr[0]);
    return s1curFrame - s2curFrame;
  });

  String tag = '';
  int count = 0;
  String bw = '';
  for (var elm in urqr) {
    final s = elm.substring(elm.indexOf(":") + 1); // strip down ur: prefix
    final s2 = s.split("/");
    tag = s2[0];
    final frameStr = s2[1].split("-");
    // final curFrame = int.parse(frameStr[0]);
    count = int.parse(frameStr[1]);
    final byteWords = s2[2];
    bw += byteWords;
  }
  Uint8List? data;
  String? error;
  if ((urqr.length / count) == 1) {
    try {
      data = bytewordsToUint8List(bw, isLong: false);
    } catch (e) {
      error = e.toString();
    }
  }
  return URQRData(
    tag: tag,
    str: bw,
    data: data ?? Uint8List.fromList([]),
    progress: count == 0 ? 0 : (urqr.length / count),
    count: count,
    error: error ?? "",
    inputs: urqr,
  );
}
