import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 러닝 타이머 위젯
/// 경과 시간을 시각적으로 표시
class RunningTimer extends StatelessWidget {
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;

  const RunningTimer({
    super.key,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 시간 표시 (왼쪽)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '경과 시간',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(elapsedSeconds),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),

        // 상태 표시 (오른쪽)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRunning && !isPaused)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(),
                  ),
                ),
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 시간을 시:분:초 형식으로 포맷
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 상태에 따른 색상 반환
  Color _getStatusColor() {
    if (!isRunning) {
      return AppColors.textSecondary;
    } else if (isPaused) {
      return AppColors.secondaryOrange;
    } else {
      return AppColors.secondaryGreen;
    }
  }

  /// 상태에 따른 텍스트 반환
  String _getStatusText() {
    if (!isRunning) {
      return '대기 중';
    } else if (isPaused) {
      return '일시정지';
    } else {
      return '러닝 중';
    }
  }
}
