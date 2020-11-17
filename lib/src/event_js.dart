@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_wrapping/js_wrapping.dart';

part 'event_js.g.dart';

@JsName('Event')
class _Event {
  @JsName('target')
  dynamic target;
}
