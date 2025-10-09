import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_profile.dart';

/// 사용자 프로필 화면
/// 사용자 정보, 설정, 통계 등을 표시
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 임시 사용자 데이터
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = _getMockUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '프로필',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // 프로필 이미지
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.textLight.withOpacity(0.2),
                        child: _userProfile.profileImageUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _userProfile.profileImageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.textLight,
                              ),
                      ),
                      const SizedBox(height: 12),
                      // 사용자 이름
                      Text(
                        _userProfile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 사용자 레벨
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getLevelText(_userProfile.level),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 메인 컨텐츠
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 목표 진행률
                  _buildGoalProgress(),
                  const SizedBox(height: 24),

                  // 통계 카드들
                  _buildStatsCards(),
                  const SizedBox(height: 24),

                  // 설정 메뉴
                  _buildSettingsMenu(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 목표 진행률 위젯
  Widget _buildGoalProgress() {
    final weeklyProgress = 0.75; // 75% 완료
    final runProgress = 0.6; // 60% 완료

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '이번 주 목표',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 주간 거리 목표
            _buildProgressItem(
              '주간 거리 목표',
              '${(_userProfile.weeklyGoal * weeklyProgress).toStringAsFixed(1)} / ${_userProfile.weeklyGoal} km',
              weeklyProgress,
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),

            // 주간 러닝 횟수 목표
            _buildProgressItem(
              '주간 러닝 횟수',
              '${(_userProfile.weeklyRunGoal * runProgress).round()} / ${_userProfile.weeklyRunGoal} 회',
              runProgress,
              AppColors.secondaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  /// 진행률 항목 위젯
  Widget _buildProgressItem(
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  /// 통계 카드들 위젯
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '총 거리',
            '156.8',
            'km',
            Icons.straighten,
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '총 시간',
            '14:32',
            '시간',
            Icons.timer,
            AppColors.secondaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '총 횟수',
            '42',
            '회',
            Icons.directions_run,
            AppColors.secondaryOrange,
          ),
        ),
      ],
    );
  }

  /// 통계 카드 위젯
  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$title ($unit)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 설정 메뉴 위젯
  Widget _buildSettingsMenu() {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: '프로필 편집',
            subtitle: '개인정보 수정',
            onTap: () => _editProfile(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.track_changes,
            title: '목표 설정',
            subtitle: '러닝 목표 관리',
            onTap: () => _setGoals(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
            title: '알림 설정',
            subtitle: '알림 관리',
            onTap: () => _notificationSettings(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.fitness_center,
            title: '건강 앱 연동',
            subtitle: 'HealthKit, Google Fit',
            onTap: () => _healthAppIntegration(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.share,
            title: '데이터 내보내기',
            subtitle: '러닝 데이터 백업',
            onTap: () => _exportData(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
            title: '도움말',
            subtitle: 'FAQ 및 지원',
            onTap: () => _showHelp(),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info,
            title: '앱 정보',
            subtitle: '버전 1.0.0',
            onTap: () => _showAppInfo(),
          ),
        ],
      ),
    );
  }

  /// 메뉴 항목 위젯
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  /// 구분선 위젯
  Widget _buildDivider() {
    return const Divider(height: 1, indent: 72, color: AppColors.textSecondary);
  }

  /// 임시 사용자 프로필 데이터
  UserProfile _getMockUserProfile() {
    return UserProfile(
      id: 'user_001',
      name: '김러너',
      email: 'runner@example.com',
      profileImageUrl: null,
      birthDate: DateTime(1990, 5, 15),
      gender: Gender.male,
      height: 175.0,
      weight: 70.0,
      level: RunningLevel.intermediate,
      weeklyGoal: 25.0,
      weeklyRunGoal: 4,
      targetPace: 5.5,
      preferredTimes: [RunningTime.morning, RunningTime.evening],
      preferredLocations: ['한강공원', '올림픽공원'],
      notifications: const NotificationSettings(
        runningReminders: true,
        goalAchievements: true,
        weeklyReports: true,
        friendActivities: false,
        marketing: false,
        pushNotificationHour: 8,
      ),
      privacy: const PrivacySettings(
        isProfilePublic: true,
        isRunningHistoryPublic: false,
        isLocationPublic: false,
        allowFriendRequests: true,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  /// 레벨 텍스트 반환
  String _getLevelText(RunningLevel level) {
    switch (level) {
      case RunningLevel.beginner:
        return '초보자';
      case RunningLevel.intermediate:
        return '중급자';
      case RunningLevel.advanced:
        return '고급자';
      case RunningLevel.expert:
        return '전문가';
    }
  }

  // 메뉴 액션 메서드들
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 편집'),
        content: const Text('프로필 편집 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _setGoals() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 설정'),
        content: const Text('목표 설정 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _notificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 설정'),
        content: const Text('알림 설정 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _healthAppIntegration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('건강 앱 연동'),
        content: const Text('건강 앱 연동 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 내보내기'),
        content: const Text('데이터 내보내기 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const Text('도움말 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'StrideNote',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.directions_run,
        size: 48,
        color: AppColors.primaryBlue,
      ),
      children: [
        const Text('러닝 트래커 앱'),
        const SizedBox(height: 16),
        const Text('개발: StrideNote Team'),
        const Text('이메일: support@stridenote.com'),
      ],
    );
  }
}
