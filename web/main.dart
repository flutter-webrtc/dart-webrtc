import 'dart:html';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/media_stream.dart';
import 'package:js/js.dart';

import 'signaling.dart';

void main() {
  var signaling = Signaling('demo.cloudwebrtc.com');

  var local = document.querySelector('#local');

  var localVideo = VideoElement()
    ..autoplay = true
    ..muted = true
    ..controls = false
    ..style.objectFit = 'contain' // contain or cover
    ..style.border = 'none'
    ..id = 'dart-webrtc-video-01';

  // Allows Safari iOS to play the video inline
  localVideo.setAttribute('playsinline', 'true');

  local.append(localVideo);

  var remote = document.querySelector('#remote');

  var remoteVideo = VideoElement()
    ..autoplay = true
    ..muted = false
    ..controls = false
    ..style.objectFit = 'contain' // contain or cover
    ..style.border = 'none'
    ..id = 'dart-webrtc-video-02';

  // Allows Safari iOS to play the video inline
  remoteVideo.setAttribute('playsinline', 'true');

  remote.append(remoteVideo);

  signaling.onLocalStream = allowInterop((MediaStream stream) {
    var rtcVideo = ConvertToRTCVideoElement(localVideo);
    rtcVideo.srcObject = stream;
  });

  signaling.onAddRemoteStream = allowInterop((MediaStream stream) {
    var rtcVideo = ConvertToRTCVideoElement(remoteVideo);
    rtcVideo.srcObject = stream;
  });

  signaling.connect();
  signaling.onStateChange = (SignalingState state) {
    document.querySelector('#output').text = state.toString();
    if (state == SignalingState.ConnectionOpen) {
      //signaling.invite('123123', 'video', false);
    }
  };
}

/*
void loopBackTest() {
  var local = document.querySelector('#local');
  var localVideo = VideoElement()
    ..autoplay = true
    ..muted = true
    ..controls = false
    ..style.objectFit = 'contain' // contain or cover
    ..style.border = 'none'
    ..id = 'dart-webrtc-video-01';

  // Allows Safari iOS to play the video inline
  localVideo.setAttribute('playsinline', 'true');
  local.append(localVideo);
  dartWebRTCTest(localVideo);
}

void dartWebRTCTest(VideoElement video) async {
  var list = await PromiseToFuture<List<dynamic>>(
      navigator.mediaDevices.enumerateDevices());
  list.forEach((e) {
    if (e is MediaDeviceInfo) {
      print('MediaDeviceInfo: ${e.label}');
    } else if (e is InputDeviceInfo) {
      print('InputDeviceInfo: ${e.label}');
    }
  });

  var pc = RTCPeerConnection();
  print('connectionState: ${pc.connectionState}');
  pc.onaddstream = allowInterop((MediaStreamEvent event) {});
  var stream = await PromiseToFuture<MediaStream>(
      navigator.mediaDevices.getDisplayMedia()
      /*.getUserMedia(MediaStreamConstraints(audio: true, video: true))*/);
  print('getDisplayMedia: stream.id => ${stream.id}');
  stream.oninactive = allowInterop((Event event) {
    print('oninactive: stream.id => ${event.target.id}');
    video.srcObject = null;
    video.remove();
  });
  pc.addStream(stream);
  var rtcVideo = ConvertToRTCVideoElement(video);
  rtcVideo.srcObject = stream;
}
*/
