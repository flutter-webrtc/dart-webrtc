@JS()
library dart_webrtc;

import 'package:js/js.dart';

import '../dart_webrtc.dart';

@JS()
class RTCDataChannel {
  external int get id;
  external String get label;

  external bool send(dynamic data);
  external void close();

  external set onopen(Function(Event) func);
  external set onbufferedamountlow(Function(Event) func);
  external set onerror(Function(Event) func);
  external set onclosing(Function(Event) func);
  external set onclose(Function(Event) func);
  external set onmessage(Function(RTCDataChannelMessage message) func);
}

@JS()
class RTCDataChannelMessage {}

@JS()
class RTCDataChannelInit {}
