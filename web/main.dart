import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/rtc_rtp_receiver_impl.dart';
import 'package:dart_webrtc/src/rtc_rtp_sender_impl.dart';

import 'utils.dart';

import 'worker/e2ee.worker.dart' as e2ee;

/*
import 'test_media_devices.dart' as media_devices_tests;
import 'test_media_stream.dart' as media_stream_tests;
import 'test_media_stream_track.dart' as media_stream_track_tests;
import 'test_peerconnection.dart' as peerconnection_tests;
import 'test_video_element.dart' as video_elelment_tests;
*/

void main() {
  var worker = Uri.base.queryParameters['worker'];
  if (worker != null && worker == 'e2ee') {
    print('worker started');
    return e2ee.e2eeWorker();
  }

  var w = html.Worker('main.dart.js?worker=e2ee');
  /*
  video_elelment_tests.testFunctions.forEach((Function func) => func());
  media_devices_tests.testFunctions.forEach((Function func) => func());
  media_stream_tests.testFunctions.forEach((Function func) => func());
  media_stream_track_tests.testFunctions.forEach((Function func) => func());
  peerconnection_tests.testFunctions.forEach((Function func) => func());
  */
  //js.context.callMethod('alert', ['Hello from Dart!']);
  w.onMessage.listen((msg) {
    print('master got ${msg.data}');
    var dog = Dog(name: msg.data['name'], age: msg.data['age']);
    print('master took back ${dog.name} and she turns into ${dog.age}!');
  });
  //aesGcmTest();
  loopBackTest(w);
}

void aesGcmTest() async {
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

  String clearText = 'Hello World!';

  var iv = makeIV();

  var buffer = Uint8List.fromList(clearText.codeUnits);
  print('clearText: $buffer');
  var cipherText = await jsutil.promiseToFuture<ByteBuffer>(encrypt(
    AesGcmParams(
      name: 'AES-GCM',
      iv: jsArrayBufferFrom(iv),
      additionalData: jsArrayBufferFrom(buffer.sublist(0, 0)),
      tagLength: 128,
    ),
    secretKey,
    jsArrayBufferFrom(buffer),
  ));

  print('cipherText: ${cipherText.asUint8List()}');

  var decrypted = await jsutil.promiseToFuture<ByteBuffer>(decrypt(
    AesGcmParams(
      name: 'AES-GCM',
      iv: jsArrayBufferFrom(iv),
      tagLength: 128,
    ),
    secretKey,
    cipherText,
  ));

  print('decrypted: ${decrypted.asUint8List()}');
}

Uint8List makeIV() {
  var iv = Uint8List(12);
  var random = Random.secure();
  for (var i = 0; i < iv.length; i++) {
    iv[i] = random.nextInt(256);
  }
  return iv;
}

void loopBackTest(html.Worker w) async {
  var local = html.document.querySelector('#local');
  var localVideo = RTCVideoElement();
  local!.append(localVideo.htmlElement);

  var remote = html.document.querySelector('#remote');
  var remotelVideo = RTCVideoElement();
  remote!.append(remotelVideo.htmlElement);

  var pc2 = await createPeerConnection({'encodedInsertableStreams': true});
  pc2.onTrack = (event) {
    if (event.track.kind == 'video') {
      remotelVideo.srcObject = event.streams[0];
    }
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
  var senders = <RTCRtpSender>[];
  stream.getTracks().forEach((track) async {
    var rtpSender = await pc1.addTrack(track, stream);
    senders.add(rtpSender);
  });

  var offer = await pc1.createOffer();
  var audioCodec = 'opus';
  var videoCodec = 'vp8';
  setPreferredCodec(offer, audio: audioCodec, video: videoCodec);
  print('offer: ${offer.sdp}');

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

  senders.forEach((rtpSender) async {
    var jsSender = (rtpSender as RTCRtpSenderWeb).jsRtpSender;
    if (js.context['RTCRtpScriptTransform'] != null) {
      print('support RTCRtpScriptTransform');
    } else {
      EncodedStreams streams =
          jsutil.callMethod(jsSender, 'createEncodedStreams', []);
      var readable = streams.readable;
      var writable = streams.writable;
      jsutil.callMethod(w, 'postMessage', [
        jsutil.jsify({
          'msgType': 'encode',
          'kind': jsSender.track!.kind!,
          'participantId': jsSender.track!.id!,
          'trackId': jsSender.track!.id!,
          'codec': jsSender.track!.kind == 'audio' ? audioCodec : videoCodec,
          'readableStream': readable,
          'writableStream': writable
        }),
        jsutil.jsify([readable, writable]),
      ]);
    }
  });

  localVideo.muted = true;
  localVideo.srcObject = stream;

  var receivers = await pc2.getReceivers();
  receivers.forEach((receiver) {
    var jsReceiver = (receiver as RTCRtpReceiverWeb).jsRtpReceiver;

    EncodedStreams streams =
        jsutil.callMethod(jsReceiver, 'createEncodedStreams', []);
    var readable = streams.readable;
    var writable = streams.writable;

    jsutil.callMethod(w, 'postMessage', [
      jsutil.jsify({
        'msgType': 'decode',
        'kind': jsReceiver.track!.kind!,
        'participantId': jsReceiver.track!.id!,
        'trackId': jsReceiver.track!.id!,
        'codec': jsReceiver.track!.kind == 'audio' ? audioCodec : videoCodec,
        'readableStream': readable,
        'writableStream': writable
      }),
      jsutil.jsify([readable, writable]),
    ]);
  });
}
