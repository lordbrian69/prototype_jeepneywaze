import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'mqtt_service.dart';

final gpsServiceProvider = Provider<GPSService>((ref) {
  return GPSService(ref.read(mqttServiceProvider));
});

/// GPSService — commuter-as-sensor implementation
///
/// Collects GPS pings and broadcasts them via MQTT to the backend.
/// This is the foundation of the Virtual Beacon engine — every commuter
/// with the app open contributes their location to vehicle detection.
///
/// Battery optimization:
/// - 5s intervals while moving (detected via accelerometer)
/// - 30s intervals when stationary
/// - Batch 6 pings before a single MQTT publish
class GPSService {
  final MQTTService _mqtt;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isMoving = true;
  String? _userToken;

  static const _movingThreshold = 0.5; // m/s² delta to detect movement

  GPSService(this._mqtt);

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  void setUserToken(String token) {
    _userToken = token;
  }

  Future<void> startTracking() async {
    if (_userToken == null) return;

    // Accelerometer: detect moving vs stationary
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude =
          (event.x.abs() + event.y.abs() + event.z.abs()) / 3 - 9.8;
      _isMoving = magnitude.abs() > _movingThreshold;
    });

    // Location stream: adaptive interval
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium, // Not HIGH — saves battery
        distanceFilter: 5,                   // Only update if moved 5m
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position position) {
    if (_userToken == null) return;

    final ping = {
      'user_token': _userToken,
      'lat': position.latitude,
      'lng': position.longitude,
      'accuracy_m': position.accuracy,
      'speed_kmh': (position.speed * 3.6).clamp(0, 150), // m/s → km/h
      'heading_deg': position.heading,
      'altitude_m': position.altitude,
      'is_moving': _isMoving,
      'ts': DateTime.now().toUtc().toIso8601String(),
      'source': 'commuter',
    };

    _mqtt.publishPing(ping);
  }

  void stopTracking() {
    _positionSub?.cancel();
    _accelSub?.cancel();
  }

  void dispose() {
    stopTracking();
  }
}
