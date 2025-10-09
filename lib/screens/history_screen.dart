import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/running_session.dart';

/// 러닝 기록 화면
/// 과거 러닝 세션들을 목록으로 표시
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = '전체';
  final List<String> _filterOptions = ['전체', '이번 주', '이번 달', '올해'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('러닝 기록'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 칩
          _buildFilterChips(),

          // 통계 요약
          _buildStatsSummary(),

          // 기록 목록
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  /// 필터 칩 위젯
  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = option == _selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option;
                });
              },
              selectedColor: AppColors.primaryBlue.withOpacity(0.2),
              checkmarkColor: AppColors.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  /// 통계 요약 위젯
  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('총 거리', '156.8', 'km')),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          Expanded(child: _buildStatItem('총 시간', '14:32', '시간')),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textLight.withOpacity(0.3),
          ),
          Expanded(child: _buildStatItem('총 횟수', '42', '회')),
        ],
      ),
    );
  }

  /// 통계 항목 위젯
  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$label ($unit)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLight.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// 기록 목록 위젯
  Widget _buildHistoryList() {
    // 임시 데이터 (실제로는 데이터베이스에서 가져옴)
    final sessions = _getMockSessions();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  /// 세션 카드 위젯
  Widget _buildSessionCard(RunningSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSessionDetail(session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 날짜 정보
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      session.startTime.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      _getMonthName(session.startTime.month),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 세션 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(session.startTime),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          '거리',
                          '${session.distanceInKm.toStringAsFixed(1)}km',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip('시간', session.formattedDuration),
                        const SizedBox(width: 8),
                        _buildInfoChip('페이스', '${session.formattedPace}/km'),
                      ],
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 칩 위젯
  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 필터 다이얼로그
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 세션 상세 정보
  void _showSessionDetail(RunningSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                '러닝 세션 상세',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 상세 정보
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailItem('날짜', _formatDate(session.startTime)),
                    _buildDetailItem('시작 시간', _formatTime(session.startTime)),
                    _buildDetailItem(
                      '종료 시간',
                      session.endTime != null
                          ? _formatTime(session.endTime!)
                          : '--',
                    ),
                    _buildDetailItem(
                      '총 거리',
                      '${session.distanceInKm.toStringAsFixed(2)} km',
                    ),
                    _buildDetailItem('총 시간', session.formattedDuration),
                    _buildDetailItem('평균 페이스', '${session.formattedPace}/km'),
                    _buildDetailItem(
                      '최고 속도',
                      '${session.maxSpeed.toStringAsFixed(1)} km/h',
                    ),
                    _buildDetailItem(
                      '평균 심박수',
                      session.averageHeartRate?.toString() ?? '--',
                    ),
                    _buildDetailItem(
                      '칼로리',
                      session.caloriesBurned?.toString() ?? '--',
                    ),
                    _buildDetailItem(
                      '고도 상승',
                      session.elevationGain?.toStringAsFixed(1) ?? '--',
                    ),
                    _buildDetailItem(
                      '러닝 타입',
                      _getRunningTypeName(session.type),
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

  /// 상세 정보 항목 위젯
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 임시 세션 데이터
  List<RunningSession> _getMockSessions() {
    return [
      RunningSession(
        id: '1',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now()
            .subtract(const Duration(days: 1))
            .add(const Duration(minutes: 28, seconds: 45)),
        totalDistance: 5200,
        totalDuration: 1725,
        averagePace: 5.5,
        maxSpeed: 12.5,
        averageHeartRate: 145,
        maxHeartRate: 165,
        caloriesBurned: 260,
        elevationGain: 50,
        elevationLoss: 45,
        gpsPoints: [],
        type: RunningType.free,
      ),
      RunningSession(
        id: '2',
        startTime: DateTime.now().subtract(const Duration(days: 3)),
        endTime: DateTime.now()
            .subtract(const Duration(days: 3))
            .add(const Duration(minutes: 22, seconds: 15)),
        totalDistance: 3800,
        totalDuration: 1335,
        averagePace: 5.8,
        maxSpeed: 11.8,
        averageHeartRate: 140,
        maxHeartRate: 160,
        caloriesBurned: 190,
        elevationGain: 30,
        elevationLoss: 35,
        gpsPoints: [],
        type: RunningType.free,
      ),
      RunningSession(
        id: '3',
        startTime: DateTime.now().subtract(const Duration(days: 5)),
        endTime: DateTime.now()
            .subtract(const Duration(days: 5))
            .add(const Duration(minutes: 38, seconds: 20)),
        totalDistance: 7100,
        totalDuration: 2300,
        averagePace: 5.4,
        maxSpeed: 13.2,
        averageHeartRate: 150,
        maxHeartRate: 170,
        caloriesBurned: 355,
        elevationGain: 80,
        elevationLoss: 75,
        gpsPoints: [],
        type: RunningType.free,
      ),
    ];
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 월 이름 반환
  String _getMonthName(int month) {
    const months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];
    return months[month - 1];
  }

  /// 러닝 타입 이름 반환
  String _getRunningTypeName(RunningType type) {
    switch (type) {
      case RunningType.free:
        return '자유주행';
      case RunningType.interval:
        return '인터벌';
      case RunningType.targetPace:
        return '타겟페이스';
      case RunningType.endurance:
        return '지구력';
      case RunningType.speed:
        return '스피드';
    }
  }
}
