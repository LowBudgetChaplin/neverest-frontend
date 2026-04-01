part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

final class AuthRestoreRequested extends AuthEvent {
  const AuthRestoreRequested();
}

final class AuthAnonymousSignInRequested extends AuthEvent {
  const AuthAnonymousSignInRequested();
}

final class AuthEmailPasswordSignInRequested extends AuthEvent {
  const AuthEmailPasswordSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthManualTokenSubmitted extends AuthEvent {
  const AuthManualTokenSubmitted(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

final class AuthManualTokenCleared extends AuthEvent {
  const AuthManualTokenCleared();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthSessionInvalidated extends AuthEvent {
  const AuthSessionInvalidated({
    required this.statusCode,
    required this.path,
  });

  final int statusCode;
  final String path;

  @override
  List<Object?> get props => [statusCode, path];
}
