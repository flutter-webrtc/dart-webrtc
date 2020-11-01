@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS()
class Navigator {
  external MediaDevices get mediaDevices;
}

@JS()
external Navigator get navigator;
