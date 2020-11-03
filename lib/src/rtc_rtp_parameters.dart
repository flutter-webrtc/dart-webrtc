@JS()
library dart_webrtc;

import 'package:js/js.dart';

import 'rtc_rtcp_parameters.dart';

@JS()
@anonymous
class RTCRTPCodec {
  external factory RTCRTPCodec(
      {int payloadType,
      String name,
      String kind,
      int clockRate,
      int numChannels,
      Map<dynamic, dynamic> parameters});
  // Payload type used to identify this codec in RTP packets.
  external int get payloadType;

  /// Name used to identify the codec. Equivalent to MIME subtype.
  external String get name;

  /// The media type of this codec. Equivalent to MIME top-level type.
  external String get kind;

  /// Clock rate in Hertz.
  external int get clockRate;

  /// The number of audio channels used. Set to null for video codecs.
  external int get numChannels;

  /// The "format specific parameters" field from the "a=fmtp" line in the SDP
  external Map<dynamic, dynamic> get parameters;
}

@JS()
@anonymous
class RTCRtpEncoding {
  external factory RTCRtpEncoding(
      {String rid,
      bool active,
      int maxBitrateBps,
      int maxFramerate,
      int minBitrateBps,
      int numTemporalLayers,
      double scaleResolutionDownBy,
      int ssrc});

  /// If non-null, this represents the RID that identifies this encoding layer.
  /// RIDs are used to identify layers in simulcast.
  external String get rid;

  /// Set to true to cause this encoding to be sent, and false for it not to
  /// be sent.
  external bool get active;

  /// If non-null, this represents the Transport Independent Application
  /// Specific maximum bandwidth defined in RFC3890. If null, there is no
  /// maximum bitrate.
  external int get maxBitrateBps;

  /// The minimum bitrate in bps for video.
  external int get minBitrateBps;

  /// The max framerate in fps for video.
  external int get maxFramerate;

  /// The number of temporal layers for video.
  external int get numTemporalLayers;

  /// If non-null, scale the width and height down by this factor for video. If null,
  /// implementation default scaling factor will be used.
  external double get scaleResolutionDownBy;

  /// SSRC to be used by this encoding.
  /// Can't be changed between getParameters/setParameters.
  external int get ssrc;
}

@JS()
@anonymous
class RTCHeaderExtension {
  external factory RTCHeaderExtension({String uri, String id, bool encrypted});

  /// The URI of the RTP header extension, as defined in RFC5285.
  external String get uri;

  /// The value put in the RTP packet to identify the header extension.
  external int get id;

  /// Whether the header extension is encrypted or not.
  external bool get encrypted;
}

@JS()
@anonymous
class RTCRtpEncodingParameters {
  external factory RTCRtpEncodingParameters(
      {List<RTCRtpEncoding> encodings,
      List<RTCHeaderExtension> headerExtensions,
      List<RTCRTPCodec> codecs,
      RTCRTCPParameters rtcp});

  external RTCRTCPParameters get rtcp;

  external List<RTCHeaderExtension> get headerExtensions;

  external List<RTCRtpEncoding> get encodings;

  external List<RTCRTPCodec> get codecs;
}
