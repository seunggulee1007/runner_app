import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/running_screen.dart';

/// 러닝 시작을 위한 메인 카드 위젯
/// "오늘의 러닝 시작하기" 버튼과 현재 상태를 표시
class RunningCard extends StatelessWidget {
  const RunningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Row(
                children: [
                  const Icon(
                    Icons.directions_run,
                    color: AppColors.textLight,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '오늘의 러닝',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 설명
              Text(
                '새로운 러닝 세션을 시작하고\n개인 기록을 업데이트해보세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 24),

              // 러닝 시작 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _startRunning(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textLight,
                    foregroundColor: AppColors.primaryBlue,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '러닝 시작하기',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 빠른 옵션들
              Row(
                children: [
                  Expanded(
                    child: _buildQuickOption(
                      context,
                      icon: Icons.timer,
                      label: '빠른 시작',
                      onTap: () => _startQuickRun(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickOption(
                      context,
                      icon: Icons.track_changes,
                      label: '목표 설정',
                      onTap: () => _setGoal(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빠른 옵션 위젯
  Widget _buildQuickOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.textLight.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textLight, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 러닝 시작
  void _startRunning(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RunningScreen()));
  }

  /// 빠른 러닝 시작
  void _startQuickRun(BuildContext context) {
    // 빠른 러닝 모드로 시작
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RunningScreen(quickStart: true),
      ),
    );
  }

  /// 목표 설정
  void _setGoal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 설정'),
        content: const Text('러닝 목표를 설정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 목표 설정 화면으로 이동
            },
            child: const Text('설정'),
          ),
        ],
      ),
    );
  }
}
