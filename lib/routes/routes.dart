import 'package:flutter/cupertino.dart';
import 'package:screen_sharing/features/home_screen/view/home_screen.dart';
import 'package:screen_sharing/features/host_screen/view/host_screen.dart';
import 'package:screen_sharing/features/view_screen/view/view_screen.dart';

class Routes {
  static const String homeScreen = '/homeScreen';
  static const String hostScreen = '/hostScreen';
  static const String viewScreen = '/viewScreen';
  static Map<String, WidgetBuilder> get routes => {
        homeScreen: (BuildContext context) => const HomeScreen(),
        hostScreen: (BuildContext context) => const HostScreen(),
        viewScreen: (BuildContext context) => const ViewerScreen(),
      };
}
