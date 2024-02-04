import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_webrtc/src/rtc_transform_stream.dart';
import 'package:js/js.dart';
import 'package:logging/logging.dart';

import 'e2ee.cryptor.dart';
import 'e2ee.keyhandler.dart';
import 'e2ee.logger.dart';

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
ParticipantKeyHandler? sharedKeyHandler;
var sharedKey = Uint8List(0);

KeyOptions keyProviderOptions = KeyOptions(
  sharedKey: true,
  ratchetSalt: Uint8List.fromList('ratchetSalt'.codeUnits),
  ratchetWindowSize: 16,
  failureTolerance: -1,
);

ParticipantKeyHandler getParticipantKeyHandler(String participantIdentity) {
  if (keyProviderOptions.sharedKey) {
    return getSharedKeyHandler();
  }
  var keys = participantKeys[participantIdentity];
  if (keys == null) {
    keys = ParticipantKeyHandler(
      worker: self,
      participantIdentity: participantIdentity,
      keyOptions: keyProviderOptions,
    );
    if (sharedKey.isNotEmpty) {
      keys.setKey(sharedKey);
    }
    //keys.on(KeyHandlerEvent.KeyRatcheted, emitRatchetedKeys);
    participantKeys[participantIdentity] = keys;
  }
  return keys;
}

FrameCryptor getTrackCryptor(String participantIdentity, String trackId) {
  var cryptor =
      participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);
  if (cryptor == null) {
    logger.info(
        'creating new cryptor for $participantIdentity, trackId $trackId');

    cryptor = FrameCryptor(
      worker: self,
      participantIdentity: participantIdentity,
      trackId: trackId,
      keyHandler: getParticipantKeyHandler(participantIdentity),
    );
    //setupCryptorErrorEvents(cryptor);
    participantCryptors.add(cryptor);
  } else if (participantIdentity != cryptor.participantIdentity) {
    // assign new participant id to track cryptor and pass in correct key handler
    cryptor.setParticipant(
        participantIdentity, getParticipantKeyHandler(participantIdentity));
  }
  if (keyProviderOptions.sharedKey) {}
  return cryptor;
}

void unsetCryptorParticipant(String trackId) {
  participantCryptors
      .firstWhereOrNull((c) => c.trackId == trackId)
      ?.unsetParticipant();
}

ParticipantKeyHandler getSharedKeyHandler() {
  sharedKeyHandler ??= ParticipantKeyHandler(
    worker: self,
    participantIdentity: 'shared-key',
    keyOptions: keyProviderOptions,
  );
  return sharedKeyHandler!;
}

void setSharedKey(Uint8List key, {int keyIndex = 0}) {
  logger.info('setting shared key');
  sharedKey = key;
  getSharedKeyHandler().setKey(key, keyIndex: keyIndex);
}

