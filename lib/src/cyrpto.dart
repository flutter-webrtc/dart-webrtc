import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as jsutil;
import 'dart:typed_data';

import 'package:js/js.dart';

@JS('Promise')
class Promise<T> {
  external factory Promise._();
}

@anonymous
@JS('CryptoKey')
class AesCryptoKey {}

@JS('crypto.subtle.encrypt')
external Promise<ByteBuffer> encrypt(
  dynamic algorithm,
  AesCryptoKey key,
  ByteBuffer data,
);

@JS('crypto.subtle.decrypt')
external Promise<ByteBuffer> decrypt(
  dynamic algorithm,
  AesCryptoKey key,
  ByteBuffer data,
);

@JS()
@anonymous
class AesGcmParams {
  external factory AesGcmParams({
    required String name,
    required ByteBuffer iv,
    ByteBuffer? additionalData,
    required int tagLength,
  });
}

ByteBuffer jsArrayBufferFrom(List<int> data) {
  // Avoid copying if possible
  if (data is Uint8List &&
      data.offsetInBytes == 0 &&
      data.lengthInBytes == data.buffer.lengthInBytes) {
    return data.buffer;
  }
  // Copy
  return Uint8List.fromList(data).buffer;
}

@JS('crypto.subtle.importKey')
external Promise<AesCryptoKey> importKey(
  String format,
  dynamic keyData,
  dynamic algorithm,
  bool extractable,
  List<String> keyUsages,
);

FutureOr<AesCryptoKey> cryptoKeyFromAesSecretKey(
  List<int> secretKeyData, {
  required String webCryptoAlgorithm,
}) async {
  return jsutil.promiseToFuture(importKey(
    'raw',
    jsArrayBufferFrom(secretKeyData),
    webCryptoAlgorithm,
    false,
    ['encrypt', 'decrypt'],
  ));
}
