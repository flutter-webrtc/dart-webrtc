import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:dart_webrtc/src/enum.dart';
import 'package:test/test.dart';

RTCPeerConnection pc1;
RTCPeerConnection pc2;

RTCSessionDescription offer;
RTCSessionDescription answer;

List<void Function()> testFunctions = <void Function()>[
  () => test('RTCPeerConnection.constructor()', () async {
        pc1 =
            RTCPeerConnection(configuration: RTCConfiguration(iceServers: []));

        expect(pc1.connectionState,
            RTCPeerConnectionState.RTCPeerConnectionStateNew);
        expect(pc1.signalingState, RTCSignalingState.RTCSignalingStateStable);

        pc2 =
            RTCPeerConnection(configuration: RTCConfiguration(iceServers: []));

        expect(pc2.connectionState,
            RTCPeerConnectionState.RTCPeerConnectionStateNew);
        expect(pc2.signalingState, RTCSignalingState.RTCSignalingStateStable);

        pc1.onicecandidate = (RTCPeerConnectionIceEvent event) async {
          if (event.candidate == null) {
            print('pc1: end-of-candidate');
            return;
          }
          print('pc1: onicecaniddate => ${event.candidate.candidate}');
          await pc2.addIceCandidate(event.candidate);
        };

        pc2.onicecandidate = (RTCPeerConnectionIceEvent event) async {
          if (event.candidate == null) {
            print('pc2: end-of-candidate');
            return;
          }
          print('pc2: onicecaniddate => ${event.candidate.candidate}');
          await pc1.addIceCandidate(event.candidate);
        };

        pc1.onconnectionstatechange = (RTCPeerConnectionState state) {
          print('pc1: onconnectionstatechange => ${state.toString()}');
        };
        pc2.onconnectionstatechange = (RTCPeerConnectionState state) {
          print('pc2: onconnectionstatechange => ${state.toString()}');
        };

        pc1.oniceconnectionstatechange = (RTCIceConnectionState state) {
          print('pc1: oniceconnectionstatechange => ${state.toString()}');
        };
        pc2.oniceconnectionstatechange = (RTCIceConnectionState state) {
          print('pc2: oniceconnectionstatechange => ${state.toString()}');
        };

        pc1.onicegatheringstatechange = (RTCIceGatheringState state) {
          print('pc1: onicegatheringstatechange => ${state.toString()}');
        };
        pc2.onicegatheringstatechange = (RTCIceGatheringState state) {
          print('pc2: onicegatheringstatechange => ${state.toString()}');
        };

        pc1.onsignalingstatechange = (RTCSignalingState state) {
          print('pc1: onsignalingstatechange => ${state.toString()}');
        };
        pc2.onsignalingstatechange = (RTCSignalingState state) {
          print('pc2: onsignalingstatechange => ${state.toString()}');
        };

        pc1.onicegatheringstatechange = (RTCIceGatheringState state) {
          print('pc1: onicegatheringstatechange => ${state.toString()}');
        };
        pc2.onicegatheringstatechange = (RTCIceGatheringState state) {
          print('pc2: onicegatheringstatechange => ${state.toString()}');
        };
      }),
  () => test('RTCPeerConnection.createOffer()', () async {
        offer = await pc1.createOffer(
            options: RTCOfferOptions(
                offerToReceiveAudio: true, offerToReceiveVideo: true));
        await pc1.setLocalDescription(offer);
        expect(pc1.signalingState,
            RTCSignalingState.RTCSignalingStateHaveLocalOffer);

        await pc2.setRemoteDescription(offer);
        expect(pc2.signalingState,
            RTCSignalingState.RTCSignalingStateHaveRemoteOffer);
      }),
  () => test('RTCPeerConnection.createAnswer()', () async {
        answer = await pc2.createAnswer(options: RTCAnswerOptions());
        await pc2.setLocalDescription(answer);
        expect(pc2.signalingState, RTCSignalingState.RTCSignalingStateStable);

        await pc1.setRemoteDescription(answer);
        expect(pc1.signalingState, RTCSignalingState.RTCSignalingStateStable);
      }),
  () => test('RTCPeerConnection.localDescription()', () async {
        expect(pc1.localDescription.sdp.isNotEmpty, true);
        expect(pc2.localDescription.sdp.isNotEmpty, true);
      }),
  () => test('RTCPeerConnection.remoteDescription()', () async {
        expect(pc1.remoteDescription.sdp.isNotEmpty, true);
        expect(pc2.remoteDescription.sdp.isNotEmpty, true);
      }),
  () => test('RTCPeerConnection.close()', () async {
        await Future.delayed(Duration(seconds: 5), () {
          pc1.close();
          expect(pc1.signalingState, RTCSignalingState.RTCSignalingStateClosed);
          pc2.close();
          expect(pc2.signalingState, RTCSignalingState.RTCSignalingStateClosed);
        });
      })
];
