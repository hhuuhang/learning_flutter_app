import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/place_result.dart';

class NominatimException implements Exception {
  const NominatimException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NominatimService {
  NominatimService({http.Client? client}) : _client = client ?? http.Client();

  static const _nominatimHost = 'nominatim.openstreetmap.org';
  static const _photonHost = 'photon.komoot.io';
  static const _language = 'vi,en';
  static const _userAgent =
      'MapChatFlutterDemo/1.0 (local development; replace contact before release)';

  final http.Client _client;
  DateTime? _lastRequestAt;

  Future<List<PlaceResult>> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final uri = Uri.https(_nominatimHost, '/search', {
      'q': trimmedQuery,
      'format': 'jsonv2',
      'addressdetails': '1',
      'extratags': '1',
      'namedetails': '1',
      'limit': '8',
      'accept-language': _language,
    });

    final data = await _getJsonWithFallback(
      primaryUri: uri,
      fallbackUri: Uri.https(_photonHost, '/api/', {
        'q': trimmedQuery,
        'limit': '8',
      }),
      fallbackParser: _parsePhotonResults,
    );

    if (data is List<PlaceResult>) return data;
    if (data is! List) {
      throw const NominatimException('Không đọc được kết quả tìm kiếm.');
    }

    return data
        .whereType<Map>()
        .map((item) => PlaceResult.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<PlaceResult?> reverse(LatLng point) async {
    final uri = Uri.https(_nominatimHost, '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'format': 'jsonv2',
      'zoom': '18',
      'addressdetails': '1',
      'extratags': '1',
      'namedetails': '1',
      'accept-language': _language,
    });

    final data = await _getJsonWithFallback(
      primaryUri: uri,
      fallbackUri: Uri.https(_photonHost, '/reverse', {
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'limit': '1',
      }),
      fallbackParser: (json) => _parsePhotonResults(json).firstOrNull,
    );

    if (data is PlaceResult?) return data;
    if (data is! Map) {
      throw const NominatimException('Không đọc được thông tin địa điểm.');
    }
    if (data['error'] != null) return null;

    return PlaceResult.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Object?> _getJsonWithFallback({
    required Uri primaryUri,
    required Uri fallbackUri,
    required Object? Function(Object? json) fallbackParser,
  }) async {
    try {
      return await _getJson(primaryUri);
    } on NominatimException {
      return _getFallbackJson(fallbackUri, fallbackParser);
    }
  }

  Future<Object?> _getFallbackJson(
    Uri uri,
    Object? Function(Object? json) parser,
  ) async {
    try {
      final data = await _getJson(uri, enforceRateLimit: false);
      return parser(data);
    } on NominatimException {
      rethrow;
    }
  }

  List<PlaceResult> _parsePhotonResults(Object? json) {
    if (json is! Map) return const [];
    final features = json['features'];
    if (features is! List) return const [];

    return features
        .whereType<Map>()
        .map((item) =>
            PlaceResult.fromPhotonFeature(Map<String, dynamic>.from(item)))
        .where(
            (place) => place.point.latitude != 0 || place.point.longitude != 0)
        .toList();
  }

  Future<Object?> _getJson(Uri uri, {bool enforceRateLimit = true}) async {
    if (enforceRateLimit) await _respectRateLimit();

    late final http.Response response;
    try {
      response = await _client.get(uri, headers: const {
        'Accept': 'application/json',
        'Accept-Language': _language,
        'User-Agent': _userAgent,
      }).timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const NominatimException(
        'Không kết nối được dịch vụ bản đồ. Kiểm tra internet rồi thử lại.',
      );
    } on http.ClientException catch (error) {
      throw NominatimException(_friendlyNetworkMessage(error));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NominatimException(
        'Dịch vụ bản đồ trả về lỗi ${response.statusCode}. Vui lòng thử lại sau.',
      );
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const NominatimException('Dữ liệu bản đồ trả về không hợp lệ.');
    }
  }

  Future<void> _respectRateLimit() async {
    final lastRequestAt = _lastRequestAt;
    final now = DateTime.now();
    if (lastRequestAt != null) {
      final elapsed = now.difference(lastRequestAt);
      const minimumGap = Duration(milliseconds: 1100);
      if (elapsed < minimumGap) {
        await Future<void>.delayed(minimumGap - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }

  void dispose() {
    _client.close();
  }

  String _friendlyNetworkMessage(http.ClientException error) {
    final raw = error.message.toLowerCase();
    if (raw.contains('failed host lookup') ||
        raw.contains('no address associated') ||
        raw.contains('nodename nor servname')) {
      return 'Không phân giải được máy chủ bản đồ. Hãy kiểm tra internet/DNS '
          'của emulator hoặc đổi mạng rồi thử lại.';
    }
    if (raw.contains('connection refused') ||
        raw.contains('network is unreachable')) {
      return 'Không kết nối được internet từ thiết bị/emulator.';
    }
    return 'Không kết nối được dịch vụ bản đồ. Vui lòng thử lại.';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
