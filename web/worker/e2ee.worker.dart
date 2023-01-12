import 'dart:html';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';

import 'cryptor.dart';

@JS('self')
external DedicatedWorkerGlobalScope get self;

void e2eeWorker() async {
  print('Worker created');

  var cryptors = <String, Cryptor>{};

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

  self.onMessage.listen((e) {
    var msg = e.data;
    var msgType = msg['msgType'];

    switch (msgType) {
      case 'decode':
      case 'encode':
        var kind = msg['kind'];
        var participantId = msg['participantId'] as String;
        var trackId = msg['trackId'];
        var readable = msg['readableStream'] as ReadableStream;
        var writable = msg['writableStream'] as WritableStream;
        var codec = msg['codec'] as String;
        print(
            'worker: got $msgType, kind $kind, trackId $trackId, participantId $participantId, ${readable.runtimeType} ${writable.runtimeType}}');
        var cryptor = Cryptor(
            participantId: participantId,
            trackId: trackId,
            kind: kind,
            secretKey: secretKey,
            sharedKey: false);
        cryptor.setupTransform(
            operation: msgType,
            readable: readable,
            writable: writable,
            trackId: trackId,
            codec: codec);
        cryptors[participantId] = cryptor;
        break;
      case 'removeTransform':
        var removeMsg = msg as RemoveTransformMessage;
        print(
            'worker: removing ${removeMsg.msgType} for ${removeMsg.participantId} ${removeMsg.trackId}');
        break;
      default:
        print('worker: unknown message kind ${msg.msgType}');
    }
    var olderDog = Dog(name: '2.0', age: 1);
    self.postMessage(olderDog);
  });
}
