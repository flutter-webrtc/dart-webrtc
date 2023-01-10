import 'dart:js';
import 'dart:js_util';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_webrtc/dart_webrtc.dart';

final IV_LENGTH = 12;

class Cryptor {
  Cryptor(
      {required this.participantId,
      required this.trackId,
      required this.sharedKey,
      required this.kind,
      required this.secretKey,
      this.codec = 'vp8'});
  Map<int, int> sendCounts = {};
  final String participantId;
  String trackId;
  String codec;
  final bool sharedKey;
  final String kind;
  final AesCryptoKey secretKey;
  final int keyIndex = 0;

  Uint8List makeIv(
      {required int synchronizationSource, required int timestamp}) {
    var iv = ByteData(IV_LENGTH);

    // having to keep our own send count (similar to a picture id) is not ideal.
    if (sendCounts[synchronizationSource] == null) {
      // Initialize with a random offset, similar to the RTP sequence number.
      sendCounts[synchronizationSource] = Random.secure().nextInt(0xffff);
    }

    var sendCount = sendCounts[synchronizationSource] ?? 0;

    iv.setUint32(0, synchronizationSource);
    iv.setUint32(4, timestamp);
    iv.setUint32(8, sendCount % 0xffff);

    sendCounts[synchronizationSource] = sendCount + 1;

    return iv.buffer.asUint8List();
  }

  Future<void> setupTransform({
    required String operation,
    required ReadableStream readable,
    required WritableStream writable,
    required String trackId,
    String? codec,
  }) async {
    if (codec != null) {
      print('setting codec on cryptor to $codec');
      this.codec = codec;
    }
    try {
      var transformer = TransformStream(jsify({
        'transform': allowInterop(
            operation == 'encode' ? encodeFunction : decodeFunction)
      }));
      readable.pipeThrough(transformer).pipeTo(writable);
    } catch (e) {
      print('e ${e.toString()}');
    }
    this.trackId = trackId;
  }

  int getUnencryptedBytes(RTCEncodedFrame frame) {
    switch (frame.type) {
      case 'key':
        return 10;
      case 'delta':
        return 3;
      case 'audio':
        return 1; // frame.type is not set on audio, so this is set manually
      default:
        return 0;
    }
  }

  Future<void> encodeFunction(
    RTCEncodedFrame frame,
    TransformStreamDefaultController controller,
  ) async {
    var buffer = frame.data.asUint8List();
    var headerLength = kind == 'video' ? getUnencryptedBytes(frame) : 1;
    var metaData = frame.getMetadata();
    var iv = makeIv(
        synchronizationSource: metaData.synchronizationSource,
        timestamp: frame.timestamp);

    var frameTrailer = ByteData(2);
    frameTrailer.setInt8(0, IV_LENGTH);
    frameTrailer.setInt8(1, keyIndex);

    var cipherText = await promiseToFuture<ByteBuffer>(encrypt(
      AesGcmParams(
        name: 'AES-GCM',
        iv: jsArrayBufferFrom(iv),
        additionalData: jsArrayBufferFrom(buffer.sublist(0, headerLength)),
      ),
      secretKey,
      jsArrayBufferFrom(buffer.sublist(headerLength, buffer.length)),
    ));

    print(
        'buffer: ${buffer.length}, cipherText: ${cipherText.asUint8List().length}');
    var finalBuffer = BytesBuilder();

    finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
    finalBuffer.add(cipherText.asUint8List());
    finalBuffer.add(iv);
    finalBuffer.add(frameTrailer.buffer.asUint8List());
    frame.data = jsArrayBufferFrom(finalBuffer.toBytes());

    controller.enqueue(frame);

    print(
        'headerLength: $headerLength,  timestamp: ${frame.timestamp}, ssrc: ${metaData.synchronizationSource}, data length: ${buffer.length}, encrypted length: ${finalBuffer.toBytes().length}, key ${secretKey.toString()} , iv $iv');
  }

  Future<void> decodeFunction(
    RTCEncodedFrame frame,
    TransformStreamDefaultController controller,
  ) async {
    var buffer = frame.data.asUint8List();
    var headerLength = kind == 'video' ? getUnencryptedBytes(frame) : 1;
    var metaData = frame.getMetadata();

    var frameTrailer = buffer.sublist(buffer.length - 2);
    var ivLength = frameTrailer[0];
    var keyIndex = frameTrailer[1];
    var iv = buffer.sublist(buffer.length - ivLength - 2, buffer.length - 2);

    var decrypted = await promiseToFuture<ByteBuffer>(decrypt(
      AesGcmParams(
        name: 'AES-GCM',
        iv: jsArrayBufferFrom(iv),
        additionalData: jsArrayBufferFrom(buffer.sublist(0, headerLength)),
      ),
      secretKey,
      jsArrayBufferFrom(
          buffer.sublist(headerLength, buffer.length - ivLength - 2)),
    ));
    print(
        'buffer: ${buffer.length}, decrypted: ${decrypted.asUint8List().length}');
    var finalBuffer = BytesBuilder();

    finalBuffer.add(Uint8List.fromList(buffer.sublist(0, headerLength)));
    finalBuffer.add(decrypted.asUint8List());
    frame.data = jsArrayBufferFrom(finalBuffer.toBytes());
    controller.enqueue(frame);

    print(
        'headerLength: $headerLength, timestamp: ${frame.timestamp}, ssrc: ${metaData.synchronizationSource}, data length: ${buffer.length}, decrypted length: ${finalBuffer.toBytes().length}, key ${secretKey.toString()}, keyindex $keyIndex iv $iv');
  }
}
