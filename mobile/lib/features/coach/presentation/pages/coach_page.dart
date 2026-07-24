import 'package:flutter/material.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  String _goal = '5 km';
  int _days = 3;
  int _weeks = 8;
  List<_Workout> _plan = const [];

  void _generatePlan() {
    final longRun = switch (_goal) {
      '10 km' => 8,
      '21 km' => 14,
      '42 km' => 22,
      _ => 5,
    };
    final workouts = <_Workout>[
      const _Workout(
        'Corrida leve',
        '30–40 min em ritmo confortável',
        Icons.self_improvement_rounded,
      ),
      const _Workout(
        'Intervalado',
        '6 × 400 m forte, 2 min de recuperação',
        Icons.speed_rounded,
      ),
      _Workout('Longão', '$longRun km em ritmo fácil', Icons.route_rounded),
    ];
    if (_days >= 4) {
      workouts.insert(
        1,
        const _Workout(
          'Força e mobilidade',
          '25 min: core, panturrilha, glúteos e mobilidade',
          Icons.fitness_center_rounded,
        ),
      );
    }
    if (_days >= 5) {
      workouts.add(
        const _Workout('Regenerativo', '25 min muito leve', Icons.eco_rounded),
      );
    }
    setState(() => _plan = workouts);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Treinador inteligente',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Plano adaptativo gratuito. Ele usa seu objetivo agora e, nas '
            'próximas versões, também considerará seu histórico completo.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _goal,
                    decoration: const InputDecoration(
                      labelText: 'Objetivo',
                      prefixIcon: Icon(Icons.flag_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const ['5 km', '10 km', '21 km', '42 km']
                        .map(
                          (goal) =>
                              DropdownMenuItem(value: goal, child: Text(goal)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _goal = value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Text('$_days dias por semana')),
                      Slider(
                        value: _days.toDouble(),
                        min: 2,
                        max: 6,
                        divisions: 4,
                        label: '$_days',
                        onChanged: (value) =>
                            setState(() => _days = value.round()),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('$_weeks semanas')),
                      Slider(
                        value: _weeks.toDouble(),
                        min: 4,
                        max: 20,
                        divisions: 8,
                        label: '$_weeks',
                        onChanged: (value) =>
                            setState(() => _weeks = value.round()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _generatePlan,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Criar meu plano'),
                  ),
                ],
              ),
            ),
          ),
          if (_plan.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Sua primeira semana',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _plan.length; index++) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(_plan[index].icon)),
                  title: Text(
                    'Dia ${index + 1} · ${_plan[index].title}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(_plan[index].description),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Text(
              'Recomendação esportiva, não médica. Interrompa o treino em caso '
              'de dor, tontura ou mal-estar.',
            ),
          ],
        ],
      ),
    );
  }
}

class _Workout {
  const _Workout(this.title, this.description, this.icon);
  final String title;
  final String description;
  final IconData icon;
}
