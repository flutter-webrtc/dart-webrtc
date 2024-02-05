import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_webrtc/src/event.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'rtc_transform_stream.dart';
import 'utils.dart';

class WorkerResponse {
  WorkerResponse(this.msgId, this.data);
  String msgId;
  dynamic data;
}

extension RtcRtpReceiverExt on html.RtcRtpReceiver {
  static Map<int, ReadableStream> readableStreams_ = {};
  static Map<int, WritableStream> writableStreams_ = {};

  ReadableStream? get readable {
    if (readableStreams_.containsKey(hashCode)) {
      return readableStreams_[hashCode]!;
    }
    return null;
  }

  WritableStream? get writable {
    if (writableStreams_.containsKey(hashCode)) {
      return writableStreams_[hashCode]!;
    }
    return null;
  }

  set readableStream(ReadableStream stream) {
    readableStreams_[hashCode] = stream;
  }

  set writableStream(WritableStream stream) {
    writableStreams_[hashCode] = stream;
  }

  void closeStreams() {
    readableStreams_.remove(hashCode);
    writableStreams_.remove(hashCode);
  }
}

extension RtcRtpSenderExt on html.RtcRtpSender {
  static Map<int, ReadableStream> readableStreams_ = {};
  static Map<int, WritableStream> writableStreams_ = {};

  ReadableStream? get readable {
    if (readableStreams_.containsKey(hashCode)) {
      return readableStreams_[hashCode]!;
    }
    return null;
  }

  WritableStream? get writable {
    if (writableStreams_.containsKey(hashCode)) {
      return writableStreams_[hashCode]!;
    }
    return null;
  }

  set readableStream(ReadableStream stream) {
    readableStreams_[hashCode] = stream;
  }

  set writableStream(WritableStream stream) {
    writableStreams_[hashCode] = stream;
  }

  void closeStreams() {
    readableStreams_.remove(hashCode);
    writableStreams_.remove(hashCode);
  }
}

class FrameCryptorImpl extends FrameCryptor {
  FrameCryptorImpl(
      this._factory, this.worker, this._participantId, this._trackId,
      {this.jsSender, this.jsReceiver, required this.keyProvider});
  html.Worker worker;
  bool _enabled = false;
  int _keyIndex = 0;
  final String _participantId;
  final String _trackId;
  final html.RtcRtpSender? jsSender;
  final html.RtcRtpReceiver? jsReceiver;
  final FrameCryptorFactoryImpl _factory;
  final KeyProviderImpl keyProvider;

  @override
  Future<void> dispose() async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'dispose',
        'msgId': msgId,
        'trackId': _trackId,
      })
    ]);
    _factory.removeFrameCryptor(_trackId);
    return;
  }

  @override
  Future<bool> get enabled => Future(() => _enabled);

  @override
  Future<int> get keyIndex => Future(() => _keyIndex);

  @override
  String get participantId => _participantId;

  String get trackId => _trackId;

  @override
  Future<bool> setEnabled(bool enabled) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'enable',
        'msgId': msgId,
        'trackId': _trackId,
        'enabled': enabled
      })
    ]);
    _enabled = enabled;
    return true;
  }

  @override
  Future<bool> setKeyIndex(int index) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setKeyIndex',
        'msgId': msgId,
        'trackId': _trackId,
        'index': index,
      })
    ]);
    _keyIndex = index;
    return true;
  }

  @override
  Future<void> updateCodec(String codec) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'updateCodec',
        'msgId': msgId,
        'trackId': _trackId,
        'codec': codec,
      })
    ]);
  }
}

class KeyProviderImpl implements KeyProvider {
  KeyProviderImpl(this._id, this.worker, this.options, this.events);
  final String _id;
  final html.Worker worker;
  final KeyProviderOptions options;
  final Map<String, List<Uint8List>> _keys = {};
  final EventsEmitter<WorkerResponse> events;

  @override
  String get id => _id;

