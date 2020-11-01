import 'dart:html';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef OnMessageCallback = void Function(dynamic msg);
typedef OnCloseCallback = void Function(int code, String reason);
typedef OnOpenCallback = void Function();

class SimpleWebSocket {
  String _url;
  var _socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(this._url) {
    _url = _url.replaceAll('https:', 'wss:');
  }

  void connect() async {
    try {
      _socket = WebSocket(_url);
      _socket.onOpen.listen((e) {
        this?.onOpen();
      });

      _socket.onMessage.listen((e) {
        this?.onMessage(e.data);
      });

      _socket.onClose.listen((e) {
        this?.onClose(e.code, e.reason);
      });
    } catch (e) {
      this?.onClose(500, e.toString());
    }
  }

  void send(data) {
    if (_socket != null && _socket.readyState == WebSocket.OPEN) {
      _socket.send(data);
      print('send: $data');
    } else {
      print('WebSocket not connected, message $data not sent');
    }
  }

  void close() {
    if (_socket != null) _socket.close();
  }
}

Future<Map> getTurnCredential(String host, int port) async {
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
  final res = await http.get(url);
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    print('getTurnCredential:response => $data.');
    return data;
  }
  return {};
}
