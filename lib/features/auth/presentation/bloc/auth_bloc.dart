import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/services/api_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_session.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        super(const AuthState.initial()) {
    on<AuthRestoreRequested>(_onRestoreRequested);
    on<AuthAnonymousSignInRequested>(_onAnonymousSignInRequested);
    on<AuthEmailPasswordSignInRequested>(_onEmailPasswordSignInRequested);
    on<AuthEmailPasswordRegisterRequested>(_onEmailPasswordRegisterRequested);
    on<AuthManualTokenSubmitted>(_onManualTokenSubmitted);
    on<AuthManualTokenCleared>(_onManualTokenCleared);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthSessionInvalidated>(_onSessionInvalidated);

    _apiAuthFailureSubscription = apiClient.authFailures.listen((failure) {
      add(
        AuthSessionInvalidated(
          statusCode: failure.statusCode,
          path: failure.path,
        ),
      );
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<ApiAuthFailure> _apiAuthFailureSubscription;
  bool _isSessionInvalidationInProgress = false;
  static const _registerSuccessMessage =
      'Account created successfully. Please sign in.';

  Future<void> _onRestoreRequested(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final session = await _repository.restoreSession();
      if (session != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: session,
            clearMessage: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onAnonymousSignInRequested(
    AuthAnonymousSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final session = await _repository.signInAnonymously();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearMessage: true,
        ),
      );
    } on AuthRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onEmailPasswordSignInRequested(
    AuthEmailPasswordSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final session = await _repository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearMessage: true,
        ),
      );
    } on AuthRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onEmailPasswordRegisterRequested(
    AuthEmailPasswordRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      await _repository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        phoneNumber: event.phoneNumber,
        avatarB64: event.avatarB64,
      );
      await _repository.signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          message: _registerSuccessMessage,
        ),
      );
    } on AuthRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onManualTokenSubmitted(
    AuthManualTokenSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final session = await _repository.saveManualToken(event.token);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          clearMessage: true,
        ),
      );
    } on AuthRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onManualTokenCleared(
    AuthManualTokenCleared event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.clearManualToken();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearSession: true,
        message: null,
      ),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          message: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          clearSession: true,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSessionInvalidated(
    AuthSessionInvalidated event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status != AuthStatus.authenticated ||
        _isSessionInvalidationInProgress) {
      return;
    }

    if (event.statusCode == 403) {
      emit(
        state.copyWith(
          message:
              'Access denied for ${event.path}. Your account does not have the required role.',
        ),
      );
      return;
    }

    _isSessionInvalidationInProgress = true;
    try {
      await _repository.signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
          message:
              'Session expired or token invalid. Please sign in again to continue.',
        ),
      );
    } finally {
      _isSessionInvalidationInProgress = false;
    }
  }

  @override
  Future<void> close() async {
    await _apiAuthFailureSubscription.cancel();
    return super.close();
  }
}
