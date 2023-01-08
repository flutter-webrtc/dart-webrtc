import 'dart:typed_data';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:dart_webrtc/src/rtc_rtp_receiver_impl.dart';
import 'package:webrtc_interface/src/rtc_rtp_receiver.dart';
import 'package:webrtc_interface/src/rtc_rtp_sender.dart';

import 'frame_cryptor.dart';
import 'rtc_rtp_sender_impl.dart';

extension RtcRtpReceiverExt on html.RtcRtpReceiver {
  html.RtcRtpReceiver get jsRtpReceiver => this;

  dynamic createEncodedStreams() {
    //return jsRtpReceiver.createEncodedStreams();
  }
}

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._id);
  final String _id;
  @override
  String get id => _id;

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> getKeys({required String participantId}) {
    // TODO: implement getKeys
    throw UnimplementedError();
  }

  @override
  Future<bool> setKey(
      {required String participantId,
      required int index,
      required Uint8List key}) {
    // TODO: implement setKey
    throw UnimplementedError();
  }

  @override
  Future<bool> setKeys(
      {required String participantId, required List<Uint8List> keys}) {
    // TODO: implement setKeys
    throw UnimplementedError();
  }
}

class FrameCryptorFactoryImpl implements FrameCryptorFactory {
  FrameCryptorFactoryImpl._internal();

  static final FrameCryptorFactoryImpl instance =
      FrameCryptorFactoryImpl._internal();

  @override
  Future<KeyManager> createDefaultKeyManager() {
    // TODO: implement createDefaultKeyManager
    throw UnimplementedError();
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpReceiver(
      {required String participantId,
      required RTCRtpReceiver receiver,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpReceiver jsRtpSender =
        (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    throw UnimplementedError();
  }

  @override
  Future<FrameCryptor> createFrameCryptorForRtpSender(
      {required String participantId,
      required RTCRtpSender sender,
      required Algorithm algorithm,
      required KeyManager keyManager}) {
    html.RtcRtpSender jsRtpSender = (sender as RTCRtpSenderWeb).jsRtpSender;

    throw UnimplementedError();
  }
}
