import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 러닝 통계 위젯
/// 실시간 러닝 데이터를 표시
class RunningStats extends StatelessWidget {
  final double distance;
  final double speed;
  final double pace;
  final int? heartRate;
  final Map<String, dynamic>? heartRateZones;

  const RunningStats({
    super.key,
    required this.distance,
    required this.speed,
    required this.pace,
    this.heartRate,
    this.heartRateZones,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 첫 번째 행: 거리와 속도
          Row(
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
          const SizedBox(height: 8),

          // 두 번째 행: 페이스와 심박수
          Row(
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

          // 심박수 존 정보 (있는 경우에만 표시)
          if (heartRateZones != null && heartRateZones!['currentZone'] != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getZoneColor(
                  heartRateZones!['currentZone'],
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getZoneColor(
                    heartRateZones!['currentZone'],
                  ).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: _getZoneColor(heartRateZones!['currentZone']),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getZoneText(heartRateZones!['currentZone']),
                    style: TextStyle(
                      color: _getZoneColor(heartRateZones!['currentZone']),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 심박수 존에 따른 색상 반환
  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'recovery':
        return Colors.green;
      case 'aerobic':
        return Colors.blue;
      case 'threshold':
        return Colors.orange;
      case 'anaerobic':
        return Colors.red;
      case 'neuromuscular':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 심박수 존에 따른 텍스트 반환
  String _getZoneText(String zone) {
    switch (zone) {
      case 'recovery':
        return '휴식';
      case 'aerobic':
        return '유산소';
      case 'threshold':
        return '임계점';
      case 'anaerobic':
        return '무산소';
      case 'neuromuscular':
        return '신경근';
      default:
        return '알 수 없음';
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),

          // 제목
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // 값
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
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
