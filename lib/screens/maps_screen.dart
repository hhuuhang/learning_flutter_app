import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/place_result.dart';
import '../services/nominatim_service.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, this.enableNetworkTiles = true});

  final bool enableNetworkTiles;

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  static const _initialCenter = LatLng(10.7769, 106.7009);

  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _nominatimService = NominatimService();

  List<PlaceResult> _results = const [];
  PlaceResult? _selectedPlace;
  LatLng? _userLocation;
  String? _statusMessage;
  bool _isSearching = false;
  bool _isLocating = false;
  bool _tileWarningShown = false;
  double _currentZoom = 13;
  LatLng _currentCenter = _initialCenter;

  @override
  void dispose() {
    _searchController.dispose();
    _nominatimService.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) return;

    setState(() {
      _isSearching = true;
      _statusMessage = null;
    });

    try {
      final results = await _nominatimService.search(query);
      if (!mounted) return;

      setState(() {
        _results = results;
        _selectedPlace = results.isEmpty ? null : results.first;
        _statusMessage =
            results.isEmpty ? 'Không tìm thấy địa điểm phù hợp.' : null;
      });

      if (results.isNotEmpty) {
        _moveTo(results.first.point, 16);
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _reverseLookup(LatLng point) async {
    setState(() {
      _selectedPlace = null;
      _statusMessage = 'Đang đọc thông tin địa điểm...';
    });

    try {
      final place = await _nominatimService.reverse(point);
      if (!mounted) return;

      setState(() {
        _selectedPlace = place;
        _statusMessage =
            place == null ? 'Không có dữ liệu tại điểm này.' : null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _selectedPlace = _coordinatePlace(point);
        _statusMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _locateMe() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
      _statusMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const NominatimException('Dịch vụ định vị đang tắt.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const NominatimException(
            'Ứng dụng chưa có quyền truy cập vị trí.');
      }

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() => _userLocation = point);
      _moveTo(point, 16);
      await _reverseLookup(point);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _statusMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _selectPlace(PlaceResult place) {
    setState(() => _selectedPlace = place);
    _moveTo(place.point, 16);
  }

  void _moveTo(LatLng point, double zoom) {
    _currentCenter = point;
    _currentZoom = zoom;
    _mapController.move(point, zoom);
  }

  void _zoomBy(double delta) {
    final nextZoom = (_currentZoom + delta).clamp(3, 19).toDouble();
    _moveTo(_currentCenter, nextZoom);
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleTileError(Object error) {
    if (_tileWarningShown || !mounted) return;
    _tileWarningShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Không tải được một số ô bản đồ. App sẽ thử nguồn dự phòng; '
            'nếu vẫn trống, hãy kiểm tra internet/DNS của emulator.';
      });
    });
  }

  String _friendlyError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.contains('ClientException') ||
        message.contains('SocketException') ||
        message.contains('Failed host lookup')) {
      return 'Không kết nối được máy chủ bản đồ. Hãy kiểm tra internet/DNS '
          'của emulator rồi thử lại.';
    }
    return message;
  }

  PlaceResult _coordinatePlace(LatLng point) {
    return PlaceResult(
      placeId:
          'coordinate-${point.latitude.toStringAsFixed(6)}-${point.longitude.toStringAsFixed(6)}',
      displayName: 'Tọa độ đã chọn',
      point: point,
      category: 'coordinate',
      type: 'manual',
      address: const {},
      extraTags: const {},
      nameDetails: const {
        'name': 'Tọa độ đã chọn',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _currentZoom,
            minZoom: 3,
            maxZoom: 19,
            onTap: (_, point) => _reverseLookup(point),
            onPositionChanged: (camera, _) {
              _currentCenter = camera.center;
              _currentZoom = camera.zoom;
            },
          ),
          children: [
            if (widget.enableNetworkTiles)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                fallbackUrl:
                    'https://cartodb-basemaps-a.global.ssl.fastly.net/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'vn.learningflutter.mapchat',
                errorTileCallback: (_, error, __) => _handleTileError(error),
              ),
            MarkerLayer(markers: _markers),
            RichAttributionWidget(
              showFlutterMapAttribution: false,
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () =>
                      _openUrl('https://www.openstreetmap.org/copyright'),
                ),
                TextSourceAttribution(
                  'Nominatim',
                  onTap: () => _openUrl('https://nominatim.org/'),
                ),
                TextSourceAttribution(
                  'Photon',
                  onTap: () => _openUrl('https://photon.komoot.io/'),
                ),
                TextSourceAttribution(
                  'CARTO',
                  onTap: () => _openUrl('https://carto.com/attributions'),
                ),
              ],
            ),
          ],
        ),
        _SearchPanel(
          controller: _searchController,
          isSearching: _isSearching,
          statusMessage: _statusMessage,
          results: _results,
          onSearch: _search,
          onClear: () {
            setState(() {
              _results = const [];
              _selectedPlace = null;
              _statusMessage = null;
              _searchController.clear();
            });
          },
          onSelectPlace: _selectPlace,
        ),
        Positioned(
          right: 12,
          bottom: _selectedPlace == null ? 24 : 220,
          child: _MapControls(
            isLocating: _isLocating,
            onLocate: _locateMe,
            onZoomIn: () => _zoomBy(1),
            onZoomOut: () => _zoomBy(-1),
          ),
        ),
        if (_selectedPlace != null)
          _PlaceDetailsSheet(
            place: _selectedPlace!,
            onOpenOsm: _selectedPlace!.osmUrl == null
                ? null
                : () => _openUrl(_selectedPlace!.osmUrl!),
          ),
      ],
    );
  }

  List<Marker> get _markers {
    final markers = <Marker>[
      for (final result in _results)
        Marker(
          point: result.point,
          width: 42,
          height: 42,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => _selectPlace(result),
            child: Icon(
              Icons.location_on,
              color: result.placeId == _selectedPlace?.placeId
                  ? const Color(0xFFE11D48)
                  : const Color(0xFF2563EB),
              size: 40,
            ),
          ),
        ),
      if (_selectedPlace != null && !_results.contains(_selectedPlace))
        Marker(
          point: _selectedPlace!.point,
          width: 46,
          height: 46,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on,
            color: Color(0xFFE11D48),
            size: 44,
          ),
        ),
      if (_userLocation != null)
        Marker(
          point: _userLocation!,
          width: 22,
          height: 22,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
    ];
    return markers;
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.isSearching,
    required this.statusMessage,
    required this.results,
    required this.onSearch,
    required this.onClear,
    required this.onSelectPlace,
  });

  final TextEditingController controller;
  final bool isSearching;
  final String? statusMessage;
  final List<PlaceResult> results;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<PlaceResult> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                elevation: 6,
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Tìm địa điểm, địa chỉ, quán ăn...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSearching)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            tooltip: 'Tìm kiếm',
                            onPressed: onSearch,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        IconButton(
                          tooltip: 'Xóa',
                          onPressed: onClear,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              if (statusMessage != null)
                _FloatingMessage(message: statusMessage!),
              if (results.isNotEmpty)
                _SearchResults(
                  results: results,
                  onSelectPlace: onSelectPlace,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.results,
    required this.onSelectPlace,
  });

  final List<PlaceResult> results;
  final ValueChanged<PlaceResult> onSelectPlace;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(
              result.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              result.coordinates,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.end,
            ),
            onTap: () => onSelectPlace(result),
          );
        },
      ),
    );
  }
}

class _FloatingMessage extends StatelessWidget {
  const _FloatingMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.isLocating,
    required this.onLocate,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final bool isLocating;
  final VoidCallback onLocate;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Vị trí của tôi',
            onPressed: isLocating ? null : onLocate,
            icon: isLocating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: 'Phóng to',
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
          ),
          const Divider(height: 1),
          IconButton(
            tooltip: 'Thu nhỏ',
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

class _PlaceDetailsSheet extends StatelessWidget {
  const _PlaceDetailsSheet({
    required this.place,
    required this.onOpenOsm,
  });

  final PlaceResult place;
  final VoidCallback? onOpenOsm;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  place.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.pin_drop_outlined,
                      label: place.coordinates,
                    ),
                    for (final chip in place.infoChips)
                      _InfoChip(icon: Icons.info_outline, label: chip),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: onOpenOsm,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Mở trên OSM'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dữ liệu mở',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
