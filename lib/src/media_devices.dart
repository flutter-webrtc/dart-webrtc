@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'event.dart';
import 'media_stream.dart';

@JS()
@anonymous
class MediaStreamConstraints {
  external factory MediaStreamConstraints({dynamic audio, dynamic video});
  external dynamic get audio;
  external dynamic get video;
}

@JS('MediaDeviceInfo')
class MediaDeviceInfo {
  external String get deviceId;
  external String get groupId;
  external String get kind;
  external String get label;
}

@JS('MediaDevices')
class MediaDevicesJs {
  external factory MediaDevicesJs();
  external dynamic enumerateDevices();
  external dynamic getUserMedia(MediaStreamConstraints constraints);
  external dynamic getDisplayMedia(MediaStreamConstraints constraints);
  external set devicechange(Function(Event<MediaDevicesJs> event) func);
}

class MediaDevices {
  MediaDevices(this._js);

  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    try {
      var jsList = await promiseToFuture<List<dynamic>>(_js.enumerateDevices());
      return jsList.map((e) => e as MediaDeviceInfo).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaStream> getUserMedia({MediaStreamConstraints constraints}) async {
    try {
      var jsStream =
          await promiseToFuture<MediaStreamJs>(_js.getUserMedia(constraints));
      return MediaStream(jsStream);
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaStream> getDisplayMedia(
      {MediaStreamConstraints constraints}) async {
    try {
      var jsStream = await promiseToFuture<MediaStreamJs>(
          _js.getDisplayMedia(constraints));
      return MediaStream(jsStream);
    } catch (e) {
      rethrow;
    }
  }

  final MediaDevicesJs _js;
}
