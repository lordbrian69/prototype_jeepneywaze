import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Shows a persistent orange banner when the device is offline.
/// JeepneyWaze continues to work from cache — brownout resilience.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _sub;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      setState(() {
        _isOffline = results.every((r) => r == ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFE8401C),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const SafeArea(
        bottom: false,
        child: Text(
          '📡 Offline — Nagpapakita ng nakaimbak na datos',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
