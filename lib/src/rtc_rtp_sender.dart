@JS()
library dart_webrtc;

import 'package:js/js.dart';
import '../dart_webrtc.dart';

@JS()
class RTCRtpSender {
  external factory RTCRtpSender();
  external MediaStreamTrack get track;
  external dynamic get dtmf;
  external dynamic getParameters();
  external dynamic getStats();
  external void setStreams(List<MediaStream> streams);
  external void replaceTrack(MediaStreamTrack track);

  external static dynamic getCapabilities();
}
