@JS()
library dart_webrtc;

import 'dart:convert';

import 'package:js/js.dart';

class RTCStats {
  RTCStats({this.type, this.id, this.timestamp, this.values});
  factory RTCStats.fromMap(Map<String, dynamic> map) => RTCStats(
      id: map['id'],
      type: map['type'],
      timestamp: map['timestamp'],
      values: map);
  String type;

  String id;

  dynamic timestamp;

  List<String> names() => values.entries.map((e) => e.key).toList();

  Map<String, dynamic> values;
}

class RTCStatsReport {
  RTCStatsReport(this._jsStats) {
    _jsStats.forEach(allowInterop((dynamic value, String key, dynamic array) {
      _stats[key] = RTCStats.fromMap(statsToMap(value));
    }));
  }
  final RTCStatsReportJs _jsStats;
  Map<String, RTCStats> _stats = {};

  int get size => _jsStats.size;

  RTCStats operator [](String key) => _stats[key];

  List<String> keys() => _stats.entries.map((e) => e.key).toList();

  Map<String, RTCStats> get values => _stats;
}

@JS('RTCStatsReport')
abstract class RTCStatsReportJs {
  external int get size;
  external void forEach(
      void Function(dynamic stats, String key, dynamic _) func);
}

// Calls invoke JavaScript `JSON.stringify(obj)`.
@JS('JSON.stringify')
external String stringify(Object obj);
final JsonDecoder decoder = JsonDecoder();

Map<String, dynamic> statsToMap(dynamic stats) =>
    decoder.convert(stringify(stats));
