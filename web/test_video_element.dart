import 'package:test/test.dart';

import 'test_data.dart' show localVideo;

List<void Function()> testFunctions = <void Function()>[
  () => test('RTCVideoElement.constructor()', () {
        expect(localVideo != null, true);
      }),
  () => test('RTCVideoElement.muted()', () {
        localVideo.muted = true;
        expect(localVideo.muted, true);
        localVideo.muted = false;
        expect(localVideo.muted, false);
      }),
  () => test('RTCVideoElement.controls()', () {
        localVideo.controls = false;
        expect(localVideo.controls, false);
        localVideo.controls = true;
        expect(localVideo.controls, true);
      }),
  () => test('RTCVideoElement.autoplay()', () {
        localVideo.autoplay = false;
        expect(localVideo.autoplay, false);
        localVideo.autoplay = true;
        expect(localVideo.autoplay, true);
      })
];
