import 'dart:math' as math;
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';

abstract final class Haversine {
  static const _earthRadiusMeters = 6371008.8;

  static double distance(GPSPointModel first, GPSPointModel second) {
    final latDistance = _radians(second.latitude - first.latitude);
    final lonDistance = _radians(second.longitude - first.longitude);
    final a =
        math.sin(latDistance / 2) * math.sin(latDistance / 2) +
        math.cos(_radians(first.latitude)) *
            math.cos(_radians(second.latitude)) *
            math.sin(lonDistance / 2) *
            math.sin(lonDistance / 2);
    return _earthRadiusMeters * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
