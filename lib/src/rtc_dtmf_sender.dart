@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS('RTCDTMFToneChangeEvent')
class RTCDTMFToneChangeEvent {
  external factory RTCDTMFToneChangeEvent();
  external String get tone;
}

@JS('RTCDTMFSender')
@anonymous
class RTCDTMFSender {
  external factory RTCDTMFSender();

  external void insertDTMF(String tones, int duration, int interToneGap);

  external String get toneBuffer;

  external set tonechange(Function(RTCDTMFToneChangeEvent) func);
}
