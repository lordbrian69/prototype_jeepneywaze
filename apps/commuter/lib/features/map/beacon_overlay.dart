import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/beacon.dart';

/// Renders Virtual Beacon markers on the map.
/// Each marker is a jeepney icon rotated to its heading direction.
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
          .where((b) => !b.isStale)
          .map((beacon) => Marker(
                point: LatLng(beacon.lat, beacon.lng),
                width: 48,
                height: 48,
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

class _BeaconMarker extends StatelessWidget {
  final VirtualBeacon beacon;
  final bool isSelected;

  const _BeaconMarker({required this.beacon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: beacon.headingDeg * (pi / 180),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _crowdingColor(beacon),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.directions_bus, color: Colors.white, size: 22),
      ),
    );
  }

  Color _crowdingColor(VirtualBeacon b) {
    // Green = Malwag, Yellow = OK, Orange = Siksikan, Red = Puno
    if (b.occupancyEst >= 12) return Colors.red;
    if (b.occupancyEst >= 8) return const Color(0xFFE8401C);
    if (b.occupancyEst >= 4) return Colors.amber;
    return Colors.green;
  }
}
