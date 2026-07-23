import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runvibe_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              context.go('/home');
            }
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message!)));
            }
          },
          builder: (context, state) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.directions_run_rounded, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        'RUNVIBE',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 32),
                      if (_register)
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Informe o nome'
                              : null,
                        ),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        validator: (value) => !(value?.contains('@') ?? false)
                            ? 'E-mail inválido'
                            : null,
                      ),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Senha'),
                        validator: (value) => (value?.length ?? 0) < 8
                            ? 'Use pelo menos 8 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.status == AuthStatus.loading
                            ? null
                            : _submit,
                        child: state.status == AuthStatus.loading
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(),
                              )
                            : Text(_register ? 'Criar conta' : 'Entrar'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _register = !_register),
                        child: Text(
                          _register ? 'Já tenho uma conta' : 'Criar uma conta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    if (_register) {
      bloc.add(RegisterSubmitted(_name.text, _email.text, _password.text));
    } else {
      bloc.add(LoginSubmitted(_email.text, _password.text));
    }
  }
}
