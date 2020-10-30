import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/media_stream.dart';
import 'package:js/js.dart';
import 'dart:html';

void main() {
  var element = document.querySelector('#output');

  var video = VideoElement()
    ..autoplay = true
    ..muted = true
    ..controls = false
    ..style.objectFit = 'contain' // contain or cover
    ..style.border = 'none'
    ..id = 'dart-webrtc-video-01';

  // Allows Safari iOS to play the video inline
  video.setAttribute('playsinline', 'true');

  element.append(video);

  dartWebRTCTest(video);
}

void dartWebRTCTest(VideoElement video) async {
  var pc = RTCPeerConnection();
  print('connectionState: ${pc.connectionState}');
  pc.onaddstream = allowInterop((MediaStream stream) {});
  var stream = await PromiseToFuture<MediaStream>(
      navigator.mediaDevices.getDisplayMedia()
      /*.getUserMedia(MediaStreamConstraints(audio: true, video: true))*/);
  print('getDisplayMedia: stream.id => ${stream.id}');
  stream.oninactive = allowInterop((Event event) {
    print('oninactive: stream.id => ${event.target.id}');
    video.srcObject = null;
    video.remove();
  });

  var rtcVideo = ConvertToRTCVideoElement(video);
  rtcVideo.srcObject = stream;
}
