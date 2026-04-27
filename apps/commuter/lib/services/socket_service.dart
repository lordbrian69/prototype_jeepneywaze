import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants.dart';
import '../data/models/beacon.dart';

final socketServiceProvider = Provider((ref) => SocketService());

class SocketService {
  io.Socket? _socket;
  final _beaconController = StreamController<VirtualBeacon>.broadcast();
  final _beaconRemovedController = StreamController<String>.broadcast();

  Stream<VirtualBeacon> get onBeaconUpdate => _beaconController.stream;
  Stream<String> get onBeaconRemoved => _beaconRemovedController.stream;

  void connect() {
    _socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.on('connect', (_) {
      print('Socket.io connected');
    });

    _socket!.on('beacon:update', (data) {
      try {
        final beacon = VirtualBeacon.fromJson(Map<String, dynamic>.from(data));
        _beaconController.add(beacon);
      } catch (e) {
        print('Beacon parse error: $e');
      }
    });

    _socket!.on('beacon:removed', (data) {
      final beaconId = data['beacon_id'] as String?;
      if (beaconId != null) _beaconRemovedController.add(beaconId);
    });
  }

  void subscribeToRoute(String routeId) {
    _socket?.emit('subscribe:route', routeId);
  }

  void unsubscribeFromRoute(String routeId) {
    _socket?.emit('unsubscribe:route', routeId);
  }

  void subscribeToStop(String stopId) {
    _socket?.emit('subscribe:stop', stopId);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _beaconController.close();
    _beaconRemovedController.close();
  }
}
