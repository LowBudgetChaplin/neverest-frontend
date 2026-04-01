import '../../../app/services/api_client.dart';
import '../domain/app_profile.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AppProfile> loadOrCreateProfile({
    required String suggestedDisplayName,
    required bool preferMeEndpoints,
  }) async {
    final displayName = _normalizeDisplayName(suggestedDisplayName);

    if (preferMeEndpoints) {
      try {
        return await getMyProfile();
      } on ApiException catch (error) {
        if (error.statusCode == 404) {
          return createMyProfile(displayName);
        }

        final authIssue = error.statusCode == 400 ||
            error.statusCode == 401 ||
            error.statusCode == 403;
        if (!authIssue) {
          rethrow;
        }
      }
    }

    return _loadOrCreateWithoutMe(displayName);
  }

  Future<AppProfile> getMyProfile() async {
    final response = await _apiClient.get('/api/v1/users/me');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException('Invalid /users/me response payload.');
    }
    return AppProfile.fromJson(data);
  }

  Future<AppProfile> createMyProfile(String displayName) async {
    final response = await _apiClient.post(
      '/api/v1/users/me',
      data: {'displayName': displayName},
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException('Invalid /users/me creation payload.');
    }
    return AppProfile.fromJson(data);
  }

  Future<AppProfile> _loadOrCreateWithoutMe(String displayName) async {
    final listResponse = await _apiClient.get('/api/v1/users');
    final payload = listResponse.data;
    if (payload is List && payload.isNotEmpty) {
      final first = payload.first;
      if (first is Map<String, dynamic>) {
        return AppProfile.fromJson(first);
      }
    }

    final createResponse = await _apiClient.post(
      '/api/v1/users',
      data: {'displayName': displayName},
    );
    final created = createResponse.data;
    if (created is! Map<String, dynamic>) {
      throw ApiException('Invalid /users creation payload.');
    }
    return AppProfile.fromJson(created);
  }

  String _normalizeDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Neverest User';
    }
    return trimmed;
  }
}
