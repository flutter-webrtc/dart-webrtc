import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

class MediaStreamTrackWeb extends MediaStreamTrack {
  MediaStreamTrackWeb(this.jsTrack) {
    jsTrack.addEventListener(
        'ended',
        (web.Event event) {
          onEnded?.call();
        }.toJS);
    jsTrack.addEventListener(
        'mute',
        (web.Event event) {
          onMute?.call();
        }.toJS);
    jsTrack.addEventListener(
        'unmute',
        (web.Event event) {
          onUnMute?.call();
        }.toJS);
  }

  final web.MediaStreamTrack jsTrack;

  @override
  String? get id => jsTrack.id;

  @override
  String? get kind => jsTrack.kind;

  @override
  String? get label => jsTrack.label;

  @override
  bool get enabled => jsTrack.enabled;

  @override
  bool? get muted => jsTrack.muted;

  @override
  set enabled(bool? b) {
    jsTrack.enabled = b ?? false;
  }

  @override
  Map<String, dynamic> getConstraints() {
    final c = jsTrack.getConstraints();
    final jso = (c as JSObject).dartify();
    return (jso as Map).cast<String, dynamic>();
  }

  @override
  Future<void> applyConstraints([Map<String, dynamic>? constraints]) async {
    // TODO(wermathurin): Wait for: https://github.com/dart-lang/sdk/commit/1a861435579a37c297f3be0cf69735d5b492bc6c
    // to be merged to use jsTrack.applyConstraints() directly
    final arg = (constraints ?? {}).jsify();

    await jsTrack.applyConstraints(arg as web.MediaTrackConstraints).toDart;
  }

  // TODO(wermathurin): https://github.com/dart-lang/sdk/issues/44319
  // @override
  // MediaTrackCapabilities getCapabilities() {
  //   var _converted = jsTrack.getCapabilities();
  //   print(_converted['aspectRatio'].runtimeType);
  //   return null;
  // }

  @override
  Map<String, dynamic> getSettings() {
    var settings = jsTrack.getSettings();
    var _converted = <String, dynamic>{};
    if (kind == 'audio') {
      _converted['sampleRate'] = settings.sampleRate;
      _converted['sampleSize'] = settings.sampleSize;
      _converted['echoCancellation'] = settings.echoCancellation;
      _converted['autoGainControl'] = settings.autoGainControl;
      _converted['noiseSuppression'] = settings.noiseSuppression;
      _converted['latency'] = settings.latency;
      _converted['channelCount'] = settings.channelCount;
    } else {
      _converted['width'] = settings.width;
      _converted['height'] = settings.height;
      _converted['aspectRatio'] = settings.aspectRatio;
      _converted['frameRate'] = settings.frameRate;
      if (isMobile) {
        _converted['facingMode'] = settings.facingMode;
      }
      _converted['resizeMode'] = settings.resizeMode;
    }
    _converted['deviceId'] = settings.deviceId;
    _converted['groupId'] = settings.groupId;
    return _converted;
  }

  @override
  Future<ByteBuffer> captureFrame() async {
    final imageCapture = ImageCapture(jsTrack);
    final bitmap = await imageCapture.grabFrame().toDart as web.ImageBitmap;
    final canvas = web.HTMLCanvasElement();
    canvas.width = bitmap.width;
    canvas.height = bitmap.height;
    final renderer =
        canvas.getContext('bitmaprenderer') as web.ImageBitmapRenderingContext;
    renderer.transferFromImageBitmap(bitmap);

    final blobCompleter = Completer<web.Blob>();
    final void Function(web.Blob blob) toBlob = (web.Blob blob) {
      blobCompleter.complete(blob);
    };
    canvas.toBlob(toBlob.toJS);

    final blod = await blobCompleter.future;

    var array = await blod.arrayBuffer().toDart;
    bitmap.close();
    return array.toDart;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> stop() async {
    jsTrack.stop();
  }

  @override
  Future<bool> hasTorch() {
    return Future.value(false);
  }

  @override
  Future<void> setTorch(bool torch) {
    throw UnimplementedError('The web implementation does not support torch');
  }

  @override
  Future<MediaStreamTrack> clone() async {
    return MediaStreamTrackWeb(jsTrack.clone());
  }
}

extension type ImageCapture._(JSObject _) implements JSObject {
  external factory ImageCapture(web.MediaStreamTrack track);

  external JSPromise grabFrame();
}
