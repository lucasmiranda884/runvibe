import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:runvibe_mobile/core/di/injection.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Future<List<Map<String, dynamic>>>? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _results = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _results = getIt<Dio>()
            .get<List<dynamic>>(
              'users/search',
              queryParameters: {'query': query.trim()},
            )
            .then(
              (response) =>
                  (response.data ?? const []).cast<Map<String, dynamic>>(),
            );
      });
    });
  }

  Future<void> _toggle(Map<String, dynamic> user) async {
    final response = await getIt<Dio>().post<Map<String, dynamic>>(
      'users/${user['id']}/follow',
    );
    setState(() => user['followedByMe'] = response.data?['active'] == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encontrar amigos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _controller,
              hintText: 'Nome ou e-mail cadastrado',
              leading: const Icon(Icons.search_rounded),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _results == null
                ? const Center(
                    child: Text('Digite pelo menos duas letras ou o e-mail.'),
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _results,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Não foi possível buscar usuários.'),
                        );
                      }
                      final users = snapshot.data ?? const [];
                      if (users.isEmpty) {
                        return const Center(
                          child: Text('Nenhum usuário encontrado.'),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final following = user['followedByMe'] == true;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (user['name'] as String? ?? 'R')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text(
                                user['name'] as String? ?? 'Corredor',
                              ),
                              subtitle: Text(user['email'] as String? ?? ''),
                              trailing: FilledButton.tonal(
                                onPressed: () => _toggle(user),
                                child: Text(following ? 'Seguindo' : 'Seguir'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
