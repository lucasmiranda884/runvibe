import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:runvibe_mobile/core/di/injection.dart';
import 'package:runvibe_mobile/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:runvibe_mobile/features/tracking/presentation/pages/tracking_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final TrackingBloc _trackingBloc = getIt<TrackingBloc>();

  @override
  void dispose() {
    _trackingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const _FeedPage(),
          const _ProgressPage(),
          BlocProvider.value(
            value: _trackingBloc,
            child: const TrackingPage(),
          ),
          const _ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progresso',
          ),
          NavigationDestination(
            icon: Icon(Icons.radio_button_checked),
            selectedIcon: Icon(Icons.radio_button_checked),
            label: 'Gravar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  late Future<List<_ActivityItem>> _future = _load();

  Future<List<_ActivityItem>> _load() async {
    final response = await getIt<Dio>().get<Map<String, dynamic>>('feed');
    final content = response.data?['content'] as List<dynamic>? ?? const [];
    return content
        .map((item) => _ActivityItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const _RunVibeWordmark(),
                    const Spacer(),
                    _RoundIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _RoundIconButton(
                      icon: Icons.person_add_alt_1_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _QuickAction(Icons.directions_run_rounded, 'Correr'),
                    _QuickAction(Icons.route_rounded, 'Rotas'),
                    _QuickAction(Icons.groups_2_outlined, 'Clubes'),
                    _QuickAction(Icons.emoji_events_outlined, 'Desafios'),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<_ActivityItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: _MessageState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Não foi possível carregar o feed',
                      subtitle:
                          'Sua corrida continua segura offline. Puxe para atualizar.',
                      action: _refresh,
                    ),
                  );
                }
                final activities = snapshot.data ?? const [];
                if (activities.isEmpty) {
                  return const SliverFillRemaining(
                    child: _MessageState(
                      icon: Icons.groups_rounded,
                      title: 'Sua comunidade começa aqui',
                      subtitle:
                          'Siga corredores ou grave sua primeira atividade para movimentar o feed.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, index) =>
                        _ActivityCard(activity: activities[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPage extends StatelessWidget {
  const _ProgressPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Seu progresso',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Consistência vale mais que velocidade.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          Card(
            color: const Color(0xFF11180F),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESTA SEMANA',
                    style: TextStyle(
                      color: Color(0xFFB7F34A),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      _DarkMetric(value: '0,0', label: 'quilômetros'),
                      _DarkMetric(value: '0', label: 'atividades'),
                      _DarkMetric(value: '0m', label: 'tempo'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const LinearProgressIndicator(
                    value: 0,
                    minHeight: 8,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    backgroundColor: Color(0xFF35402F),
                    color: Color(0xFFB7F34A),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Meta semanal: 15 km',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTile(
            icon: Icons.calendar_month_rounded,
            title: 'Calendário de treinos',
            subtitle: 'Veja sua frequência e dias ativos',
          ),
          const SizedBox(height: 12),
          const _SectionTile(
            icon: Icons.speed_rounded,
            title: 'Melhores esforços',
            subtitle: 'Recordes de 1 km, 5 km, 10 km e mais',
          ),
          const SizedBox(height: 12),
          const _SectionTile(
            icon: Icons.checkroom_rounded,
            title: 'Meus tênis',
            subtitle: 'Controle de desgaste por quilometragem',
          ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text(
                'Perfil',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFF11180F),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 44),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corredor RunVibe',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text('Sua jornada começa agora'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileMetric('0', 'Atividades'),
              _ProfileMetric('0', 'Seguindo'),
              _ProfileMetric('0', 'Seguidores'),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar perfil'),
          ),
          const SizedBox(height: 24),
          const _SectionTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Conquistas',
            subtitle: 'Marcos e desafios concluídos',
          ),
          const SizedBox(height: 12),
          const _SectionTile(
            icon: Icons.shield_outlined,
            title: 'Privacidade',
            subtitle: 'Controle quem vê suas atividades',
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final _ActivityItem activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF11180F),
                  child: Text(
                    activity.userName.isEmpty
                        ? 'R'
                        : activity.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.userName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        DateFormat(
                          "d 'de' MMM • HH:mm",
                          'pt_BR',
                        ).format(activity.createdAt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded),
              ],
            ),
          ),
          Container(
            height: 150,
            color: const Color(0xFFE8EDDF),
            child: CustomPaint(
              painter: _RoutePainter(),
              child: const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CardMetric(
                      '${(activity.distanceMeters / 1000).toStringAsFixed(2)} km',
                      'Distância',
                    ),
                    _CardMetric(_duration(activity.elapsedSeconds), 'Tempo'),
                    _CardMetric(_pace(activity.paceSeconds), 'Ritmo'),
                  ],
                ),
                const Divider(height: 30),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border_rounded),
                    ),
                    const Text('Kudos'),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                    const Text('Comentar'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _duration(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  static String _pace(int seconds) =>
      seconds <= 0 ? '--:--' : '${_duration(seconds)} /km';
}

class _ActivityItem {
  const _ActivityItem({
    required this.userName,
    required this.title,
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.paceSeconds,
    required this.createdAt,
  });

  factory _ActivityItem.fromJson(Map<String, dynamic> json) => _ActivityItem(
    userName: json['userName'] as String? ?? 'Corredor',
    title: json['title'] as String? ?? 'Corrida',
    distanceMeters: (json['totalDistanceMeters'] as num?)?.toDouble() ?? 0,
    elapsedSeconds: (json['elapsedTimeSeconds'] as num?)?.toInt() ?? 0,
    paceSeconds: (json['averagePaceSecondsPerKm'] as num?)?.toInt() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String userName;
  final String title;
  final double distanceMeters;
  final int elapsedSeconds;
  final int paceSeconds;
  final DateTime createdAt;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFFD8DFCE)
      ..strokeWidth = 1;
    for (var x = 18.0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 18.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final route = Path()
      ..moveTo(size.width * .1, size.height * .72)
      ..cubicTo(
        size.width * .25,
        size.height * .15,
        size.width * .38,
        size.height * .88,
        size.width * .52,
        size.height * .42,
      )
      ..cubicTo(
        size.width * .65,
        size.height * .08,
        size.width * .74,
        size.height * .72,
        size.width * .9,
        size.height * .25,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF5C8F20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RunVibeWordmark extends StatelessWidget {
  const _RunVibeWordmark();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF11180F),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.directions_run_rounded,
            color: Color(0xFFB7F34A),
          ),
        ),
      ),
      SizedBox(width: 9),
      Text(
        'RUNVIBE',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: -.6,
        ),
      ),
    ],
  );
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      IconButton.filledTonal(onPressed: onTap, icon: Icon(icon));
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: SizedBox(
      width: 76,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(icon, color: const Color(0xFF35551B)),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: const Color(0xFF5C8F20)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: action, child: const Text('Tentar novamente')),
          ],
        ],
      ),
    ),
  );
}

class _DarkMetric extends StatelessWidget {
  const _DarkMetric({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    ),
  );
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8F8C8),
        child: Icon(icon, color: const Color(0xFF35551B)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _CardMetric extends StatelessWidget {
  const _CardMetric(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
