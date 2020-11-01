@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'event.dart';
import 'media_stream_track.dart';

@JS('MediaStream')
class MediaStream {
  external bool get active;
  external String get id;
  external void addTrack(MediaStreamTrack track);
  external void removeTrack(MediaStreamTrack track);
  external MediaStream clone();
  external List<MediaStreamTrack> getTracks();
  external List<MediaStreamTrack> getAudioTracks();
  external List<MediaStreamTrack> getVideoTracks();
  external MediaStreamTrack getTrackById(String id);
  external set onaddtrack(Function(MediaStreamTrack track) func);
  external set oninactive(Function(Event vent) func);
  external set onremovetrack(Function(MediaStreamTrack track) func);
}
