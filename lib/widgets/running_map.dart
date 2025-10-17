import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_colors.dart';
import '../models/running_session.dart';

/// 러닝 세션 중 실시간 지도 표시 위젯
/// GPS 경로를 실시간으로 표시하고 현재 위치를 추적
///
/// Features:
/// - 실시간 GPS 경로 표시
/// - 시작점과 현재 위치 마커
/// - 다크 테마 지원
/// - 성능 최적화된 폴리라인 렌더링
class RunningMap extends StatefulWidget {
  final List<GPSPoint> gpsPoints;
  final GPSPoint? currentPosition;
  final bool isRunning;
  final VoidCallback? onMapReady;

  const RunningMap({
    super.key,
    required this.gpsPoints,
    this.currentPosition,
    this.isRunning = false,
    this.onMapReady,
  });

  @override
  State<RunningMap> createState() => _RunningMapState();
}

class _RunningMapState extends State<RunningMap> {
  // 지도 상수
  static const double _defaultZoom = 15.0;
  static const double _boundsPadding = 100.0;
  static const double _polylineWidth = 4.0;
  static const double _dashLength = 20.0;
  static const double _gapLength = 10.0;

  // 기본 위치 (서울 시청)
  static const LatLng _defaultLocation = LatLng(37.5665, 126.9780);
  static const LatLng _defaultSouthwest = LatLng(37.5, 127.0);
  static const LatLng _defaultNortheast = LatLng(37.6, 127.1);

  // UI 상수
  static const double _iconSize = 48.0;
  static const double _spacingSmall = 6.0;
  static const double _spacingMedium = 12.0;
  static const double _spacingLarge = 16.0;
  static const double _containerPadding = 16.0;

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _updateMapData();
  }

  @override
  void didUpdateWidget(RunningMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gpsPoints != widget.gpsPoints ||
        oldWidget.currentPosition != widget.currentPosition) {
      _updateMapData();
    }
  }

  /// 지도 데이터 업데이트
  void _updateMapData() {
    _updatePolylines();
    _updateMarkers();
    _updateCameraPosition();
  }

  /// GPS 경로를 폴리라인으로 변환
  void _updatePolylines() {
    if (widget.gpsPoints.length < 2) return;

    final points = widget.gpsPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('running_route'),
        points: points,
        color: widget.isRunning
            ? AppColors.primaryBlue
            : AppColors.textSecondary,
        width: _polylineWidth.round(),
        patterns: widget.isRunning
            ? []
            : [PatternItem.dash(_dashLength), PatternItem.gap(_gapLength)],
      ),
    };
  }

  /// 마커 업데이트 (시작점, 현재 위치)
  void _updateMarkers() {
    _markers.clear();

    if (widget.gpsPoints.isNotEmpty) {
      // 시작점 마커
      final startPoint = widget.gpsPoints.first;
      _markers.add(
        Marker(
          markerId: const MarkerId('start_point'),
          position: LatLng(startPoint.latitude, startPoint.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: '시작점', snippet: '러닝 시작 위치'),
        ),
      );

      // 현재 위치 마커 (러닝 중일 때만)
      if (widget.isRunning && widget.currentPosition != null) {
        _currentLocation = LatLng(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('current_position'),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: '현재 위치', snippet: '실시간 위치'),
          ),
        );
      }
    }
  }

  /// 카메라 위치 업데이트
  void _updateCameraPosition() {
    if (_mapController == null) return;

    if (widget.gpsPoints.isNotEmpty) {
      final bounds = _calculateBounds();
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _boundsPadding),
      );
    }
  }

  /// GPS 포인트들의 경계 계산
  LatLngBounds _calculateBounds() {
    if (widget.gpsPoints.isEmpty) {
      return LatLngBounds(
        southwest: _defaultSouthwest,
        northeast: _defaultNortheast,
      );
    }

    double minLat = widget.gpsPoints.first.latitude;
    double maxLat = widget.gpsPoints.first.latitude;
    double minLng = widget.gpsPoints.first.longitude;
    double maxLng = widget.gpsPoints.first.longitude;

    for (final point in widget.gpsPoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// 지도 컨트롤러 설정
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapReady?.call();
    _updateCameraPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMapContent(),
      ),
    );
  }

  /// 지도 콘텐츠 빌드
  Widget _buildMapContent() {
    // 실제 Google Maps 표시
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _defaultLocation,
        zoom: _defaultZoom,
      ),
      polylines: _polylines,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      mapType: MapType.normal,
      style: _getMapStyle(),
    );
  }

  /// 대체 UI 빌드 (API 키가 없을 때)
  Widget _buildPlaceholderUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_containerPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: _iconSize,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: _spacingMedium),
            Text(
              '지도 기능',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _spacingSmall),
            Text(
              'Google Maps API 키를 설정하면\n실시간 경로를 확인할 수 있습니다',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: _spacingMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'GPS 경로: ${widget.gpsPoints.length}개 포인트',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 다크 테마에 맞는 지도 스타일
  String _getMapStyle() {
    return '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "administrative.country",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#181818"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#1b1b1b"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#2c2c2c"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#8a8a8a"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#373737"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#3c3c3c"
          }
        ]
      },
      {
        "featureType": "road.highway.controlled_access",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#4e4e4e"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
    ''';
  }
}
