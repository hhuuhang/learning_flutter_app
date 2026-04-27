import 'package:latlong2/latlong.dart';

class PlaceResult {
  const PlaceResult({
    required this.placeId,
    required this.displayName,
    required this.point,
    required this.category,
    required this.type,
    required this.address,
    required this.extraTags,
    required this.nameDetails,
    this.importance,
    this.osmType,
    this.osmId,
  });

  final String placeId;
  final String displayName;
  final LatLng point;
  final String category;
  final String type;
  final double? importance;
  final String? osmType;
  final int? osmId;
  final Map<String, dynamic> address;
  final Map<String, dynamic> extraTags;
  final Map<String, dynamic> nameDetails;

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      placeId: '${json['place_id'] ?? json['osm_id'] ?? ''}',
      displayName: '${json['display_name'] ?? 'Không rõ địa điểm'}',
      point: LatLng(
        _parseDouble(json['lat']),
        _parseDouble(json['lon']),
      ),
      category: '${json['category'] ?? ''}',
      type: '${json['type'] ?? ''}',
      importance: _tryParseDouble(json['importance']),
      osmType: json['osm_type']?.toString(),
      osmId: int.tryParse('${json['osm_id'] ?? ''}'),
      address: _asMap(json['address']),
      extraTags: _asMap(json['extratags']),
      nameDetails: _asMap(json['namedetails']),
    );
  }

  factory PlaceResult.fromPhotonFeature(Map<String, dynamic> json) {
    final properties = _asMap(json['properties']);
    final geometry = _asMap(json['geometry']);
    final coordinates = geometry['coordinates'];
    final lon = coordinates is List && coordinates.isNotEmpty
        ? _parseDouble(coordinates[0])
        : 0.0;
    final lat = coordinates is List && coordinates.length > 1
        ? _parseDouble(coordinates[1])
        : 0.0;

    final address = <String, dynamic>{
      if (properties['housenumber'] != null)
        'house_number': properties['housenumber'],
      if (properties['street'] != null) 'road': properties['street'],
      if (properties['district'] != null) 'suburb': properties['district'],
      if (properties['city'] != null) 'city': properties['city'],
      if (properties['state'] != null) 'state': properties['state'],
      if (properties['country'] != null) 'country': properties['country'],
      if (properties['postcode'] != null) 'postcode': properties['postcode'],
    };

    final name = '${properties['name'] ?? 'Không rõ địa điểm'}';
    final displayParts = [
      name,
      properties['street'],
      properties['district'],
      properties['city'],
      properties['state'],
      properties['country'],
    ]
        .where((part) => part != null && part.toString().trim().isNotEmpty)
        .map((part) => part.toString().trim())
        .toSet()
        .toList();

    return PlaceResult(
      placeId:
          'photon-${properties['osm_type'] ?? ''}-${properties['osm_id'] ?? name}',
      displayName: displayParts.join(', '),
      point: LatLng(lat, lon),
      category: '${properties['osm_key'] ?? ''}',
      type: '${properties['osm_value'] ?? properties['type'] ?? ''}',
      osmType: properties['osm_type']?.toString(),
      osmId: int.tryParse('${properties['osm_id'] ?? ''}'),
      address: address,
      extraTags: const {},
      nameDetails: {
        if (properties['name'] != null) 'name': properties['name'],
      },
    );
  }

  String get title {
    final vietnameseName = nameDetails['name:vi'] ?? nameDetails['name'];
    final resolvedName = vietnameseName?.toString().trim();
    if (resolvedName != null && resolvedName.isNotEmpty) {
      return resolvedName;
    }

    final firstPart = displayName.split(',').first.trim();
    return firstPart.isEmpty ? 'Địa điểm đã chọn' : firstPart;
  }

  String get subtitle {
    final parts = <String>[
      _addressValue('road'),
      _addressValue('quarter'),
      _addressValue('suburb'),
      _addressValue('city'),
      _addressValue('town'),
      _addressValue('state'),
      _addressValue('country'),
    ].where((value) => value.isNotEmpty).toSet().toList();

    if (parts.isEmpty) return displayName;
    return parts.join(', ');
  }

  String get coordinates {
    return '${point.latitude.toStringAsFixed(5)}, '
        '${point.longitude.toStringAsFixed(5)}';
  }

  String? get osmUrl {
    final id = osmId;
    final rawType = osmType?.toLowerCase();
    if (id == null || rawType == null || rawType.isEmpty) return null;

    final type = switch (rawType) {
      'n' || 'node' => 'node',
      'w' || 'way' => 'way',
      'r' || 'relation' => 'relation',
      _ => rawType,
    };
    return 'https://www.openstreetmap.org/$type/$id';
  }

  List<String> get infoChips {
    final chips = <String>[];
    if (category.isNotEmpty) chips.add(_humanize(category));
    if (type.isNotEmpty) chips.add(_humanize(type));

    final openingHours = extraTags['opening_hours']?.toString();
    if (openingHours != null && openingHours.isNotEmpty) {
      chips.add('Giờ mở cửa: $openingHours');
    }

    final cuisine = extraTags['cuisine']?.toString();
    if (cuisine != null && cuisine.isNotEmpty) {
      chips.add('Ẩm thực: ${_humanize(cuisine)}');
    }

    final website = extraTags['website']?.toString();
    if (website != null && website.isNotEmpty) chips.add('Có website');

    return chips.toSet().take(5).toList();
  }

  String _addressValue(String key) => address[key]?.toString().trim() ?? '';

  static double _parseDouble(Object? value) => _tryParseDouble(value) ?? 0;

  static double? _tryParseDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}');
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }

  static String _humanize(String value) {
    return value.replaceAll('_', ' ').trim();
  }
}
