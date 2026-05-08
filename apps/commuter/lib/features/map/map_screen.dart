import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/design_tokens.dart';
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
  String _activeFilter = 'Lahat';

  static const _filters = [
    'Lahat',
    'EDSA Cubao–Quiapo',
    'Colon–SM',
    '+ Dagdag',
  ];

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
    if (token == null) return;

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
      drawer: _buildDrawer(context),
      backgroundColor: JWColors.white,
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────
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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jeepneywaze.commuter',
              ),
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

          // ── Top: search bar + filter chips ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  JWSpacing.xl,
                  JWSpacing.xl,
                  JWSpacing.xl,
                  0,
                ),
                child: Column(
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: JWSpacing.md),
                    _buildFilterChips(),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating Action Buttons (right side) ───────
          Positioned(
            right: JWSpacing.xl,
            bottom: 200,
            child: Column(
              children: [
                _buildFab(
                  icon: Icons.layers_outlined,
                  onTap: () {},
                  tooltip: 'Layers',
                ),
                const SizedBox(height: JWSpacing.lg),
                _buildFab(
                  icon: Icons.my_location,
                  onTap: _centerOnUser,
                  tooltip: 'Locate me',
                ),
              ],
            ),
          ),

          // ── ETA Card (when beacon selected) ────────────
          if (_selectedBeaconId != null && _beacons[_selectedBeaconId] != null)
            Positioned(
              bottom: 240,
              left: JWSpacing.xl,
              right: JWSpacing.xl,
              child: ETACard(
                beacon: _beacons[_selectedBeaconId]!,
                onCrowdingTap: () =>
                    context.push('/crowding/$_selectedBeaconId'),
                onDismiss: () =>
                    setState(() => _selectedBeaconId = null),
              ),
            ),

          // ── Bottom sheet (collapsed peek) ──────────────
          _buildBottomSheet(),

          // ── Bottom navigation bar ──────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(context),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // SEARCH BAR
  // ──────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Builder(
      builder: (ctx) => Container(
        height: 52,
        decoration: BoxDecoration(
          color: JWColors.white,
          borderRadius: BorderRadius.circular(JWRadius.card),
          boxShadow: JWShadows.light,
        ),
        child: Row(
          children: [
            const SizedBox(width: JWSpacing.lg),
            const Icon(Icons.search, size: 18, color: JWColors.black),
            const SizedBox(width: JWSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/routes'),
                child: Text(
                  'Saan ka pupunta?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JWColors.mutedGray,
                      ),
                ),
              ),
            ),
            // Hamburger / avatar button
            GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: JWColors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu,
                  color: JWColors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // FILTER CHIPS
  // ──────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: JWSpacing.sm),
        itemBuilder: (_, i) {
          final label = _filters[i];
          final active = label == _activeFilter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = label),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JWSpacing.lg,
                vertical: JWSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: active ? JWColors.black : JWColors.chipGray,
                borderRadius: BorderRadius.circular(JWRadius.pill),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: active ? JWColors.white : JWColors.black,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // FAB
  // ──────────────────────────────────────────────────────
  Widget _buildFab({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: JWColors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 20, color: JWColors.black),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // BOTTOM SHEET (peek)
  // ──────────────────────────────────────────────────────
  Widget _buildBottomSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 72, // space for bottom nav
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          color: JWColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(JWRadius.sheet),
            topRight: Radius.circular(JWRadius.sheet),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: JWSpacing.md),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: JWColors.chipGray,
                borderRadius: BorderRadius.circular(JWRadius.pill),
              ),
            ),
            const SizedBox(height: JWSpacing.md),
            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: JWSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mga Malapit na Jeepney',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/routes'),
                    child: Text(
                      'Tingnan lahat',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: JWColors.bodyGray,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JWSpacing.md),
            Expanded(
              child: _beacons.isEmpty
                  ? _buildEmptyNearby()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: JWSpacing.xl,
                      ),
                      itemCount: _beacons.length.clamp(0, 6),
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: JWSpacing.md),
                      itemBuilder: (_, i) =>
                          _buildRouteCard(_beacons.values.elementAt(i)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNearby() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: JWSpacing.xl),
        child: Text(
          'Wala pang nakikitang jeepney sa malapit.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: JWColors.mutedGray,
              ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(VirtualBeacon b) {
    final crowdingColor = b.occupancyEst >= 8
        ? JWColors.siksikanRed
        : (b.occupancyEst >= 4 ? JWColors.warningOrange : JWColors.malwagGreen);
    final crowdingLabel = b.occupancyEst >= 8
        ? 'SIKSIKAN'
        : (b.occupancyEst >= 4 ? 'KATAMTAMAN' : 'MALWAG');

    return GestureDetector(
      onTap: () => setState(() => _selectedBeaconId = b.id),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: JWColors.white,
          borderRadius: BorderRadius.circular(JWRadius.card),
          boxShadow: JWShadows.light,
          border: Border(
            left: BorderSide(color: crowdingColor, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(JWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Route pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JWSpacing.md,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: JWColors.black,
                borderRadius: BorderRadius.circular(JWRadius.pill),
              ),
              child: Text(
                (b.routeId ?? 'JEEP').split('-').take(2).join('-').toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: JWColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            // ETA
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '~${(b.speedKmh / 5).round()}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 28),
                ),
                const SizedBox(width: 4),
                Text('min',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            // Crowding badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: JWSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: crowdingColor,
                borderRadius: BorderRadius.circular(JWRadius.pill),
              ),
              child: Text(
                crowdingLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: JWColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // BOTTOM NAV
  // ──────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: JWColors.white,
        border: Border(
          top: BorderSide(color: JWColors.chipGray, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        top: JWSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + JWSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.map, 'Map', active: true, onTap: () {}),
          _navItem(Icons.alt_route, 'Routes',
              onTap: () => context.push('/routes')),
          _navItem(Icons.notifications_none, 'Alerts', onTap: () {}),
          _navItem(Icons.person_outline, 'Profile', onTap: () {}),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {bool active = false, required VoidCallback onTap}) {
    final color = active ? JWColors.black : JWColors.mutedGray;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator pill
          Container(
            width: 20,
            height: 3,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: active ? JWColors.jeepneyYellow : Colors.transparent,
              borderRadius: BorderRadius.circular(JWRadius.pill),
            ),
          ),
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // DRAWER
  // ──────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: JWColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              JWSpacing.xl,
              48,
              JWSpacing.xl,
              JWSpacing.xl,
            ),
            color: JWColors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: JWColors.jeepneyYellow,
                    borderRadius: BorderRadius.circular(JWRadius.card),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: JWColors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(height: JWSpacing.lg),
                Text(
                  'JeepneyWaze',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: JWColors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alam mo na. Sumakay na.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: JWColors.mutedGray,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: JWSpacing.sm),
          _drawerTile(Icons.map, 'Mapa', () => Navigator.pop(context)),
          _drawerTile(Icons.search, 'Hanapin ang Ruta', () {
            Navigator.pop(context);
            context.push('/routes');
          }),
          _drawerTile(Icons.report, 'Mag-Report ng Crowd', () {
            Navigator.pop(context);
            context.push('/crowding/demo-beacon-id');
          }, subtitle: 'Siksikan / Malwag'),
          const Divider(),
          _drawerTile(Icons.login, 'Mag-sign In', () {
            Navigator.pop(context);
            context.push('/login');
          }),
          _drawerTile(Icons.info_outline, 'Tungkol sa', () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'JeepneyWaze',
              applicationVersion: '1.0.0 (dev)',
              applicationIcon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: JWColors.jeepneyYellow,
                  borderRadius: BorderRadius.circular(JWRadius.card),
                ),
                child: const Icon(Icons.directions_bus,
                    color: JWColors.black, size: 24),
              ),
              children: const [
                Text(
                  'Real-time jeepney tracking — para sa commuter. '
                  'Powered by the Virtual Beacon engine: GPS clustering '
                  'mula sa mga commuter, walang kailangang hardware.',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label, VoidCallback onTap,
      {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: JWColors.black, size: 22),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: JWSpacing.xl),
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
