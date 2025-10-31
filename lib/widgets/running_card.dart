import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../screens/running_screen.dart';
import '../services/location_service.dart';

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
  Future<void> _startRunning(BuildContext context) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 위치 서비스 가져오기
      final locationService =
          Provider.of<LocationService>(context, listen: false);

      // 위치 권한 확인 및 요청
      final hasPermission = await locationService.requestLocationPermission();

      // 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!hasPermission) {
        // 권한이 거부된 경우
        if (context.mounted) {
          _showPermissionDeniedDialog(context);
        }
        return;
      }

      // 권한이 있으면 러닝 화면으로 이동
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RunningScreen()),
        );
      }
    } catch (e) {
      // 에러 발생 시 로딩 닫기
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('러닝을 시작할 수 없습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 위치 권한 거부 다이얼로그
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: AppColors.error),
            SizedBox(width: 8),
            Text('위치 권한 필요'),
          ],
        ),
        content: const Text(
          '러닝 추적을 위해서는 위치 권한이 필요합니다.\n'
          '설정에서 위치 권한을 허용해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 설정 앱으로 이동 (추가 구현 필요)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
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
