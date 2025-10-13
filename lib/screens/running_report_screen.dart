import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../models/running_session.dart';

/// 러닝 종료 후 리포트 화면
///
/// 러닝 세션의 상세 통계와 경로를 표시
class RunningReportScreen extends StatelessWidget {
  final RunningSession session;

  const RunningReportScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('러닝 완료'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // 공유 버튼
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 축하 메시지
            _buildCongratulationSection(),

            // 주요 통계 카드
            _buildMainStatsCard(),

            // 지도 (경로 표시)
            _buildRouteMap(),

            // 상세 통계
            _buildDetailedStats(),

            // 페이스 그래프
            _buildPaceChart(),

            // 고도 그래프 (TODO: GPS 데이터에 고도 포함 시)
            // _buildElevationChart(),

            // 하단 버튼
            _buildBottomButtons(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 축하 메시지 섹션
  Widget _buildCongratulationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            '러닝 완료!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formattedDate,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// 주요 통계 카드
  Widget _buildMainStatsCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMainStatItem(
                Icons.straighten,
                '거리',
                '${((session.distance ?? 0) / 1000).toStringAsFixed(2)} km',
              ),
              _buildVerticalDivider(),
              _buildMainStatItem(Icons.timer, '시간', _formattedDuration),
              _buildVerticalDivider(),
              _buildMainStatItem(
                Icons.speed,
                '평균 페이스',
                session.formattedAvgPace,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 주요 통계 아이템
  Widget _buildMainStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 32),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  /// 수직 구분선
  Widget _buildVerticalDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  /// 경로 지도
  Widget _buildRouteMap() {
    final routePoints = session.routePoints;

    if (routePoints.isEmpty) {
      return const SizedBox.shrink();
    }

    // 경로의 중심점 계산
    final totalLat = routePoints.map((p) => p.latitude).reduce((a, b) => a + b);
    final totalLng = routePoints
        .map((p) => p.longitude)
        .reduce((a, b) => a + b);
    final center = LatLng(
      totalLat / routePoints.length,
      totalLng / routePoints.length,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 300,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              // 타일 레이어
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.runner_app',
              ),

              // 경로 폴리라인
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.0,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),

              // 시작/종료 마커
              MarkerLayer(
                markers: [
                  // 시작 마커
                  Marker(
                    point: routePoints.first,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // 종료 마커
                  Marker(
                    point: routePoints.last,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.sports_score,
                        color: Colors.white,
                        size: 20,
                      ),
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

  /// 상세 통계
  Widget _buildDetailedStats() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '상세 통계',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                '평균 속도',
                '${session.avgSpeed?.toStringAsFixed(1) ?? '0.0'} km/h',
              ),
              _buildStatRow(
                '최고 속도',
                '${session.maxSpeed?.toStringAsFixed(1) ?? '0.0'} km/h',
              ),
              _buildStatRow(
                '칼로리',
                '${session.calories?.toStringAsFixed(0) ?? '0'} kcal',
              ),
              if (session.avgHeartRate != null)
                _buildStatRow('평균 심박수', '${session.avgHeartRate} bpm'),
              if (session.elevationGain != null)
                _buildStatRow(
                  '고도 상승',
                  '${session.elevationGain?.toStringAsFixed(0)} m',
                ),
              if (session.elevationLoss != null)
                _buildStatRow(
                  '고도 하강',
                  '${session.elevationLoss?.toStringAsFixed(0)} m',
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 통계 행
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 페이스 그래프
  Widget _buildPaceChart() {
    // GPS 데이터에서 페이스 계산
    final paceData = _calculatePaceData();

    if (paceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '페이스 변화',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}\'',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}km',
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: paceData,
                        isCurved: true,
                        color: AppColors.primaryBlue,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 페이스 데이터 계산 (GPS 포인트 기반)
  List<FlSpot> _calculatePaceData() {
    final gpsData = session.gpsData;
    if (gpsData == null) {
      return [];
    }

    // gpsData['points']가 실제 포인트 리스트
    final points = gpsData['points'] as List<dynamic>?;
    if (points == null || points.isEmpty) {
      return [];
    }

    final List<FlSpot> spots = [];
    double cumulativeDistance = 0;

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1] as Map<String, dynamic>;
      final curr = points[i] as Map<String, dynamic>;

      // 거리 계산 (Haversine formula)
      final distance = _calculateDistance(
        prev['latitude'] as double,
        prev['longitude'] as double,
        curr['latitude'] as double,
        curr['longitude'] as double,
      );

      cumulativeDistance += distance;

      // 시간 차이 (초)
      final prevTimestamp = prev['timestamp'];
      final currTimestamp = curr['timestamp'];

      if (prevTimestamp == null || currTimestamp == null) continue;

      final prevTime = DateTime.parse(prevTimestamp as String);
      final currTime = DateTime.parse(currTimestamp as String);
      final timeDiff = currTime.difference(prevTime).inSeconds;

      if (timeDiff > 0 && distance > 0) {
        // 페이스 계산 (분/km)
        final pace = (timeDiff / 60.0) / (distance / 1000.0);

        // 비정상적인 값 필터링 (0~20분/km 범위)
        if (pace > 0 && pace < 20) {
          spots.add(FlSpot(cumulativeDistance / 1000.0, pace));
        }
      }
    }

    return spots;
  }

  /// 거리 계산 (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // 지구 반지름 (미터)
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// 하단 버튼
  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _shareReport(context),
              icon: const Icon(Icons.share),
              label: const Text('공유하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _goHome(context),
              icon: const Icon(Icons.home),
              label: const Text('홈으로'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 공유하기
  void _shareReport(BuildContext context) {
    final message =
        '''
🏃 러닝 완료!

📍 거리: ${((session.distance ?? 0) / 1000).toStringAsFixed(2)} km
⏱️ 시간: $_formattedDuration
📊 평균 페이스: ${session.formattedAvgPace}
🔥 칼로리: ${session.calories?.toStringAsFixed(0) ?? '0'} kcal

#러닝 #운동 #건강
''';

    Share.share(message);
  }

  /// 홈으로 이동
  void _goHome(BuildContext context) {
    // 모든 화면을 pop하고 홈으로
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 포맷된 날짜
  String get _formattedDate {
    final date = session.createdAt;
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 포맷된 시간
  String get _formattedDuration {
    final duration = session.duration ?? 0;
    final hours = (duration ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((duration % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
