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
  double _weeklyKm = 10;
  String _level = 'Iniciante';
  String _preferredWorkout = 'Variado';
  List<_Workout> _plan = const [];

  void _generatePlan() {
    final targetLongRun = switch (_goal) {
      '10 km' => 10.0,
      '21 km' => 18.0,
      '42 km' => 30.0,
      _ => 6.0,
    };
    final safeLongRun = (_weeklyKm * 0.45).clamp(4, targetLongRun);
    final repetitions = _level == 'Iniciante'
        ? 6
        : _level == 'Intermediário'
        ? 8
        : 10;
    final hardSeconds = _level == 'Iniciante' ? 45 : 60;
    final workouts = <_Workout>[
      _Workout(
        'Corrida leve',
        '${(_weeklyKm / _days).clamp(3, 8).toStringAsFixed(1)} km em ritmo confortável',
        Icons.self_improvement_rounded,
      ),
      if (_preferredWorkout == 'Variado' || _preferredWorkout == 'Tiros')
        _Workout(
          'Treino de tiros',
          '$repetitions × $hardSeconds s forte, com 90 s trotando',
          Icons.speed_rounded,
        ),
      if (_preferredWorkout == 'Variado' || _preferredWorkout == 'Intervalado')
        const _Workout(
          'Intervalado progressivo',
          '10 min leve + 4 × (3 min moderado / 2 min leve) + 8 min leve',
          Icons.timer_rounded,
        ),
      if (_preferredWorkout == 'Variado' || _preferredWorkout == 'Fartlek')
        const _Workout(
          'Fartlek',
          '10 min leve + 8 × (1 min rápido / 1 min livre) + 10 min leve',
          Icons.multiline_chart_rounded,
        ),
      _Workout(
        'Longão',
        '${safeLongRun.toStringAsFixed(1)} km em ritmo fácil',
        Icons.route_rounded,
      ),
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
            'Plano ajustado ao seu objetivo, nível e volume atual. A carga '
            'aumenta de forma conservadora para facilitar os testes práticos.',
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
                  DropdownButtonFormField<String>(
                    initialValue: _level,
                    decoration: const InputDecoration(
                      labelText: 'Nível atual',
                      prefixIcon: Icon(Icons.trending_up_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Iniciante', 'Intermediário', 'Avançado']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _level = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _preferredWorkout,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de treino',
                      prefixIcon: Icon(Icons.tune_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Variado', 'Tiros', 'Intervalado', 'Fartlek']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _preferredWorkout = value!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_weeklyKm.toStringAsFixed(0)} km por semana atualmente',
                        ),
                      ),
                      Slider(
                        value: _weeklyKm,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: '${_weeklyKm.round()} km',
                        onChanged: (value) => setState(() => _weeklyKm = value),
                      ),
                    ],
                  ),
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
