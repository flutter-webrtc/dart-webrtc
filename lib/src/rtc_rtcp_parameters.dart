@JS()
library dart_webrtc;

import 'package:js/js.dart';

@JS()
@anonymous
class RTCRTCPParameters {
  external factory RTCRTCPParameters({String cname, bool reducedSize});

  /// The Canonical Name used by RTCP
  external String get cname;

  /// Whether reduced size RTCP is configured or compound RTCP
  external bool get reducedSize;
}