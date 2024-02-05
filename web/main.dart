import 'dart:html' as html;
import 'dart:typed_data';

import 'package:dart_webrtc/dart_webrtc.dart';

/*
import 'test_media_devices.dart' as media_devices_tests;
import 'test_media_stream.dart' as media_stream_tests;
import 'test_media_stream_track.dart' as media_stream_track_tests;
import 'test_peerconnection.dart' as peerconnection_tests;
import 'test_video_element.dart' as video_elelment_tests;
*/
void main() {
  /*
  video_elelment_tests.testFunctions.forEach((Function func) => func());
  media_devices_tests.testFunctions.forEach((Function func) => func());
  media_stream_tests.testFunctions.forEach((Function func) => func());
  media_stream_track_tests.testFunctions.forEach((Function func) => func());
  peerconnection_tests.testFunctions.forEach((Function func) => func());
  */
  loopBackTest();
}

List<FrameCryptor> pc1FrameCryptors = [];
List<FrameCryptor> pc2FrameCryptors = [];

void loopBackTest() async {
  var local = html.document.querySelector('#local');
  var localVideo = RTCVideoElement();
  local!.append(localVideo.htmlElement);

  var remote = html.document.querySelector('#remote');
  var remotelVideo = RTCVideoElement();
  remote!.append(remotelVideo.htmlElement);

  var acaps = await getRtpSenderCapabilities('audio');
  print('sender audio capabilities: ${acaps.toMap()}');

  var vcaps = await getRtpSenderCapabilities('video');
  print('sender video capabilities: ${vcaps.toMap()}');
  /*
  capabilities = await getRtpReceiverCapabilities('audio');
  print('receiver audio capabilities: ${capabilities.toMap()}');

  capabilities = await getRtpReceiverCapabilities('video');
  print('receiver video capabilities: ${capabilities.toMap()}');
  */
  var keyProviderOptions = KeyProviderOptions(
      sharedKey: false,
      ratchetWindowSize: 16,
      failureTolerance: -1,
      ratchetSalt: Uint8List.fromList('testSalt'.codeUnits));
  var keyProvider =
      await frameCryptorFactory.createDefaultKeyProvider(keyProviderOptions);

  await keyProvider.setKey(
      participantId: 'sender',
      index: 0,
      key: Uint8List.fromList('testkey'.codeUnits));

  await keyProvider.setKey(
      participantId: 'receiver',
      index: 0,
      key: Uint8List.fromList('testkey'.codeUnits));

  var pc2 = await createPeerConnection({'encodedInsertableStreams': true});
  pc2.onTrack = (event) async {
    if (event.track.kind == 'video') {
      remotelVideo.srcObject = event.streams[0];
    }
    var fc = await frameCryptorFactory.createFrameCryptorForRtpReceiver(
        participantId: 'receiver',
        receiver: event.receiver!,
        algorithm: Algorithm.kAesGcm,
        keyProvider: keyProvider);
    await fc.setEnabled(true);
    await fc.setKeyIndex(0);
    await fc.updateCodec('vp8');
    pc2FrameCryptors.add(fc);
  };
  pc2.onConnectionState = (state) {
    print('connectionState $state');
  };

  pc2.onIceConnectionState = (state) {
    print('iceConnectionState $state');
  };

  var pc1 = await createPeerConnection({'encodedInsertableStreams': true});

  pc1.onIceCandidate = (candidate) => pc2.addCandidate(candidate);
  pc2.onIceCandidate = (candidate) => pc1.addCandidate(candidate);

  var stream =
      await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
  /*.getUserMedia(MediaStreamConstraints(audio: true, video: true))*/
  print('getDisplayMedia: stream.id => ${stream.id}');

  navigator.mediaDevices.ondevicechange = (event) async {
    var list = await navigator.mediaDevices.enumerateDevices();
    print('ondevicechange: ');
    list.where((element) => element.kind == 'audiooutput').forEach((e) {
      print('${e.runtimeType}: ${e.label}, type => ${e.kind}');
    });
  };

  var list = await navigator.mediaDevices.enumerateDevices();
  list.forEach((e) {
    print('${e.runtimeType}: ${e.label}, type => ${e.kind}');
  });
  var outputList = list.where((element) => element.kind == 'audiooutput');
  if (outputList.isNotEmpty) {
    var sinkId = outputList.last.deviceId;
    try {
      await navigator.mediaDevices
          .selectAudioOutput(AudioOutputOptions(deviceId: sinkId));
    } catch (e) {
      print('selectAudioOutput error: ${e.toString()}');
      await localVideo.setSinkId(sinkId);
    }
  }

  stream.getTracks().forEach((track) async {
    var sender = await pc1.addTrack(track, stream);
    var fc = await frameCryptorFactory.createFrameCryptorForRtpSender(
        participantId: 'sender',
        sender: sender,
        algorithm: Algorithm.kAesGcm,
        keyProvider: keyProvider);
    await fc.setEnabled(true);
    await fc.setKeyIndex(0);
    await fc.updateCodec('vp8');
    pc1FrameCryptors.add(fc);
  });
/*
  var transceivers = await pc1.getTransceivers();
  transceivers.forEach((transceiver) {
    print('transceiver: ${transceiver.sender.track!.kind!}');
    if (transceiver.sender.track!.kind! == 'video') {
      transceiver.setCodecPreferences([
        RTCRtpCodecCapability(
          mimeType: 'video/VP8',
          clockRate: 90000,
        )
      ]);
    } else if (transceiver.sender.track!.kind! == 'audio') {
      transceiver.setCodecPreferences([
        RTCRtpCodecCapability(
          mimeType: 'audio/PCMU',
          clockRate: 8000,
          channels: 1,
        )
      ]);
    }
  });
*/
  var offer = await pc1.createOffer();

  await pc2.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));
  await pc2.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly));

  await pc1.setLocalDescription(offer);
  await pc2.setRemoteDescription(offer);
  var answer = await pc2.createAnswer({});
  await pc2.setLocalDescription(answer);

  await pc1.setRemoteDescription(answer);

  localVideo.muted = true;
  localVideo.srcObject = stream;
