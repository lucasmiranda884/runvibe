import 'package:flutter_test/flutter_test.dart';
import 'package:runvibe_mobile/features/tracking/domain/haversine.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';

void main() {
  test('calcula aproximadamente um quilômetro', () {
    final time = DateTime.utc(2026);
    final first = GPSPointModel(
      latitude: 0,
      longitude: 0,
      elevation: 0,
      speedMs: 0,
      heartRate: 0,
      timestamp: time,
    );
    final second = GPSPointModel(
      latitude: 0,
      longitude: .009,
      elevation: 0,
      speedMs: 0,
      heartRate: 0,
      timestamp: time,
    );
    expect(Haversine.distance(first, second), inInclusiveRange(999, 1002));
  });
}
