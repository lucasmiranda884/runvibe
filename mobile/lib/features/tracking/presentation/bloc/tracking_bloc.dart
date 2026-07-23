import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:runvibe_mobile/features/tracking/data/tracking_repository.dart';
import 'package:runvibe_mobile/features/tracking/domain/haversine.dart';
import 'package:runvibe_mobile/features/tracking/domain/location_service.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/activity_draft_model.dart';
import 'package:runvibe_mobile/features/tracking/domain/models/gps_point_model.dart';
import 'package:uuid/uuid.dart';

sealed class TrackingEvent extends Equatable {
  const TrackingEvent();
  @override
  List<Object?> get props => [];
}

final class TrackingStarted extends TrackingEvent {
  const TrackingStarted({this.shoeId});
  final String? shoeId;
}

final class TrackingPausedRequested extends TrackingEvent {
  const TrackingPausedRequested();
}

final class TrackingResumed extends TrackingEvent {
  const TrackingResumed();
}

final class TrackingFinished extends TrackingEvent {
  const TrackingFinished();
}

final class _PointReceived extends TrackingEvent {
  const _PointReceived(this.point);
  final GPSPointModel point;
}

final class _SecondElapsed extends TrackingEvent {
  const _SecondElapsed();
}

sealed class TrackingState extends Equatable {
  const TrackingState();
  @override
  List<Object?> get props => [];
}

final class TrackingInitial extends TrackingState {
  const TrackingInitial({this.error});
  final String? error;
  @override
  List<Object?> get props => [error];
}

abstract class TrackingMetricsState extends TrackingState {
  const TrackingMetricsState({
    required this.elapsedSeconds,
    required this.movingSeconds,
    required this.distanceMeters,
    required this.points,
    required this.averagePaceSecondsPerKm,
  });
  final int elapsedSeconds;
  final int movingSeconds;
  final double distanceMeters;
  final List<GPSPointModel> points;
  final int averagePaceSecondsPerKm;
  int get instantPaceSecondsPerKm {
    if (points.isEmpty || points.last.speedMs < .5) return 0;
    return (1000 / points.last.speedMs).round();
  }

  @override
  List<Object?> get props => [
    elapsedSeconds,
    movingSeconds,
    distanceMeters,
    points,
    averagePaceSecondsPerKm,
  ];
}

final class TrackingInProgress extends TrackingMetricsState {
  const TrackingInProgress({
    required super.elapsedSeconds,
    required super.movingSeconds,
    required super.distanceMeters,
    required super.points,
    required super.averagePaceSecondsPerKm,
  });
}

final class TrackingPaused extends TrackingMetricsState {
  const TrackingPaused({
    required super.elapsedSeconds,
    required super.movingSeconds,
    required super.distanceMeters,
    required super.points,
    required super.averagePaceSecondsPerKm,
  });
}

final class TrackingCompleted extends TrackingMetricsState {
  const TrackingCompleted({
    required super.elapsedSeconds,
    required super.movingSeconds,
    required super.distanceMeters,
    required super.points,
    required super.averagePaceSecondsPerKm,
    required this.synced,
  });
  final bool synced;
  @override
  List<Object?> get props => [...super.props, synced];
}

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc(this._location, this._repository)
    : super(const TrackingInitial()) {
    on<TrackingStarted>(_start);
    on<TrackingPausedRequested>(_pause);
    on<TrackingResumed>(_resume);
    on<TrackingFinished>(_finish);
    on<_PointReceived>(_point);
    on<_SecondElapsed>(_tick);
  }

  final LocationService _location;
  final TrackingRepository _repository;
  StreamSubscription<GPSPointModel>? _gpsSubscription;
  Timer? _timer;
  DateTime? _startTime;
  String? _shoeId;
  int _elapsed = 0;
  int _moving = 0;
  double _distance = 0;
  final List<GPSPointModel> _points = [];

  Future<void> _start(
    TrackingStarted event,
    Emitter<TrackingState> emit,
  ) async {
    try {
      await _location.ensurePermissions();
      _timer?.cancel();
      await _gpsSubscription?.cancel();
      _elapsed = 0;
      _moving = 0;
      _distance = 0;
      _points.clear();
      _startTime = DateTime.now().toUtc();
      _shoeId = event.shoeId;
      _startStreams();
      emit(_inProgress());
    } on LocationPermissionException catch (error) {
      emit(TrackingInitial(error: error.message));
    }
  }

  Future<void> _pause(
    TrackingPausedRequested event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingInProgress) return;
    await _gpsSubscription?.cancel();
    emit(
      TrackingPaused(
        elapsedSeconds: _elapsed,
        movingSeconds: _moving,
        distanceMeters: _distance,
        points: List.unmodifiable(_points),
        averagePaceSecondsPerKm: _pace,
      ),
    );
  }

  Future<void> _resume(
    TrackingResumed event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingPaused) return;
    _startGpsStream();
    emit(_inProgress());
  }

  Future<void> _finish(
    TrackingFinished event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingMetricsState || _points.length < 2) return;
    _timer?.cancel();
    await _gpsSubscription?.cancel();
    await _location.stopBackgroundMode();
    final draft = ActivityDraftModel(
      localId: const Uuid().v4(),
      startTime: _startTime!,
      elapsedTimeSeconds: _elapsed,
      movingTimeSeconds: _moving,
      totalDistanceMeters: _distance,
      points: List.unmodifiable(_points),
      shoeId: _shoeId,
    );
    final synced = await _repository.saveAndSync(draft);
    emit(
      TrackingCompleted(
        elapsedSeconds: _elapsed,
        movingSeconds: _moving,
        distanceMeters: _distance,
        points: List.unmodifiable(_points),
        averagePaceSecondsPerKm: _pace,
        synced: synced,
      ),
    );
  }

  void _point(_PointReceived event, Emitter<TrackingState> emit) {
    if (state is! TrackingInProgress) return;
    if (_points.isNotEmpty) {
      final increment = Haversine.distance(_points.last, event.point);
      if (increment <= 100) _distance += increment;
    }
    _points.add(event.point);
    emit(_inProgress());
  }

  void _tick(_SecondElapsed event, Emitter<TrackingState> emit) {
    if (state is! TrackingMetricsState || state is TrackingCompleted) return;
    _elapsed++;
    if (state is TrackingInProgress) {
      _moving++;
      emit(_inProgress());
    } else {
      emit(
        TrackingPaused(
          elapsedSeconds: _elapsed,
          movingSeconds: _moving,
          distanceMeters: _distance,
          points: List.unmodifiable(_points),
          averagePaceSecondsPerKm: _pace,
        ),
      );
    }
  }

  void _startStreams() {
    _startGpsStream();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _SecondElapsed()),
    );
  }

  void _startGpsStream() {
    _gpsSubscription = _location.points.listen(
      (point) => add(_PointReceived(point)),
    );
  }

  int get _pace => _distance <= 0 ? 0 : (_moving / (_distance / 1000)).round();
  TrackingInProgress _inProgress() => TrackingInProgress(
    elapsedSeconds: _elapsed,
    movingSeconds: _moving,
    distanceMeters: _distance,
    points: List.unmodifiable(_points),
    averagePaceSecondsPerKm: _pace,
  );

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _gpsSubscription?.cancel();
    return super.close();
  }
}
