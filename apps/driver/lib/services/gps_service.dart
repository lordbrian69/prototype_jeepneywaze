import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';
import 'mqtt_service.dart';

final gpsServiceProvider = Provider<GpsService>((ref) {
  return GpsService(ref.read(mqttServiceProvider));
});

class GpsService {
  final MQTTService _mqtt;
  StreamSubscription<Position>? _sub;
  String? _userToken;

  GpsService(this._mqtt);

  Future<bool> requestPermission() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> start(String userToken) async {
    _userToken = userToken;
    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: DriverConstants.gpsDistanceFilterMeters,
      ),
    ).listen(_emit);
  }

  void _emit(Position pos) {
    if (_userToken == null) return;
    _mqtt.publishPing({
      'user_token': _userToken,
      'lat': pos.latitude,
      'lng': pos.longitude,
      'accuracy_m': pos.accuracy,
      'speed_kmh': (pos.speed * 3.6).clamp(0, 150),
      'heading_deg': pos.heading,
      'altitude_m': pos.altitude,
      'is_moving': pos.speed > 0.5,
      'ts': DateTime.now().toUtc().toIso8601String(),
      'source': 'driver',
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
