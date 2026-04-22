import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_sharing/features/view_screen/cubit/view_screen_cubit.dart';
import 'package:screen_sharing/routes/routes.dart';

import '../../../core/util/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //ForegroundService.startService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Share')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              child: const Text('Start Sharing'),
              onPressed: () async {
                await ForegroundService.startService();
                Navigator.pushNamed(context, Routes.hostScreen);
              },
            ),
            const SizedBox(height: 20),
            Text('Hello'),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(12),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              child: const Text('Join with Code'),
              onPressed: () {
                Navigator.pushNamed(context, Routes.viewScreen);
                //context.read<ViewScreenCubit>().initializeRenderer();
              },
            ),
          ],
        ),
      ),
    );
  }
}
