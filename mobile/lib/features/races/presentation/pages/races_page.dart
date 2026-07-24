import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RacesPage extends StatefulWidget {
  const RacesPage({super.key});

  @override
  State<RacesPage> createState() => _RacesPageState();
}

class _RacesPageState extends State<RacesPage> {
  String _state = 'Todos';

  static final _races = <_Race>[
    _Race(
      'SP City Marathon',
      DateTime(2026, 7, 26),
      'São Paulo, SP',
      '21 km · 42 km',
      'https://www.iguanasports.com.br',
    ),
    _Race(
      'Live! 42k Brasília',
      DateTime(2026, 8, 2),
      'Brasília, DF',
      '42 km',
      'https://www.live.com.br/etapa/live42k-brasilia',
    ),
    _Race(
      'Maratona Internacional de João Pessoa',
      DateTime(2026, 8, 2),
      'João Pessoa, PB',
      '42 km',
      'https://www.race83.com.br',
    ),
    _Race(
      '28ª Meia Maratona Internacional do Rio',
      DateTime(2026, 8, 16),
      'Rio de Janeiro, RJ',
      '5 km · 21 km',
      'https://www.meiamaratonadoriodejaneiro.com.br',
    ),
    _Race(
      'Meia Maratona do Sol Sicredi',
      DateTime(2026, 9, 20),
      'Natal, RN',
      '21 km',
      'https://meiadosol.com.br',
    ),
    _Race(
      'Maratona de Salvador',
      DateTime(2026, 9, 27),
      'Salvador, BA',
      '42 km',
      'https://www.ticketsports.com.br/e/maratona-salvador-2026-74554',
    ),
    _Race(
      '101ª São Silvestre',
      DateTime(2026, 12, 31),
      'São Paulo, SP',
      '15 km',
      'https://www.saosilvestre.com.br',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _state == 'Todos'
        ? _races
        : _races.where((race) => race.place.endsWith(_state)).toList();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Corridas no Brasil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Provas com Permit CBAt e inscrição no organizador.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Todos', 'SP', 'RJ', 'DF', 'PB', 'RN', 'BA']
                          .map(
                            (state) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(state),
                                selected: _state == state,
                                onSelected: (_) =>
                                    setState(() => _state = state),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final race = visible[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${race.date.day}',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(_month(race.date.month)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                race.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text('${race.place} · ${race.distance}'),
                              const SizedBox(height: 8),
                              FilledButton.tonal(
                                onPressed: () => launchUrl(
                                  Uri.parse(race.url),
                                  mode: LaunchMode.externalApplication,
                                ),
                                child: const Text('Inscrever-se'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _month(int month) => const [
    '',
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ][month];
}

class _Race {
  const _Race(this.name, this.date, this.place, this.distance, this.url);
  final String name;
  final DateTime date;
  final String place;
  final String distance;
  final String url;
}