void main() async {
  // configure logs for debugging
  Logger.root.level = Level.CONFIG;
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  logger.info('Worker created');

  if (js_util.getProperty(self, 'RTCTransformEvent') != null) {
    logger.info('setup RTCTransformEvent event handler');
    self.onrtctransform = allowInterop((event) {
      logger.info('Got onrtctransform event');
      var transformer = (event as RTCTransformEvent).transformer;
      transformer.handled = true;
      var options = transformer.options;
      var kind = options.kind;
      var participantId = options.participantId;
      var trackId = options.trackId;
      var codec = options.codec;
      var msgType = options.msgType;

      var cryptor = getTrackCryptor(participantId, trackId);

      cryptor.setupTransform(
          operation: msgType,
          readable: transformer.readable,
          writable: transformer.writable,
          trackId: trackId,
          kind: kind,
          codec: codec);
    });
  }

  self.onMessage.listen((e) async {
    var msg = e.data;
    var msgType = msg['msgType'];
    var msgId = msg['msgId'] as String?;
    logger.info('Got message $msgType, msgId $msgId');
    switch (msgType) {
      case 'init':
        var options = msg['keyOptions'];
        keyProviderOptions = KeyOptions(
            sharedKey: options['sharedKey'],
            ratchetSalt: Uint8List.fromList(
                base64Decode(options['ratchetSalt'] as String)),
            ratchetWindowSize: options['ratchetWindowSize'],
            failureTolerance: options['failureTolerance'] ?? -1,
            uncryptedMagicBytes: options['uncryptedMagicBytes'] != null
                ? Uint8List.fromList(
                    base64Decode(options['uncryptedMagicBytes'] as String))
                : null);
        logger.config(
            'Init with keyProviderOptions:\n ${keyProviderOptions.toString()}');
        self.postMessage({
          'type': 'init',
          'msgId': msgId,
          'msgType': 'response',
        });
        break;
      case 'enable':
        {
          var enabled = msg['enabled'] as bool;
          var participantId = msg['participantId'] as String;

          var cryptors = participantCryptors
              .where((c) => c.participantIdentity == participantId)
              .toList();
          for (var cryptor in cryptors) {
            logger.config(
                'Set enable $enabled for participantId $participantId, trackId ${cryptor.trackId}');
            cryptor.setEnabled(enabled);
          }
          self.postMessage({
            'type': 'cryptorEnabled',
            'participantId': participantId,
            'enable': enabled,
            'msgId': msgId,
            'msgType': 'response',
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

          logger.config(
              'SetupTransform for kind $kind, trackId $trackId, participantId $participantId, ${readable.runtimeType} ${writable.runtimeType}}');

          var cryptor = getTrackCryptor(participantId, trackId);

          await cryptor.setupTransform(
              operation: msgType,
              readable: readable,
              writable: writable,
              trackId: trackId,
              kind: kind);

          self.postMessage({
            'type': 'cryptorSetup',
            'participantId': participantId,
            'trackId': trackId,
            'exist': exist,
            'operation': msgType,
            'msgId': msgId,
            'msgType': 'response',
          });
          cryptor.lastError = CryptorError.kNew;
        }
        break;
      case 'removeTransform':
        {
          var trackId = msg['trackId'] as String;
          logger.config('Removing trackId $trackId');
          unsetCryptorParticipant(trackId);
          self.postMessage({
            'type': 'cryptorRemoved',
            'trackId': trackId,
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'setKey':
      case 'setSharedKey':
        {
          var key = Uint8List.fromList(base64Decode(msg['key'] as String));
          var keyIndex = msg['keyIndex'] as int;
          if (keyProviderOptions.sharedKey) {
            logger.config('Set SharedKey keyIndex $keyIndex');
            setSharedKey(key, keyIndex: keyIndex);
          } else {
            var participantId = msg['participantId'] as String;
            logger.config(
                'Set key for participant $participantId, keyIndex $keyIndex');
            await getParticipantKeyHandler(participantId)
                .setKey(key, keyIndex: keyIndex);
          }

          self.postMessage({
            'type': 'setKey',
            'participantId': msg['participantId'],
            'sharedKey': keyProviderOptions.sharedKey,
            'keyIndex': keyIndex,
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'ratchetKey':
      case 'ratchetSharedKey':
        {
          var keyIndex = msg['keyIndex'];
          var participantId = msg['participantId'] as String;
          Uint8List? newKey;
          if (keyProviderOptions.sharedKey) {
            logger.config('RatchetKey for SharedKey, keyIndex $keyIndex');
            newKey = await getSharedKeyHandler().ratchetKey(keyIndex);
          } else {
            logger.config(
                'RatchetKey for participant $participantId, keyIndex $keyIndex');
            newKey = await getParticipantKeyHandler(participantId)
                .ratchetKey(keyIndex);
          }

          self.postMessage({
            'type': 'ratchetKey',
            'sharedKey': keyProviderOptions.sharedKey,
            'participantId': participantId,
            'newKey': newKey != null ? base64Encode(newKey) : '',
            'keyIndex': keyIndex,
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'setKeyIndex':
        {
          var keyIndex = msg['index'];
          var participantId = msg['participantId'] as String;
          logger.config('Setup key index for participant $participantId');
          var cryptors = participantCryptors
              .where((c) => c.participantIdentity == participantId)
              .toList();
          for (var c in cryptors) {
            logger.config(
                'Set keyIndex for participantId $participantId, trackId ${c.trackId}');
            c.setKeyIndex(keyIndex);
          }

          self.postMessage({
            'type': 'setKeyIndex',
            'participantId': participantId,
            'keyIndex': keyIndex,
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'exportKey':
      case 'exportSharedKey':
        {
          var keyIndex = msg['keyIndex'] as int;
          var participantId = msg['participantId'] as String;
          Uint8List? key;
          if (keyProviderOptions.sharedKey) {
            logger.config('Export SharedKey keyIndex $keyIndex');
            key = await getSharedKeyHandler().exportKey(keyIndex);
          } else {
            logger.config(
                'Export key for participant $participantId, keyIndex $keyIndex');
            key = await getParticipantKeyHandler(participantId)
                .exportKey(keyIndex);
          }
          self.postMessage({
            'type': 'exportKey',
            'participantId': participantId,
            'keyIndex': keyIndex,
            'exportedKey': key != null ? base64Encode(key) : '',
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'setSifTrailer':
        {
          var sifTrailer =
              Uint8List.fromList(base64Decode(msg['sifTrailer'] as String));
          keyProviderOptions.uncryptedMagicBytes = sifTrailer;
          logger.config('SetSifTrailer = $sifTrailer');
          for (var c in participantCryptors) {
            c.setSifTrailer(sifTrailer);
          }

          self.postMessage({
            'type': 'setSifTrailer',
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'updateCodec':
        {
          var codec = msg['codec'] as String;
          var trackId = msg['trackId'] as String;
          logger.config('Update codec for trackId $trackId, codec $codec');
          var cryptor =
              participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);
          cryptor?.updateCodec(codec);

          self.postMessage({
            'type': 'updateCodec',
            'msgId': msgId,
            'msgType': 'response',
          });
        }
        break;
      case 'dispose':
        {
          var trackId = msg['trackId'] as String;
          logger.config('Dispose for trackId $trackId');
          var cryptor =
              participantCryptors.firstWhereOrNull((c) => c.trackId == trackId);
          if (cryptor != null) {
            cryptor.lastError = CryptorError.kDisposed;
            self.postMessage({
              'type': 'cryptorDispose',
              'participantId': cryptor.participantIdentity,
              'trackId': trackId,
              'msgId': msgId,
              'msgType': 'response',
            });
          } else {
            self.postMessage({
              'type': 'cryptorDispose',
              'error': 'cryptor not found',
              'msgId': msgId,
              'msgType': 'response',
            });
          }
        }
        break;
      default:
        logger.warning('Unknown message kind $msg');
    }
  });
}
