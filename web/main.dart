import 'dart:html' as html;

import 'package:dart_webrtc/dart_webrtc.dart';

import 'test_media_devices.dart' as media_devices_tests;
import 'test_media_stream.dart' as media_stream_tests;
import 'test_media_stream_track.dart' as media_stream_track_tests;
import 'test_peerconnection.dart' as peerconnection_tests;
import 'test_video_element.dart' as video_elelment_tests;

void main() {
  video_elelment_tests.testFunctions.forEach((Function func) => func());
  media_devices_tests.testFunctions.forEach((Function func) => func());
  media_stream_tests.testFunctions.forEach((Function func) => func());
  media_stream_track_tests.testFunctions.forEach((Function func) => func());
  peerconnection_tests.testFunctions.forEach((Function func) => func());
}

void loopBackTest() async {
  var local = html.document.querySelector('#local');
  RTCVideoElement localVideo;
  localVideo = RTCVideoElement();
  local.append(localVideo.htmlElement);

  var list = await navigator.mediaDevices.enumerateDevices();
  list.forEach((e) {
    print('${e.runtimeType}: ${e.label}, type => ${e.kind}');
  });

  var pc = RTCPeerConnection();
  print('connectionState: ${pc.connectionState}');
  pc.onaddstream = (MediaStreamEvent event) {};
  var stream = await navigator.mediaDevices.getUserMedia(
      constraints: MediaStreamConstraints(audio: true, video: true));
  /*.getUserMedia(MediaStreamConstraints(audio: true, video: true))*/
  print('getDisplayMedia: stream.id => ${stream.id}');
  stream.oninactive = (Event event) {
    print('oninactive: stream.id => ${event.target.id}');
    localVideo.srcObject = null;
  };
  pc.addStream(stream);
  localVideo.srcObject = stream;
}
