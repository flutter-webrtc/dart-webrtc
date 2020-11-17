// GENERATED CODE - DO NOT MODIFY BY HAND

part of dart_webrtc;

// **************************************************************************
// JsWrappingGenerator
// **************************************************************************

@GeneratedFrom(_Navigator)
// @JS('Navigator')

class Navigator {
  Navigator(this.jsObject);
  final Object jsObject;
}

@GeneratedFrom(_Navigator)
extension Navigator$Ext on Navigator {
  Object get _mediaDevices => getProperty(jsObject, 'mediaDevices');

  set _mediaDevices(Object value) {
    setProperty(jsObject, 'mediaDevices', value);
  }

  MediaDevices get mediaDevices => MediaDevices(_mediaDevices);
}
