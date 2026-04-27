import 'package:flutter/material.dart';
import '../../data/models/beacon.dart';

class ETACard extends StatelessWidget {
  final VirtualBeacon beacon;
  final VoidCallback onCrowdingTap;
  final VoidCallback onDismiss;

  const ETACard({
    super.key,
    required this.beacon,
    required this.onCrowdingTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus, color: Color(0xFFE8401C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    beacon.routeName ?? 'Jeepney',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onDismiss,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.speed,
                  label: '${beacon.speedKmh.toStringAsFixed(0)} km/h',
                ),
                _InfoChip(
                  icon: Icons.people,
                  label: beacon.crowdingLabel,
                  color: _crowdingColor(beacon),
                ),
                _InfoChip(
                  icon: Icons.verified,
                  label: '${(beacon.confidence * 100).toStringAsFixed(0)}% sure',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCrowdingTap,
                icon: const Icon(Icons.report, size: 16),
                label: const Text('I-report ang siksikan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _crowdingColor(VirtualBeacon b) {
    if (b.occupancyEst >= 12) return Colors.red;
    if (b.occupancyEst >= 8) return const Color(0xFFE8401C);
    if (b.occupancyEst >= 4) return Colors.amber;
    return Colors.green;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey[700],
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
