import 'dart:async';
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:js_util' as jsutil;

import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';
import 'utils.dart';

extension MediaConstraintsWeb on MediaStreamConstraints {
  web.MediaStreamConstraints toWeb() {
    return web.MediaStreamConstraints(
      audio: audio,
      video: video,
    );
  }
}

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
      }
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }

    throw 'getUserMedia is missing';
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
        throw UnimplementedError('getDisplayMedia is missing');
      }
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    final devices = await getSources();

    return devices.map((e) {
      var input = e as web.MediaDeviceInfo;
      return MediaDeviceInfo(
        deviceId: input.deviceId,
        groupId: input.groupId,
        kind: input.kind,
        label: input.label,
      );
    }).toList();
  }

  @override
  Future<List<dynamic>> getSources() async {
    var sources = await jsutil.promiseToFuture<List<dynamic>>(
        web.window.navigator.mediaDevices.enumerateDevices());
    return sources;
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    final mediaDevices = web.window.navigator.mediaDevices;

    var constraints = mediaDevices.getSupportedConstraints();

    return MediaTrackSupportedConstraints(
        aspectRatio: constraints.aspectRatio,
        autoGainControl: constraints.autoGainControl,
        channelCount: constraints.channelCount,
        deviceId: constraints.deviceId,
        echoCancellation: constraints.echoCancellation,
        facingMode: constraints.facingMode,
        frameRate: constraints.frameRate,
        groupId: constraints.groupId,
        height: constraints.height,
        latency: constraints.latency,
        noiseSuppression: constraints.noiseSuppression,
        resizeMode: constraints.resizeMode,
        sampleRate: constraints.sampleRate,
        sampleSize: constraints.sampleSize,
        width: constraints.width);
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

      return jsutil.getProperty(mediaDevices, 'ondevicechange');
    } catch (e) {
      throw 'Unable to get ondevicechange: ${e.toString()}';
    }
  }
}
