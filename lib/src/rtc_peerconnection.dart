@JS()
library dart_webrtc;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/rtc_rtp_sender.dart';

import 'media_stream.dart';
import 'rtc_track_event.dart';
import 'package:js/js.dart';

@JS()
class RTCOfferOptions {
  external factory RTCOfferOptions({
    bool iceRestart,
    bool offerToReceiveAudio,
    bool offerToReceiveVideo,
    bool voiceActivityDetection,
  });
  external bool get iceRestart;
  external bool get offerToReceiveAudio;
  external bool get offerToReceiveVideo;
  external bool get voiceActivityDetection;
}

@JS()
class RTCAnswerOptions {
  external factory RTCAnswerOptions({bool voiceActivityDetection});
  external bool get voiceActivityDetection;
}

@JS()
class RTCConfiguration {
  external factory RTCConfiguration({
    List<RTCIceServer> iceServers,
    String rtcpMuxPolicy,
    String iceTransportPolicy,
    String bundlePolicy,
    String peerIdentity,
    int iceCandidatePoolSize,
  });
  external List<RTCIceServer> get iceServers;

  ///Optional: 'negotiate' or 'require'
  external String get rtcpMuxPolicy;

  ///Optional: 'relay' or 'all'
  external String get iceTransportPolicy;

  /// A DOMString which specifies the target peer identity for the
  /// RTCPeerConnection. If this value is set (it defaults to null),
  /// the RTCPeerConnection will not connect to a remote peer unless
  ///  it can successfully authenticate with the given name.
  external String get peerIdentity;

  external int get iceCandidatePoolSize;

  ///Optional: 'balanced' | 'max-compat' | 'max-bundle'
  external String get bundlePolicy;
}

@JS()
class RTCIceServer {
  external factory RTCIceServer(
      {String urls, String username, String credential});
  // String or List<String>
  external dynamic get urls;
  external String get username;
  external String get credential;
}

@JS()
class RTCPeerConnection {
  external factory RTCPeerConnection({RTCConfiguration configuration});
  external dynamic get connectionState;
  external dynamic get signalingState;
  external dynamic get iceConnectionState;
  external dynamic get iceGatheringState;
  external dynamic get localDescription;
  external dynamic get remoteDescription;
  external dynamic get canTrickleIceCandidates;
  external void addStream(MediaStream stream);
  external void removeStream(MediaStream stream);

  external RTCRtpSender addTrack(
      MediaStreamTrack track, List<MediaStream> streams);
  external void removeTrack(RTCRtpSender sender);

  external void setLocalDescription(RTCSessionDescription desc);
  external void setRemoteDescription(RTCSessionDescription desc);
  external void addIceCandidate(RTCIceCandidate candidate);

  external RTCDataChannel createDataChannel(
      String label, RTCDataChannelInit init);
  external RTCSessionDescription createOffer({RTCOfferOptions options});
  external RTCSessionDescription createAnswer({RTCAnswerOptions options});
  external List<RTCRtpSender> getSenders();
  external List<RTCRtpReceiver> getReceivers();
  external List<RTCRtpTransceiver> getTransceivers();
  external RTCRtpTransceiver addTransceiver(
      dynamic trackOrKind, RTCRtpTransceiverInit init);

  external set onaddstream(void Function(MediaStream stream) func);
  external set onremovestream(void Function(MediaStream stream) func);
  external set onconnectionstatechange(void Function(dynamic state) func);
  external set ondatachannel(void Function(dynamic channel) func);
  external set onicecandidate(void Function(RTCIceCandidate candidate) func);
  external set oniceconnectionstatechange(void Function(dynamic state) func);
  external set ontrack(RTCTrackEvent event);
  external void close();
}
