import 'dart:html';
import 'dart:js_util' as jsutil;
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';

@JS('self')
external DedicatedWorkerGlobalScope get self;

void main() async {
  print('Worker created');

  var secretKey = await cryptoKeyFromAesSecretKey([
    200,
    244,
    58,
    72,
    214,
    245,
    86,
    82,
    192,
    127,
    23,
    153,
    167,
    172,
    122,
    234,
    140,
    70,
    175,
    74,
    61,
    11,
    134,
    58,
    185,
    102,
    172,
    17,
    11,
    6,
    119,
    253
  ], webCryptoAlgorithm: 'AES-GCM');

  var iv = makeIV();

  self.onMessage.listen((e) {
    var msg = e.data;
    var msgType = msg['msgType'];

    switch (msgType) {
      case 'decode':
      case 'encode':
        var kind = msg['kind'];
        var participantId = msg['participantId'];
        var trackId = msg['trackId'];
        var readable = msg['readableStream'] as ReadableStream;
        var writable = msg['writableStream'] as WritableStream;
        print(
            'worker: got $msgType, kind $kind, trackId $trackId, participantId $participantId, ${readable.runtimeType} ${writable.runtimeType}}');
        readable
            .pipeThrough(TransformStream(jsutil.jsify({
              'transform': allowInterop((RTCEncodedFrame frame,
                  TransformStreamDefaultController controller) async {
                var buffer = frame.data.asUint8List();
                var headerLength = kind == 'video' ? 10 : 1;
                var metaData = frame.getMetadata();

                if (msgType == 'encode') {
                  var cipherText =
                      await jsutil.promiseToFuture<ByteBuffer>(encrypt(
                    AesGcmParams(
                      name: 'AES-GCM',
                      iv: jsArrayBufferFrom(iv),
                      additionalData:
                          jsArrayBufferFrom(buffer.sublist(0, headerLength)),
                      tagLength: 128,
                    ),
                    secretKey,
                    jsArrayBufferFrom(
                        buffer.sublist(headerLength, buffer.length)),
                  ));

                  print(
                      'buffer: ${buffer.length}, cipherText: ${cipherText.asUint8List().length}');
                  var finalBuffer = BytesBuilder();

                  finalBuffer
                      .add(Uint8List.fromList(buffer.sublist(0, headerLength)));

                  finalBuffer.add(cipherText.asUint8List());
                  frame.data = jsArrayBufferFrom(finalBuffer.toBytes());

                  controller.enqueue(frame);
                } else {
                  var decrypted =
                      await jsutil.promiseToFuture<ByteBuffer>(decrypt(
                    AesGcmParams(
                      name: 'AES-GCM',
                      iv: jsArrayBufferFrom(iv),
                      additionalData:
                          jsArrayBufferFrom(buffer.sublist(0, headerLength)),
                      tagLength: 128,
                    ),
                    secretKey,
                    jsArrayBufferFrom(
                        buffer.sublist(headerLength, buffer.length)),
                  ));
                  print(
                      'buffer: ${buffer.length}, decrypted: ${decrypted.asUint8List().length}');
                  var finalBuffer = BytesBuilder();

                  finalBuffer
                      .add(Uint8List.fromList(buffer.sublist(0, headerLength)));

                  finalBuffer.add(decrypted.asUint8List());
                  frame.data = jsArrayBufferFrom(finalBuffer.toBytes());
                  controller.enqueue(frame);
                }

                print(
                    '$msgType => timestamp: ${frame.timestamp}, ssrc: ${metaData.synchronizationSource}, data length: ${buffer.length}, key ${secretKey.toString()} , iv ${iv.buffer.lengthInBytes}');
              })
            })))
            .pipeTo(writable);

        print('worker: enabling $kind for  $participantId $trackId');
        break;
      case 'removeTransform':
        var removeMsg = msg as RemoveTransformMessage;
        print(
            'worker: removing ${removeMsg.msgType} for ${removeMsg.participantId} ${removeMsg.trackId}');
        break;
      default:
        print('worker: unknown message kind ${msg.msgType}');
    }
    //print('worker: got ${dog.name} from master, raising it from ${dog.age}...');

    var olderDog = Dog(name: '2.0', age: 1);
    self.postMessage(olderDog);
  });
}

Uint8List makeIV() {
  var iv = Uint8List(12);
  var random = Random.secure();
  for (var i = 0; i < iv.length; i++) {
    iv[i] = random.nextInt(256);
  }
  return iv;
}
