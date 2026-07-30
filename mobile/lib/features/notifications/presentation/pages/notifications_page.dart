import 'package:flutter/material.dart';
import 'package:runvibe_mobile/core/di/injection.dart';
import 'package:runvibe_mobile/features/tracking/data/activity_local_data_source.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pending = getIt<ActivityLocalDataSource>().pending();
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: Text('${pending.length} atividade(s) aguardando envio'),
                subtitle: const Text(
                  'Elas estão salvas neste aparelho e serão sincronizadas quando possível.',
                ),
              ),
            ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.notifications_active_outlined),
              title: Text('Central de notificações ativa'),
              subtitle: Text(
                'Lembretes de treino e interações sociais aparecerão aqui.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
