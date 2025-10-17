import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

/// HealthKit (iOS) 및 Google Fit (Android) 연동을 위한 서비스
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  Health? _health;
  bool _isInitialized = false;
  bool _hasPermissions = false;

  // HealthKit에서 읽을 데이터 타입들
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  /// 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _health = Health();
      _isInitialized = true;

      if (kDebugMode) {
        print('HealthService: 초기화 완료');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: 초기화 실패 - $e');
      }
      return false;
    }
  }

  /// HealthKit/Google Fit 권한 요청
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // 각 데이터 타입에 대해 READ 권한 요청
      final permissions = List.generate(
        _healthDataTypes.length,
        (index) => HealthDataAccess.READ,
      );

      // iOS HealthKit 권한 요청
      if (Platform.isIOS) {
        _hasPermissions = await _health!.requestAuthorization(
          _healthDataTypes,
          permissions: permissions,
        );
      }
      // Android Google Fit 권한 요청
      else if (Platform.isAndroid) {
        _hasPermissions = await _health!.requestAuthorization(
          _healthDataTypes,
          permissions: permissions,
        );
      }

      if (kDebugMode) {
        print('HealthService: 권한 요청 결과 - $_hasPermissions');
      }

      return _hasPermissions;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: 권한 요청 실패 - $e');
      }
      return false;
    }
  }

  /// 권한 상태 확인
  Future<bool> checkPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_health == null) {
        _hasPermissions = false;
        return false;
      }

      for (final dataType in _healthDataTypes) {
        final hasAccess = await _health!.hasPermissions([dataType]);
        if (hasAccess == false) {
          _hasPermissions = false;
          return false;
        }
      }
      _hasPermissions = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: 권한 확인 실패 - $e');
      }
      return false;
    }
  }

  /// 특정 시간 범위의 심박수 데이터 가져오기
  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!_hasPermissions) {
      throw Exception('HealthKit/Google Fit 권한이 없습니다.');
    }

    try {
      final heartRateData = await _health!.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.HEART_RATE],
      );

      if (kDebugMode) {
        print('HealthService: 심박수 데이터 ${heartRateData.length}개 수집');
      }

      return heartRateData;
    } catch (e) {
      if (kDebugMode) {
        print('HealthService: 심박수 데이터 수집 실패 - $e');
      }
      rethrow;
    }
  }

  /// 러닝 세션 중 심박수 데이터 실시간 수집
  Stream<List<HealthDataPoint>> getHeartRateStream({
    required DateTime startTime,
  }) async* {
    if (!_hasPermissions) {
      throw Exception('HealthKit/Google Fit 권한이 없습니다.');
    }

    // 5초마다 새로운 심박수 데이터 확인
    await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
      try {
        final endTime = DateTime.now();
        final heartRateData = await getHeartRateData(
          startTime: startTime,
          endTime: endTime,
        );

        // 새로운 데이터만 필터링 (이전에 수집한 데이터 제외)
        // TODO: 이전 데이터와 비교하여 새로운 데이터만 반환하는 로직 구현

        yield heartRateData;
      } catch (e) {
        if (kDebugMode) {
          print('HealthService: 실시간 심박수 수집 오류 - $e');
        }
      }
    }
  }

  /// 평균 심박수 계산
  double calculateAverageHeartRate(List<HealthDataPoint> heartRateData) {
    if (heartRateData.isEmpty) return 0.0;

    double totalHeartRate = 0.0;
    int validDataCount = 0;

    for (final dataPoint in heartRateData) {
      if (dataPoint.value is NumericHealthValue) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        if (value > 0) {
          totalHeartRate += value;
          validDataCount++;
        }
      }
    }

    return validDataCount > 0 ? totalHeartRate / validDataCount : 0.0;
  }

  /// 심박수 존 분석 (연령 기반)
  Map<String, dynamic> analyzeHeartRateZones({
    required double averageHeartRate,
    required int age,
  }) {
    // 최대 심박수 계산 (220 - 연령)
    final maxHeartRate = 220 - age;

    // 심박수 존 정의
    final zones = {
      'recovery': maxHeartRate * 0.5, // 50% 이하
      'aerobic': maxHeartRate * 0.7, // 50-70%
      'threshold': maxHeartRate * 0.8, // 70-80%
      'anaerobic': maxHeartRate * 0.9, // 80-90%
      'neuromuscular': maxHeartRate, // 90% 이상
    };

    // 현재 평균 심박수가 어느 존에 속하는지 판단
    String currentZone = 'recovery';
    if (averageHeartRate >= zones['neuromuscular']!) {
      currentZone = 'neuromuscular';
    } else if (averageHeartRate >= zones['anaerobic']!) {
      currentZone = 'anaerobic';
    } else if (averageHeartRate >= zones['threshold']!) {
      currentZone = 'threshold';
    } else if (averageHeartRate >= zones['aerobic']!) {
      currentZone = 'aerobic';
    }

    return {
      'currentZone': currentZone,
      'averageHeartRate': averageHeartRate,
      'maxHeartRate': maxHeartRate,
      ...zones,
    };
  }

  /// 서비스 상태 확인
  bool get isInitialized => _isInitialized;
  bool get hasPermissions => _hasPermissions;

  /// 지원되는 플랫폼인지 확인
  bool get isSupported {
    return Platform.isIOS || Platform.isAndroid;
  }
}
