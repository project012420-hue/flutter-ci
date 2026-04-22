import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:screen_sharing/core/util/signaling.dart';
import 'package:screen_sharing/features/host_screen/cubit/host_screen_cubit.dart';

import '../../../core/util/service.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  late HostScreenCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<HostScreenCubit>();
    cubit.renderer.initialize();
    cubit.startForegroundService();
    cubit.start();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sharing')),
      body: BlocBuilder<HostScreenCubit, HostScreenState>(
        builder: (context, state) {
          return Column(
            children: [
              Text('Code: ${cubit.code}', style: const TextStyle(fontSize: 24)),
              Expanded(child: RTCVideoView(cubit.renderer)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(100, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      ForegroundService.stopService();
                      Signaling().deleteSession(cubit.code);
                      Navigator.pop(context);
                    },
                    child: Text('stop'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(150, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                        backgroundColor:
                            cubit.isPaused ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white),
                    onPressed: () => cubit.isPaused
                        ? cubit.resumeScreenShare()
                        : cubit.pauseScreenShare(),
                    child: Text(cubit.isPaused ? 'Resume' : 'Pause'),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
            ],
          );
        },
      ),
    );
  }
}
