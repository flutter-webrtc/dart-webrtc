@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS()
@anonymous
class MediaStreamConstraints {
  external factory MediaStreamConstraints({dynamic audio, dynamic video});
  external dynamic get audio;
  external dynamic get video;
}

@JS()
class InputDeviceInfo {
  external String get deviceId;
  external String get groupId;
  external String get kind;
  external String get label;
}

@JS()
class MediaDeviceInfo {
  external String get deviceId;
  external String get groupId;
  external String get kind;
  external String get label;
}

@JS()
class MediaDevices {
  external factory MediaDevices();
  external dynamic enumerateDevices();
  external dynamic getUserMedia(MediaStreamConstraints constraints);
  external dynamic getDisplayMedia();
  external set devicechange(Function(Event<MediaDevices> event) func);
}
