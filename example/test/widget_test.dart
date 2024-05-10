// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:bytewords/bytewords.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Uint8List input = Uint8List.fromList([0, 1, 2, 128, 255]);
  final inputLen = input.length;
  group('test1', () {
    test('test_encode(bw_standard)', () {
      const expectedResult = "able acid also lava zoom jade need echo taxi";
      final result = bytewordsEncode(BytewordsStyle.standard, input);
      assert(expectedResult == result, "invalid encode results");
    });
    test('test_encode(bw_uri)', () {
      const expectedResult = "able-acid-also-lava-zoom-jade-need-echo-taxi";
      final result = bytewordsEncode(BytewordsStyle.uri, input);
      assert(expectedResult == result, "invalid encode results");
    });

    test('test_encode(bw_minimal)', () {
      const expectedResult = "aeadaolazmjendeoti";
      final result = bytewordsEncode(BytewordsStyle.minimal, input);
      assert(expectedResult == result, "invalid encode results");
    });
  });

  group("test_decode", () {
    test('test_decode(bw_standard)', () {
      final result = bytewordsDecode(BytewordsStyle.standard,
          "able acid also lava zoom jade need echo taxi");
      assert(result == input, "invalid decode result");
    });
    test('test_decode(bw_uri)', () {
      final result = bytewordsDecode(
          BytewordsStyle.uri, "able-acid-also-lava-zoom-jade-need-echo-taxi");
      assert(result == input, "invalid decode result");
    });
    test('test_decode(bw_minimal)', () {
      final result =
          bytewordsDecode(BytewordsStyle.minimal, "aeadaolazmjendeoti");
      assert(result == input, "invalid decode result");
    });
  });

  group('bad checksum', () {
    test('test_decode(bw_standard)', () {
      final result = bytewordsDecode(BytewordsStyle.standard,
          "able acid also lava zero jade need echo wolf");
      assert(result.isEmpty, "non-empty invalid result");
    });
    test('test_decode(bw_uri)', () {
      final result = bytewordsDecode(
          BytewordsStyle.uri, "able-acid-also-lava-zero-jade-need-echo-wolf");
      assert(result.isEmpty, "non-empty invalid result");
    });

    test('test_decode(bw_minimal)', () {
      final result =
          bytewordsDecode(BytewordsStyle.minimal, "aeadaolazojendeowf");
      assert(result.isEmpty, "non-empty invalid result");
    });
  });

  group('too short', () {
    test('test_decode(bw_standard, "wolf")', () {
      final result = bytewordsDecode(BytewordsStyle.standard, "wolf");
      assert(result.isEmpty, "non-empty invalid result");
    });

    test('test_decode(bw_standard, "")', () {
      final result = bytewordsDecode(BytewordsStyle.standard, "");
      assert(result.isEmpty, "non-empty invalid result");
    });
  });
}
