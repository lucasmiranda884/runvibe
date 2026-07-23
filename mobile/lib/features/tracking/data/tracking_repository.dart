import 'package:dio/dio.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_local_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_remote_data_source.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_request_dto.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';

class TrackingRepository {
  TrackingRepository(this._local, this._remote);
  final ActivityLocalDataSource _local;
  final ActivityRemoteDataSource _remote;

  Future<bool> saveAndSync(ActivityDraftModel draft) async {
    await _local.save(draft);
    return sync(draft);
  }

  Future<bool> sync(ActivityDraftModel draft) async {
    try {
      await _remote.create(
        ActivityRequestDTO(
          title: 'Corrida ${draft.startTime.toLocal()}',
          description: 'Registrada pelo RunVibe Mobile',
          draft: draft,
        ),
      );
      await _local.delete(draft.localId);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> syncPending() async {
    for (final draft in _local.pending()) {
      await sync(draft);
    }
  }
}
