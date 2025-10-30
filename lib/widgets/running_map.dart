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
  static const double _dashLength = 20.0;
  static const double _gapLength = 10.0;

  // 기본 위치 (서울 시청)
  static const LatLng _defaultLocation = LatLng(37.5665, 126.9780);
  static const LatLng _defaultSouthwest = LatLng(37.5, 127.0);
  static const LatLng _defaultNortheast = LatLng(37.6, 127.1);

  // UI 상수
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
      
      // 러닝 중일 때 현재 위치로 카메라 이동
      if (widget.isRunning && widget.currentPosition != null) {
        _moveToCurrentPosition();
      }
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
    if (widget.gpsPoints.length < 2) {
      _polylines = {};
      return;
    }

    final points = widget.gpsPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    _polylines = {
      Polyline(
        polylineId: const PolylineId('running_route'),
        points: points,
        color: widget.isRunning
            ? AppColors.primaryBlue
            : AppColors.secondaryRed,
        width: 6, // 더 두껍게 표시
        patterns: widget.isRunning
            ? []
            : [PatternItem.dash(_dashLength), PatternItem.gap(_gapLength)],
        geodesic: true, // 지구 곡면을 고려한 경로 표시
        jointType: JointType.round, // 부드러운 모서리
        endCap: Cap.roundCap, // 둥근 끝부분
        startCap: Cap.roundCap, // 둥근 시작부분
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

  /// 현재 위치로 카메라 이동 (러닝 중 실시간 추적)
  void _moveToCurrentPosition() {
    if (_mapController == null || widget.currentPosition == null) return;

    final currentLatLng = LatLng(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
    );

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 17.0, // 더 가까운 줌 레벨로 설정
          tilt: 45.0, // 약간 기울여서 3D 효과
          bearing: 0.0,
        ),
      ),
    );
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
    // Google Maps API 키 검증
    if (!_isGoogleMapsApiKeyValid()) {
      return _buildPlaceholderUI();
    }

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

  /// Google Maps API 키 유효성 검증
  bool _isGoogleMapsApiKeyValid() {
    // iOS에서 API 키 확인
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Info.plist에서 GMSApiKey 확인
      // 실제 구현에서는 환경 변수나 설정에서 확인
      return false; // 임시로 false 반환하여 플레이스홀더 표시
    }
    
    // Android에서 API 키 확인
    if (Theme.of(context).platform == TargetPlatform.android) {
      // AndroidManifest.xml에서 API 키 확인
      // 실제 구현에서는 환경 변수나 설정에서 확인
      return false; // 임시로 false 반환하여 플레이스홀더 표시
    }
    
    return false;
  }

  /// 대체 UI 빌드 (API 키가 없을 때)
  Widget _buildPlaceholderUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundDark,
            AppColors.primaryBlueDark.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_containerPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 지도 아이콘과 애니메이션
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.route,
                  size: 60,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              
              // 제목
              Text(
                '실시간 경로 추적 중',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              
              // 상태 메시지
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isRunning
                      ? AppColors.primaryBlue.withValues(alpha: 0.2)
                      : AppColors.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isRunning ? Icons.play_arrow : Icons.pause,
                      color: widget.isRunning
                          ? AppColors.primaryBlue
                          : AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isRunning ? '러닝 중' : '일시정지',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: widget.isRunning
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // GPS 경로 정보 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GPS 경로 포인트',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.gpsPoints.length}개',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.gpsPoints.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 12),
                      _buildCoordinateRow(
                        '시작점',
                        widget.gpsPoints.first.latitude,
                        widget.gpsPoints.first.longitude,
                      ),
                      if (widget.currentPosition != null) ...[
                        const SizedBox(height: 8),
                        _buildCoordinateRow(
                          '현재 위치',
                          widget.currentPosition!.latitude,
                          widget.currentPosition!.longitude,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Google Maps API 키를 설정하면\n실시간 지도로 경로를 확인할 수 있습니다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 좌표 정보 행 위젯
  Widget _buildCoordinateRow(String label, double lat, double lng) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textLight,
            fontFamily: 'monospace',
          ),
        ),
      ],
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
