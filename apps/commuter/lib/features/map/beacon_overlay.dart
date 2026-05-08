import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/design_tokens.dart';
import '../../data/models/beacon.dart';

/// Renders Virtual Beacon markers on the map.
/// 44×44px rounded square in Jeepney Yellow with black jeepney icon
/// and a pulsing yellow glow ring (per JW Design spec).
class BeaconOverlay extends StatelessWidget {
  final List<VirtualBeacon> beacons;
  final String? selectedId;
  final ValueChanged<VirtualBeacon> onBeaconTap;

  const BeaconOverlay({
    super.key,
    required this.beacons,
    required this.onBeaconTap,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: beacons
          .map((beacon) => Marker(
                point: LatLng(beacon.lat, beacon.lng),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => onBeaconTap(beacon),
                  child: _BeaconMarker(
                    beacon: beacon,
                    isSelected: selectedId == beacon.id,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _BeaconMarker extends StatefulWidget {
  final VirtualBeacon beacon;
  final bool isSelected;

  const _BeaconMarker({required this.beacon, required this.isSelected});

  @override
  State<_BeaconMarker> createState() => _BeaconMarkerState();
}

class _BeaconMarkerState extends State<_BeaconMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStale = widget.beacon.isStale;
    final fillColor = isStale ? JWColors.mutedGray : JWColors.jeepneyYellow;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring (only for active beacons)
        if (!isStale)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final t = _pulseController.value;
              final scale = 1.0 + (t * 0.6);
              final opacity = (1.0 - t).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: JWColors.jeepneyYellow.withOpacity(0.4 * opacity),
                    borderRadius: BorderRadius.circular(JWRadius.card),
                  ),
                ),
              );
            },
          ),

        // Marker body
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(JWRadius.card),
            border: Border.all(
              color: JWColors.black,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: isStale ? null : JWShadows.beacon,
          ),
          child: const Icon(
            Icons.directions_bus,
            color: JWColors.black,
            size: 24,
          ),
        ),
      ],
    );
  }
}
