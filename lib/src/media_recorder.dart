import 'package:webrtc_interface/src/media_recorder.dart' as _interface;

import '../dart_webrtc.dart';

class MediaRecorder extends _interface.MediaRecorder {
  MediaRecorder() : _delegate = mediaRecorder();
  final _interface.MediaRecorder _delegate;

  @override
  Future<void> start(
    String path, {
    MediaStreamTrack? videoTrack,
    RecorderAudioChannel? audioChannel,
    MediaStreamTrack? audioTrack,
    int rotationDegrees = 0,
  }) =>
      _delegate.start(path, videoTrack: videoTrack, audioChannel: audioChannel);

  @override
  Future stop({String? albumName}) =>
      _delegate.stop(albumName: albumName ?? 'FlutterWebRtc');

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne)? onDataChunk,
    String? mimeType,
    int timeSlice = 1000,
  }) =>
      _delegate.startWeb(
        stream,
        onDataChunk: onDataChunk,
        mimeType: mimeType ?? 'video/webm',
        timeSlice: timeSlice,
      );

  @override
  Future<void> changeVideoTrack(MediaStreamTrack videoTrack) {
    // TODO: implement changeVideoTrack
    throw UnimplementedError();
  }
}
