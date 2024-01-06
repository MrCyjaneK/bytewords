# Bytewords: Encoding binary data as English words

> This is a dart implementation of [BlockchainCommons/Research/papers/bcr-2020-012-bytewords.md](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-012-bytewords.md)

## Usage

```dart
typedef ByteWords = String;
ByteWords uint8ListToBytewords(Uint8List list_);
ByteWords uint8ListToBytewordsShort(Uint8List list);
Uint8List bytewordsToUint8List(ByteWords byteWords);
```

Functions do what you would expect them to do. There is no error handling, we trust you to provide the correct string.