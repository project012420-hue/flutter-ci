import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/util/signaling.dart';

part 'host_screen_state.dart';

class HostScreenCubit extends Cubit<HostScreenState> {
  HostScreenCubit() : super(HostScreenInitial());

  final renderer = RTCVideoRenderer();
  final signaling = Signaling();
  late RTCPeerConnection _pc;
  String code = '';
  static const channel = MethodChannel('foreground');
  MediaStream? screenStream;
  bool isPaused = false;

  bool _answerSet = false;

  Future<void> startForegroundService() async {
    try {
      await channel.invokeMethod('startForegroundService');
    } on PlatformException catch (e) {
      print("Failed to start foreground service: ${e.message}");
    }
    emit(HostScreenInitial());
  }

  Future<void> stopForegroundService() async {
    try {
      await channel.invokeMethod('stopForegroundService');
    } on PlatformException catch (e) {
      print("Failed to stop foreground service: ${e.message}");
    }
    emit(HostScreenInitial());
  }

  String generateCode() => (100000 + Random().nextInt(900000)).toString();
  Future<void> start() async {
    code = generateCode();
    await signaling.createSession(code);

    MediaStream? stream;

    try {
      stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'frameRate': 15,
          'width': {'max': 720},
          'height': {'max': 1280},
        },
        'audio': true
      });
    } catch (_) {
      print('Full resolution failed, retrying with 720p 15fps');
      stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'frameRate': 15,
          'width': {'max': 480},
          'height': {'max': 720},
        },
        'audio': {
          'echoCancellation': false,
          'noiseSuppression': false,
          'autoGainControl': false,
        }
      });
    }
    final audio = stream.getAudioTracks().length;
    print('Host audio output $audio');
    if (stream == null) {
      print('Failed to get screen stream');
      return;
    }

    screenStream = stream;

    renderer.srcObject = stream;
    emit(HostScreenConnected());

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });

    for (var track in stream.getTracks()) {
      await _pc.addTrack(track, stream);
    }

    _pc.onIceCandidate = (c) {
      if (c != null) signaling.sendCandidate(code, 'host', c);
    };

    _pc.onConnectionState = (state) => print('Host PC state: $state');
    _pc.onIceConnectionState = (state) => print('Host ICE state: $state');

    final offer = await _pc.createOffer();
    await _pc.setLocalDescription(offer);
    await signaling.sendOffer(code, offer);

    signaling.listen(code).listen((doc) async {
      final rawData = doc.data();
      if (rawData == null) return;

      final data = rawData as Map<String, dynamic>?;
      if (data == null) return;

      if (data.containsKey('answer') &&
          data['answer'] != null &&
          !_answerSet &&
          _pc.signalingState ==
              RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        final answerData = data['answer'] as Map<String, dynamic>;
        final answer = RTCSessionDescription(
          answerData['sdp'] as String,
          answerData['type'] as String,
        );

        await _pc.setRemoteDescription(answer);
        _answerSet = true;
        print('Host: Remote answer applied');
      }
    });

    signaling.candidates(code, 'viewer').listen((snapshot) {
      for (var d in snapshot.docs) {
        final c = d.data() as Map<String, dynamic>?;
        if (c == null) continue;

        final candidateStr = c['candidate'] as String?;
        final sdpMid = c['sdpMid'] as String?;
        final sdpMLineIndex = c['sdpMLineIndex'] as int?;
        if (candidateStr != null && sdpMid != null && sdpMLineIndex != null) {
          _pc.addCandidate(
              RTCIceCandidate(candidateStr, sdpMid, sdpMLineIndex));
        }
      }
    });

    emit(HostScreenInitial());
  }

  void pauseScreenShare() {
    if (screenStream == null) return;

    for (final track in screenStream!.getTracks()) {
      track.enabled = false;
    }

    isPaused = true;
    emit(HostScreenInitial());
  }

  void resumeScreenShare() {
    if (screenStream == null) return;

    for (final track in screenStream!.getTracks()) {
      track.enabled = true;
    }

    isPaused = false;
    emit(HostScreenInitial());
  }
}
