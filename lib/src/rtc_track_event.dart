@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS('RTCTrackEvent')
class RTCTrackEvent {
  external RTCRtpReceiver get receiver;
  external List<MediaStream> get streams;
  external MediaStreamTrack get track;
  external RTCRtpTransceiver get transceiver;
}

/*
class RTCTrackEvent {
  RTCTrackEvent(this._js);
  RTCRtpReceiver get receiver => _js.receiver;
  List<MediaStream> get streams => _js.streams;
  MediaStreamTrack get track => _js.track;
  RTCRtpTransceiver get transceiver => _js.transceiver;
  final RTCTrackEventJs _js;
}
*/
