@JS()
library dart_webrtc;

import 'dart:async';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_wrapping/js_wrapping.dart';
import 'media_stream_js.dart';
part 'media_devices_js.g.dart';

@JsName('MediaDeviceInfo')
abstract class _MediaDeviceInfo {
  @JsName('deviceId')
  String deviceId;
  @JsName('groupId')
  String groupId;
  @JsName('kind')
  String kind;
  @JsName('label')
  String label;
}

@JS()
@anonymous
class MediaStreamConstraints {
  external factory MediaStreamConstraints({dynamic audio, dynamic video});
  external dynamic get audio;
  external dynamic get video;
}

@JsName('MediaDevices')
abstract class _MediaDevices {
  @JsName('enumerateDevices')
  Object _enumerateDevices();
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var array = await promiseToFuture<List<dynamic>>(_enumerateDevices());
    return array.map((e) => MediaDeviceInfo(e)).toList();
  }

  @JsName('getUserMedia')
  Object _getUserMedia(MediaStreamConstraints constraints);
  Future<MediaStream> getUserMedia({MediaStreamConstraints constraints}) async {
    var stream = await promiseToFuture<dynamic>(_getUserMedia(constraints));
    return MediaStream(stream);
  }

  @JsName('getDisplayMedia')
  dynamic _getDisplayMedia(MediaStreamConstraints constraints);
  Future<MediaStream> getDisplayMedia(
      {MediaStreamConstraints constraints}) async {
    var stream = await promiseToFuture<dynamic>(_getDisplayMedia(constraints));
    return MediaStream(stream);
  }
}
