import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/enum.dart';
import 'package:test/test.dart';

RTCPeerConnection pc;

List<void Function()> testFunctions = <void Function()>[
  () => test('RTCPeerConnection.constructor()', () async {
        pc = RTCPeerConnection(configuration: RTCConfiguration(iceServers: []));
        expect(pc.connectionState,
            RTCPeerConnectionState.RTCPeerConnectionStateNew);
        expect(pc.signalingState, RTCSignalingState.RTCSignalingStateStable);
      }),
  () => test('RTCPeerConnection.createOffer()', () async {
        var offer = await pc.createOffer(
            options: RTCOfferOptions(
                offerToReceiveAudio: true, offerToReceiveVideo: true));
        await pc.setLocalDescription(offer);
        expect(pc.signalingState,
            RTCSignalingState.RTCSignalingStateHaveLocalOffer);
      }),
  () => test('RTCPeerConnection.createAnswer()', () {}),
  () => test('RTCPeerConnection.close()', () {
        pc.close();
        expect(pc.signalingState, RTCSignalingState.RTCSignalingStateClosed);
      })
];
