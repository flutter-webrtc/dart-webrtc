// GENERATED CODE - DO NOT MODIFY BY HAND

part of dart_webrtc;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_MediaDeviceInfo)
// @JS('MediaDeviceInfo')

class MediaDeviceInfo {
  MediaDeviceInfo(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_MediaDeviceInfo)
extension MediaDeviceInfo$Ext on MediaDeviceInfo {
  String get deviceId => getProperty(jsObject, 'deviceId');

  set deviceId(String value) {
    setProperty(jsObject, 'deviceId', value);
  }

  String get groupId => getProperty(jsObject, 'groupId');

  set groupId(String value) {
    setProperty(jsObject, 'groupId', value);
  }

  String get kind => getProperty(jsObject, 'kind');

  set kind(String value) {
    setProperty(jsObject, 'kind', value);
  }

  String get label => getProperty(jsObject, 'label');

  set label(String value) {
    setProperty(jsObject, 'label', value);
  }
}

@GeneratedFrom(_MediaDevices)
// @JS('MediaDevices')

class MediaDevices {
  MediaDevices(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_MediaDevices)
extension MediaDevices$Ext on MediaDevices {
  Object _enumerateDevices() => callMethod(jsObject, 'enumerateDevices', []);
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    var array = await promiseToFuture<List<dynamic>>(_enumerateDevices());
    return array.map((e) => MediaDeviceInfo(e)).toList();
  }

  Object _getUserMedia(MediaStreamConstraints constraints) =>
      callMethod(jsObject, 'getUserMedia', [constraints]);
  Future<MediaStream> getUserMedia({MediaStreamConstraints constraints}) async {
    var stream = await promiseToFuture<dynamic>(_getUserMedia(constraints));
    return MediaStream(stream);
  }

  dynamic _getDisplayMedia(MediaStreamConstraints constraints) =>
      callMethod(jsObject, 'getDisplayMedia', [constraints]);
  Future<MediaStream> getDisplayMedia(
      {MediaStreamConstraints constraints}) async {
    var stream = await promiseToFuture<dynamic>(_getDisplayMedia(constraints));
    return MediaStream(stream);
  }
}
