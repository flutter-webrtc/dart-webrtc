import 'dart:js_util' as jsutil;

import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_track_impl.dart';
import 'rtc_rtp_parameters_impl.dart';

class RTCRtpReceiverWeb extends RTCRtpReceiver {
  RTCRtpReceiverWeb(this._jsRtpReceiver);

  /// private:
  final web.RTCRtpReceiver _jsRtpReceiver;

  @override
  Future<List<StatsReport>> getStats() async {
    var stats = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsRtpReceiver, 'getStats', []));
    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  /// The WebRTC specification only defines RTCRtpParameters in terms of senders,
  /// but this API also applies them to receivers, similar to ORTC:
  /// http://ortc.org/wp-content/uploads/2016/03/ortc.html#rtcrtpparameters*.
  @override
  RTCRtpParameters get parameters {
    var parameters = jsutil.callMethod(_jsRtpReceiver, 'getParameters', []);
    return RTCRtpParametersWeb.fromJsObject(parameters);
  }

  @override
  MediaStreamTrack? get track => MediaStreamTrackWeb(_jsRtpReceiver.track);

  @override
  String get receiverId => '${_jsRtpReceiver.hashCode}';

  web.RTCRtpReceiver get jsRtpReceiver => _jsRtpReceiver;
}
