import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

/// 사용자 프로필 서비스 클래스
class UserProfileService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  /// 현재 사용자의 프로필 가져오기
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('사용자 프로필 가져오기 오류: $e');
      return null;
    }
  }

  /// 사용자 프로필 생성
  static Future<UserProfile?> createUserProfile({
    required String email,
    String? displayName,
    String? avatarUrl,
    DateTime? birthDate,
    Gender? gender,
    int? height,
    double? weight,
    FitnessLevel? fitnessLevel,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('사용자가 로그인되지 않았습니다.');

      final profileData = {
        'id': user.id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'birth_date': birthDate?.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD 형식
        'gender': gender?.name,
        'height': height,
        'weight': weight,
        'fitness_level': fitnessLevel?.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('user_profiles')
          .insert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('사용자 프로필 생성 오류: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 업데이트
  static Future<UserProfile?> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    DateTime? birthDate,
    Gender? gender,
    int? height,
    double? weight,
    FitnessLevel? fitnessLevel,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('사용자가 로그인되지 않았습니다.');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updateData['display_name'] = displayName;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (birthDate != null)
        updateData['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (gender != null) updateData['gender'] = gender.name;
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (fitnessLevel != null) updateData['fitness_level'] = fitnessLevel.name;

      final response = await _supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('사용자 프로필 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 사용자 프로필 삭제
  static Future<bool> deleteUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('사용자가 로그인되지 않았습니다.');

      await _supabase.from('user_profiles').delete().eq('id', user.id);

      return true;
    } catch (e) {
      print('사용자 프로필 삭제 오류: $e');
      return false;
    }
  }

  /// Google 로그인 후 프로필 자동 생성
  static Future<UserProfile?> createProfileFromGoogleAuth({
    required String email,
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      // 기존 프로필이 있는지 확인
      final existingProfile = await getCurrentUserProfile();
      if (existingProfile != null) {
        print('기존 프로필이 존재합니다: ${existingProfile.email}');
        return existingProfile;
      }

      // 새 프로필 생성
      print('Google 로그인으로 새 프로필 생성: $email');
      return await createUserProfile(
        email: email,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      print('Google 로그인 프로필 생성 오류: $e');
      rethrow;
    }
  }

  /// 프로필 완성도 확인
  static Future<bool> isProfileComplete() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isComplete ?? false;
    } catch (e) {
      print('프로필 완성도 확인 오류: $e');
      return false;
    }
  }
}
