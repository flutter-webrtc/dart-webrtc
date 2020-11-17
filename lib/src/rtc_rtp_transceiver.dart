@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream_js.dart';
import 'rtc_rtp_parameters.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';

@JS()
@anonymous
class RTCRtpTransceiverInit {
  external factory RTCRtpTransceiverInit(
      {String direction,
      List<MediaStream> streams,
      List<RTCRtpEncodingParameters> sendEncodings});
  external String get direction;
  external List<MediaStream> get streams;
  external List<RTCRtpEncodingParameters> get sendEncodings;
}

@JS('RTCRtpTransceiver')
class RTCRtpTransceiver {
  external factory RTCRtpTransceiver();
  external String get direction;
  external set direction(String dir);
  external String get mid;
  external RTCRtpReceiver get receiver;
  external RTCRtpSender get sender;
  external bool get stopped;

  external void setCodecPreferences();
  external void stop();
}
