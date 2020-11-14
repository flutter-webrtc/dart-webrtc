@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
class RTCDataChannel {
  external int get id;
  external String get label;
  external String get binaryType;
  external int get bufferedAmount;
  external int get maxPacketLifeTime;
  external int get maxRetransmits;
  external bool get negotiated;
  external bool get ordered;
  external String get protocol;
  external String get readyState;

  external bool send(dynamic data);
  external bool sendByteBuffer(dynamic data);
  external void close();
  external set onopen(Function() func);
  external set onbufferedamountlow(Function() func);
  external set onerror(Function() func);
  external set onclosing(Function() func);
  external set onclose(Function() func);
  external set onmessage(Function(RTCDataChannelMessage message) func);
}

@JS()
class RTCDataChannelMessage {
  external dynamic get data;
}

@JS()
@anonymous
class RTCDataChannelInit {
  external factory RTCDataChannelInit({
    bool ordered,
    int maxPacketLifeTime,
    int maxRetransmits,
    String protocol,
    bool negotiated,
    int id,
  });
  external bool get ordered;
  external int get maxPacketLifeTime;
  external int get maxRetransmits;
  external String get protocol;
  external bool get negotiated;
  external int get id;
}

@JS('RTCDataChannelEvent')
class RTCDataChannelEvent {
  external RTCDataChannel get channel;
}
