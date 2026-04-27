import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../data/models/beacon.dart';
import '../../services/api_client.dart';
import '../../services/gps_service.dart';
import '../../services/mqtt_service.dart';
import '../../services/socket_service.dart';
import '../eta/eta_card.dart';
import '../offline/offline_banner.dart';
import 'beacon_overlay.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  final Map<String, VirtualBeacon> _beacons = {};
  String? _selectedBeaconId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    _initSocket();
    await _startGpsBroadcast();
    await _loadNearbyBeacons();
  }

  void _initSocket() {
    final socket = ref.read(socketServiceProvider);
    socket.connect();
    socket.subscribeToRoute(AppConstants.pilotRouteManila);

    socket.onBeaconUpdate.listen((beacon) {
      if (mounted) {
        setState(() => _beacons[beacon.id] = beacon);
      }
    });

    socket.onBeaconRemoved.listen((beaconId) {
      if (mounted) {
        setState(() => _beacons.remove(beaconId));
      }
    });
  }

  Future<void> _startGpsBroadcast() async {
    final api = ref.read(apiClientProvider);
    final token = api.userToken;
    if (token == null) return; // Not authenticated yet

    final mqtt = ref.read(mqttServiceProvider);
    await mqtt.connect(token);

    final gps = ref.read(gpsServiceProvider);
    final ok = await gps.requestPermission();
    if (!ok) return;

    gps.setUserToken(token);
    await gps.startTracking();
  }

  Future<void> _loadNearbyBeacons() async {
    try {
      final api = ref.read(apiClientProvider);
      final beacons = await api.nearbyBeacons(
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
      );
      if (mounted) {
        setState(() {
          for (final b in beacons) {
            _beacons[b.id] = b;
          }
        });
      }
    } catch (_) {
      // Soft-fail — map will populate via Socket.io as beacons form.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── MapLibre / OSM map ─────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                AppConstants.defaultLat,
                AppConstants.defaultLng,
              ),
              initialZoom: AppConstants.defaultZoom,
              onTap: (_, __) => setState(() => _selectedBeaconId = null),
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jeepneywaze.commuter',
                fallbackUrl: 'assets/map/offline_tiles/{z}/{x}/{y}.png',
              ),
              // Virtual Beacon markers
              BeaconOverlay(
                beacons: _beacons.values.toList(),
                selectedId: _selectedBeaconId,
                onBeaconTap: (beacon) {
                  setState(() => _selectedBeaconId = beacon.id);
                },
              ),
            ],
          ),

          // ── Offline indicator ──────────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineBanner(),
          ),

          // ── ETA Card (shows when beacon selected) ──────
          if (_selectedBeaconId != null && _beacons[_selectedBeaconId] != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: ETACard(
                beacon: _beacons[_selectedBeaconId]!,
                onCrowdingTap: () =>
                    context.push('/crowding/$_selectedBeaconId'),
                onDismiss: () =>
                    setState(() => _selectedBeaconId = null),
              ),
            ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'search',
            onPressed: () => context.push('/routes'),
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'locate',
            onPressed: _centerOnUser,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _centerOnUser() {
    // Uses geolocator — handled by GPSService
  }

  @override
  void dispose() {
    ref.read(socketServiceProvider).disconnect();
    super.dispose();
  }
}
