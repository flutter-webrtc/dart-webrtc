// GENERATED CODE - DO NOT MODIFY BY HAND

part of dart_webrtc;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_MediaStreamTrack)
// @JS('MediaStreamTrack')

class MediaStreamTrack {
  MediaStreamTrack(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_MediaStreamTrack)
extension MediaStreamTrack$Ext on MediaStreamTrack {
  String get kind => getProperty(jsObject, 'kind');

  set kind(String value) {
    setProperty(jsObject, 'kind', value);
  }

  String get label => getProperty(jsObject, 'label');

  set label(String value) {
    setProperty(jsObject, 'label', value);
  }

  String get id => getProperty(jsObject, 'id');

  set id(String value) {
    setProperty(jsObject, 'id', value);
  }

  /// live or ended
  String get readyState => getProperty(jsObject, 'readyState');

  /// live or ended
  set readyState(String value) {
    setProperty(jsObject, 'readyState', value);
  }

  bool get enabled => getProperty(jsObject, 'enabled');

  set enabled(bool value) {
    setProperty(jsObject, 'enabled', value);
  }

  Function get _onmute => getProperty(jsObject, 'onmute');

  set _onmute(Function value) {
    setProperty(jsObject, 'onmute', value);
  }

  Function get _onunmute => getProperty(jsObject, 'onunmute');

  set _onunmute(Function value) {
    setProperty(jsObject, 'onunmute', value);
  }

  Function get _onended => getProperty(jsObject, 'onended');

  set _onended(Function value) {
    setProperty(jsObject, 'onended', value);
  }

  void _stop() => callMethod(jsObject, 'stop', []);

  void _applyConstraints(dynamic) =>
      callMethod(jsObject, 'applyConstraints', [dynamic]);
}
