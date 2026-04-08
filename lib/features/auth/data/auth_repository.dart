import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/services/auth_token_storage.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  AuthRepository({
    required AuthTokenStorage tokenStorage,
    FirebaseAuth? firebaseAuth,
    required bool firebaseReady,
    String? firebaseInitError,
  })  : _tokenStorage = tokenStorage,
        _firebaseAuth = firebaseAuth,
        _firebaseReady = firebaseReady,
        _firebaseInitError = firebaseInitError;

  final AuthTokenStorage _tokenStorage;
  final FirebaseAuth? _firebaseAuth;
  final bool _firebaseReady;
  final String? _firebaseInitError;

  bool get firebaseReady => _firebaseReady;
  String? get firebaseInitError => _firebaseInitError;

  Future<AuthSession?> restoreSession() async {
    final firebaseAuth = _firebaseAuth;
    if (_firebaseReady && firebaseAuth != null) {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        final token = await currentUser.getIdToken();
        if (token != null && token.isNotEmpty) {
          await _tokenStorage.saveToken(token);
          return _toFirebaseSession(currentUser, token);
        }
      }
    }

    final savedToken = await _tokenStorage.readToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      return AuthSession(
        token: savedToken,
        isAnonymous: false,
        isManualToken: true,
      );
    }

    return null;
  }

  Future<AuthSession> signInAnonymously() async {
    _ensureFirebaseReady();
    final firebaseAuth = _firebaseAuth!;
    try {
      final credential = await firebaseAuth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw AuthRepositoryException('Firebase did not return a user.');
      }
      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        throw AuthRepositoryException('Could not generate Firebase ID token.');
      }
      await _tokenStorage.saveToken(token);
      return _toFirebaseSession(user, token);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(error.message ?? error.code);
    }
  }

  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _ensureFirebaseReady();
    final firebaseAuth = _firebaseAuth!;
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthRepositoryException('Firebase did not return a user.');
      }
      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty) {
        throw AuthRepositoryException('Could not generate Firebase ID token.');
      }
      await _tokenStorage.saveToken(token);
      return _toFirebaseSession(user, token);
    } on FirebaseAuthException catch (error) {
      throw AuthRepositoryException(error.message ?? error.code);
    }
  }

  Future<AuthSession> saveManualToken(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      throw AuthRepositoryException('Token is required.');
    }
    await _tokenStorage.saveToken(normalized);
    return AuthSession(
      token: normalized,
      isAnonymous: false,
      isManualToken: true,
    );
  }

  Future<void> clearManualToken() async {
    await _tokenStorage.clearToken();
  }

  Future<void> signOut() async {
    if (_firebaseReady) {
      await _firebaseAuth?.signOut();
    }
    await _tokenStorage.clearToken();
  }

  void _ensureFirebaseReady() {
    if (!_firebaseReady || _firebaseAuth == null) {
      throw AuthRepositoryException(
        _firebaseInitError ??
            'Firebase is not configured. Add Firebase app config files first.',
      );
    }
  }

  AuthSession _toFirebaseSession(User user, String token) {
    return AuthSession(
      token: token,
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
      isManualToken: false,
    );
  }
}

class AuthRepositoryException implements Exception {
  AuthRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
