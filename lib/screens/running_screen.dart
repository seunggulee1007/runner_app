import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../services/running_service.dart';
import '../services/gps_tracker_service.dart';
import 'running_report_screen.dart';

/// 러닝 세션 화면
///
/// 실시간 러닝 데이터를 표시하고 세션을 관리
class RunningScreen extends StatefulWidget {
  final bool quickStart;

  const RunningScreen({super.key, this.quickStart = false});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  late RunningService _runningService;
  late GPSTrackerService _gpsTrackerService;

  // 러닝 세션 상태
  bool _isRunning = false;
  bool _isPaused = false;
  int _countdown = 3;

  // 타이머
  Timer? _timer;
  Timer? _countdownTimer;

  // 러닝 데이터
  int _elapsedSeconds = 0;
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;
  double _averagePace = 0.0;

  // GPS 데이터
  final List<Position> _positions = [];
  StreamSubscription<Position>? _locationSubscription;
  String? _userId;
  String? _sessionId; // 현재 러닝 세션 ID

  // 지도 컨트롤러
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  final List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _runningService = Provider.of<RunningService>(context, listen: false);
    _gpsTrackerService = Provider.of<GPSTrackerService>(context, listen: false);
    _userId = Supabase.instance.client.auth.currentUser?.id;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _locationSubscription?.cancel();
    _gpsTrackerService.stopLocationStream();
    super.dispose();
  }

  /// 러닝 시작 (카운트다운 포함)
  Future<void> _startRunning() async {
    // 1. GPS 권한 요청
    final hasPermission = await _gpsTrackerService.requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 권한이 필요합니다')));
      }
      return;
    }

    // 2. 위치 서비스 확인
    final serviceEnabled = await _gpsTrackerService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 서비스를 켜주세요')));
      }
      return;
    }

    // 3. 카운트다운 시작
    _countdown = 3;

    // 카운트다운 다이얼로그 표시 (타이머는 다이얼로그 내부에서 처리)
    _showCountdownDialog();
  }

  /// 실제 러닝 시작
  Future<void> _beginRunning() async {
    // Supabase 세션 시작
    if (_userId != null) {
      try {
        final session = await _runningService.startSession(userId: _userId!);
        _sessionId = session.id; // UUID 저장
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('세션 시작 실패: $e')));
        }
        return; // 실패하면 러닝 시작 중단
      }
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _positions.clear();
    });

    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    // GPS 추적 시작
    _locationSubscription = _gpsTrackerService.startLocationStream().listen(
      (position) {
        if (!_isPaused && mounted) {
          setState(() {
            _positions.add(position);

            // 현재 위치 업데이트
            _currentLocation = LatLng(position.latitude, position.longitude);

            // 경로에 포인트 추가
            _routePoints.add(_currentLocation!);

            // 지도 카메라 이동 (현재 위치 중심)
            if (_routePoints.isNotEmpty) {
              _mapController.move(_currentLocation!, 17.0);
            }

            // 거리 계산 (전체 위치 목록에서)
            if (_positions.length >= 2) {
              _totalDistance = _gpsTrackerService.calculateTotalDistance(
                _positions,
              );
            }

            // 현재 속도 (m/s를 km/h로 변환)
            _currentSpeed = position.speed * 3.6;

            // 평균 페이스 계산 (분/km)
            if (_totalDistance > 0 && _elapsedSeconds > 0) {
              final distanceInKm = _totalDistance / 1000.0;
              final timeInMinutes = _elapsedSeconds / 60.0;
              _averagePace = timeInMinutes / distanceInKm;
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('GPS 오류: $error')));
        }
      },
    );
  }

  /// 러닝 일시정지
  void _pauseRunning() {
    setState(() {
      _isPaused = true;
    });
  }

  /// 러닝 재개
  void _resumeRunning() {
    setState(() {
      _isPaused = false;
    });
  }

  /// 러닝 종료
  Future<void> _stopRunning() async {
    // 종료 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('러닝 종료'),
        content: const Text('러닝을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('종료'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 타이머 & GPS 중지
      _timer?.cancel();
      _locationSubscription?.cancel();
      _gpsTrackerService.stopLocationStream();

      setState(() {
        _isRunning = false;
        _isPaused = false;
      });

      // 세션 저장
      await _saveSession();
    }
  }

  /// 세션 저장
  Future<void> _saveSession() async {
    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      }
      return;
    }

    if (_positions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('GPS 데이터가 없습니다')));
      }
      return;
    }

    // 세션 ID 확인
    if (_sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('세션 정보가 없습니다')));
      }
      return;
    }

    try {
      // GPS 데이터를 JSON 형식으로 변환
      final gpsData = {
        'points': _positions
            .map(
              (p) => {
                'latitude': p.latitude,
                'longitude': p.longitude,
                'altitude': p.altitude,
                'timestamp': DateTime.now().toIso8601String(),
                'speed': p.speed,
                'accuracy': p.accuracy,
              },
            )
            .toList(),
      };

      // Supabase에 세션 저장 (GPS 데이터 포함)
      final session = await _runningService.endSession(
        sessionId: _sessionId!,
        distance: _totalDistance,
        duration: _elapsedSeconds,
        gpsData: gpsData,
      );

      if (mounted) {
        // 리포트 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RunningReportScreen(session: session),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  /// 카운트다운 다이얼로그 표시
  void _showCountdownDialog() {
    final countdownNotifier = ValueNotifier<int>(_countdown);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ValueListenableBuilder<int>(
        valueListenable: countdownNotifier,
        builder: (context, countdown, child) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Text(
                  countdown > 0 ? '$countdown' : 'GO!',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // 타이머는 다이얼로그 밖에서 한 번만 생성
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        countdownNotifier.value = _countdown; // 다이얼로그 업데이트
      } else {
        timer.cancel();
        countdownNotifier.dispose(); // 메모리 정리
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // 다이얼로그 닫기
        }
        _beginRunning();
      }
    });
  }

  /// 포맷된 시간 (HH:MM:SS)
  String get _formattedTime {
    final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 포맷된 거리 (km)
  String get _formattedDistance {
    return (_totalDistance / 1000.0).toStringAsFixed(2);
  }

  /// 포맷된 페이스 (분:초/km)
  String get _formattedPace {
    if (_averagePace == 0) return '0\'00"';
    final minutes = _averagePace.floor();
    final seconds = ((_averagePace - minutes) * 60).round();
    return '$minutes\'${seconds.toString().padLeft(2, '0')}"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('러닝'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 타이머 영역
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                _formattedTime,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),

          // 지도 영역
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // 지도
                _buildMap(),

                // 통계 오버레이 (상단)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildStatsOverlay(),
                ),
              ],
            ),
          ),

          // 컨트롤 버튼 영역
          Expanded(flex: 2, child: _buildControlButtons()),
        ],
      ),
    );
  }

  /// 지도 위젯
  Widget _buildMap() {
    // 기본 위치 (서울)
    final center = _currentLocation ?? LatLng(37.5665, 126.9780);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 17.0,
        minZoom: 10.0,
        maxZoom: 19.0,
      ),
      children: [
        // 타일 레이어 (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.runner_app',
        ),

        // 경로 폴리라인
        if (_routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: AppColors.primaryBlue,
              ),
            ],
          ),

        // 마커 레이어
        MarkerLayer(
          markers: [
            // 시작 마커
            if (_routePoints.isNotEmpty)
              Marker(
                point: _routePoints.first,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 20),
                ),
              ),

            // 현재 위치 마커
            if (_currentLocation != null && _isRunning)
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 통계 오버레이 위젯
  Widget _buildStatsOverlay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('거리', '$_formattedDistance km'),
          _buildVerticalDivider(),
          _buildStatItem('페이스', '$_formattedPace/km'),
          _buildVerticalDivider(),
          _buildStatItem('속도', '${_currentSpeed.toStringAsFixed(1)} km/h'),
        ],
      ),
    );
  }

  /// 통계 아이템 위젯
  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  /// 수직 구분선
  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  /// 컨트롤 버튼 영역
  Widget _buildControlButtons() {
    if (!_isRunning) {
      // 시작 전
      return Center(
        child: ElevatedButton(
          onPressed: _startRunning,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            '시작',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // 러닝 중
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 일시정지/재개 버튼
          ElevatedButton(
            onPressed: _isPaused ? _resumeRunning : _pauseRunning,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _isPaused ? '재개' : '일시정지',
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // 종료 버튼
          ElevatedButton(
            onPressed: _stopRunning,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('종료', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
