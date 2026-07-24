import 'dart:async';
import 'dart:io';

import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:runvibe_mobile/features/tracking/domain/foreground_tracking_service.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';

class LocationPermissionException implements Exception {
  const LocationPermissionException(this.message);
  final String message;
}

class LocationService {
  LocationService(this._location, this._foregroundService);

  final Location _location;
  final ForegroundTrackingService _foregroundService;

  Future<void> ensurePermissions() async {
    var enabled = await _location.serviceEnabled();
    if (!enabled) {
      enabled = await _location.requestService();
    }
    if (!enabled) {
      throw const LocationPermissionException(
        'Ative o GPS para iniciar a corrida.',
      );
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.grantedLimited) {
      throw const LocationPermissionException(
        'Permita localização sempre nas configurações do aparelho.',
      );
    }

    await _location.changeSettings(
      accuracy: LocationAccuracy.navigation,
      interval: 1000,
      distanceFilter: 3,
    );
    // Android 10+ exige que a permissão em primeiro plano seja concedida antes
    // da permissão "o tempo todo". A corrida não deve ser bloqueada caso o
    // usuário escolha conceder a permissão de fundo depois.
    if (Platform.isAndroid) {
      final alwaysStatus = await permissions.Permission.locationAlways.status;
      if (!alwaysStatus.isGranted) {
        await permissions.Permission.locationAlways.request();
      }
    }

    await _foregroundService.start();
    try {
      await _location.enableBackgroundMode(enable: true);
    } catch (_) {
      // O rastreamento em primeiro plano continua funcionando. A tela de
      // configurações orienta o usuário a liberar "o tempo todo".
    }
  }

  Stream<GPSPointModel> get points => _location.onLocationChanged.map(
    (data) => GPSPointModel(
      latitude: data.latitude,
      longitude: data.longitude,
      elevation: data.altitude ?? 0,
      speedMs: (data.speed ?? 0).clamp(0, double.infinity).toDouble(),
      heartRate: 0,
      timestamp: data.time == null
          ? DateTime.now().toUtc()
          : DateTime.fromMillisecondsSinceEpoch(
              data.time!.round(),
              isUtc: true,
            ),
    ),
  );

  Future<void> stopBackgroundMode() async {
    await _location.enableBackgroundMode(enable: false);
    await _foregroundService.stop();
  }
}
