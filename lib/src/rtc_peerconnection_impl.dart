import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_util' as jsutil;

import 'package:platform_detect/platform_detect.dart';
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';
import 'media_stream_track_impl.dart';
import 'rtc_data_channel_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';
import 'rtc_configuration_impl.dart';

/*
 *  PeerConnection
 */
class RTCPeerConnectionWeb extends RTCPeerConnection {
  RTCPeerConnectionWeb(this._peerConnectionId, this._jsPc) {
    _jsPc.ondatachannel = (dataChannelEvent) {
      if (dataChannelEvent.channel != null) {
        onDataChannel?.call(RTCDataChannelWeb(dataChannelEvent.channel!));
      }
    }.toJS;

    _jsPc.onicecandidate = (iceEvent) {
      if (iceEvent.candidate != null) {
        onIceCandidate?.call(_iceFromJs(iceEvent.candidate!));
      }
    }.toJS;

    _jsPc.onconnectionstatechange = (_) {
      _iceConnectionState =
          iceConnectionStateForString(_jsPc.iceConnectionState);
      onIceConnectionState?.call(_iceConnectionState!);

      if (browser.isFirefox) {
        switch (_iceConnectionState!) {
          case RTCIceConnectionState.RTCIceConnectionStateNew:
            _connectionState = RTCPeerConnectionState.RTCPeerConnectionStateNew;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
            _connectionState =
                RTCPeerConnectionState.RTCPeerConnectionStateConnecting;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
            _connectionState =
                RTCPeerConnectionState.RTCPeerConnectionStateConnected;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            _connectionState =
                RTCPeerConnectionState.RTCPeerConnectionStateFailed;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            _connectionState =
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateClosed:
            _connectionState =
                RTCPeerConnectionState.RTCPeerConnectionStateClosed;
            break;
          default:
            break;
        }
        onConnectionState?.call(_connectionState!);
      }
    }.toJS;

    jsutil.setProperty(_jsPc, 'onicegatheringstatechange', js.allowInterop((_) {
      _iceGatheringState = iceGatheringStateforString(_jsPc.iceGatheringState);
      onIceGatheringState?.call(_iceGatheringState!);
    }));

    _jsPc.onsignalingstatechange = (_) {
      _signalingState = signalingStateForString(_jsPc.signalingState);
      onSignalingState?.call(_signalingState!);
    }.toJS;

    if (!browser.isFirefox) {
      _jsPc.onconnectionstatechange = (_) {
        _connectionState = peerConnectionStateForString(_jsPc.connectionState);
        onConnectionState?.call(_connectionState!);
      }.toJS;
    }

    _jsPc.onnegotiationneeded = (_) {
      onRenegotiationNeeded?.call();
    }.toJS;

    _jsPc.ontrack = (web.RTCTrackEvent trackEvent) {
      onTrack?.call(
        RTCTrackEvent(
          track: MediaStreamTrackWeb(trackEvent.track),
          receiver: RTCRtpReceiverWeb(trackEvent.receiver),
          transceiver: RTCRtpTransceiverWeb.fromJsObject(
              jsutil.getProperty(trackEvent, 'transceiver')),
          streams: trackEvent.streams.toDart
              .map((web.MediaStream stream) =>
                  MediaStreamWeb(stream, _peerConnectionId))
              .toList(),
        ),
      );
    }.toJS;
  }

  final String _peerConnectionId;
  late final web.RTCPeerConnection _jsPc;
  final _configuration = <String, dynamic>{};

  RTCSignalingState? _signalingState;
  RTCIceGatheringState? _iceGatheringState;
  RTCIceConnectionState? _iceConnectionState;
  RTCPeerConnectionState? _connectionState;

  @override
  RTCSignalingState? get signalingState => _signalingState;

  @override
  Future<RTCSignalingState?> getSignalingState() async {
    _signalingState = signalingStateForString(_jsPc.signalingState);
    return signalingState;
  }

  @override
  RTCIceGatheringState? get iceGatheringState => _iceGatheringState;

  @override
  Future<RTCIceGatheringState?> getIceGatheringState() async {
    _iceGatheringState = iceGatheringStateforString(_jsPc.iceGatheringState);
    return _iceGatheringState;
  }

