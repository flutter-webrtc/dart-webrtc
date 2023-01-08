import 'package:js/js.dart';

import 'rtc_transform_stream.dart';

@JS()
@anonymous
class Dog {
  external factory Dog({String name, int age});
  external String get name;
  external int get age;
}

@JS()
abstract class TransformMessage {
  external String get msgType;
  external String get kind;
}

@anonymous
@JS()
class EnableTransformMessage {
  external factory EnableTransformMessage({
    ReadableStream readable,
    WritableStream writable,
    String msgType,
    String kind,
    String participantId,
    String trackId,
    String codec,
  });
  external ReadableStream get readable;
  external WritableStream get writable;
  external String get msgType; // 'encode' or 'decode'
  external String get participantId;
  external String get trackId;
  external String get kind;
  external String get codec;
}

@anonymous
@JS()
class RemoveTransformMessage {
  external factory RemoveTransformMessage(
      {String msgType, String participantId, String trackId});
  external String get msgType; // 'removeTransform'
  external String get participantId;
  external String get trackId;
}
