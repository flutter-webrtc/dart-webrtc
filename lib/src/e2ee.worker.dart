import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';

import 'cryptor.dart';
import 'rtc_transform_stream.dart';

@JS()
abstract class TransformMessage {
  external String get msgType;
  external String get kind;
}

@anonymous
@JS()
class EnableTransformMessage {
  external factory EnableTransformMessage({
    ReadableStream readable,
    WritableStream writable,
    String msgType,
    String kind,
    String participantId,
    String trackId,
    String codec,
  });
  external ReadableStream get readable;
  external WritableStream get writable;
  external String get msgType; // 'encode' or 'decode'
  external String get participantId;
  external String get trackId;
  external String get kind;
  external String get codec;
}

@anonymous
@JS()
class RemoveTransformMessage {
  external factory RemoveTransformMessage(
      {String msgType, String participantId, String trackId});
  external String get msgType; // 'removeTransform'
  external String get participantId;
  external String get trackId;
}

@JS('self')
external html.DedicatedWorkerGlobalScope get self;

extension PropsRTCTransformEventHandler on html.DedicatedWorkerGlobalScope {
  set onrtctransform(Function(dynamic) callback) =>
      js_util.setProperty<Function>(this, 'onrtctransform', callback);
}

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

  print('setup transform event handler');
  if (js_util.getProperty(self, 'RTCTransformEvent') != null) {
    self.onrtctransform = allowInterop((event) {
      print('got transform event');
      var transformer = (event as RTCTransformEvent).transformer;
      print('transformer $transformer');
      transformer.handled = true;
      var options = transformer.options;
      var kind = options.kind;
      var participantId = options.participantId;
      var trackId = options.trackId;
      var codec = options.codec;
      var msgType = options.msgType;
      var cryptor = Cryptor(
          participantId: participantId,
          trackId: trackId,
          kind: kind,
          secretKey: secretKey,
          sharedKey: false);
      print('transform $codec');

      cryptor.setupTransform(
          operation: msgType,
          readable: transformer.readable,
          writable: transformer.writable,
          trackId: trackId,
          codec: codec);
      cryptors[participantId] = cryptor;
    });
  }

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
    self.postMessage({});
  });
}
