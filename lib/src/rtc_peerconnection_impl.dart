import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:js_util' as jsutil;

import 'package:js/js_util.dart';
import 'package:platform_detect/platform_detect.dart';
import 'package:web/web.dart' as web;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'media_stream_track_impl.dart';
import 'rtc_data_channel_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_receiver_impl.dart';
import 'rtc_rtp_sender_impl.dart';
import 'rtc_rtp_transceiver_impl.dart';

extension on web.RTCDataChannelInit {
  external set binaryType(String value);
}

/*
 *  PeerConnection
 */
class RTCPeerConnectionWeb extends RTCPeerConnection {
  RTCPeerConnectionWeb(this._peerConnectionId, this._jsPc) {
    _jsPc.addEventListener(
        'datachannel',
        (web.RTCDataChannelEvent dataChannelEvent) {
          if (dataChannelEvent.channel != null) {
            onDataChannel?.call(RTCDataChannelWeb(dataChannelEvent.channel!));
          }
        }.toJS);

    _jsPc.addEventListener(
        'icecandidate',
        (web.RTCPeerConnectionIceEvent iceEvent) {
          if (iceEvent.candidate != null) {
            onIceCandidate?.call(_iceFromJs(iceEvent.candidate!));
          }
        }.toJS);

    _jsPc.addEventListener(
        'iceconnectionstatechange',
        (web.Event _) {
          _iceConnectionState =
              iceConnectionStateForString(_jsPc.iceConnectionState);
          onIceConnectionState?.call(_iceConnectionState!);

          if (browser.isFirefox) {
            switch (_iceConnectionState!) {
              case RTCIceConnectionState.RTCIceConnectionStateNew:
                _connectionState =
                    RTCPeerConnectionState.RTCPeerConnectionStateNew;
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
        }.toJS);

    jsutil.setProperty(_jsPc, 'onicegatheringstatechange', js.allowInterop((_) {
      _iceGatheringState = iceGatheringStateforString(_jsPc.iceGatheringState);
      onIceGatheringState?.call(_iceGatheringState!);
    }));

    _jsPc.addEventListener(
        'signalingstatechange',
        (web.Event _) {
          _signalingState = signalingStateForString(_jsPc.signalingState);
          onSignalingState?.call(_signalingState!);
        }.toJS);

    if (!browser.isFirefox) {
      _jsPc.addEventListener(
          'connectionstatechange',
          (web.Event _) {
            _connectionState =
                peerConnectionStateForString(_jsPc.connectionState);
            onConnectionState?.call(_connectionState!);
          }.toJS);
    }

    _jsPc.addEventListener(
        'negotiationneeded',
        (web.Event _) {
          onRenegotiationNeeded?.call();
        }.toJS);

    _jsPc.addEventListener(
        'track',
        (web.RTCTrackEvent trackEvent) {
          onTrack?.call(
            RTCTrackEvent(
                track: MediaStreamTrackWeb(trackEvent.track),
                receiver: RTCRtpReceiverWeb(trackEvent.receiver),
                transceiver: RTCRtpTransceiverWeb.fromJsObject(
                    jsutil.getProperty(trackEvent, 'transceiver')),
                streams: trackEvent.streams.toDart
                    .map((dynamic stream) =>
                        MediaStreamWeb(stream, _peerConnectionId))
                    .toList()),
          );
        }.toJS);
  }

  final String _peerConnectionId;
  late final web.RTCPeerConnection _jsPc;
  final _localStreams = <String, MediaStream>{};
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
    _jsPc.setConfiguration(jsify(configuration) as web.RTCConfiguration);
    return Future.value();
  }

  @override
  Future<RTCSessionDescription> createOffer(
      [Map<String, dynamic>? constraints]) async {
    final args = newObject<JSObject>();
    if (constraints != null) {
      for (var key in constraints.keys) {
        args.setProperty(key.toJS, constraints[key]);
      }
    }
    final desc = await _jsPc.createOffer(args).toDart;

    return RTCSessionDescription(desc!.sdp, desc.type);
  }

  @override
  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic>? constraints]) async {
    final args = newObject<JSObject>();
    if (constraints != null) {
      for (var key in constraints.keys) {
        args.setProperty(key.toJS, constraints[key]);
      }
    }
    final desc = await _jsPc.createAnswer(args).toDart;
    return RTCSessionDescription(desc!.sdp, desc.type);
  }

  @override
  Future<void> addStream(MediaStream stream) {
    var _native = stream as MediaStreamWeb;
    _localStreams.putIfAbsent(
        stream.id, () => MediaStreamWeb(_native.jsStream, _peerConnectionId));

    _jsPc.addStream(stream.jsStream);

    return Future.value();
  }

  @override
  Future<void> removeStream(MediaStream stream) async {
    var _native = stream as MediaStreamWeb;
    _localStreams.remove(stream.id);
    _jsPc.removeStream(_native.jsStream);
    return Future.value();
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {
    await _jsPc
        .setLocalDescription(web.RTCLocalSessionDescriptionInit(
          type: description.type!,
          sdp: description.sdp!,
        ))
        .toDart;
  }

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    await _jsPc
        .setRemoteDescription(web.RTCSessionDescriptionInit(
          type: description.type!,
          sdp: description.sdp!,
        ))
        .toDart;
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
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    await _jsPc
        .addIceCandidate(web.RTCIceCandidateInit(
            candidate: candidate.candidate!,
            sdpMid: candidate.sdpMid!,
            sdpMLineIndex: candidate.sdpMLineIndex))
        .toDart;
  }

  @override
  Future<List<StatsReport>> getStats([MediaStreamTrack? track]) async {
    var stats;
    if (track != null) {
      var jsTrack = (track as MediaStreamTrackWeb).jsTrack;
      stats = await _jsPc.getStats(jsTrack).toDart;
    } else {
      stats = await _jsPc.getStats().toDart;
    }

    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  @override
  List<MediaStream> getLocalStreams() =>
      _jsPc.getLocalStreams().toDart.map((e) => _localStreams[e.id]!).toList();

  @override
  List<MediaStream> getRemoteStreams() => _jsPc
      .getRemoteStreams()
      .toDart
      .map((e) => MediaStreamWeb(e, _peerConnectionId))
      .toList();

  @override
  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict) {
    var dcInit = web.RTCDataChannelInit(
      id: dataChannelDict.id,
      ordered: dataChannelDict.ordered,
      protocol: dataChannelDict.protocol,
      negotiated: dataChannelDict.negotiated,
    );

    if (dataChannelDict.binaryType == 'binary') {
      dcInit.binaryType = 'arraybuffer'; // Avoid Blob in data channel
    }

    if (dataChannelDict.maxRetransmits > 0) {
      dcInit.maxRetransmits = dataChannelDict.maxRetransmits;
    }

    if (dataChannelDict.maxRetransmitTime > 0) {
      dcInit.maxPacketLifeTime = dataChannelDict.maxRetransmitTime;
    }

    final jsDc = _jsPc.createDataChannel(
      label,
      dcInit,
    );

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
  RTCDTMFSender createDtmfSender(MediaStreamTrack track) {
    var _native = track as MediaStreamTrackWeb;
    var jsDtmfSender = _jsPc.createDTMFSender(_native.jsTrack);
    return RTCDTMFSenderWeb(jsDtmfSender);
  }

  //
  // utility section
  //

  RTCIceCandidate _iceFromJs(web.RTCIceCandidate candidate) => RTCIceCandidate(
        candidate.candidate,
        candidate.sdpMid,
        candidate.sdpMLineIndex,
      );

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

extension type _RTCMediaStreamEvent._(JSObject _)
    implements web.Event, JSObject {
  external web.MediaStream get stream;
}

extension _AddRemoveStream on web.RTCPeerConnection {
  external void addStream(web.MediaStream stream);

  external void removeStream(web.MediaStream stream);

  external JSArray<web.MediaStream> getLocalStreams();
  external JSArray<web.MediaStream> getRemoteStreams();

  external web.RTCDTMFSender createDTMFSender(web.MediaStreamTrack track);
}
