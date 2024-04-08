import 'dart:js_interop';

import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

extension RTCConfigurationWeb on RTCConfiguration {
  web.RTCConfiguration toWebConfig() {
    var config = web.RTCConfiguration();

    if (iceServers != null) {
      config.iceServers = iceServers!
          .map((e) => web.RTCIceServer(
                urls: e.urls?.toList().jsify() ?? [].jsify()!,
                username: e.username ?? '',
                credential: e.credential ?? '',
              ))
          .toList()
          .toJS;
    }

    if (rtcpMuxPolicy != null) {
      config.rtcpMuxPolicy = rtcpMuxPolicy!;
    }

    if (bundlePolicy != null) {
      config.bundlePolicy = bundlePolicy!;
    }

    if (iceCandidatePoolSize != null) {
      config.iceCandidatePoolSize = iceCandidatePoolSize!;
    }

    if (iceTransportPolicy != null) {
      config.iceTransportPolicy = iceTransportPolicy!;
    }

    return config;
  }
}