  @override
  RTCIceConnectionState? get iceConnectionState => _iceConnectionState;

  @override
  Future<RTCIceConnectionState?> getIceConnectionState() async {
    _iceConnectionState = iceConnectionStateForString(_jsPc.iceConnectionState);
    if (browser.isFirefox) {
      switch (_iceConnectionState!) {
        case RTCIceConnectionState.RTCIceConnectionStateNew:
          _connectionState = RTCPeerConnectionState.RTCPeerConnectionStateNew;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          _connectionState =
              RTCPeerConnectionState.RTCPeerConnectionStateConnecting;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          _connectionState =
              RTCPeerConnectionState.RTCPeerConnectionStateConnected;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          _connectionState =
              RTCPeerConnectionState.RTCPeerConnectionStateFailed;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          _connectionState =
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected;
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          _connectionState =
              RTCPeerConnectionState.RTCPeerConnectionStateClosed;
          break;
        default:
          break;
      }
    }
    return _iceConnectionState;
  }

  @override
  RTCPeerConnectionState? get connectionState => _connectionState;

  @override
  Future<RTCPeerConnectionState?> getConnectionState() async {
    if (browser.isFirefox) {
      await getIceConnectionState();
    } else {
      _connectionState = peerConnectionStateForString(_jsPc.connectionState);
    }
    return _connectionState;
  }

  @override
  Future<void> dispose() {
    _jsPc.close();
    return Future.value();
  }

  @override
  Map<String, dynamic> get getConfiguration => _configuration;

  @override
  Future<void> setConfiguration(Map<String, dynamic> configuration) {
    _configuration.addAll(configuration);
    var webConfig = RTCConfiguration.fromMap(configuration).toWebConfig();
    _jsPc.setConfiguration(webConfig);
    return Future.value();
  }

