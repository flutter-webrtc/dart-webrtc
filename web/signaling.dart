import 'dart:convert';
import 'dart:async';
import 'random_string.dart';
import 'simple_websocket.dart';

import 'package:dart_webrtc/dart_webrtc.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

/*
 * callbacks for Signaling API.
 */
typedef SignalingStateCallback = void Function(SignalingState state);
typedef StreamStateCallback = void Function(MediaStream stream);
typedef OtherEventCallback = void Function(dynamic event);
typedef DataChannelMessageCallback = void Function(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef DataChannelCallback = void Function(RTCDataChannel dc);

class Signaling {
  final JsonEncoder _encoder = JsonEncoder();
  final String _selfId = randomNumeric(6);
  SimpleWebSocket _socket;
  var _sessionId;
  var _host;
  final _port = 8086;
  final _peerConnections = <String, RTCPeerConnection>{};
  final _dataChannels = <String, RTCDataChannel>{};
  final _remoteCandidates = <RTCIceCandidate>[];
  var _iceServers = <RTCIceServer>[];
  var _turnCredential;

  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Signaling(_host);

  void close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    _peerConnections.forEach((key, pc) {
      pc.close();
    });
    if (_socket != null) _socket.close();
  }

  void switchCamera() {
    if (_localStream != null) {
      //TODO: _localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void invite(String peer_id, String media, use_screen) {
    _sessionId = _selfId + '-' + peer_id;

    if (onStateChange != null) {
      onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peer_id, media, use_screen).then((pc) {
      _peerConnections[peer_id] = pc;
      if (media == 'data') {
        _createDataChannel(peer_id, pc);
      }
      _createOffer(peer_id, pc, media);
    });
  }

  void bye() {
    _send('bye', {
      'session_id': _sessionId,
      'from': _selfId,
    });
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;
    var data = mapData['data'];

    switch (mapData['type']) {
      case 'peers':
        List<dynamic> peers = data;
        if (onPeersUpdate != null) {
          var event = <String, dynamic>{};
          event['self'] = _selfId;
          event['peers'] = peers;
          onPeersUpdate(event);
        }

        break;
      case 'offer':
        var id = data['from'];
        var description = data['description'];
        var media = data['media'];
        var sessionId = data['session_id'];
        _sessionId = sessionId;

        if (onStateChange != null) {
          onStateChange(SignalingState.CallStateNew);
        }

        var pc = await _createPeerConnection(id, media, false);
        _peerConnections[id] = pc;
        await pc.setRemoteDescription(RTCSessionDescription(
            sdp: description['sdp'], type: description['type']));
        await _createAnswer(id, pc, media);
        if (_remoteCandidates.isNotEmpty) {
          _remoteCandidates.forEach((candidate) async {
            await pc.addIceCandidate(candidate);
          });
          _remoteCandidates.clear();
        }

        break;
      case 'answer':
        var id = data['from'];
        var description = data['description'];

        var pc = _peerConnections[id];
        if (pc != null) {
          await pc.setRemoteDescription(RTCSessionDescription(
              sdp: description['sdp'], type: description['type']));
        }

        break;
      case 'candidate':
        var id = data['from'];
        var candidateMap = data['candidate'];
        var pc = _peerConnections[id];
        var candidate = RTCIceCandidate(
            candidate: candidateMap['candidate'],
            sdpMid: candidateMap['sdpMid'],
            sdpMLineIndex: candidateMap['sdpMLineIndex']);
        if (pc != null) {
          await pc.addIceCandidate(candidate);
        } else {
          _remoteCandidates.add(candidate);
        }

        break;
      case 'leave':
        var id = data;
        var pc = _peerConnections.remove(id);
        _dataChannels.remove(id);

        if (_localStream != null) {
          _localStream.dispose();
          _localStream = null;
        }

        if (pc != null) {
          pc.close();
        }
        _sessionId = null;
        onStateChange?.call(SignalingState.CallStateBye);

        break;
      case 'bye':
        var to = data['to'];
        var sessionId = data['session_id'];
        print('bye: ' + sessionId);

        if (_localStream != null) {
          _localStream.dispose();
          _localStream = null;
        }

        var pc = _peerConnections[to];
        if (pc != null) {
          pc.close();
          _peerConnections.remove(to);
        }

        var dc = _dataChannels[to];
        if (dc != null) {
          dc.close();
          _dataChannels.remove(to);
        }

        _sessionId = null;
        onStateChange?.call(SignalingState.CallStateBye);

        break;
      case 'keepalive':
        print('keepalive response!');

        break;
      default:
        break;
    }
  }

  void connect() async {
    var url = 'https://$_host:$_port/ws';
    _socket = SimpleWebSocket(url);

    print('connect to $url');

    if (_turnCredential == null) {
      try {
        _turnCredential = await getTurnCredential(_host, _port);
        _iceServers = [
          RTCIceServer(
              urls: _turnCredential['uris'][0],
              username: _turnCredential['username'],
              credential: _turnCredential['password'])
        ];
      } catch (e) {
        print('error: ${e.toString()}');
      }
    }

    _socket.onOpen = () {
      print('onOpen');
      this?.onStateChange(SignalingState.ConnectionOpen);
      _send('new',
          {'name': 'dart_webrtc', 'id': _selfId, 'user_agent': 'broswer'});
    };

    _socket.onMessage = (message) {
      print('Received data: ' + message);
      var decoder = JsonDecoder();
      onMessage(decoder.convert(message));
    };

    _socket.onClose = (int code, String reason) {
      print('Closed by server [$code => $reason]!');
      if (onStateChange != null) {
        onStateChange(SignalingState.ConnectionClosed);
      }
    };

    await _socket.connect();
  }

  Future<MediaStream> createStream(media, user_screen) async {
    MediaStream stream = user_screen
        ? await navigator.mediaDevices.getDisplayMedia()
        : await navigator.mediaDevices
            .getUserMedia(MediaStreamConstraints(audio: true, video: {
            'mandatory': {
              'minWidth':
                  '640', // Provide your own width, height and frame rate here
              'minHeight': '480',
              'minFrameRate': '30',
            },
            'facingMode': 'user',
            'optional': [],
          }));
    if (onLocalStream != null) {
      onLocalStream(stream);
    }
    return stream;
  }

  Future<RTCPeerConnection> _createPeerConnection(
      id, media, user_screen) async {
    if (media != 'data') _localStream = await createStream(media, user_screen);
    var pc = RTCPeerConnection(
        configuration: RTCConfiguration(
            iceServers: _iceServers.isNotEmpty
                ? _iceServers
                : [RTCIceServer(urls: 'stun:stun.l.google.com:19302')]));
    if (media != 'data') pc.addStream(_localStream);
    pc.onicecandidate = (RTCIceCandidate candidate) {
      _send('candidate', {
        'to': id,
        'from': _selfId,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': _sessionId,
      });
    };

    pc.oniceconnectionstatechange = (state) {};

    pc.onaddstream = (stream) {
      if (onAddRemoteStream != null) onAddRemoteStream(stream);
      //_remoteStreams.add(stream);
    };

    pc.onremovestream = (stream) {
      if (onRemoveRemoteStream != null) onRemoveRemoteStream(stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.ondatachannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  void _addDataChannel(id, RTCDataChannel channel) {
    channel.onmessage = (RTCDataChannelMessage data) {
      if (onDataChannelMessage != null) onDataChannelMessage(channel, data);
    };
    _dataChannels[id] = channel;

    if (onDataChannel != null) onDataChannel(channel);
  }

  void _createDataChannel(id, RTCPeerConnection pc,
      {String label = 'fileTransfer'}) async {
    var dataChannelDict = RTCDataChannelInit();
    var channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  void _createOffer(String id, RTCPeerConnection pc, String media) async {
    try {
      var s = await pc.createOffer(
          options: RTCOfferOptions(
        offerToReceiveAudio: media == 'data' ? false : true,
        offerToReceiveVideo: media == 'data' ? false : true,
      ));
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': _sessionId,
        'media': media,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _createAnswer(String id, RTCPeerConnection pc, media) async {
    try {
      var s = await pc.createAnswer();
      pc.setLocalDescription(s);
      _send('answer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': _sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _send(event, data) {
    var request = {};
    request['type'] = event;
    request['data'] = data;
    _socket.send(_encoder.convert(request));
  }
}
