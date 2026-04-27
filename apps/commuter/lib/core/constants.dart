class AppConstants {
  // Replace with your actual Supabase project values
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Android emulator → localhost
  );

  static const socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const mqttBrokerUrl = String.fromEnvironment(
    'MQTT_BROKER_URL',
    defaultValue: 'ws://10.0.2.2:9001',
  );

  // GPS ping intervals (milliseconds)
  static const gpsIntervalMovingMs = 5000;
  static const gpsIntervalStationaryMs = 30000;

  // Map defaults (Manila — Cubao)
  static const defaultLat = 14.6194;
  static const defaultLng = 121.0567;
  static const defaultZoom = 15.0;

  // Phase 1 pilot route IDs (set after seeding)
  static const pilotRouteManila = 'MNL-CUB-QUI';
  static const pilotRouteCebu = 'CEB-COL-SM';

  // Colors
  static const primaryOrange = 0xFFE8401C;
  static const jeepneyYellow = 0xFFFFCC00;
}
