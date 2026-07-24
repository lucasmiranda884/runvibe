import 'package:dio/dio.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_local_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_remote_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_request_dto.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';

class TrackingRepository {
  TrackingRepository(this._local, this._remote);
  final ActivityLocalDataSource _local;
  final ActivityRemoteDataSource _remote;
  bool _syncing = false;

  Future<bool> saveAndSync(ActivityDraftModel draft) async {
    await _local.save(draft);
    return sync(draft);
  }

  Future<bool> sync(ActivityDraftModel draft) async {
    try {
      await _remote.create(
        ActivityRequestDTO(
          title: '${_sportName(draft.sportType)} ${draft.startTime.toLocal()}',
          description: 'Registrada pelo RunVibe Mobile',
          draft: draft,
        ),
      );
      await _local.markSynced(draft);
      return true;
    } on DioException {
      return false;
    }
  }

  String _sportName(String type) => switch (type) {
    'CYCLING' => 'Pedalada',
    'WALKING' => 'Caminhada',
    'HIKING' => 'Trilha',
    _ => 'Corrida',
  };

  Future<void> syncPending() async {
    if (_syncing) return;
    _syncing = true;
    try {
      for (final draft in _local.pending()) {
        await sync(draft);
      }
    } finally {
      _syncing = false;
    }
  }
}
