part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  unavailable,
  failure,
}

final class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.session,
    this.message,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final AuthSession? session;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? message,
    bool clearSession = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
