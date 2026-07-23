import 'package:hive/hive.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';

class ActivityLocalDataSource {
  static const _boxName = 'activity_drafts';
  late final Box<dynamic> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> save(ActivityDraftModel draft) =>
      _box.put(draft.localId, draft.toJson());
  Future<void> delete(String localId) => _box.delete(localId);

  List<ActivityDraftModel> pending() => _box.values
      .whereType<Map<dynamic, dynamic>>()
      .map(ActivityDraftModel.fromJson)
      .where((draft) => draft.pendingSync)
      .toList(growable: false);
}
