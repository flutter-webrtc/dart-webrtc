@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class Event<T> {
  external T get target;
}
