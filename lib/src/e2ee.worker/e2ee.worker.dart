import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:js/js.dart';

import '../rtc_transform_stream.dart';
import 'e2ee.cryptor.dart';
import 'e2ee.participant_key_handler.dart';

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

var participantCryptors = <FrameCryptor>[];
var participantKeys = <String, ParticipantKeyHandler>{};
Map<String, bool> encryptionEnabledMap = {};
Uint8List sifTrailer = Uint8List(0);

KeyProviderOptions keyProviderOptions = KeyProviderOptions(
    sharedKey: true,
    ratchetSalt: Uint8List(0),
    ratchetWindowSize: 0,
    failureTolerance: -1);
bool useSharedKey = false;

void setEncryptionEnabled(bool enabled, String participantId) {
  encryptionEnabledMap[participantId] = enabled;
}

void unsetCryptorParticipant(trackId) {
  participantCryptors
      .firstWhereOrNull((c) => c.getTrackId() == trackId)
      ?.unsetParticipant();
}

ParticipantKeyHandler? getParticipantKeyHandler(String participantIdentity) {
  if (useSharedKey) {
    return getSharedKeyHandler();
  }
  var keys = participantKeys[participantIdentity];
  if (keys == null) {
    keys = ParticipantKeyHandler(keyProviderOptions, participantIdentity);
    if (sharedKey != null) {
      keys.setKey(sharedKey!);
    }
    //keys.on(KeyHandlerEvent.KeyRatcheted, emitRatchetedKeys);
    participantKeys[participantIdentity] = keys;
  }
  return keys;
}

ParticipantKeyHandler? sharedKeyHandler;
Uint8List? sharedKey;

ParticipantKeyHandler? getSharedKeyHandler() {
  sharedKeyHandler ??= ParticipantKeyHandler(keyProviderOptions, 'shared-key');
  return sharedKeyHandler;
}

void setSharedKey(Uint8List key, int? index) {
  sharedKey = key;
  getSharedKeyHandler()?.setKey(key, keyIndex: index!);
}

void handleRatchetRequest(int keyIndex, [String? participantIdentity]) async {
  if (useSharedKey) {
    var keyHandler = getSharedKeyHandler();
    await keyHandler?.ratchetKey(keyIndex);
    keyHandler?.resetKeyStatus();
  } else if (participantIdentity != null) {
    var keyHandler = getParticipantKeyHandler(participantIdentity);
    await keyHandler?.ratchetKey(keyIndex);
    keyHandler?.resetKeyStatus();
  } else {
    print(
        'no participant Id was provided for ratchet request and shared key usage is disabled');
  }
}

void handleSifTrailer(Uint8List trailer) {
  sifTrailer = trailer;
  participantCryptors.forEach((c) => c.setSifTrailer(trailer));
}

