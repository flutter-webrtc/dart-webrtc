import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';

class MediaRecorderWeb extends MediaRecorder {
  late web.MediaRecorder _recorder;
  late Completer<String> _completer;

  @override
  Future<void> start(
    String path, {
    MediaStreamTrack? videoTrack,
    MediaStreamTrack? audioTrack,
    RecorderAudioChannel? audioChannel,
    int? rotation,
  }) {
    throw 'Use startWeb on Flutter Web!';
  }

  @override
  void startWeb(
    MediaStream stream, {
    Function(dynamic blob, bool isLastOne)? onDataChunk,
    String mimeType = 'video/webm',
    int timeSlice = 1000,
  }) {
    var _native = stream as MediaStreamWeb;
    _recorder = web.MediaRecorder(
        _native.jsStream, web.MediaRecorderOptions(mimeType: mimeType));
    if (onDataChunk == null) {
      var _chunks = <web.Blob>[];
      _completer = Completer<String>();
      _recorder.addEventListener(
          'dataavailable',
          (web.Event event) {
            final web.Blob blob = js.JsObject.fromBrowserObject(event)['data'];
            if (blob.size > 0) {
              _chunks.add(blob);
            }
            if (_recorder.state == 'inactive') {
              final blob =
                  web.Blob(_chunks.toJS, web.BlobPropertyBag(type: mimeType));
              _completer.complete(web.URL.createObjectURL(blob));
            }
          }.toJS);
      _recorder.addEventListener(
          'error',
          (JSAny error) {
            _completer.completeError(error);
          }.toJS);
    } else {
      _recorder.addEventListener(
          'dataavailable',
          (web.Event event) {
            onDataChunk(
              js.JsObject.fromBrowserObject(event)['data'],
              _recorder.state == 'inactive',
            );
          }.toJS);
    }
    _recorder.start(timeSlice);
  }

  @override
  Future<dynamic> stop() {
    _recorder.stop();
    return _completer.future;
  }
}
