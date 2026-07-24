import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runvibe_mobile/app/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'APARÊNCIA',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeController,
            builder: (context, mode, _) => Card(
              child: RadioGroup<ThemeMode>(
                groupValue: mode,
                onChanged: (value) => setThemeMode(value!),
                child: const Column(
                  children: [
                    RadioListTile(
                      value: ThemeMode.system,
                      title: Text('Usar tema do aparelho'),
                    ),
                    RadioListTile(
                      value: ThemeMode.light,
                      title: Text('Modo claro'),
                    ),
                    RadioListTile(
                      value: ThemeMode.dark,
                      title: Text('Modo escuro'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('GPS', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Permissão de localização'),
              subtitle: const Text(
                'Defina como “Permitir o tempo todo” para correr com a tela bloqueada.',
              ),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: openAppSettings,
            ),
          ),
        ],
      ),
    );
  }
}