  @override
  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic>? constraints]) async {
    final args = constraints != null ? [jsutil.jsify(constraints)] : [];
    final desc = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsPc, 'createOffer', args));
    return RTCSessionDescription(
        jsutil.getProperty(desc, 'sdp'), jsutil.getProperty(desc, 'type'));
  }

  @override
  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic>? constraints]) async {
    final args = constraints != null ? [jsutil.jsify(constraints)] : [];
    final desc = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsPc, 'createAnswer', args));
    return RTCSessionDescription(
        jsutil.getProperty(desc, 'sdp'), jsutil.getProperty(desc, 'type'));
  }

  @override
  Future<void> addStream(MediaStream stream) {
    throw UnimplementedError(
        'addStream is not implemented in web, please use addTrack');
  }

  @override
  Future<void> removeStream(MediaStream stream) async {
    throw UnimplementedError(
        'removeStream is not implemented in web, please use removeTrack');
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    await jsutil.promiseToFuture(_jsPc.setLocalDescription(
        web.RTCLocalSessionDescriptionInit(
            sdp: description.sdp!, type: description.type!)));
  }

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await jsutil.promiseToFuture(_jsPc.setRemoteDescription(
        web.RTCSessionDescriptionInit(
            sdp: description.sdp!, type: description.type!)));
  }

  @override
  Future<RTCSessionDescription?> getLocalDescription() async {
    if (null == _jsPc.localDescription) {
      return null;
    }
    return _sessionFromJs(_jsPc.localDescription);
  }

  @override
  Future<RTCSessionDescription?> getRemoteDescription() async {
    if (null == _jsPc.remoteDescription) {
      return null;
    }
    return _sessionFromJs(_jsPc.remoteDescription);
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) {
    return jsutil.promiseToFuture<void>(
        jsutil.callMethod(_jsPc, 'addIceCandidate', [_iceToJs(candidate)]));
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack? track]) async {
    var stats;
    if (track != null) {
      var jsTrack = (track as MediaStreamTrackWeb).jsTrack;
      stats = await jsutil.promiseToFuture<dynamic>(
          jsutil.callMethod(_jsPc, 'getStats', [jsTrack]));
    } else {
      stats = await jsutil.promiseToFuture(_jsPc.getStats());
    }

    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  @override
  @Deprecated('Deprecated API')
  List<MediaStream> getLocalStreams() => throw UnimplementedError();

  @override
  @Deprecated('Deprecated API')
  List<MediaStream> getRemoteStreams() => throw UnimplementedError();

  @override
  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict) {
    final map = dataChannelDict.toMap();
    if (dataChannelDict.binaryType == 'binary') {
      map['binaryType'] = 'arraybuffer'; // Avoid Blob in data channel
    }
    final jsDc = _jsPc.createDataChannel(label, dataChannelDict.toWeb());
    return Future.value(RTCDataChannelWeb(jsDc));
  }

  @override
  Future<void> restartIce() {
    jsutil.callMethod(_jsPc, 'restartIce', []);
    return Future.value();
  }

  @override
  Future<void> close() async {
    _jsPc.close();
    return Future.value();
  }

  @override
  @Deprecated('Use RTCRtpSender.dtmf instead')
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) =>
      throw UnimplementedError();

  //
  // utility section
  //

  RTCIceCandidate _iceFromJs(web.RTCIceCandidate candidate) => RTCIceCandidate(
        candidate.candidate,
        candidate.sdpMid,
        candidate.sdpMLineIndex,
      );

  web.RTCIceCandidate _iceToJs(RTCIceCandidate c) =>
      web.RTCIceCandidate(web.RTCIceCandidateInit(
        candidate: c.candidate ?? '',
        sdpMid: c.sdpMid,
        sdpMLineIndex: c.sdpMLineIndex,
      ));

  RTCSessionDescription _sessionFromJs(web.RTCSessionDescription? sd) =>
      RTCSessionDescription(sd?.sdp, sd?.type);

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track,
      [MediaStream? stream]) async {
    var jStream = (stream as MediaStreamWeb).jsStream;
    var jsTrack = (track as MediaStreamTrackWeb).jsTrack;
    var sender = _jsPc.addTrack(jsTrack, jStream);
    return RTCRtpSenderWeb.fromJsSender(sender);
  }

  @override
  Future<bool> removeTrack(RTCRtpSender sender) async {
    var nativeSender = sender as RTCRtpSenderWeb;
    // var nativeTrack = nativeSender.track as MediaStreamTrackWeb;
    jsutil.callMethod(_jsPc, 'removeTrack', [nativeSender.jsRtpSender]);
    return Future<bool>.value(true);
  }

  @override
  Future<List<RTCRtpSender>> getSenders() async {
    var senders = jsutil.callMethod(_jsPc, 'getSenders', []);
    var list = <RTCRtpSender>[];
    senders.forEach((e) {
      list.add(RTCRtpSenderWeb.fromJsSender(e));
    });
    return list;
  }

  @override
  Future<List<RTCRtpReceiver>> getReceivers() async {
    var receivers = jsutil.callMethod(_jsPc, 'getReceivers', []);

    var list = <RTCRtpReceiver>[];
    receivers.forEach((e) {
      list.add(RTCRtpReceiverWeb(e));
    });

    return list;
  }

  @override
  Future<List<RTCRtpTransceiver>> getTransceivers() async {
    var transceivers = jsutil.callMethod(_jsPc, 'getTransceivers', []);

    var list = <RTCRtpTransceiver>[];
    transceivers.forEach((e) {
      list.add(RTCRtpTransceiverWeb.fromJsObject(e));
    });

    return list;
  }

  //'audio|video', { 'direction': 'recvonly|sendonly|sendrecv' }
  //
  // https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/addTransceiver
  //
  @override
  Future<RTCRtpTransceiver> addTransceiver({
    MediaStreamTrack? track,
    RTCRtpMediaType? kind,
    RTCRtpTransceiverInit? init,
  }) async {
    final jsTrack = track is MediaStreamTrackWeb ? track.jsTrack : null;
    final kindString = kind != null ? typeRTCRtpMediaTypetoString[kind] : null;
    final trackOrKind = jsTrack ?? kindString;
    assert(trackOrKind != null, 'track or kind must not be null');

    final transceiver = jsutil.callMethod(
      _jsPc,
      'addTransceiver',
      [
        trackOrKind,
        if (init != null) init.toJsObject(),
      ],
    );

    return RTCRtpTransceiverWeb.fromJsObject(
      transceiver,
      peerConnectionId: _peerConnectionId,
    );
  }
}
