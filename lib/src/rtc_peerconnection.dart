@JS()
library dart_webrtc;

import 'dart:html';
import 'package:js/js.dart';

import '../dart_webrtc.dart';
import 'media_stream.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_track_event.dart';

@JS()
@anonymous
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
@anonymous
class RTCAnswerOptions {
  external factory RTCAnswerOptions({bool voiceActivityDetection});
  external bool get voiceActivityDetection;
}

@JS()
class MediaStreamEvent {
  external factory MediaStreamEvent();
  MediaStream stream;
}

@JS()
@anonymous
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
@anonymous
class RTCIceServer {
  external factory RTCIceServer(
      {String urls, String username, String credential});
  // String or List<String>
  external dynamic get urls;
  external String get username;
  external String get credential;
}

@JS('RTCPeerConnection')
class RTCPeerConnectionJs {
  external factory RTCPeerConnectionJs([RTCConfiguration configuration]);
  external dynamic get connectionState;
  external dynamic get signalingState;
  external dynamic get iceConnectionState;
  external dynamic get iceGatheringState;
  external dynamic get localDescription;
  external dynamic get remoteDescription;
  external dynamic get canTrickleIceCandidates;
  external void addStream(MediaStreamJs stream);
  external void removeStream(MediaStreamJs stream);

  external RTCRtpSender addTrack(
      MediaStreamTrack track, List<MediaStreamJs> streams);
  external void removeTrack(RTCRtpSender sender);

  external void setLocalDescription(RTCSessionDescription desc);
  external void setRemoteDescription(RTCSessionDescription desc);
  external void addIceCandidate(RTCIceCandidate candidate);

  external RTCDataChannel createDataChannel(
      String label, RTCDataChannelInit init);

  external dynamic createOffer([RTCOfferOptions options]);
  external dynamic createAnswer([RTCAnswerOptions options]);

  external List<RTCRtpSender> getSenders();
  external List<RTCRtpReceiver> getReceivers();
  external List<RTCRtpTransceiver> getTransceivers();
  external RTCRtpTransceiver addTransceiver(
      dynamic trackOrKind, RTCRtpTransceiverInit init);

  external Map<String, RTCStats> getStats();

  external set onaddstream(void Function(MediaStreamEvent stream) func);
  external set onremovestream(void Function(MediaStream stream) func);
  external set onconnectionstatechange(void Function(dynamic state) func);
  external set ondatachannel(void Function(RTCDataChannel channel) func);
  external set onicecandidate(
      void Function(RtcPeerConnectionIceEvent event) func);
  external set oniceconnectionstatechange(void Function(dynamic state) func);
  external set ontrack(RTCTrackEvent event);
  external void close();
}

class RTCPeerConnection {
  RTCPeerConnection({RTCConfiguration configuration}) {
    _internal = RTCPeerConnectionJs(configuration);
  }
  RTCPeerConnectionJs _internal;

  dynamic get connectionState => _internal.connectionState;

  void addStream(MediaStream stream) => _internal.addStream(stream.js);

  void removeStream(MediaStream stream) => _internal.removeStream(stream.js);

  Future<RTCRtpSender> addTrack(
      {MediaStreamTrack track, List<MediaStreamJs> streams}) async {
    try {
      var sender = await promiseToFuture<RTCRtpSender>(
          _internal.addTrack(track, streams));
      return sender;
    } catch (e) {
      rethrow;
    }
  }

  void removeTrack(RTCRtpSender sender) => _internal.removeTrack(sender);

  void setLocalDescription(RTCSessionDescription desc) =>
      _internal.setLocalDescription(desc);

  void setRemoteDescription(RTCSessionDescription desc) =>
      _internal.setRemoteDescription(desc);

  void addIceCandidate(RTCIceCandidate candidate) =>
      _internal.addIceCandidate(candidate);

  Future<RTCSessionDescription> createOffer({RTCOfferOptions options}) async {
    try {
      var desc = await promiseToFuture<dynamic>(_internal.createOffer(options));
      return RTCSessionDescription(type: desc.type, sdp: desc.sdp);
    } catch (e) {
      rethrow;
    }
  }

  Future<RTCSessionDescription> createAnswer({RTCAnswerOptions options}) async {
    try {
      var desc =
          await promiseToFuture<dynamic>(_internal.createAnswer(options));
      return RTCSessionDescription(type: desc.type, sdp: desc.sdp);
    } catch (e) {
      rethrow;
    }
  }

  Future<RTCDataChannel> createDataChannel(
      {String label, RTCDataChannelInit init}) async {
    try {
      var dc = await promiseToFuture<RTCDataChannel>(
          _internal.createDataChannel(label, init));
      return dc;
    } catch (e) {
      rethrow;
    }
  }

  set onaddstream(Function(MediaStreamEvent stream) func) =>
      _internal.onaddstream = allowInterop(func);

  set onremovestream(Function(MediaStream stream) func) =>
      _internal.onremovestream = allowInterop(func);

  set onconnectionstatechange(Function(dynamic state) func) =>
      _internal.onremovestream = allowInterop(func);

  set ondatachannel(Function(RTCDataChannel channel) func) =>
      _internal.ondatachannel = allowInterop(func);

  set onicecandidate(Function(RtcPeerConnectionIceEvent event) func) =>
      _internal.onicecandidate = allowInterop(func);

  set oniceconnectionstatechange(Function(dynamic state) func) =>
      _internal.oniceconnectionstatechange = allowInterop(func);

  set ontrack(Function(RTCTrackEvent event) func) =>
      _internal.ontrack = allowInterop(func);

  void close() => _internal.close();
}
