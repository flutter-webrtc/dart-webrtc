@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'event.dart';
import 'media_stream_track.dart';

@JS('MediaStream')
class MediaStreamJs {
  external bool get active;
  external String get id;
  external void addTrack(MediaStreamTrack track);
  external void removeTrack(MediaStreamTrack track);
  external MediaStreamJs clone();
  external List<MediaStreamTrack> getTracks();
  external List<MediaStreamTrack> getAudioTracks();
  external List<MediaStreamTrack> getVideoTracks();
  external MediaStreamTrack getTrackById(String id);
  external set onaddtrack(Function(MediaStreamTrackEvent event) func);
  external set oninactive(Function(Event vent) func);
  external set onremovetrack(Function(MediaStreamTrackEvent event) func);
}

@JS()
class MediaStreamTrackEvent {
  external MediaStreamTrack get track;
}

class MediaStream {
  MediaStream(this._js);
  final MediaStreamJs _js;
  MediaStreamJs get js => _js;
  bool get active => _js.active;
  String get id => _js.id;
  void addTrack(MediaStreamTrack track) => _js.addTrack(track);
  void removeTrack(MediaStreamTrack track) => _js.removeTrack(track);
  MediaStream clone() => MediaStream(_js.clone());
  List<MediaStreamTrack> getTracks() => _js.getTracks();
  List<MediaStreamTrack> getAudioTracks() => _js.getAudioTracks();
  List<MediaStreamTrack> getVideoTracks() => _js.getVideoTracks();
  MediaStreamTrack getTrackById(String id) => _js.getTrackById(id);
  set onaddtrack(Function(MediaStreamTrackEvent event) func) =>
      _js.onaddtrack = allowInterop(func);
  set oninactive(Function(Event vent) func) =>
      _js.oninactive = allowInterop(func);
  set onremovetrack(Function(MediaStreamTrackEvent event) func) =>
      _js.onremovetrack = allowInterop(func);
}
