import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_util' as jsutil;
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';
import 'utils.dart';

class MediaDevicesWeb extends MediaDevices {
  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      if (!isMobile) {
        if (mediaConstraints['video'] is Map &&
            mediaConstraints['video']['facingMode'] != null) {
          mediaConstraints['video'].remove('facingMode');
        }
      }

      mediaConstraints.putIfAbsent('video', () => false);
      mediaConstraints.putIfAbsent('audio', () => false);

      final mediaDevices = web.window.navigator.mediaDevices;

      if (jsutil.hasProperty(mediaDevices, 'getUserMedia')) {
        var args = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<web.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getUserMedia', [args]));

        return MediaStreamWeb(jsStream, 'local');
      } else {
        final streamCompleter = Completer<web.MediaStream>();

        web.window.navigator.getUserMedia(
            web.MediaStreamConstraints(
              audio: mediaConstraints['audio'],
              video: mediaConstraints['video'],
            ),
            (web.MediaStream stream) {}.toJS,
            (JSAny err) {
              streamCompleter.completeError(err);
            }.toJS);

        final jsStream = await streamCompleter.future;
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;

      if (jsutil.hasProperty(mediaDevices, 'getDisplayMedia')) {
        final arg = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<web.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getDisplayMedia', [arg]));
        return MediaStreamWeb(jsStream, 'local');
      } else {
        final streamCompleter = Completer<web.MediaStream>();

        web.window.navigator.getUserMedia(
            web.MediaStreamConstraints(
                video: jsutil.jsify({'mediaSource': 'screen'}),
                audio: mediaConstraints['audio'] ?? false),
            (web.MediaStream stream) {
              streamCompleter.complete(stream);
            }.toJS,
            (JSAny err) {
              streamCompleter.completeError(err);
            }.toJS);
        final jsStream = await streamCompleter.future;
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    final devices = await getSources();

    return devices.map((e) {
      var input = e;
      return MediaDeviceInfo(
        deviceId: input.deviceId,
        groupId: input.groupId,
        kind: input.kind,
        label: input.label,
      );
    }).toList();
  }

  @override
  Future<List<web.MediaDeviceInfo>> getSources() async {
    final devices =
        await web.window.navigator.mediaDevices.enumerateDevices().toDart;
    return devices.toDart;
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    final mediaDevices = web.window.navigator.mediaDevices;

    var _mapConstraints = mediaDevices.getSupportedConstraints();

    return MediaTrackSupportedConstraints(
        aspectRatio: _mapConstraints.aspectRatio,
        autoGainControl: _mapConstraints.autoGainControl,
        brightness: _mapConstraints.brightness,
        channelCount: _mapConstraints.channelCount,
        colorTemperature: _mapConstraints.colorTemperature,
        contrast: _mapConstraints.contrast,
        deviceId: _mapConstraints.deviceId,
        echoCancellation: _mapConstraints.echoCancellation,
        exposureCompensation: _mapConstraints.exposureCompensation,
        exposureMode: _mapConstraints.exposureMode,
        exposureTime: _mapConstraints.exposureTime,
        facingMode: _mapConstraints.facingMode,
        focusDistance: _mapConstraints.focusDistance,
        focusMode: _mapConstraints.focusMode,
        frameRate: _mapConstraints.frameRate,
        groupId: _mapConstraints.groupId,
        height: _mapConstraints.height,
        iso: _mapConstraints.iso,
        latency: _mapConstraints.latency,
        noiseSuppression: _mapConstraints.noiseSuppression,
        pan: _mapConstraints.pan,
        pointsOfInterest: _mapConstraints.pointsOfInterest,
        resizeMode: _mapConstraints.resizeMode,
        saturation: _mapConstraints.saturation,
        sampleRate: _mapConstraints.sampleRate,
        sampleSize: _mapConstraints.sampleSize,
        sharpness: _mapConstraints.sharpness,
        tilt: _mapConstraints.tilt,
        torch: _mapConstraints.torch,
        whiteBalanceMode: _mapConstraints.whiteBalanceMode,
        width: _mapConstraints.width,
        zoom: _mapConstraints.zoom);
  }

  @override
  Future<MediaDeviceInfo> selectAudioOutput(
      [AudioOutputOptions? options]) async {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;

      if (jsutil.hasProperty(mediaDevices, 'selectAudioOutput')) {
        if (options != null) {
          final arg = jsutil.jsify(options);
          final deviceInfo = await jsutil.promiseToFuture<web.MediaDeviceInfo>(
              jsutil.callMethod(mediaDevices, 'selectAudioOutput', [arg]));
          return MediaDeviceInfo(
            kind: deviceInfo.kind,
            label: deviceInfo.label,
            deviceId: deviceInfo.deviceId,
            groupId: deviceInfo.groupId,
          );
        } else {
          final deviceInfo = await jsutil.promiseToFuture<web.MediaDeviceInfo>(
              jsutil.callMethod(mediaDevices, 'selectAudioOutput', []));
          return MediaDeviceInfo(
            kind: deviceInfo.kind,
            label: deviceInfo.label,
            deviceId: deviceInfo.deviceId,
            groupId: deviceInfo.groupId,
          );
        }
      } else {
        throw UnimplementedError('selectAudioOutput is missing');
      }
    } catch (e) {
      throw 'Unable to selectAudioOutput: ${e.toString()}, Please try to use MediaElement.setSinkId instead.';
    }
  }

  @override
  set ondevicechange(Function(dynamic event)? listener) {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;

      jsutil.setProperty(mediaDevices, 'ondevicechange',
          js.allowInterop((evt) => listener?.call(evt)));
    } catch (e) {
      throw 'Unable to set ondevicechange: ${e.toString()}';
    }
  }

  @override
  Function(dynamic event)? get ondevicechange {
    try {
      final mediaDevices = web.window.navigator.mediaDevices;

      jsutil.getProperty(mediaDevices, 'ondevicechange');
    } catch (e) {
      throw 'Unable to get ondevicechange: ${e.toString()}';
    }
    return null;
  }
}

extension _MediaTrackConstraints on web.MediaTrackSupportedConstraints {
  external bool get brightness;
  external bool get colorTemperature;
  external bool get contrast;
  external bool get exposureCompensation;
  external bool get exposureMode;
  external bool get exposureTime;
  external bool get focusDistance;
  external bool get focusMode;
  external bool get iso;
  external bool get pan;
  external bool get pointsOfInterest;
  external bool get saturation;
  external bool get sharpness;
  external bool get tilt;
  external bool get torch;
  external bool get whiteBalanceMode;
  external bool get zoom;
}
