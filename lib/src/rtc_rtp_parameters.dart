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
      {String transactionId,
      List<RTCRtpEncoding> encodings,
      List<RTCHeaderExtension> headerExtensions,
      List<RTCRTPCodec> codecs,
      RTCRTCPParameters rtcp});

  external RTCRTCPParameters get rtcp;

  external List<RTCHeaderExtension> get headerExtensions;

  external set encodings(List<RTCRtpEncoding> encodings);

  external List<RTCRtpEncoding> get encodings;

  external List<RTCRTPCodec> get codecs;

  external String get transactionId;
}

Map<String, dynamic> rtpEncodingParametersToMap(
    RTCRtpEncodingParameters parameters) {
  return {
    'transactionId': parameters.transactionId,
    'rtcp': rtcpParametersToMap(parameters.rtcp),
    'headerExtensions': parameters.headerExtensions
        .map((e) => headerExtensionToMap(e))
        .toList(),
    'encodings': parameters.encodings.map((e) => rtpEncodingToMap(e)).toList(),
    'codecs': parameters.codecs.map((e) => rtcCodecToMap(e)).toList(),
  };
}

RTCRtpEncodingParameters rtpEncodingParametersFromMap(
    Map<String, dynamic> map) {
  return RTCRtpEncodingParameters(
      transactionId: map['transactionId'],
      rtcp: map['rtcp'] != null
          ? rtcpParametersFromMap(map['rtcp'])
          : RTCRTCPParameters(),
      codecs: map['codecs'] != null
          ? (map['codecs'] as List).map((e) => rtcCodecFromMap(e)).toList()
          : [],
      encodings: map['codecs'] != null
          ? (map['encodings'] as List)
              .map((e) => rtpEncodingFromMap(e))
              .toList()
          : [],
      headerExtensions: map['headerExtensions'] != null
          ? (map['headerExtensions'] as List)
              .map((e) => headerExtensionFromMap(e))
              .toList()
          : []);
}

Map<String, dynamic> rtpEncodingToMap(RTCRtpEncoding encoding) {
  return {
    'rid': encoding.rid,
    'active': encoding.active,
    'maxBitrateBps': encoding.maxBitrateBps,
    'minBitrateBps': encoding.minBitrateBps,
    'maxFramerate': encoding.maxFramerate,
    'numTemporalLayers': encoding.numTemporalLayers,
    'scaleResolutionDownBy': encoding.scaleResolutionDownBy,
    'ssrc': encoding.ssrc
  };
}

RTCRtpEncoding rtpEncodingFromMap(Map<String, dynamic> map) {
  return RTCRtpEncoding(
      rid: map['rid'],
      active: map['active'] ?? true,
      maxBitrateBps: map['maxBitrateBps'],
      minBitrateBps: map['minBitrateBps'],
      numTemporalLayers: map['numTemporalLayers'],
      scaleResolutionDownBy: map['scaleResolutionDownBy'],
      ssrc: map['ssrc']);
}

Map<String, dynamic> rtcCodecToMap(RTCRTPCodec codec) {
  return {
    'payloadType': codec.payloadType,
    'name': codec.name,
    'kind': codec.kind,
    'clockRate': codec.clockRate,
    'numChannels': codec.numChannels,
    'parameters': codec.parameters
  };
}

RTCRTPCodec rtcCodecFromMap(Map<String, dynamic> map) {
  return RTCRTPCodec(
      payloadType: map['payloadType'],
      name: map['name'],
      kind: map['kind'],
      clockRate: map['clockRate'],
      numChannels: map['numChannels'],
      parameters: map['parameters']);
}

Map<String, dynamic> headerExtensionToMap(RTCHeaderExtension headerExtension) {
  return {
    'uri': headerExtension.uri,
    'id': headerExtension.id,
    'encrypted': headerExtension.encrypted
  };
}

RTCHeaderExtension headerExtensionFromMap(Map<String, dynamic> map) {
  return RTCHeaderExtension(
      encrypted: map['encrypted'], id: map['id'], uri: map['uri']);
}
