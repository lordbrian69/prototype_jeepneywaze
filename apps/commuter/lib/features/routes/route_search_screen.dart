import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/api_client.dart';

final _routesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(apiClientProvider).listRoutes();
});

class RouteSearchScreen extends ConsumerWidget {
  const RouteSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(_routesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Hanapin ang ruta')),
      body: routes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final r = list[i];
            return ListTile(
              leading: const Icon(Icons.directions_bus,
                  color: Color(0xFFE8401C)),
              title: Text(r['name'] as String),
              subtitle: Text(r['code'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/routes/${r['id']}'),
            );
          },
        ),
      ),
    );
  }
}
