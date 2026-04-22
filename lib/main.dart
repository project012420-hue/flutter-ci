import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_sharing/cubit_providers/cubit_providers.dart';
import 'package:screen_sharing/routes/routes.dart';

import 'features/home_screen/view/home_screen.dart';
const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: cubitLists,
      child: MaterialApp(
        routes: Routes.routes,
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
