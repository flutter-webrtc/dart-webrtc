@JS()
library dart_webrtc;

import 'package:dart_webrtc/src/enum.dart';
import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS()
class RTCDataChannel {
  external int get id;
  external String get label;
  external dynamic get readyState;
  external bool send(dynamic data);
  external void close();

  external set onopen(Function() func);
  external set onbufferedamountlow(Function() func);
  external set onerror(Function() func);
  external set onclosing(Function() func);
  external set onclose(Function() func);
  external set onmessage(Function(RTCDataChannelMessage message) func);

  RTCDataChannelState get state => rtcDataChannelStateForString(readyState);
}

@JS()
class RTCDataChannelMessage {}

@JS()
class RTCDataChannelInit {}