/*
  var key2 = await keyProvider.ratchetKey(index: 0, participantId: 'sender');
  print('ratchetKey key2: ${key2.toList()}');
*/
  await keyProvider.setKey(
      index: 1,
      participantId: 'sender',
      key: Uint8List.fromList('testkey3'.codeUnits));

  await keyProvider.setKey(
      index: 1,
      participantId: 'receiver',
      key: Uint8List.fromList('testkey3'.codeUnits));

  [...pc1FrameCryptors, ...pc2FrameCryptors].forEach((element) async {
    await element.setKeyIndex(1);
  });

  await keyProvider.setKey(
      index: 2,
      participantId: 'sender',
      key: Uint8List.fromList('testkey4'.codeUnits));

  await keyProvider.setKey(
      index: 2,
      participantId: 'receiver',
      key: Uint8List.fromList('testkey4'.codeUnits));

  [...pc1FrameCryptors, ...pc2FrameCryptors].forEach((element) async {
    await element.setKeyIndex(2);
  });

  var key = await keyProvider.ratchetKey(index: 2, participantId: 'sender');
  print('ratchetKey key: ${key.toList()}');

  var key1 = await keyProvider.ratchetKey(index: 0, participantId: 'sender');
  print('ratchetKey key1: ${key1.toList()}');

  [...pc1FrameCryptors, ...pc2FrameCryptors].forEach((element) async {
    await element.setKeyIndex(0);
  });

  /*
  await keyProvider.setKey(
      index: 0,
      participantId: 'sender',
      key: Uint8List.fromList('testkey2'.codeUnits));

  */
}
