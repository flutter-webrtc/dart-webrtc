@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'enums.dart';
import 'event_js.dart';
import 'media_stream_js.dart';
import 'media_stream_track_js.dart';
import 'rtc_data_channel.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_transceiver.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_resport.dart';
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
  external factory RTCAnswerOptions(
      {bool offerToReceiveAudio,
      bool offerToReceiveVideo,
      bool voiceActivityDetection});
  external bool get offerToReceiveAudio;
  external bool get offerToReceiveVideo;
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
  external factory RTCConfiguration(
      {List<RTCIceServer> iceServers,
      String iceTransportPolicy,
      String bundlePolicy,
      String peerIdentity,
      String sdpSemantics,
      int iceCandidatePoolSize});
  external List<RTCIceServer> get iceServers;

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

  /// 'plan-b' | 'unified-plan'
  external String get sdpSemantics;
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
  external bool get canTrickleIceCandidates;
  external RTCConfiguration getConfiguration();
  external void setConfiguration(RTCConfiguration configuration);
  external void addStream(MediaStream stream);
  external void removeStream(MediaStream stream);
  external List<MediaStream> getLocalStreams();
  external List<MediaStream> getRemoteStreams();
  external RTCRtpSender addTrack(MediaStreamTrack track, MediaStream stream);
  external void removeTrack(RTCRtpSender sender);
  external dynamic setLocalDescription(RTCSessionDescription desc);
  external dynamic setRemoteDescription(RTCSessionDescription desc);
  external dynamic addIceCandidate(RTCIceCandidate candidate);
  external RTCDataChannel createDataChannel(
      String label, RTCDataChannelInit init);
  external dynamic createOffer([RTCOfferOptions options]);
  external dynamic createAnswer([RTCAnswerOptions options]);
  external List<RTCRtpSender> getSenders();
  external List<RTCRtpReceiver> getReceivers();
  external List<RTCRtpTransceiver> getTransceivers();
  external RTCRtpTransceiver addTransceiver(
      dynamic trackOrKind, RTCRtpTransceiverInit init);
  external RTCStatsReportJs getStats();
  external void restartIce();
  external RTCDTMFSender createDTMFSender();
  external set onaddstream(Function(MediaStreamEvent stream) func);
  external set onremovestream(Function(MediaStreamEvent stream) func);
  external set onconnectionstatechange(Function(dynamic state) func);
  external set oniceconnectionstatechange(Function(dynamic state) func);
  external set onicegatheringstatechange(Function(dynamic state) func);
  external set onnegotiationneeded(Function(Event event) func);
  external set onsignalingstatechange(Function(dynamic state) func);
  external set ondatachannel(Function(RTCDataChannelEvent event) func);
  external set onicecandidate(Function(RTCPeerConnectionIceEvent event) func);
  external set ontrack(Function(RTCTrackEvent event) func);
  external void close();
}

class RTCPeerConnection {
  RTCPeerConnection({RTCConfiguration configuration}) {
    _internal = RTCPeerConnectionJs(configuration);
  }
  RTCPeerConnectionJs _internal;

  RTCConfiguration getConfiguration() => _internal.getConfiguration();

  RTCDTMFSender createDTMFSender() => _internal.createDTMFSender();

  List<RTCRtpSender> get senders => _internal.getSenders();

  List<RTCRtpReceiver> get receivers => _internal.getReceivers();

  List<RTCRtpTransceiver> get transceivers => _internal.getTransceivers();

  void setConfiguration(RTCConfiguration configuration) =>
      _internal.setConfiguration(configuration);

  RTCPeerConnectionState get connectionState =>
      peerConnectionStateForString(_internal.connectionState);

  RTCSignalingState get signalingState =>
      signalingStateForString(_internal.signalingState);

  RTCIceConnectionState get iceConnectionState =>
      iceConnectionStateForString(_internal.iceConnectionState);

