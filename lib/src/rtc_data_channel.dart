@JS()
library dart_webrtc;

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:js/js.dart';

@JS()
class RTCDataChannel {
  external void close();
  external set onopen(Function(Event<RTCDataChannel> event) func);
  external set onbufferedamountlow(Function(Event<RTCDataChannel> event) func);
  external set onerror(Function(Event<RTCDataChannel> event) func);
  external set onclosing(Function(Event<RTCDataChannel> event) func);
  external set onclose(Function(Event<RTCDataChannel> event) func);
  external set onmessage(Function(RTCDataChannelMessage message) func);
}

@JS()
class RTCDataChannelMessage {}

@JS()
class RTCDataChannelInit {}
