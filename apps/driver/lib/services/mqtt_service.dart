import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../core/constants.dart';

final mqttServiceProvider = Provider<MQTTService>((ref) => MQTTService());

class MQTTService {
  MqttServerClient? _client;
  String? _userToken;

  Future<bool> connect(String userToken) async {
    _userToken = userToken;

    final uri = Uri.parse(DriverConstants.mqttBrokerUrl);
    final host = uri.host.isNotEmpty ? uri.host : '10.0.2.2';
    final port = uri.hasPort ? uri.port : 9001;

    final clientId = 'driver_${userToken.substring(0, 8)}';
    final client = MqttServerClient.withPort(host, clientId, port);
    client.useWebSocket = true;
    client.websocketProtocols = const ['mqtt'];
    client.autoReconnect = true;
    client.keepAlivePeriod = 30;
    client.logging(on: false);
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    _client = client;
    try {
      await client.connect();
      return client.connectionStatus?.state == MqttConnectionState.connected;
    } catch (_) {
      return false;
    }
  }

  void publishPing(Map<String, dynamic> ping) {
    if (_userToken == null) return;
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }
    final topic = 'jw/gps/$_userToken';
    final payload = MqttClientPayloadBuilder()..addString(jsonEncode(ping));
    _client!.publishMessage(topic, MqttQos.atMostOnce, payload.payload!);
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
