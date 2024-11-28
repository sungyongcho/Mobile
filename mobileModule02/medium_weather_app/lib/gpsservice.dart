import 'package:flutter/services.dart';

class GPSService {
  static const MethodChannel _channel = MethodChannel('com.example.app/gps');

  static Future<Map<String, double>> getCurrentLocation() async {
    final Map<String, double> location =
        Map<String, double>.from(await _channel.invokeMethod('getLocation'));
    return location;
  }
}
