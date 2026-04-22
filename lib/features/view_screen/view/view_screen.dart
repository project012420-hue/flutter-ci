import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:screen_sharing/features/view_screen/cubit/view_screen_cubit.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({super.key});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late ViewScreenCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<ViewScreenCubit>();
    cubit.initializeRenderer();
  }

  @override
  void dispose() {
    super.dispose();
    // cubit.pc?.close();
    // cubit.renderer.dispose();
    cubit.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Screen Share')),
      body: BlocBuilder<ViewScreenCubit, ViewScreenState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: cubit.controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange),
                    ),
                    labelText: 'Enter code',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: cubit.join,
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: const Text('Join'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RTCVideoView(
                  cubit.renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                ),
              ),
              if (state is ViewScreenConnecting)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(13),
                    color: Colors.black54,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'Connecting…',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
