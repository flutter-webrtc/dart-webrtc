@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS('Navigator')
class NavigatorJs {
  external MediaDevicesJs get mediaDevices;
}

class Navigator {
  Navigator(this._js);
  MediaDevices get mediaDevices => MediaDevices(_js.mediaDevices);
  NavigatorJs _js;
}

@JS('navigator')
external NavigatorJs get navigatorjs;

final Navigator navigator = Navigator(navigatorjs);