void main() async {
  print('E2EE Worker created');

  if (js_util.getProperty(self, 'RTCTransformEvent') != null) {
    print('setup transform event handler');
    self.onrtctransform = allowInterop((event) {
      print('got transform event');
      var transformer = (event as RTCTransformEvent).transformer;
      transformer.handled = true;
      var options = transformer.options;
      var kind = options.kind;
      var participantId = options.participantId;
      var trackId = options.trackId;
      var codec = options.codec;
      var msgType = options.msgType;

      var cryptor =
          participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);

      if (cryptor == null) {
        cryptor = FrameCryptor(
          keyHander: getParticipantKeyHandler(participantId)!,
          worker: self,
          participantIdentity: participantId,
          trackId: trackId,
          keyOptions: keyProviderOptions,
        );
        participantCryptors.add(cryptor);
      }

      cryptor.setupTransform(
          operation: msgType,
          readable: transformer.readable,
          writable: transformer.writable,
          trackId: trackId,
          kind: kind,
          codec: codec);
    });
  }

  self.onMessage.listen((e) {
    var msg = e.data;
    var msgType = msg['msgType'];
    switch (msgType) {
      case 'init':
        var options = msg['keyOptions'];
        keyProviderOptions = KeyProviderOptions(
            sharedKey: options['sharedKey'],
            ratchetSalt: Uint8List.fromList(
                base64Decode(options['ratchetSalt'] as String)),
            ratchetWindowSize: options['ratchetWindowSize'],
            failureTolerance: options['failureTolerance'] ?? -1,
            uncryptedMagicBytes: options['ratchetSalt'] != null
                ? Uint8List.fromList(
                    base64Decode(options['uncryptedMagicBytes'] as String))
                : null);
        useSharedKey = keyProviderOptions.sharedKey;
        print('worker: init with keyOptions ${keyProviderOptions.toString()}');
        break;
      case 'enable':
        {
          var enabled = msg['enabled'] as bool;
          var participantId = msg['participantId'] as String;
          print('worker: set enable $enabled for participantId $participantId');
          setEncryptionEnabled(enabled, participantId);
          self.postMessage({
            'type': 'cryptorEnabled',
            'participantId': participantId,
            'enable': enabled,
          });
        }
        break;
      case 'decode':
      case 'encode':
        {
          var kind = msg['kind'];
          var exist = msg['exist'] as bool;
          var participantId = msg['participantId'] as String;
          var trackId = msg['trackId'];
          var readable = msg['readableStream'] as ReadableStream;
          var writable = msg['writableStream'] as WritableStream;

          print(
              'worker: got $msgType, kind $kind, trackId $trackId, participantId $participantId, ${readable.runtimeType} ${writable.runtimeType}}');
          var cryptor =
              participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);

          if (cryptor == null) {
            cryptor = FrameCryptor(
                keyHander: getParticipantKeyHandler(participantId)!,
                worker: self,
                participantIdentity: participantId,
                trackId: trackId,
                keyOptions: keyProviderOptions);
            participantCryptors.add(cryptor);
          }
          if (!exist) {
            cryptor.setupTransform(
                operation: msgType,
                readable: readable,
                writable: writable,
                trackId: trackId,
                kind: kind);
          }
          cryptor.setParticipant(
              participantId, getParticipantKeyHandler(participantId)!);
          self.postMessage({
            'type': 'cryptorSetup',
            'participantId': participantId,
            'trackId': trackId,
            'exist': exist,
            'operation': msgType,
          });
          cryptor.lastError = CryptorError.kNew;
        }
        break;
      case 'removeTransform':
        {
          var trackId = msg['trackId'] as String;
          unsetCryptorParticipant(trackId);
        }
        break;
      case 'setKey':
        {
          var key = Uint8List.fromList(base64Decode(msg['key'] as String));
          var keyIndex = msg['keyIndex'];
          var participantId = msg['participantId'] as String;
          print('worker: setup key for participant $participantId');
          if (useSharedKey) {
            getSharedKeyHandler()?.setKey(key, keyIndex: keyIndex);
          } else {
            var keyHandler = getParticipantKeyHandler(participantId);
            keyHandler?.setKey(key, keyIndex: keyIndex);
          }
        }
        break;
      case 'setSharedKey':
        {
          var key = Uint8List.fromList(base64Decode(msg['key'] as String));
          var keyIndex = msg['keyIndex'];
          getSharedKeyHandler()?.setKey(key, keyIndex: keyIndex);
        }
        break;
      case 'ratchetKey':
        {
          var keyIndex = msg['keyIndex'];
          var participantId = msg['participantId'] as String;
          print(
              'worker: ratchetKey for participant $participantId, keyIndex $keyIndex');
          var keys = getParticipantKeyHandler(participantId);
          if (keys != null) {
            keys.ratchetKey(keyIndex).then((newKeySet) {
              self.postMessage({
                'type': 'ratchetKey',
                'participantId': participantId,
                'key': '',
              });
            });
          }
        }
        break;
      case 'ratchetSharedKey':
        {
          var keyIndex = msg['keyIndex'];
          var keys = getSharedKeyHandler();
          keys?.ratchetKey(keyIndex);
        }
        break;
      case 'setKeyIndex':
        {
          var keyIndex = msg['index'];
          var participantId = msg['participantId'] as String;
          print('worker: setup key index for participant $participantId');
          var keys = getParticipantKeyHandler(participantId);
          keys?.setCurrentKeyIndex(keyIndex);
        }
        break;
      case 'setSifTrailer':
        {
          var sifTrailer =
              Uint8List.fromList(base64Decode(msg['sifTrailer'] as String));
          keyProviderOptions.uncryptedMagicBytes = sifTrailer;
          for (var c in participantCryptors) {
            c.keyOptions.uncryptedMagicBytes = sifTrailer;
          }
        }
        break;
      case 'updateCodec':
        {
          var codec = msg['codec'] as String;
          var trackId = msg['trackId'] as String;
          print('worker: update codec for trackId $trackId, codec $codec');
          var cryptor =
              participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);
          cryptor?.updateCodec(codec);
        }
        break;
      case 'dispose':
        {
          var trackId = msg['trackId'] as String;
          print('worker: dispose trackId $trackId');
          var cryptor =
              participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);
          if (cryptor != null) {
            cryptor.lastError = CryptorError.kDisposed;
            self.postMessage({
              'type': 'cryptorDispose',
              'participantId': cryptor.participantIdentity,
              'trackId': trackId,
            });
          }
        }
        break;
      default:
        print('worker: unknown message kind $msg');
    }
  });
}
