import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../core/constants.dart';

final mqttServiceProvider = Provider<MQTTService>((ref) => MQTTService());

/// MQTTService — publishes GPS pings to jw/gps/{user_token}
/// Uses WebSocket transport for mobile clients.
class MQTTService {
  MqttServerClient? _client;
  String? _userToken;
  final List<Map<String, dynamic>> _pendingPings = [];

  Future<void> connect(String userToken) async {
    _userToken = userToken;

    final uri = Uri.parse(AppConstants.mqttBrokerUrl);
    final host = uri.host.isNotEmpty ? uri.host : '10.0.2.2';
    final port = uri.hasPort ? uri.port : 9001;
    final path = uri.path.isNotEmpty ? uri.path : '/mqtt';

    final clientId = 'commuter_${userToken.substring(0, 8)}';
    final client = MqttServerClient.withPort(host, clientId, port);
    client.useWebSocket = true;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.autoReconnect = true;
    client.keepAlivePeriod = 30;
    client.logging(on: false);
    // Some brokers require a trailing websocket path (e.g. /mqtt)
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    if (path != '/') {
      client.websocketProtocols = const ['mqtt'];
    }

    _client = client;

    try {
      await client.connect();
      for (final ping in _pendingPings) {
        _publish(ping);
      }
      _pendingPings.clear();
    } catch (_) {
      // Connection failed — pings will queue in _pendingPings until retry.
    }
  }

  void publishPing(Map<String, dynamic> ping) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _publish(ping);
    } else {
      _pendingPings.add(ping);
      if (_pendingPings.length > 60) {
        _pendingPings.removeAt(0); // Rolling 5-minute buffer
      }
    }
  }

  void _publish(Map<String, dynamic> ping) {
    if (_userToken == null || _client == null) return;
    final topic = 'jw/gps/$_userToken';
    final payload = MqttClientPayloadBuilder()..addString(jsonEncode(ping));
    _client!.publishMessage(topic, MqttQos.atMostOnce, payload.payload!);
  }

  void disconnect() {
    _client?.disconnect();
  }
}
