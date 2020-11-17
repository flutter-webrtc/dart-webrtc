@JS()
library dart_webrtc;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'js_wrapping/js_wrapping.dart';
import 'media_stream_track_js.dart';

part 'media_stream_js.g.dart';

@JsName('MediaStream')
abstract class _MediaStream {
  @JsName('active')
  bool active;

  @JsName('id')
  String id;

  @JsName('addTrack')
  void _addTrack(MediaStreamTrack track);

  void addTrack(dynamic track) => _addTrack(track.jsObject);

  @JsName('addTrack')
  void _removeTrack(dynamic track);

  void removeTrack(dynamic track) => _removeTrack(track.jsObject);

  @JsName('clone')
  Object _clone();

  MediaStream clone() => MediaStream(_clone());

  @JsName('getTracks')
  List<dynamic> _getTracks();

  List<MediaStreamTrack> getTracks() =>
      _getTracks().map((e) => MediaStreamTrack(e)).toList();

  @JsName('getAudioTracks')
  List<dynamic> _getAudioTracks();
  List<MediaStreamTrack> getAudioTracks() =>
      _getAudioTracks().map((e) => MediaStreamTrack(e)).toList();

  @JsName('getVideoTracks')
  List<dynamic> _getVideoTracks();

  List<MediaStreamTrack> getVideoTracks() =>
      _getVideoTracks().map((e) => MediaStreamTrack(e)).toList();

  @JsName('addTrack')
  dynamic _getTrackById(String id);

  MediaStreamTrack getTrackById(String id) =>
      MediaStreamTrack(_getTrackById(id));

  @JsName('onaddtrack')
  Function(MediaStreamTrackEvent) _onaddtrack;

  set onaddtrack(Function(MediaStreamTrackEvent) func) =>
      _onaddtrack = (evt) => func(MediaStreamTrackEvent(evt));

  @JsName('oninactive')
  Function(Object) _oninactive;

  set oninactive(Function(MediaStreamTrackEvent) func) =>
      _oninactive = (evt) => func(MediaStreamTrackEvent(evt));

  @JsName('onremovetrack')
  Function(MediaStreamTrackEvent) _onremovetrack;

  set onremovetrack(Function(MediaStreamTrackEvent) func) =>
      _onremovetrack = (evt) => func(MediaStreamTrackEvent(evt));
}

@JsName('Event')
abstract class _MediaStreamTrackEvent {
  @JsName('target')
  dynamic _target;
  MediaStream get target => MediaStream(_target);
}
