import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../core/util/signaling.dart';

part 'view_screen_state.dart';

class ViewScreenCubit extends Cubit<ViewScreenState> {
  ViewScreenCubit() : super(ViewScreenInitial());

  final controller = TextEditingController();
  final renderer = RTCVideoRenderer();
  final signaling = Signaling();

  RTCPeerConnection? pc;
  bool offerHandled = false;

  Future<void> initializeRenderer() async {
    await renderer.initialize();
    emit(ViewScreenInitial());
  }

  Future<void> join() async {
    final code = controller.text.trim();
    if (code.isEmpty) return;
    emit(ViewScreenConnecting());

    pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    pc!.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
    );

    pc!.onConnectionState =
        (state) => print('Viewer: PeerConnection state -> $state');
    pc!.onIceConnectionState =
        (state) => print('Viewer: ICE connection state -> $state');
    pc!.onIceGatheringState =
        (state) => print('Viewer: ICE gathering state -> $state');
    pc!.onIceCandidate = (candidate) async {
      if (candidate != null) {
        print('Viewer: Sending ICE candidate -> ${candidate.candidate}');
        await signaling.sendCandidate(code, 'viewer', candidate);
      }
    };

    pc!.onTrack = (event) {
      print('Viewer: onTrack triggered for ${event.track.kind}');
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        renderer.srcObject = event.streams.first;
        emit(ViewScreenConnected());

        print('Viewer: remote stream attached to renderer');
      }
      for (var track in event.streams.first.getAudioTracks()) {
        print('Viewer audio track enabled: ${track.enabled}');
      }
    };

    signaling.listen(code).listen((doc) async {
      final rawData = doc.data();
      if (rawData == null) return;

      final data = rawData as Map<String, dynamic>?;
      if (data == null) return;

      if (!offerHandled && data.containsKey('offer') && data['offer'] != null) {
        offerHandled = true;
        print('Viewer: Offer received -> ${data['offer']}');

        final offerData = data['offer'] as Map<String, dynamic>;
        final offer = RTCSessionDescription(
          offerData['sdp'] as String,
          offerData['type'] as String,
        );

        await pc!.setRemoteDescription(offer);
        final answer = await pc!.createAnswer();
        await pc!.setLocalDescription(answer);
        print('Viewer: Answer created and set locally');

        await signaling.sendAnswer(code, answer);
        print('Viewer: Answer sent via signaling');
      }
    });

    signaling.candidates(code, 'host').listen((snapshot) {
      for (var doc in snapshot.docs) {
        final rawData = doc.data();
        if (rawData == null) continue;

        final c = rawData as Map<String, dynamic>?;
        if (c == null) continue;

        final candidateStr = c['candidate'] as String?;
        final sdpMid = c['sdpMid'] as String?;
        final sdpMLineIndex = c['sdpMLineIndex'] as int?;

        if (candidateStr != null && sdpMid != null && sdpMLineIndex != null) {
          final candidate =
              RTCIceCandidate(candidateStr, sdpMid, sdpMLineIndex);
          pc?.addCandidate(candidate);
          print('Viewer: Added ICE candidate from host -> $candidateStr');
        }
      }
    });
  }
}
