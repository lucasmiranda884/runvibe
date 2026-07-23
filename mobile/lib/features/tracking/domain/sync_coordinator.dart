import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:runvibe_mobile/features/tracking/data/tracking_repository.dart';

class SyncCoordinator {
  SyncCoordinator(this._repository);
  final TrackingRepository _repository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> start() async {
    await _repository.syncPending();
    _subscription ??= Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      if (results.any((value) => value != ConnectivityResult.none)) {
        await _repository.syncPending();
      }
    });
  }

  Future<void> dispose() async => _subscription?.cancel();
}
