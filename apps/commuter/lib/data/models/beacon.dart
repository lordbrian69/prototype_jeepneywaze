class VirtualBeacon {
  final String id;
  final String? routeId;
  final String? routeName;
  final String? routeCode;
  final double lat;
  final double lng;
  final double headingDeg;
  final double speedKmh;
  final int occupancyEst;
  final double confidence;
  final DateTime lastSeen;
  final String status;

  const VirtualBeacon({
    required this.id,
    this.routeId,
    this.routeName,
    this.routeCode,
    required this.lat,
    required this.lng,
    this.headingDeg = 0,
    this.speedKmh = 0,
    this.occupancyEst = 0,
    this.confidence = 0,
    required this.lastSeen,
    this.status = 'active',
  });

  factory VirtualBeacon.fromJson(Map<String, dynamic> json) {
    return VirtualBeacon(
      id: json['id'] as String,
      routeId: json['route_id'] as String?,
      routeName: json['route_name'] as String?,
      routeCode: json['route_code'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      headingDeg: (json['heading_deg'] as num?)?.toDouble() ?? 0,
      speedKmh: (json['speed_kmh'] as num?)?.toDouble() ?? 0,
      occupancyEst: (json['occupancy_est'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      lastSeen: DateTime.parse(json['last_seen'] as String),
      status: json['status'] as String? ?? 'active',
    );
  }

  /// Crowding label based on occupancy estimate
  String get crowdingLabel {
    if (occupancyEst >= 12) return 'Puno'; // Full
    if (occupancyEst >= 8) return 'Siksikan'; // Packed
    if (occupancyEst >= 4) return 'OK';
    return 'Malwag'; // Empty
  }

  bool get isStale => DateTime.now().difference(lastSeen).inSeconds > 90;
}
