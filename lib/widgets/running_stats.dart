import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 러닝 통계 위젯
/// 실시간 러닝 데이터를 표시
class RunningStats extends StatelessWidget {
  final double distance;
  final double speed;
  final double pace;
  final int? heartRate;

  const RunningStats({
    super.key,
    required this.distance,
    required this.speed,
    required this.pace,
    this.heartRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 첫 번째 행: 거리와 속도
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.straighten,
                    title: '거리',
                    value: (distance / 1000).toStringAsFixed(2),
                    unit: 'km',
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed,
                    title: '속도',
                    value: speed.toStringAsFixed(1),
                    unit: 'km/h',
                    color: AppColors.secondaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 두 번째 행: 페이스와 심박수
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    title: '페이스',
                    value: _formatPace(pace),
                    unit: '/km',
                    color: AppColors.secondaryOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.favorite,
                    title: '심박수',
                    value: heartRate?.toString() ?? '--',
                    unit: 'BPM',
                    color: AppColors.secondaryRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드 위젯
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(height: 3),

          // 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 1),

          // 값
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 페이스를 분:초 형식으로 포맷
  String _formatPace(double paceInMinutesPerKm) {
    if (paceInMinutesPerKm == 0) return '--:--';

    final minutes = paceInMinutesPerKm.floor();
    final seconds = ((paceInMinutesPerKm - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
