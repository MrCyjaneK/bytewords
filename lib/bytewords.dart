import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'bytewords_bindings_generated.dart';

enum BytewordsStyle {
  standard,
  uri,
  minimal,
}

int _styleToInt(BytewordsStyle bs) => switch (bs) {
      BytewordsStyle.standard => bw_style_e.bw_standard,
      BytewordsStyle.uri => bw_style_e.bw_uri,
      BytewordsStyle.minimal => bw_style_e.bw_minimal,
    };

String bytewordsEncode(BytewordsStyle style, Uint8List inBuf) {
  final pointer = malloc.allocate<Uint8>(inBuf.length);
  for (var i = 0; i < inBuf.length; i++) {
    pointer[i] = inBuf[i];
  }
  // function call
  final char =
      _bindings.bytewords_encode(_styleToInt(style), pointer, inBuf.length);
  malloc.free(pointer);
  final str = char.cast<Utf8>().toDartString();
  malloc.free(char);
  return str;
}

Uint8List bytewordsDecode(BytewordsStyle style, String input) {
  // uint8_t** out_buf, size_t* out_len
  final input_ = input.toNativeUtf8();
  Pointer<Pointer<Uint8>> ptr = malloc.allocate(1);
  Pointer<Size> outLen = malloc.allocate(1);
  final status = _bindings.bytewords_decode(
      _styleToInt(style), input_.cast(), ptr, outLen);
  malloc.free(input_);
  if (status == false) {
    malloc.free(ptr);
    malloc.free(outLen);
    return Uint8List.fromList([]);
  }

  List<int> vals = [];
  final data = Pointer<Uint8>.fromAddress(ptr.value.address);
  for (var i = 0; i < outLen.value; i++) {
    vals.add(data[i]);
  }
  malloc.free(ptr);
  malloc.free(outLen);

  return Uint8List.fromList(vals);
}

const String _libName = 'bytewords';

/// The dynamic library in which the symbols for [BytewordsBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final BytewordsBindings _bindings = BytewordsBindings(_dylib);
