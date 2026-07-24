import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ActivityPhotoStorage {
  ActivityPhotoStorage(this._picker);

  final ImagePicker _picker;

  Future<List<String>> pickAndStore() async {
    final selected = await _picker.pickMultiImage(
      limit: 2,
      imageQuality: 72,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (selected.isEmpty) return const [];
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/runvibe/activity_photos');
    await directory.create(recursive: true);
    final paths = <String>[];
    for (final image in selected.take(2)) {
      final extension = image.path.toLowerCase().endsWith('.png')
          ? 'png'
          : 'jpg';
      final destination = '${directory.path}/${const Uuid().v4()}.$extension';
      await File(image.path).copy(destination);
      paths.add(destination);
    }
    return paths;
  }

  Future<String?> pickProfilePhoto() async {
    final selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (selected == null) return null;
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/runvibe/profile');
    await directory.create(recursive: true);
    final destination = '${directory.path}/profile.jpg';
    await File(selected.path).copy(destination);
    return destination;
  }
}
