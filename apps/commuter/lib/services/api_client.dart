import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../data/models/beacon.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  final Dio _dio;
  String? _jwt;
  String? _userToken;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jwt != null) {
          options.headers['Authorization'] = 'Bearer $_jwt';
        }
        if (_userToken != null) {
          options.headers['x-user-token'] = _userToken;
        }
        handler.next(options);
      },
    ));
  }

  String? get userToken => _userToken;

  void setSession({required String jwt, required String userToken}) {
    _jwt = jwt;
    _userToken = userToken;
  }

  /// Exchange a Supabase access token for a JeepneyWaze JWT + rotating GPS ping token.
  Future<({String jwt, String userToken, bool isPremium})> verifyOtp({
    required String supabaseAccessToken,
    required String supabaseUserId,
    String lang = 'tl',
  }) async {
    final res = await _dio.post('/api/v1/auth/verify-otp', data: {
      'supabase_access_token': supabaseAccessToken,
      'supabase_user_id': supabaseUserId,
      'lang': lang,
    });
    final body = res.data as Map<String, dynamic>;
    setSession(jwt: body['jwt'] as String, userToken: body['user_token'] as String);
    return (
      jwt: body['jwt'] as String,
      userToken: body['user_token'] as String,
      isPremium: (body['is_premium'] as bool?) ?? false,
    );
  }

  Future<List<Map<String, dynamic>>> listRoutes() async {
    final res = await _dio.get('/api/v1/routes');
    return List<Map<String, dynamic>>.from(res.data['routes'] as List);
  }

  Future<List<Map<String, dynamic>>> listStops(String routeId) async {
    final res = await _dio.get('/api/v1/routes/$routeId/stops');
    return List<Map<String, dynamic>>.from(res.data['stops'] as List);
  }

  Future<List<VirtualBeacon>> nearbyBeacons({
    required double lat,
    required double lng,
    double radiusM = 1500,
    String? routeId,
  }) async {
    final res = await _dio.get('/api/v1/beacons/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius_m': radiusM,
      if (routeId != null) 'route_id': routeId,
    });
    return (res.data['beacons'] as List)
        .map((b) => VirtualBeacon.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> eta({
    required String stopId,
    required String routeId,
  }) async {
    final res = await _dio.get('/api/v1/eta', queryParameters: {
      'stop_id': stopId,
      'route_id': routeId,
    });
    return List<Map<String, dynamic>>.from(res.data['etas'] as List);
  }

  Future<void> reportCrowding({
    required String beaconId,
    required String level,
  }) async {
    await _dio.post(
      '/api/v1/beacons/$beaconId/crowding',
      data: {'level': level, 'user_token': _userToken},
    );
  }
}
