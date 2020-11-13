@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS('MediaStreamTrack')
class MediaStreamTrack {
  external factory MediaStreamTrack();
  external String get kind;
  external String get label;
  external String get id;

  /// live or ended
  external String get readyState;

  external bool get enabled;
  external set enabled(bool v);

  external set onmute(Function func);
  external set onunmute(Function func);
  external set onended(Function func);

  external void stop();

  external dynamic getConstraints();
  external void applyConstraints(dynamic);
}
