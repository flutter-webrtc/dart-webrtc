import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:test/test.dart';

MediaStream mediaStream;

List<void Function()> testFunctions = <void Function()>[
  () => test('MediaStream.constructor()', () async {
        mediaStream = await navigator.mediaDevices.getUserMedia(
            constraints: MediaStreamConstraints(audio: true, video: true));

        expect(mediaStream.id != null, true);
      }),
  () => test('MediaStream.active()', () {
        expect(mediaStream.active, true);
      }),
  () => test('MediaStream.getTracks()', () {
        expect(mediaStream.getTracks().length, 2);
      }),
  () => test('MediaStream.getAudioTracks()', () {
        expect(mediaStream.getAudioTracks().length, 1);
        var track =
            mediaStream.getTrackById(mediaStream.getAudioTracks()[0].id);
        expect(track.id, mediaStream.getAudioTracks()[0].id);
      }),
  () => test('MediaStream.getVideoTracks()', () {
        expect(mediaStream.getVideoTracks().length, 1);
        var track =
            mediaStream.getTrackById(mediaStream.getVideoTracks()[0].id);
        expect(track.id, mediaStream.getVideoTracks()[0].id);
      }),
  () => test('MediaStream.removeTrack()', () {
        var track =
            mediaStream.getTrackById(mediaStream.getVideoTracks()[0].id);
        mediaStream.removeTrack(track);
        expect(mediaStream.getVideoTracks().length, 0);
      }),
  () => test('MediaStream.close()', () {
        mediaStream.getTracks().forEach((element) {
          element.stop();
          mediaStream.removeTrack(element);
        });
        expect(mediaStream.getTracks().isEmpty, true);
        mediaStream = null;
      })
];
