import 'package:flutter_test/flutter_test.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_request_dto.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';

void main() {
  final firstPoint = GPSPointModel(
    latitude: -23.5505,
    longitude: -46.6333,
    elevation: 760,
    speedMs: 2.8,
    heartRate: 148,
    timestamp: DateTime.utc(2026, 7, 23, 22),
  );
  final secondPoint = GPSPointModel(
    latitude: -23.551,
    longitude: -46.634,
    elevation: 762,
    speedMs: 3.1,
    heartRate: 151,
    timestamp: DateTime.utc(2026, 7, 23, 22, 0, 5),
  );

  test('rascunho offline preserva os dados ao serializar', () {
    final draft = ActivityDraftModel(
      localId: 'local-run-1',
      startTime: DateTime.utc(2026, 7, 23, 22),
      elapsedTimeSeconds: 320,
      movingTimeSeconds: 300,
      totalDistanceMeters: 1000,
      points: [firstPoint, secondPoint],
      shoeId: 'shoe-1',
    );

    expect(ActivityDraftModel.fromJson(draft.toJson()), draft);
  });

  test('payload em lote contém tempos, tênis e pontos GPS', () {
    final draft = ActivityDraftModel(
      localId: 'local-run-2',
      startTime: DateTime.utc(2026, 7, 23, 22),
      elapsedTimeSeconds: 320,
      movingTimeSeconds: 300,
      totalDistanceMeters: 1000,
      points: [firstPoint, secondPoint],
      shoeId: 'shoe-1',
    );

    final json = ActivityRequestDTO(
      title: 'Corrida noturna',
      description: 'Teste',
      draft: draft,
    ).toJson();

    expect(json['elapsedTimeSeconds'], 320);
    expect(json['movingTimeSeconds'], 300);
    expect(json['shoeId'], 'shoe-1');
    expect(json['points'], hasLength(2));
  });
}
