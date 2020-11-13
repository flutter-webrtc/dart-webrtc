@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'media_stream.dart';

@JS()
class MediaRecorder {
  external dynamic get mimeType;

  /// Returns the current state of the MediaRecorder object
  ///  (inactive, recording, or paused.)
  external String get state;

  external MediaStreamJs get stream;

  external dynamic requestData();

  external void start();

  external void pause();

  external void resume();

  external void stop();

  external set ondataavailable(Function func);

  external set onerror(Function func);

  external set onpause(Function func);

  external set onresume(Function func);

  external set onstop(Function func);
}