  Future<void> init() async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'keyProviderInit',
        'msgId': msgId,
        'keyProviderId': id,
        'keyOptions': {
          'sharedKey': options.sharedKey,
          'ratchetSalt': base64Encode(options.ratchetSalt),
          'ratchetWindowSize': options.ratchetWindowSize,
          if (options.uncryptedMagicBytes != null)
            'uncryptedMagicBytes': base64Encode(options.uncryptedMagicBytes!),
        },
      })
    ]);

    await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));
  }

  @override
  Future<void> dispose() async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'keyProviderDispose',
        'msgId': msgId,
        'keyProviderId': id,
      })
    ]);

    await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    _keys.clear();
  }

  @override
  Future<bool> setKey(
      {required String participantId,
      required int index,
      required Uint8List key}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setKey',
        'msgId': msgId,
        'keyProviderId': id,
        'participantId': participantId,
        'keyIndex': index,
        'key': base64Encode(key),
      })
    ]);

    await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    _keys[participantId] ??= [];
    if (_keys[participantId]!.length <= index) {
      _keys[participantId]!.add(key);
    } else {
      _keys[participantId]![index] = key;
    }
    return true;
  }

  @override
  Future<Uint8List> ratchetKey(
      {required String participantId, required int index}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'ratchetKey',
        'msgId': msgId,
        'keyProviderId': id,
        'participantId': participantId,
        'keyIndex': index,
      })
    ]);

    var res = await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    return base64Decode(res.data['newKey']);
  }

  @override
  Future<Uint8List> exportKey(
      {required String participantId, required int index}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'exportKey',
        'msgId': msgId,
        'keyProviderId': id,
        'participantId': participantId,
        'keyIndex': index,
      })
    ]);

    var res = await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    return base64Decode(res.data['exportedKey']);
  }

  @override
  Future<Uint8List> exportSharedKey({int index = 0}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'exportSharedKey',
        'msgId': msgId,
        'keyProviderId': id,
        'keyIndex': index,
      })
    ]);

    var res = await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    return base64Decode(res.data['exportedKey']);
  }

  @override
  Future<Uint8List> ratchetSharedKey({int index = 0}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'ratchetSharedKey',
        'msgId': msgId,
        'keyProviderId': id,
        'keyIndex': index,
      })
    ]);
    var res = await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));

    return base64Decode(res.data['newKey']);
  }

  @override
  Future<void> setSharedKey({required Uint8List key, int index = 0}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setSharedKey',
        'msgId': msgId,
        'keyProviderId': id,
        'keyIndex': index,
        'key': base64Encode(key),
      })
    ]);

    await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));
  }

  @override
  Future<void> setSifTrailer({required Uint8List trailer}) async {
    var msgId = randomString(12);
    jsutil.callMethod(worker, 'postMessage', [
      jsutil.jsify({
        'msgType': 'setSifTrailer',
        'msgId': msgId,
        'keyProviderId': id,
        'sifTrailer': base64Encode(trailer),
      })
    ]);

    await events.waitFor<WorkerResponse>(
        filter: (event) => event.msgId == msgId,
        duration: Duration(seconds: 5));
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal() {
    worker = html.Worker('e2ee.worker.dart.js');
    worker.onMessage.listen((msg) {
      print('master got ${msg.data}');
      var type = msg.data['type'];
      var msgId = msg.data['msgId'];
      var msgType = msg.data['msgType'];

      if (msgType == 'response') {
        events.emit(WorkerResponse(msgId, msg.data));
      } else if (msgType == 'event') {
        if (type == 'cryptorState') {
          var trackId = msg.data['trackId'];
          var participantId = msg.data['participantId'];
          var frameCryptor = _frameCryptors.values.firstWhereOrNull(
              (element) => (element as FrameCryptorImpl).trackId == trackId);
          var state = msg.data['state'];
          var frameCryptorState = FrameCryptorState.FrameCryptorStateNew;
          switch (state) {
            case 'ok':
              frameCryptorState = FrameCryptorState.FrameCryptorStateOk;
              break;
            case 'decryptError':
              frameCryptorState =
                  FrameCryptorState.FrameCryptorStateDecryptionFailed;
              break;
            case 'encryptError':
              frameCryptorState =
                  FrameCryptorState.FrameCryptorStateEncryptionFailed;
              break;
            case 'missingKey':
              frameCryptorState = FrameCryptorState.FrameCryptorStateMissingKey;
              break;
            case 'internalError':
              frameCryptorState =
                  FrameCryptorState.FrameCryptorStateInternalError;
              break;
            case 'keyRatcheted':
              frameCryptorState =
                  FrameCryptorState.FrameCryptorStateKeyRatcheted;
              break;
          }
          frameCryptor?.onFrameCryptorStateChanged
              ?.call(participantId, frameCryptorState);
        }
      }
    });
    worker.onError.listen((err) {
      print('worker error: $err');
    });
  }

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();

  late html.Worker worker;
  final Map<String, FrameCryptor> _frameCryptors = {};
  final EventsEmitter<WorkerResponse> events = EventsEmitter<WorkerResponse>();

  @override
  Future<KeyProvider> createDefaultKeyProvider(
      KeyProviderOptions options) async {
    var keyProvider =
        KeyProviderImpl(randomString(12), worker, options, events);
    await keyProvider.init();
    return keyProvider;
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver(
      {required String participantId,
      required RTCRtpReceiver receiver,
      required Algorithm algorithm,
      required KeyProvider keyProvider}) {
    var jsReceiver = (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    var trackId = jsReceiver.hashCode.toString();
    var kind = jsReceiver.track!.kind!;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var msgId = randomString(12);
      var options = {
        'msgType': 'decode',
        'msgId': msgId,
        'keyProviderId': (keyProvider as KeyProviderImpl).id,
        'kind': kind,
        'participantId': participantId,
        'trackId': trackId,
      };
      jsutil.setProperty(jsReceiver, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      var writable = jsReceiver.writable;
      var readable = jsReceiver.readable;
      var exist = true;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsReceiver, 'createEncodedStreams', []);
        readable = streams.readable;
        jsReceiver.readableStream = readable;
        writable = streams.writable;
        jsReceiver.writableStream = writable;
        exist = false;
      }
      var msgId = randomString(12);
      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'decode',
          'msgId': msgId,
          'keyProviderId': (keyProvider as KeyProviderImpl).id,
          'kind': kind,
          'exist': exist,
          'participantId': participantId,
          'trackId': trackId,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(
        this, worker, participantId, trackId,
        jsReceiver: jsReceiver, keyProvider: keyProvider);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender(
      {required String participantId,
      required RTCRtpSender sender,
      required Algorithm algorithm,
      required KeyProvider keyProvider}) {
    var jsSender = (sender as RTCRtpSenderWeb).jsRtpSender;
    var trackId = jsSender.hashCode.toString();
    var kind = jsSender.track!.kind!;

    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
      var msgId = randomString(12);
      var options = {
        'msgType': 'encode',
        'msgId': msgId,
        'keyProviderId': (keyProvider as KeyProviderImpl).id,
        'kind': kind,
        'participantId': participantId,
        'trackId': trackId,
        'options': keyProvider.options.toJson(),
      };
      print('object: ${options['keyProviderId']}');
      jsutil.setProperty(jsSender, 'transform',
          RTCRtpScriptTransform(worker, jsutil.jsify(options)));
    } else {
      var writable = jsSender.writable;
      var readable = jsSender.readable;
      var exist = true;
      if (writable == null || readable == null) {
        EncodedStreams streams =
            jsutil.callMethod(jsSender, 'createEncodedStreams', []);
        readable = streams.readable;
        jsSender.readableStream = readable;
        writable = streams.writable;
        jsSender.writableStream = writable;
        exist = false;
      }
      var msgId = randomString(12);
      jsutil.callMethod(worker, 'postMessage', [
        jsutil.jsify({
          'msgType': 'encode',
          'msgId': msgId,
          'keyProviderId': (keyProvider as KeyProviderImpl).id,
          'kind': kind,
          'exist': exist,
          'participantId': participantId,
          'trackId': trackId,
          'options': keyProvider.options.toJson(),
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
    FrameCryptor cryptor = FrameCryptorImpl(
        this, worker, participantId, trackId,
        jsSender: jsSender, keyProvider: keyProvider);
    _frameCryptors[trackId] = cryptor;
    return Future.value(cryptor);
  }

  void removeFrameCryptor(String trackId) {
    _frameCryptors.remove(trackId);
  }
}
