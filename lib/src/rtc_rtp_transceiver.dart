@JS()
library dart_webrtc;

import 'package:js/js.dart';
import '../dart_webrtc.dart';

@JS()
class RTCRtpEncodingParameters {}

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

@JS()
class RTCRtpTransceiver {
  external factory RTCRtpTransceiver();
  external String get direction;
  external String get mid;
  external RTCRtpReceiver get receiver;
  external RTCRtpSender get sender;
  external bool get stopped;

  external void setCodecPreferences();
  external void stop();
}
