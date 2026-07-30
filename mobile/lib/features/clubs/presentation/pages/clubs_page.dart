import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:runvibe_mobile/core/di/injection.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({super.key});

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  static const _clubs = [
    ('RunVibe Rio', 'Rio de Janeiro', 'Corrida de rua'),
    ('Longão de Domingo', 'Brasil', 'Longas distâncias'),
    ('Pedal RunVibe', 'Brasil', 'Ciclismo'),
  ];
  final Set<String> _joined = {};

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final value = await getIt<FlutterSecureStorage>().read(
      key: 'runvibe.joinedClubs',
    );
    if (!mounted || value == null) return;
    setState(() => _joined.addAll(value.split('|').where((v) => v.isNotEmpty)));
  }

  Future<void> _toggle(String name) async {
    setState(
      () => _joined.contains(name) ? _joined.remove(name) : _joined.add(name),
    );
    await getIt<FlutterSecureStorage>().write(
      key: 'runvibe.joinedClubs',
      value: _joined.join('|'),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clubes')),
    body: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _clubs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final club = _clubs[index];
        final joined = _joined.contains(club.$1);
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.groups_rounded)),
            title: Text(
              club.$1,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('${club.$2} · ${club.$3}'),
            trailing: FilledButton.tonal(
              onPressed: () => _toggle(club.$1),
              child: Text(joined ? 'Sair' : 'Participar'),
            ),
          ),
        );
      },
    ),
  );
}
