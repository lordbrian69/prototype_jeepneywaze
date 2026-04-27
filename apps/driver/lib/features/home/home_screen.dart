import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/gps_service.dart';
import '../../services/mqtt_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _plateCtrl = TextEditingController();
  bool _broadcasting = false;
  String? _error;

  String get _driverToken {
    final p = _plateCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (p.isEmpty) return 'drv_${DateTime.now().millisecondsSinceEpoch}';
    return 'drv_$p';
  }

  Future<void> _toggle() async {
    setState(() => _error = null);
    final mqtt = ref.read(mqttServiceProvider);
    final gps = ref.read(gpsServiceProvider);

    if (_broadcasting) {
      await gps.stop();
      mqtt.disconnect();
      setState(() => _broadcasting = false);
      return;
    }

    final ok = await gps.requestPermission();
    if (!ok) {
      setState(() => _error = 'Location permission required.');
      return;
    }

    final token = _driverToken;
    final connected = await mqtt.connect(token);
    if (!connected) {
      setState(() => _error = 'Could not reach MQTT broker.');
      return;
    }

    await gps.start(token);
    setState(() => _broadcasting = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JeepneyWaze Driver')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _plateCtrl,
              enabled: !_broadcasting,
              decoration: const InputDecoration(
                labelText: 'Plate number (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _broadcasting ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                      size: 64,
                      color: _broadcasting ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _broadcasting ? 'Nagba-broadcast' : 'Hindi aktibo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _broadcasting
                          ? 'Nagpapadala ng GPS tuwing lumilipat ng 5m'
                          : 'Pindutin ang Start upang magsimula',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            FilledButton.icon(
              icon: Icon(_broadcasting ? Icons.stop : Icons.play_arrow),
              label: Text(_broadcasting ? 'Stop' : 'Start broadcasting'),
              onPressed: _toggle,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }
}
