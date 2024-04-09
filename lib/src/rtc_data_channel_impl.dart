import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

class RTCDataChannelWeb extends RTCDataChannel {
  RTCDataChannelWeb(this._jsDc) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _jsDc.addEventListener(
        'close',
        (_) {
          _state = RTCDataChannelState.RTCDataChannelClosed;
          _stateChangeController.add(_state);
          onDataChannelState?.call(_state);
        }.toJS,
        false.toJS);
    _jsDc.addEventListener(
        'open',
        (_) {
          _state = RTCDataChannelState.RTCDataChannelOpen;
          _stateChangeController.add(_state);
          onDataChannelState?.call(_state);
        }.toJS,
        false.toJS);
    _jsDc.addEventListener(
        'message',
        (web.MessageEvent event) async {
          var msg = await _parse(event.data);
          _messageController.add(msg);
          onMessage?.call(msg);
        }.toJS,
        false.toJS);
    _jsDc.addEventListener(
        'bufferedamountlow',
        (_) {
          onBufferedAmountLow?.call(bufferedAmount ?? 0);
        }.toJS,
        false.toJS);
  }

  final web.RTCDataChannel _jsDc;
  RTCDataChannelState _state = RTCDataChannelState.RTCDataChannelConnecting;

  @override
  RTCDataChannelState get state => _state;

  @override
  int? get id => _jsDc.id;

  @override
  String? get label => _jsDc.label;

  @override
  int? get bufferedAmount => _jsDc.bufferedAmount;

  @override
  set bufferedAmountLowThreshold(int? bufferedAmountLowThreshold) {
    _jsDc.bufferedAmountLowThreshold = bufferedAmountLowThreshold ?? 0;
  }

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  Future<RTCDataChannelMessage> _parse(dynamic data) async {
    if (data is String) {
      return RTCDataChannelMessage(data);
    }
    dynamic arrayBuffer;
    if (data is JSArrayBuffer) {
      arrayBuffer = data.toDart;
    } else {
      arrayBuffer = data.toString();
    }
    return RTCDataChannelMessage.fromBinary(arrayBuffer.asUint8List());
  }

  @override
  Future<void> send(RTCDataChannelMessage message) {
    if (!message.isBinary) {
      _jsDc.send(message.text.toJS);
    } else {
      _jsDc.send(message.binary.toJS);
    }
    return Future.value();
  }

  @override
  Future<void> close() {
    _jsDc.close();
    return Future.value();
  }
}
