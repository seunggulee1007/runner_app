import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../services/running_service.dart';
import '../services/gps_tracker_service.dart';

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
  late LocationService _locationService;
  late RunningService _runningService;
  late GPSTrackerService _gpsTrackerService;

  // 러닝 세션 상태
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCountingDown = false;
  int _countdown = 3;

  // 타이머
  Timer? _timer;
  Timer? _countdownTimer;

  // 러닝 데이터
  int _elapsedSeconds = 0;
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;
  double _averagePace = 0.0;

  @override
  void initState() {
    super.initState();
    _locationService = Provider.of<LocationService>(context, listen: false);
    _runningService = Provider.of<RunningService>(context, listen: false);
    _gpsTrackerService = Provider.of<GPSTrackerService>(context, listen: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _locationService.stopTracking();
    super.dispose();
  }

  /// 러닝 시작 (카운트다운 포함)
  Future<void> _startRunning() async {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    // 카운트다운 다이얼로그 표시
    _showCountdownDialog();

    // 카운트다운 시작
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _countdownTimer?.cancel();
          _isCountingDown = false;
          Navigator.of(context).pop(); // 다이얼로그 닫기
          _beginRunning();
        }
      });
    });
  }

  /// 실제 러닝 시작
  void _beginRunning() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
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
    _locationService.startTracking();
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
      _timer?.cancel();
      _locationService.stopTracking();

      setState(() {
        _isRunning = false;
        _isPaused = false;
      });

      // TODO: 세션 저장 및 리포트 화면으로 이동
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('러닝 세션이 저장되었습니다')));
      }
    }
  }

  /// 카운트다운 다이얼로그 표시
  void _showCountdownDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Text(
              _countdown > 0 ? '$_countdown' : 'GO!',
              style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
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

          // 통계 영역
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildStatCard('거리', '$_formattedDistance km'),
                  const SizedBox(height: 16),
                  _buildStatCard('평균 페이스', '$_formattedPace/km'),
                  const SizedBox(height: 16),
                  _buildStatCard(
                    '속도',
                    '${_currentSpeed.toStringAsFixed(1)} km/h',
                  ),
                ],
              ),
            ),
          ),

          // 컨트롤 버튼 영역
          Expanded(flex: 2, child: _buildControlButtons()),
        ],
      ),
    );
  }

  /// 통계 카드 위젯
  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
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
