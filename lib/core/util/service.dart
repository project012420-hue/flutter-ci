import 'package:flutter/services.dart';

class ForegroundService {
  static const _channel = MethodChannel('foreground');

  static Future<void> startService() async {
    await _channel.invokeMethod('startForegroundService');
  }

  static Future<void> stopService() async {
    await _channel.invokeMethod('stopForegroundService');
  }
}
