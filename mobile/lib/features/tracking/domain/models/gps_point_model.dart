import 'package:equatable/equatable.dart';

class GPSPointModel extends Equatable {
  const GPSPointModel({
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.speedMs,
    required this.heartRate,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double elevation;
  final double speedMs;
  final int heartRate;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'elevation': elevation,
    'speedMs': speedMs,
    'heartRate': heartRate == 0 ? null : heartRate,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  factory GPSPointModel.fromJson(Map<dynamic, dynamic> json) => GPSPointModel(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
    speedMs: (json['speedMs'] as num?)?.toDouble() ?? 0,
    heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    elevation,
    speedMs,
    heartRate,
    timestamp,
  ];
}
