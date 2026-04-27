import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';

class CrowdingReportScreen extends ConsumerStatefulWidget {
  final String beaconId;

  const CrowdingReportScreen({super.key, required this.beaconId});

  @override
  ConsumerState<CrowdingReportScreen> createState() => _CrowdingReportScreenState();
}

class _CrowdingReportScreenState extends ConsumerState<CrowdingReportScreen> {
  bool _submitting = false;

  Future<void> _submit(String level) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(apiClientProvider).reportCrowding(
            beaconId: widget.beaconId,
            level: level,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salamat! +5 Guardian points')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ('malwag', 'Malwag 😊', Colors.green, 'Maraming upuan'),
      ('ok', 'OK 👍', Colors.blue, 'Ilang upuan pa'),
      ('siksikan', 'Siksikan 😰', Color(0xFFE8401C), 'Puno na halos'),
      ('puno', 'Puno! 🚫', Colors.red, 'Hindi na makasakay'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('I-report ang siksikan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gaano kasikip ang jeep na ito?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            for (final entry in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _submitting ? null : () => _submit(entry.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: entry.$3.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(entry.$2,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: entry.$3,
                            )),
                        const SizedBox(width: 12),
                        Text(entry.$4,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ),
            if (_submitting)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
