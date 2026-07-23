import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:runvibe_mobile/features/tracking/presentation/bloc/tracking_bloc.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});
  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          if (state is TrackingInProgress && state.points.isNotEmpty) {
            final last = state.points.last;
            _mapController.move(LatLng(last.latitude, last.longitude), 17);
          }
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
          final route =
              metrics?.points
                  .map((p) => LatLng(p.latitude, p.longitude))
                  .toList() ??
              const <LatLng>[];
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(-23.5505, -46.6333),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.runvibe.mobile',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        strokeWidth: 6,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  if (route.isNotEmpty)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: route.last,
                          width: 32,
                          height: 32,
                          child: const Icon(Icons.my_location, size: 28),
                        ),
                      ],
                    ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _MetricsCard(metrics: metrics),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 12,
          children: [
            _Metric(label: 'TEMPO', value: _clock(elapsed)),
            _Metric(
              label: 'DISTÂNCIA',
              value:
                  '${((metrics?.distanceMeters ?? 0) / 1000).toStringAsFixed(2)} km',
            ),
            _Metric(
              label: 'RITMO MÉDIO',
              value: pace == 0 ? '--:--' : '${_clock(pace)} /km',
            ),
            _Metric(
              label: 'AGORA',
              value: (metrics?.instantPaceSecondsPerKm ?? 0) == 0
                  ? '--:--'
                  : '${_clock(metrics!.instantPaceSecondsPerKm)} /km',
            ),
          ],
        ),
      ),
    );
  }

  String _clock(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 78,
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
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
          backgroundColor: Theme.of(context).colorScheme.error,
          onPressed: () {
            HapticFeedback.heavyImpact();
            bloc.add(const TrackingFinished());
          },
          child: const Icon(Icons.stop_rounded),
        ),
      ],
    );
  }
}
