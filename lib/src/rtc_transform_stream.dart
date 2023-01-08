import 'dart:typed_data';

import 'package:js/js.dart';

@JS('WritableStream')
abstract class WritableStream {
  external void abort();
  external void close();
  external bool locked();
  external WritableStream clone();
}

@JS('ReadableStream')
abstract class ReadableStream {
  external void cancel();
  external bool locked();
  external ReadableStream pipeThrough(dynamic transformStream);
  external void pipeTo(WritableStream writableStream);
  external ReadableStream clone();
}

@JS('TransformStream')
class TransformStream {
  external TransformStream(dynamic);
  external ReadableStream get readable;
  external WritableStream get writable;
}

@anonymous
@JS()
abstract class TransformStreamDefaultController {
  external void enqueue(dynamic chunk);
  external void error(dynamic error);
  external void terminate();
}

@anonymous
@JS()
class EncodedStreams {
  external ReadableStream get readable;
  external WritableStream get writable;
}

@JS()
class RTCEncodedFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external RTCEncodedFrameMetadata getMetadata();
}

@JS()
class RTCEncodedAudioFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external int? get size;
  external RTCEncodedAudioFrameMetadata getMetadata();
}

@JS()
class RTCEncodedVideoFrame {
  external int get timestamp;
  external ByteBuffer get data;
  external set data(ByteBuffer data);
  external String get type;
  external RTCEncodedVideoFrameMetadata getMetadata();
}

@JS()
class RTCEncodedFrameMetadata {
  external int get payloadType;
  external int get synchronizationSource;
}

@JS()
class RTCEncodedAudioFrameMetadata {
  external int get payloadType;
  external int get synchronizationSource;
}

@JS()
class RTCEncodedVideoFrameMetadata {
  external int get frameId;
  external int get width;
  external int get height;
  external int get payloadType;
  external int get synchronizationSource;
}
