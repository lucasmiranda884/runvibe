import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';

class ActivityRequestDTO {
  const ActivityRequestDTO({
    required this.title,
    required this.description,
    required this.draft,
  });

  final String title;
  final String description;
  final ActivityDraftModel draft;

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'sportType': draft.sportType,
    'shoeId': draft.shoeId,
    'elapsedTimeSeconds': draft.elapsedTimeSeconds,
    'movingTimeSeconds': draft.movingTimeSeconds,
    'points': draft.points.map((point) => point.toJson()).toList(),
  };
}
