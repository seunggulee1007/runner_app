import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 러닝 컨트롤 위젯
/// 시작, 일시정지, 재개, 중지 버튼들을 제공
class RunningControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  const RunningControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 중지 버튼
        _buildControlButton(
          icon: Icons.stop,
          size: 50,
          color: AppColors.secondaryRed,
          onPressed: onStop,
          isEnabled: isRunning,
        ),

        // 메인 컨트롤 버튼 (시작/일시정지/재개)
        _buildMainControlButton(),

        // 랩 버튼 (향후 기능)
        _buildControlButton(
          icon: Icons.flag,
          size: 50,
          color: AppColors.textSecondary,
          onPressed: () {
            // 랩 기능 (향후 구현)
          },
          isEnabled: false,
        ),
      ],
    );
  }

  /// 메인 컨트롤 버튼 (시작/일시정지/재개)
  Widget _buildMainControlButton() {
    if (!isRunning) {
      // 시작 버튼
      return _buildControlButton(
        icon: Icons.play_arrow,
        size: 70,
        color: AppColors.secondaryGreen,
        onPressed: onStart,
        isEnabled: true,
      );
    } else if (isPaused) {
      // 재개 버튼
      return _buildControlButton(
        icon: Icons.play_arrow,
        size: 70,
        color: AppColors.secondaryGreen,
        onPressed: onResume,
        isEnabled: true,
      );
    } else {
      // 일시정지 버튼
      return _buildControlButton(
        icon: Icons.pause,
        size: 70,
        color: AppColors.secondaryOrange,
        onPressed: onPause,
        isEnabled: true,
      );
    }
  }

  /// 컨트롤 버튼 위젯
  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required Color color,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? color.withValues(alpha: 0.2)
              : AppColors.textSecondary.withValues(alpha: 0.1),
          border: Border.all(
            color: isEnabled
                ? color
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: size * 0.4,
          color: isEnabled
              ? color
              : AppColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
