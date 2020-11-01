@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS('MediaStreamTrack')
class MediaStreamTrack {
  external factory MediaStreamTrack();
  external String get kind;
  external bool get muted;
  external bool get enabled;
  external set enabled(bool v);
  external String get lable;
  external String get id;
  external set onmute(Function func);
  external set onunmute(Function func);
  external set oneended(Function func);
  external void stop();
}
