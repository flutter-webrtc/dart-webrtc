@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_wrapping/js_wrapping.dart';

import 'media_devices_js.dart';

part 'navigator_js.g.dart';

@JsName('Navigator')
abstract class _Navigator {
  @JsName('mediaDevices')
  Object _mediaDevices;
  MediaDevices get mediaDevices => MediaDevices(_mediaDevices);
}

@JS('navigator')
external Object get navigatorjs;

Navigator navigator = Navigator(navigatorjs);
