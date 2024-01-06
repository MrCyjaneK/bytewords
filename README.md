# Bytewords: Encoding binary data as English words

> This is a dart implementation of [BlockchainCommons/Research/papers/bcr-2020-012-bytewords.md](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md)

## Usage

```dart
typedef ByteWords = String;
ByteWords uint8ListToBytewords(Uint8List list_);
ByteWords uint8ListToBytewordsShort(Uint8List list);
Uint8List bytewordsToUint8List(ByteWords byteWords); <--- throw's on checksum mismatch'
List<String> uint8ListToURQR(Uint8List list, String tag, {int fragLenth = 130}); <--- 'ur:${tag}/1-2/lpad....ediao'
class URQRData {
  final String tag;
  final Uint8List data;
  final double progress;
  final int count;
}
URQRData URQRToURQRData(List<String> urqr);
```