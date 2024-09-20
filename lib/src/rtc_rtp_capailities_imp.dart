import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dart_webrtc/src/rtc_data_channel_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
import 'package:web/web.dart' as web;

class RTCRtpCapabilitiesWeb {
  static RTCRtpCapabilities fromJsObject(web.RTCRtpCapabilities object) {
    return RTCRtpCapabilities.fromMap({
      'codecs': object.codecs.toDart.map((e) => e.dartify()),
      'headerExtensions':
          object.headerExtensions.toDart.map((e) => e.dartify()),
      'fecMechanisms': object.getProperty('fecMechanisms'.toJS).dartify() ?? []
    });
  }
}
