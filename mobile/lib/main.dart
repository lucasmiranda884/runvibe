import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:runvibe_mobile/app/app.dart';
import 'package:runvibe_mobile/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await Hive.initFlutter();
  await configureDependencies();
  runApp(const RunVibeApp());
}
