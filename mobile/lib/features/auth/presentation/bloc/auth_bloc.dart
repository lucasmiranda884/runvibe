import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:runvibe_mobile/features/auth/data/auth_repository.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted(this.email, this.password);
  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

final class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted(this.name, this.email, this.password);
  final String name;
  final String email;
  final String password;
  @override
  List<Object?> get props => [name, email, password];
}

enum AuthStatus { initial, loading, authenticated, failure }

final class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.message});
  final AuthStatus status;
  final String? message;
  @override
  List<Object?> get props => [status, message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<LoginSubmitted>(_login);
    on<RegisterSubmitted>(_register);
  }

  final AuthRepository _repository;

  Future<void> _login(LoginSubmitted event, Emitter<AuthState> emit) async {
    await _execute(() => _repository.login(event.email, event.password), emit);
  }

  Future<void> _register(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    await _execute(
      () => _repository.register(event.name, event.email, event.password),
      emit,
    );
  }

  Future<void> _execute(
    Future<void> Function() action,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await action();
      emit(const AuthState(status: AuthStatus.authenticated));
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      final message = switch (status) {
        400 => 'Confira os dados. A senha precisa ter pelo menos 8 caracteres.',
        401 => 'E-mail ou senha incorretos.',
        409 => 'Este e-mail já possui uma conta.',
        _
            when error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.connectionError =>
          'O servidor gratuito não respondeu após 3 minutos. Verifique a internet e tente novamente.',
        _ => 'Servidor indisponível. Sua internet está ativa? Tente novamente.',
      };
      emit(AuthState(status: AuthStatus.failure, message: message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.failure,
          message: 'Não foi possível autenticar. Confira os dados e a conexão.',
        ),
      );
    }
  }
}
