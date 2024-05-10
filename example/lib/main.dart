import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:bytewords/bytewords.dart' as bytewords;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Uint8List sumResult;
  late String sumAsyncResult;

  @override
  void initState() {
    super.initState();
    sumResult = bytewords.bytewordsDecode(
        bytewords.BytewordsStyle.minimal, 'aeadaolazmjendeoti');
    sumAsyncResult =
        bytewords.bytewordsEncode(bytewords.BytewordsStyle.minimal, sumResult);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'decode aeadaolazmjendeoti = $sumResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'encode ($sumResult) = $sumAsyncResult',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
