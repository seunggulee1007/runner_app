import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../providers/auth_provider.dart';

/// 사용자 프로필 화면
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  // 폼 컨트롤러들
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _selectedBirthDate;
  Gender? _selectedGender;
  FitnessLevel? _selectedFitnessLevel;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  /// 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await UserProfileService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });

      if (profile != null) {
        _displayNameController.text = profile.displayName ?? '';
        _heightController.text = profile.height?.toString() ?? '';
        _weightController.text = profile.weight?.toString() ?? '';
        _selectedBirthDate = profile.birthDate;
        _selectedGender = profile.gender;
        _selectedFitnessLevel = profile.fitnessLevel;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 로드 오류: $e')));
      }
    }
  }

  /// 프로필 저장
  Future<void> _saveProfile() async {
    try {
      if (_displayNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요.')));
        return;
      }

      setState(() => _isLoading = true);

      final updatedProfile = await UserProfileService.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        height: int.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
        fitnessLevel: _selectedFitnessLevel,
      );

      setState(() {
        _userProfile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다.')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필 저장 오류: $e')));
      }
    }
  }

  /// 생년월일 선택
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: const Text('저장'),
            )
          else
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('편집'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? const Center(child: Text('프로필을 찾을 수 없습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 헤더
                  _buildProfileHeader(),
                  const SizedBox(height: 24),

                  // 기본 정보
                  _buildBasicInfo(),
                  const SizedBox(height: 24),

                  // 신체 정보
                  _buildPhysicalInfo(),
                  const SizedBox(height: 24),

                  // 체력 수준
                  _buildFitnessLevel(),
                  const SizedBox(height: 24),

                  // 통계 정보
                  _buildStats(),
                ],
              ),
            ),
    );
  }

  /// 프로필 헤더 위젯
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _userProfile?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile?.displayName ?? '닉네임 없음',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile?.email ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (_userProfile?.age != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_userProfile!.age}세',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기본 정보 위젯
  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기본 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 닉네임
            TextField(
              controller: _displayNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 생년월일
            InkWell(
              onTap: _isEditing ? _selectBirthDate : null,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                      : '생년월일을 선택하세요',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 성별
            DropdownButtonFormField<Gender>(
              value: _selectedGender,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: '성별',
                border: OutlineInputBorder(),
              ),
              items: Gender.values.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender.displayName),
                );
              }).toList(),
              onChanged: _isEditing
                  ? (value) {
                      setState(() => _selectedGender = value);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 신체 정보 위젯
  Widget _buildPhysicalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '신체 정보',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '키 (cm)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '몸무게 (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 체력 수준 위젯
  Widget _buildFitnessLevel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '체력 수준',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<FitnessLevel>(
              value: _selectedFitnessLevel,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: '체력 수준',
                border: OutlineInputBorder(),
              ),
              items: FitnessLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.displayName),
                );
              }).toList(),
              onChanged: _isEditing
                  ? (value) {
                      setState(() => _selectedFitnessLevel = value);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 정보 위젯
  Widget _buildStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_userProfile?.bmi != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('BMI'),
                  Text(
                    _userProfile!.bmi!.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('프로필 완성도'),
                Text(
                  _userProfile?.isComplete == true ? '완료' : '미완료',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _userProfile?.isComplete == true
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