  RTCIceGatheringState get iceGatheringState =>
      iceGatheringStateforString(_internal.iceGatheringState);

  RTCSessionDescription get localDescription {
    var desc = _internal.localDescription;
    return RTCSessionDescription(type: desc.type, sdp: desc.sdp);
  }

  RTCSessionDescription get remoteDescription {
    var desc = _internal.remoteDescription;
    return RTCSessionDescription(type: desc.type, sdp: desc.sdp);
  }

  Future<RTCStatsReport> getStats() async {
    try {
      var jsStats =
          await promiseToFuture<RTCStatsReportJs>(_internal.getStats());
      return RTCStatsReport(jsStats);
    } catch (e) {
      rethrow;
    }
  }

  List<MediaStream> getLocalStreams() => _internal.getLocalStreams();

  List<MediaStream> getRemoteStreams() => _internal.getRemoteStreams();

  bool get canTrickleIceCandidates => _internal.canTrickleIceCandidates;

  void addStream(MediaStream stream) => _internal.addStream(stream);

  void removeStream(MediaStream stream) => _internal.removeStream(stream);

  Future<RTCRtpTransceiver> addTransceiver(
      {String kind, MediaStreamTrack track, RTCRtpTransceiverInit init}) async {
    try {
      dynamic kindOrTrack = kind ?? track;
      var transceiver = _internal.addTransceiver(kindOrTrack, init);
      return transceiver;
    } catch (e) {
      rethrow;
    }
  }

  Future<RTCRtpSender> addTrack(
      {MediaStreamTrack track, MediaStream stream}) async {
    try {
      return _internal.addTrack(track, stream);
    } catch (e) {
      rethrow;
    }
  }

  void removeTrack(RTCRtpSender sender) => _internal.removeTrack(sender);

  Future<void> setLocalDescription(RTCSessionDescription desc) async {
    try {
      await promiseToFuture<dynamic>(_internal.setLocalDescription(desc));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    try {
      await promiseToFuture<dynamic>(_internal.setRemoteDescription(desc));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await promiseToFuture<void>(_internal.addIceCandidate(candidate));
    } catch (e) {
      rethrow;
    }
  }

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
      return _internal.createDataChannel(label, init);
    } catch (e) {
      rethrow;
    }
  }

  set onaddstream(Function(MediaStreamEvent stream) func) =>
      _internal.onaddstream = allowInterop(func);

  set onremovestream(Function(MediaStreamEvent stream) func) =>
      _internal.onremovestream = allowInterop(func);

  set onconnectionstatechange(Function(RTCPeerConnectionState state) func) =>
      _internal.onconnectionstatechange = allowInterop((dynamic state) {
        func(peerConnectionStateForString(_internal.connectionState));
      });

  set oniceconnectionstatechange(Function(RTCIceConnectionState state) func) =>
      _internal.oniceconnectionstatechange = allowInterop((dynamic state) {
        func(iceConnectionStateForString(_internal.iceConnectionState));
      });

  set onsignalingstatechange(Function(RTCSignalingState state) func) =>
      _internal.onsignalingstatechange = allowInterop((dynamic state) {
        func(signalingStateForString(_internal.signalingState));
      });

  set onicegatheringstatechange(Function(RTCIceGatheringState state) func) =>
      _internal.onicegatheringstatechange = allowInterop((dynamic state) {
        func(iceGatheringStateforString(_internal.iceGatheringState));
      });

  set ondatachannel(Function(RTCDataChannelEvent event) func) =>
      _internal.ondatachannel = allowInterop(func);

  set onicecandidate(Function(RTCPeerConnectionIceEvent event) func) =>
      _internal.onicecandidate = allowInterop(func);

  set onnegotiationneeded(Function(Event event) func) =>
      _internal.onnegotiationneeded = allowInterop(func);

  set ontrack(Function(RTCTrackEvent event) func) =>
      _internal.ontrack = allowInterop(func);

  void close() => _internal.close();
}
