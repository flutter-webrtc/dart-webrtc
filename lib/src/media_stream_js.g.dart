// GENERATED CODE - DO NOT MODIFY BY HAND

part of dart_webrtc;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_MediaStream)
// @JS('MediaStream')

class MediaStream {
  MediaStream(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_MediaStream)
extension MediaStream$Ext on MediaStream {
  bool get active => getProperty(jsObject, 'active');

  set active(bool value) {
    setProperty(jsObject, 'active', value);
  }

  String get id => getProperty(jsObject, 'id');

  set id(String value) {
    setProperty(jsObject, 'id', value);
  }

  Function(MediaStreamTrackEvent) get _onaddtrack =>
      getProperty(jsObject, 'onaddtrack');

  set _onaddtrack(Function(MediaStreamTrackEvent) value) {
    setProperty(jsObject, 'onaddtrack', allowInterop(value));
  }

  Function(Object) get _oninactive => getProperty(jsObject, 'oninactive');

  set _oninactive(Function(Object) value) {
    setProperty(jsObject, 'oninactive', allowInterop(value));
  }

  Function(MediaStreamTrackEvent) get _onremovetrack =>
      getProperty(jsObject, 'onremovetrack');

  set _onremovetrack(Function(MediaStreamTrackEvent) value) {
    setProperty(jsObject, 'onremovetrack', allowInterop(value));
  }

  set onaddtrack(Function(MediaStreamTrackEvent) func) =>
      _onaddtrack = (evt) => func(MediaStreamTrackEvent(evt));
  set oninactive(Function(MediaStreamTrackEvent) func) =>
      _oninactive = (evt) => func(MediaStreamTrackEvent(evt));
  set onremovetrack(Function(MediaStreamTrackEvent) func) =>
      _onremovetrack = (evt) => func(MediaStreamTrackEvent(evt));

  void _addTrack(MediaStreamTrack track) =>
      callMethod(jsObject, 'addTrack', [track]);
  void addTrack(dynamic track) => _addTrack(track.jsObject);

  void _removeTrack(dynamic track) =>
      callMethod(jsObject, 'removeTrack', [track]);
  void removeTrack(dynamic track) => _removeTrack(track.jsObject);

  Object _clone() => callMethod(jsObject, 'clone', []);
  MediaStream clone() => MediaStream(_clone());

  List<dynamic> _getTracks() => callMethod(jsObject, 'getTracks', []);
  List<MediaStreamTrack> getTracks() =>
      _getTracks().map((e) => MediaStreamTrack(e)).toList();

  List<dynamic> _getAudioTracks() => callMethod(jsObject, 'getAudioTracks', []);
  List<MediaStreamTrack> getAudioTracks() =>
      _getAudioTracks().map((e) => MediaStreamTrack(e)).toList();

  List<dynamic> _getVideoTracks() => callMethod(jsObject, 'getVideoTracks', []);
  List<MediaStreamTrack> getVideoTracks() =>
      _getVideoTracks().map((e) => MediaStreamTrack(e)).toList();

  dynamic _getTrackById(String id) =>
      callMethod(jsObject, 'getTrackById', [id]);
  MediaStreamTrack getTrackById(String id) =>
      MediaStreamTrack(_getTrackById(id));
}

@GeneratedFrom(_MediaStreamTrackEvent)
// @JS('Event')

class MediaStreamTrackEvent {
  MediaStreamTrackEvent(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_MediaStreamTrackEvent)
extension MediaStreamTrackEvent$Ext on MediaStreamTrackEvent {
  dynamic get _target => getProperty(jsObject, 'target');

  set _target(dynamic value) {
    setProperty(jsObject, 'target', value);
  }

  MediaStream get target => MediaStream(_target);
}
