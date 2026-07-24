import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:runvibe_mobile/features/tracking/presentation/bloc/tracking_bloc.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  MapLibreMapController? _mapController;
  Line? _routeLine;
  bool _styleReady = false;
  bool _darkMap = true;
  TrackingMetricsState? _latestMetrics;

  String get _style => _darkMap
      ? 'https://tiles.openfreemap.org/styles/dark'
      : 'https://tiles.openfreemap.org/styles/liberty';

  Future<void> _updateMap(TrackingMetricsState state) async {
    _latestMetrics = state;
    final controller = _mapController;
    if (!_styleReady || controller == null || state.points.isEmpty) return;
    final points = state.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    if (points.length >= 2) {
      final options = LineOptions(
        geometry: points,
        lineColor: '#B7F34A',
        lineWidth: 6,
        lineOpacity: .95,
        lineJoin: 'round',
      );
      if (_routeLine == null) {
        _routeLine = await controller.addLine(options);
      } else {
        await controller.updateLine(_routeLine!, options);
      }
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: points.last, zoom: 17.2, tilt: 58, bearing: 20),
      ),
    );
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    _routeLine = null;
    final metrics = _latestMetrics;
    if (metrics != null) await _updateMap(metrics);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          if (state is TrackingMetricsState) _updateMap(state);
          if (state is TrackingCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.synced
                      ? 'Corrida sincronizada!'
                      : 'Salva offline. Sincronizaremos quando a internet voltar.',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final metrics = state is TrackingMetricsState ? state : null;
          return Stack(
            children: [
              MapLibreMap(
                key: ValueKey(_style),
                styleString: _style,
                onMapCreated: (controller) => _mapController = controller,
                onStyleLoadedCallback: _onStyleLoaded,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-14.235, -51.9253),
                  zoom: 3.8,
                ),
                compassEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.none,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _MetricsCard(metrics: metrics)),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            tooltip: _darkMap ? 'Mapa claro' : 'Mapa escuro',
                            onPressed: () => setState(() {
                              _styleReady = false;
                              _routeLine = null;
                              _darkMap = !_darkMap;
                            }),
                            icon: Icon(
                              _darkMap
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (state is TrackingInitial && state.error != null)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(state.error!),
                          ),
                        ),
                      _Controls(state: state),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.metrics});
  final TrackingMetricsState? metrics;

  @override
  Widget build(BuildContext context) {
    final elapsed = metrics?.elapsedSeconds ?? 0;
    final pace = metrics?.averagePaceSecondsPerKm ?? 0;
    return Card(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            _Metric(label: 'TEMPO', value: _clock(elapsed)),
            _Metric(
              label: 'DISTÂNCIA',
              value:
                  '${((metrics?.distanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
            ),
            _Metric(
              label: 'RITMO',
              value: pace == 0 ? '--:--' : '${_clock(pace)}/km',
            ),
          ],
        ),
      ),
    );
  }

  static String _clock(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        FittedBox(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});
  final TrackingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TrackingBloc>();
    if (state is TrackingInitial || state is TrackingCompleted) {
      return FloatingActionButton.large(
        heroTag: 'start-run',
        onPressed: () {
          HapticFeedback.heavyImpact();
          bloc.add(const TrackingStarted());
        },
        child: const Icon(Icons.play_arrow_rounded, size: 44),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'pause-run',
          onPressed: () {
            HapticFeedback.mediumImpact();
            bloc.add(
              state is TrackingPaused
                  ? const TrackingResumed()
                  : const TrackingPausedRequested(),
            );
          },
          child: Icon(state is TrackingPaused ? Icons.play_arrow : Icons.pause),
        ),
        const SizedBox(width: 24),
        FloatingActionButton(
          heroTag: 'finish-run',
          backgroundColor: Theme.of(context).colorScheme.error,
          onPressed: () {
            if (state is TrackingMetricsState &&
                (state as TrackingMetricsState).points.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Aguarde o GPS registrar pelo menos dois pontos.',
                  ),
                ),
              );
              return;
            }
            HapticFeedback.heavyImpact();
            bloc.add(const TrackingFinished());
          },
          child: const Icon(Icons.stop_rounded),
        ),
      ],
    );
  }
}
