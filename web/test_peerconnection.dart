import 'dart:html';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:test/test.dart';

RTCPeerConnection pc1;
RTCPeerConnection pc2;

RTCSessionDescription offer;
RTCSessionDescription answer;

void addStateCallbacks(RTCPeerConnection pc, String title) {
  pc.onconnectionstatechange = (RTCPeerConnectionState state) {
    print('$title: onconnectionstatechange => ${state.toString()}');
  };
  pc.oniceconnectionstatechange = (RTCIceConnectionState state) {
    print('$title: oniceconnectionstatechange => ${state.toString()}');
  };
  pc.onicegatheringstatechange = (RTCIceGatheringState state) {
    print('$title: onicegatheringstatechange => ${state.toString()}');
  };
  pc.onsignalingstatechange = (RTCSignalingState state) {
    print('$title: onsignalingstatechange => ${state.toString()}');
  };
  pc.onicegatheringstatechange = (RTCIceGatheringState state) {
    print('$title: onicegatheringstatechange => ${state.toString()}');
  };

  pc.onaddstream = (MediaStreamEvent event) {
    print('$title: onaddstream => ${event.stream.id}');
  };

  pc.ontrack = (RTCTrackEvent event) async {
    print(
        '$title: ontrack => ${event.track.id}, \nkind =>  ${event.track.kind}\nstream.length => ${event.streams.length}');
    var params = event.receiver.getParameters();
    print('reducedSize => ${params.rtcp.reducedSize}');
    var stats =
        await promiseToFuture<RTCStatsReport>(event.receiver.getStats());
    print('getStats => ');
    stats.forEach((RTCStats report) {
      print(
          '   type => ${report.type}, id => ${report.id}, timestamp => ${report.timestamp}');
      print('        report => ${report.toString()}');
    });
  };
}

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

        addStateCallbacks(pc1, 'pc1');
        addStateCallbacks(pc2, 'pc2');

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
      }),
  () => test('RTCPeerConnection.addTransceiver()', () async {
        await pc1.addTransceiver(
            kind: 'audio', init: RTCRtpTransceiverInit(direction: 'sendonly'));
        await pc1.addTransceiver(
            kind: 'video', init: RTCRtpTransceiverInit(direction: 'sendonly'));

        await pc2.addTransceiver(
            kind: 'audio', init: RTCRtpTransceiverInit(direction: 'recvonly'));
        await pc2.addTransceiver(
            kind: 'video', init: RTCRtpTransceiverInit(direction: 'recvonly'));
      }),
  () => test('RTCPeerConnection.createOffer()', () async {
        offer = await pc1.createOffer();
        print('pc1 offer => ${offer.sdp}');
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
        print('pc2 answer => ${answer.sdp}');
        await pc1.setRemoteDescription(answer);
        expect(pc1.signalingState, RTCSignalingState.RTCSignalingStateStable);
      }),
  () => test('RTCPeerConnection.localDescription()', () async {
        expect(pc1.localDescription.type, 'offer');
        expect(pc1.localDescription.sdp.isNotEmpty, true);
        expect(pc2.localDescription.type, 'answer');
        expect(pc2.localDescription.sdp.isNotEmpty, true);
      }),
  () => test('RTCPeerConnection.remoteDescription()', () async {
        expect(pc1.remoteDescription.type, 'answer');
        expect(pc1.remoteDescription.sdp.isNotEmpty, true);
        expect(pc2.remoteDescription.type, 'offer');
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
