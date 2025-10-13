import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../models/running_session.dart';
import '../services/running_service.dart';
import 'running_report_screen.dart';

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

  late RunningService _runningService;
  String? _userId;
  List<RunningSession>? _sessions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runningService = Provider.of<RunningService>(context, listen: false);
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _loadSessions();
  }

  /// Supabase에서 세션 불러오기
  Future<void> _loadSessions() async {
    if (_userId == null) {
      setState(() {
        _error = '로그인이 필요합니다';
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final sessions = await _runningService.getUserSessions(userId: _userId!);

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

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
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primaryBlue,
            ),
          );
        },
      ),
    );
  }

  /// 통계 요약 위젯
  Widget _buildStatsSummary() {
    // 실제 데이터 기반 통계 계산
    double totalDistance = 0;
    int totalDuration = 0;
    int totalCount = 0;

    if (_sessions != null) {
      for (var session in _sessions!) {
        totalDistance += (session.distance ?? 0) / 1000.0; // km로 변환
        totalDuration += session.duration ?? 0;
      }
      totalCount = _sessions!.length;
    }

    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final timeStr = '$hours:${minutes.toString().padLeft(2, '0')}';

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
          Expanded(
            child: _buildStatItem(
              '총 거리',
              totalDistance.toStringAsFixed(1),
              'km',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textLight.withValues(alpha: 0.3),
          ),
          Expanded(child: _buildStatItem('총 시간', timeStr, '시간')),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textLight.withValues(alpha: 0.3),
          ),
          Expanded(child: _buildStatItem('총 횟수', totalCount.toString(), '회')),
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
            color: AppColors.textLight.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  /// 기록 목록 위젯
  Widget _buildHistoryList() {
    // 로딩 중
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 발생
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSessions,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 데이터 없음
    if (_sessions == null || _sessions!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '아직 러닝 기록이 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // 실제 데이터 표시
    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sessions!.length,
        itemBuilder: (context, index) {
          final session = _sessions![index];
          return _buildSessionCard(session);
        },
      ),
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
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip(
                          '거리',
                          '${session.distanceInKm?.toStringAsFixed(1) ?? '0.0'}km',
                        ),
                        _buildInfoChip('시간', session.formattedDuration),
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
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
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
    // 리포트 화면으로 이동
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RunningReportScreen(session: session),
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
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
}
