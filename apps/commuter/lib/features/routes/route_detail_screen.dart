import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_client.dart';

final _stopsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, routeId) async => ref.read(apiClientProvider).listStops(routeId),
);

class RouteDetailScreen extends ConsumerWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stops = ref.watch(_stopsProvider(routeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Mga hinto')),
      body: stops.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, i) {
            final s = list[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE8401C),
                child: Text('${s['sequence']}',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(s['name'] as String),
              subtitle: Text(s['landmark'] as String? ?? ''),
            );
          },
        ),
      ),
    );
  }
}
