import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/running_session.dart';
import '../services/location_service.dart';
import '../services/database_service.dart';
import '../widgets/running_timer.dart';
import '../widgets/running_stats.dart';
import '../widgets/running_controls.dart';

/// 러닝 세션 화면
/// 실시간 러닝 데이터를 표시하고 세션을 관리
class RunningScreen extends StatefulWidget {
  final bool quickStart;

  const RunningScreen({super.key, this.quickStart = false});

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  late LocationService _locationService;
  late DatabaseService _databaseService;

  // 러닝 세션 상태
  bool _isRunning = false;
  bool _isPaused = false;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // 러닝 데이터
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;
  double _averagePace = 0.0;
  int? _currentHeartRate;

  // GPS 데이터
  List<GPSPoint> _gpsPoints = [];

  @override
  void initState() {
    super.initState();
    _locationService = Provider.of<LocationService>(context, listen: false);
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _initializeLocationTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationService.stopTracking();
    super.dispose();
  }

  /// 위치 추적 초기화
  Future<void> _initializeLocationTracking() async {
    final success = await _locationService.startTracking();
    if (success) {
      _locationService.gpsPointsStream.listen((points) {
        if (mounted) {
          setState(() {
            _gpsPoints = points;
            _updateRunningStats();
          });
        }
      });

      _locationService.currentPositionStream.listen((position) {
        if (mounted) {
          setState(() {
            _currentSpeed = position.speed * 3.6; // m/s to km/h
          });
        }
      });
    }
  }

  /// 러닝 통계 업데이트
  void _updateRunningStats() {
    if (_gpsPoints.length >= 2) {
      _totalDistance = _locationService.calculateTotalDistance();
      _averagePace = _calculateAveragePace();
    }
  }

  /// 평균 페이스 계산
  double _calculateAveragePace() {
    if (_totalDistance == 0 || _elapsedSeconds == 0) return 0.0;

    final distanceInKm = _totalDistance / 1000.0;
    final timeInMinutes = _elapsedSeconds / 60.0;

    return timeInMinutes / distanceInKm;
  }

  /// 러닝 시작
  void _startRunning() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _startTime = DateTime.now();
    });

    _startTimer();
  }

  /// 러닝 일시정지
  void _pauseRunning() {
    setState(() {
      _isPaused = true;
    });

    _timer?.cancel();
  }

  /// 러닝 재개
  void _resumeRunning() {
    setState(() {
      _isPaused = false;
    });

    _startTimer();
  }

  /// 러닝 중지
  void _stopRunning() {
    _timer?.cancel();
    _locationService.stopTracking();

    _saveRunningSession();

    Navigator.of(context).pop();
  }

  /// 타이머 시작
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRunning && !_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
        _updateRunningStats();
      }
    });
  }

  /// 러닝 세션 저장
  Future<void> _saveRunningSession() async {
    if (_gpsPoints.isEmpty) return;

    final session = RunningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _startTime!,
      endTime: DateTime.now(),
      totalDistance: _totalDistance,
      totalDuration: _elapsedSeconds,
      averagePace: _averagePace,
      maxSpeed: _locationService.calculateMaxSpeed(),
      averageHeartRate: _currentHeartRate,
      maxHeartRate: _currentHeartRate,
      caloriesBurned: _calculateCalories(),
      elevationGain: _locationService.calculateElevationChange()['gain'],
      elevationLoss: _locationService.calculateElevationChange()['loss'],
      gpsPoints: _gpsPoints,
      type: RunningType.free,
    );

    await _databaseService.saveRunningSession(session);
  }

  /// 칼로리 계산 (간단한 공식)
  int _calculateCalories() {
    // 간단한 칼로리 계산 공식 (실제로는 더 정확한 공식 사용)
    final distanceInKm = _totalDistance / 1000.0;
    return (distanceInKm * 50).round(); // 1km당 약 50칼로리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundDark, AppColors.primaryBlueDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 앱바
              _buildAppBar(),

              // 메인 러닝 화면
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 타이머
                      Container(
                        height: 250,
                        child: RunningTimer(
                          elapsedSeconds: _elapsedSeconds,
                          isRunning: _isRunning,
                          isPaused: _isPaused,
                        ),
                      ),

                      // 러닝 통계
                      Container(
                        height: 180,
                        child: RunningStats(
                          distance: _totalDistance,
                          speed: _currentSpeed,
                          pace: _averagePace,
                          heartRate: _currentHeartRate,
                        ),
                      ),

                      // 컨트롤 버튼들
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: RunningControls(
                          isRunning: _isRunning,
                          isPaused: _isPaused,
                          onStart: _startRunning,
                          onPause: _pauseRunning,
                          onResume: _resumeRunning,
                          onStop: _stopRunning,
                        ),
                      ),

                      // 하단 여백
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 앱바 위젯
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          bottom: BorderSide(color: AppColors.textSecondary, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textLight),
            onPressed: () {
              if (_isRunning) {
                _showExitDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          const Spacer(),
          Text(
            '러닝',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textLight),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
    );
  }

  /// 종료 확인 다이얼로그
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          '러닝을 종료하시겠습니까?',
          style: TextStyle(color: AppColors.textLight),
        ),
        content: const Text(
          '현재까지의 기록이 저장됩니다.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopRunning();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryRed,
            ),
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }

  /// 옵션 메뉴
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note, color: AppColors.textLight),
              title: const Text(
                '음악',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // 음악 연동 기능
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: AppColors.textLight),
              title: const Text(
                '음성 안내',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // 음성 안내 설정
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.textLight),
              title: const Text(
                '설정',
                style: TextStyle(color: AppColors.textLight),
              ),
              onTap: () {
                Navigator.of(context).pop();
                // 러닝 설정
              },
            ),
          ],
        ),
      ),
    );
  }
}
