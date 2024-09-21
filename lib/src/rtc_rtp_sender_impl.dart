import 'dart:async';

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_parameters_impl.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._jsRtpSender, this._ownsTrack);

  factory RTCRtpSenderWeb.fromJsSender(web.RTCRtpSender jsRtpSender) {
    return RTCRtpSenderWeb(jsRtpSender, jsRtpSender.track != null);
  }

  final web.RTCRtpSender _jsRtpSender;
  bool _ownsTrack = false;

  @override
  Future<void> replaceTrack(MediaStreamTrack? track) async {
    try {
      if (track != null) {
        var nativeTrack = track as MediaStreamTrackWeb;
        _jsRtpSender.replaceTrack(nativeTrack.jsTrack);
      } else {
        _jsRtpSender.replaceTrack(null);
      }
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::replaceTrack: ${e.toString()}';
    }
  }

  @override
  Future<void> setTrack(MediaStreamTrack? track,
      {bool takeOwnership = true}) async {
    try {
      if (track != null) {
        var nativeTrack = track as MediaStreamTrackWeb;
        _jsRtpSender.callMethod('setTrack'.toJS, nativeTrack.jsTrack);
      } else {
        _jsRtpSender.callMethod('setTrack'.toJS, null);
      }
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.toString()}';
    }
  }

  @override
  Future<void> setStreams(List<MediaStream> streams) async {
    try {
      final nativeStreams = streams.cast<MediaStreamWeb>();
      _jsRtpSender.callMethodVarArgs(
          'setStreams'.toJS, nativeStreams.map((e) => e.jsStream).toList());
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setStreams: ${e.toString()}';
    }
  }

  @override
  RTCRtpParameters get parameters {
    var parameters = _jsRtpSender.getParameters();
    return RTCRtpParametersWeb.fromJsObject(parameters);
  }

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    try {
      var oldParameters = _jsRtpSender.getParameters();

      oldParameters.encodings =
          (parameters.encodings?.map((e) => e.toMap()).toList().jsify() ??
              [].jsify()) as JSArray<web.RTCRtpEncodingParameters>;
      await _jsRtpSender.setParameters(oldParameters).toDart;
      return Future<bool>.value(true);
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.toString()}';
    }
  }

  @override
  Future<List<StatsReport>> getStats() async {
    var stats = await _jsRtpSender.getStats().toDart;
    var report = <StatsReport>[];
    (stats.dartify() as Map<String, dynamic>).forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  @override
  MediaStreamTrack? get track {
    if (null != _jsRtpSender.track) {
      return MediaStreamTrackWeb(_jsRtpSender.track!);
    }
    return null;
  }

  @override
  String get senderId => '${_jsRtpSender.hashCode}';

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender => RTCDTMFSenderWeb(_jsRtpSender.dtmf!);

  @override
  Future<void> dispose() async {}

  web.RTCRtpSender get jsRtpSender => _jsRtpSender;
}
