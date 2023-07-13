import 'dart:async';
import 'dart:html';
import 'dart:js_util' as jsutil;

import 'package:dart_webrtc/src/media_stream_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_parameters_impl.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._jsRtpSender, this._ownsTrack);

  factory RTCRtpSenderWeb.fromJsSender(RtcRtpSender jsRtpSender) {
    return RTCRtpSenderWeb(jsRtpSender, jsRtpSender.track != null);
  }

  final RtcRtpSender _jsRtpSender;
  bool _ownsTrack = false;

  @override
  Future<void> replaceTrack(MediaStreamTrack? track) async {
    try {
      if (track != null) {
        var nativeTrack = track as MediaStreamTrackWeb;
        jsutil.callMethod(_jsRtpSender, 'replaceTrack', [nativeTrack.jsTrack]);
      } else {
        jsutil.callMethod(_jsRtpSender, 'replaceTrack', [null]);
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
        jsutil.callMethod(_jsRtpSender, 'setTrack', [nativeTrack.jsTrack]);
      } else {
        jsutil.callMethod(_jsRtpSender, 'setTrack', [null]);
      }
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.toString()}';
    }
  }

  @override
  Future<void> setStreams(List<MediaStream> streams) async {
    try {
      final nativeStreams = streams.cast<MediaStreamWeb>();
      jsutil.callMethod(_jsRtpSender, 'setStreams',
          nativeStreams.map((e) => e.jsStream).toList());
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setStreams: ${e.toString()}';
    }
  }

  @override
  RTCRtpParameters get parameters {
    var parameters = jsutil.callMethod(_jsRtpSender, 'getParameters', []);
    return RTCRtpParametersWeb.fromJsObject(parameters);
  }

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    try {
      var oldParameters = jsutil.callMethod(_jsRtpSender, 'getParameters', []);
      jsutil.setProperty(
          oldParameters,
          'encodings',
          jsutil.jsify(
              parameters.encodings?.map((e) => e.toMap()).toList() ?? []));
      await jsutil.promiseToFuture<void>(
          jsutil.callMethod(_jsRtpSender, 'setParameters', [oldParameters]));
      return Future<bool>.value(true);
    } on Exception catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.toString()}';
    }
  }

  @override
  Future<List<StatsReport>> getStats() async {
    var stats = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsRtpSender, 'getStats', []));
    var report = <StatsReport>[];
    stats.forEach((key, value) {
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
  RTCDTMFSender get dtmfSender =>
      RTCDTMFSenderWeb(jsutil.getProperty(_jsRtpSender, 'dtmf'));

  @override
  Future<void> dispose() async {}

  RtcRtpSender get jsRtpSender => _jsRtpSender;
}
