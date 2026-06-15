import '../../../app/services/api_client.dart';
import '../../../app/services/auth_token_storage.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  AuthRepository({
    required AuthTokenStorage tokenStorage,
    required ApiClient apiClient,
  })  : _tokenStorage = tokenStorage,
        _apiClient = apiClient;

  final AuthTokenStorage _tokenStorage;
  final ApiClient _apiClient;

  bool get firebaseReady => true;
  String? get firebaseInitError => null;

  Future<AuthSession?> restoreSession() async {
    final savedToken = await _tokenStorage.readToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      try {
        final identity = await _resolveIdentity();
        return AuthSession(
          token: savedToken,
          uid: identity.$1,
          email: identity.$2,
          displayName: identity.$3,
          isAnonymous: false,
          isManualToken: false,
        );
      } on ApiException catch (error) {
        if (error.statusCode == 401 || error.statusCode == 403) {
          await _tokenStorage.clearToken();
          return null;
        }
        rethrow;
      }
    }

    return null;
  }

  Future<AuthSession> signInAnonymously() async {
    throw AuthRepositoryException('Anonymous sign-in is disabled.');
  }

  Future<AuthSession> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
        skipAuthFailureHandling: true,
      );
      final payload = response.data;
      final token =
          payload is Map<String, dynamic> ? payload['accessToken'] as String? : null;
      if (token == null || token.trim().isEmpty) {
        throw AuthRepositoryException('Backend did not return an access token.');
      }
      await _tokenStorage.saveToken(token);
      final identity = await _resolveIdentity();
      return AuthSession(
        token: token,
        uid: identity.$1,
        email: identity.$2,
        displayName: identity.$3,
        isAnonymous: false,
        isManualToken: false,
      );
    } on ApiException catch (error) {
      throw AuthRepositoryException(error.message);
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
    String? avatarB64,
  }) async {
    try {
      await _apiClient.post(
        '/api/v1/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName?.trim(),
          'phoneNumber': phoneNumber?.trim(),
          if (avatarB64 != null) 'avatarB64': avatarB64,
        },
        skipAuthFailureHandling: true,
      );
    } on ApiException catch (error) {
      throw AuthRepositoryException(error.message);
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
    await _tokenStorage.clearToken();
  }

  Future<(String?, String?, String?)> _resolveIdentity() async {
    final meResponse = await _apiClient.get(
      '/api/v1/auth/me',
      skipAuthFailureHandling: true,
    );
    final payload = meResponse.data;
    if (payload is! Map<String, dynamic>) {
      return (null, null, null);
    }

    final subject = payload['subject'] as String?;
    final email = subject != null && subject.contains('@') ? subject : null;
    final displayName = email == null ? null : email.split('@').first;
    return (subject, email, displayName);
  }

}

class AuthRepositoryException implements Exception {
  AuthRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
