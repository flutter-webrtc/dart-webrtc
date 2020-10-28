@JS()
library dart_webrtc;

import 'media_stream.dart';
import 'package:js/js.dart';

@JS()
class RTCPeerConnection {
  external factory RTCPeerConnection();
  external dynamic get connectionState;
  external dynamic get signalingState;
  external dynamic get iceConnectionState;
  external dynamic get iceGatheringState;
  external dynamic get localDescription;
  external dynamic get remoteDescription;
  external dynamic get canTrickleIceCandidates;
  external set onaddstream(void Function(MediaStream stream) func);
  external set onremovestream(void Function(MediaStream stream) func);
  external set onconnectionstatechange(void Function(dynamic state) func);
  external set ondatachannel(void Function(dynamic channel) func);
  external set onicecandidate(void Function(dynamic candidate) func);
  external set oniceconnectionstatechange(void Function(dynamic state) func);
}
