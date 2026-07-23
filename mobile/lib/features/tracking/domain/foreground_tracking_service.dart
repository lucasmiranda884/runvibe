import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundTrackingService {
  void initialize() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'runvibe_tracking',
        channelName: 'Corrida em andamento',
        channelDescription:
            'Mantém o registro de localização ativo durante a corrida.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<void> start() async {
    if (!Platform.isAndroid) return;

    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    final ServiceRequestResult result;
    if (await FlutterForegroundTask.isRunningService) {
      result = await FlutterForegroundTask.restartService();
    } else {
      result = await FlutterForegroundTask.startService(
        serviceId: 4407,
        serviceTypes: const [ForegroundServiceTypes.location],
        notificationTitle: 'RunVibe — corrida em andamento',
        notificationText: 'Registrando distância, ritmo e rota por GPS.',
        notificationInitialRoute: '/tracking',
        callback: foregroundTrackingCallback,
      );
    }

    if (result is ServiceRequestFailure) {
      throw StateError('Não foi possível iniciar o serviço de localização.');
    }
  }

  Future<void> stop() async {
    if (Platform.isAndroid && await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

@pragma('vm:entry-point')
void foregroundTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(_TrackingTaskHandler());
}

class _TrackingTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
