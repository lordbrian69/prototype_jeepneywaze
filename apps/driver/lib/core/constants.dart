class DriverConstants {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const mqttBrokerUrl = String.fromEnvironment(
    'MQTT_BROKER_URL',
    defaultValue: 'ws://10.0.2.2:9001',
  );

  // GPS pings while broadcasting
  static const gpsDistanceFilterMeters = 5;
}
