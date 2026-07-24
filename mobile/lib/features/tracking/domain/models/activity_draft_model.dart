import 'package:equatable/equatable.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';

class ActivityDraftModel extends Equatable {
  const ActivityDraftModel({
    required this.localId,
    required this.startTime,
    required this.elapsedTimeSeconds,
    required this.movingTimeSeconds,
    required this.totalDistanceMeters,
    required this.points,
    this.sportType = 'RUNNING',
    this.photoPaths = const [],
    this.shoeId,
    this.pendingSync = true,
  });

  final String localId;
  final DateTime startTime;
  final int elapsedTimeSeconds;
  final int movingTimeSeconds;
  final double totalDistanceMeters;
  final List<GPSPointModel> points;
  final String sportType;
  final List<String> photoPaths;
  final String? shoeId;
  final bool pendingSync;

  Map<String, dynamic> toJson() => {
    'localId': localId,
    'startTime': startTime.toUtc().toIso8601String(),
    'elapsedTimeSeconds': elapsedTimeSeconds,
    'movingTimeSeconds': movingTimeSeconds,
    'totalDistanceMeters': totalDistanceMeters,
    'points': points.map((point) => point.toJson()).toList(),
    'sportType': sportType,
    'photoPaths': photoPaths.take(2).toList(growable: false),
    'shoeId': shoeId,
    'pendingSync': pendingSync,
  };

  factory ActivityDraftModel.fromJson(Map<dynamic, dynamic> json) =>
      ActivityDraftModel(
        localId: json['localId'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        elapsedTimeSeconds: json['elapsedTimeSeconds'] as int,
        movingTimeSeconds: json['movingTimeSeconds'] as int,
        totalDistanceMeters: (json['totalDistanceMeters'] as num).toDouble(),
        points: (json['points'] as List)
            .map(
              (item) => GPSPointModel.fromJson(item as Map<dynamic, dynamic>),
            )
            .toList(growable: false),
        sportType: json['sportType'] as String? ?? 'RUNNING',
        photoPaths:
            (json['photoPaths'] as List?)
                ?.whereType<String>()
                .take(2)
                .toList(growable: false) ??
            const [],
        shoeId: json['shoeId'] as String?,
        pendingSync: json['pendingSync'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [
    localId,
    startTime,
    elapsedTimeSeconds,
    movingTimeSeconds,
    totalDistanceMeters,
    points,
    sportType,
    photoPaths,
    shoeId,
    pendingSync,
  ];
}
