@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_wrapping/js_wrapping.dart';

part 'media_stream_track_js.g.dart';

@JsName('MediaStreamTrack')
abstract class _MediaStreamTrack {
  @JsName('kind')
  String kind;

  @JsName('label')
  String label;

  @JsName('id')
  String id;

  /// live or ended
  @JsName('readyState')
  String readyState;

  @JsName('enabled')
  bool enabled;

  @JsName('onmute')
  Function _onmute;

  @JsName('onunmute')
  Function _onunmute;

  @JsName('onended')
  Function _onended;

  @JsName('stop')
  void _stop();

  @JsName('applyConstraints')
  void _applyConstraints(dynamic);
}
