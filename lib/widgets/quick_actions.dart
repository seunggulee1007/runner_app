import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 빠른 액션 위젯
/// 자주 사용하는 기능들에 빠르게 접근할 수 있는 버튼들
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 액션 버튼들
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.track_changes,
                title: '목표 설정',
                subtitle: '주간 목표 관리',
                color: AppColors.primaryBlue,
                onTap: () => _showGoalSetting(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.analytics,
                title: '상세 통계',
                subtitle: '성과 분석',
                color: AppColors.secondaryGreen,
                onTap: () => _showDetailedStats(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.share,
                title: '기록 공유',
                subtitle: '소셜 공유',
                color: AppColors.secondaryOrange,
                onTap: () => _shareRecord(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.settings,
                title: '설정',
                subtitle: '앱 설정',
                color: AppColors.textSecondary,
                onTap: () => _openSettings(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 액션 버튼 위젯
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),

            // 제목
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // 부제목
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// 목표 설정 다이얼로그
  void _showGoalSetting(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('주간 러닝 목표를 설정하세요'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '주간 목표 거리 (km)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '주간 러닝 횟수',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage(context, '목표가 설정되었습니다!');
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// 상세 통계 화면
  void _showDetailedStats(BuildContext context) {
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
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                '상세 통계',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 통계 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildStatItem('총 러닝 거리', '156.8 km'),
                    _buildStatItem('총 러닝 시간', '14시간 32분'),
                    _buildStatItem('총 러닝 횟수', '42회'),
                    _buildStatItem('평균 페이스', '5:34 /km'),
                    _buildStatItem('최고 속도', '12.5 km/h'),
                    _buildStatItem('총 칼로리', '8,420 kcal'),
                    _buildStatItem('평균 심박수', '145 BPM'),
                    _buildStatItem('총 고도 상승', '1,250 m'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 통계 항목 위젯
  Widget _buildStatItem(String label, String value) {
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

  /// 기록 공유
  void _shareRecord(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 공유'),
        content: const Text('어떤 기록을 공유하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage(context, '기록이 공유되었습니다!');
            },
            child: const Text('공유'),
          ),
        ],
      ),
    );
  }

  /// 설정 화면
  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
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
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                '설정',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 설정 항목들
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: '알림 설정',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.location_on,
                      title: '위치 서비스',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.fitness_center,
                      title: '건강 앱 연동',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.privacy_tip,
                      title: '개인정보 보호',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.help,
                      title: '도움말',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.info,
                      title: '앱 정보',
                      onTap: () {},
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

  /// 설정 항목 위젯
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
