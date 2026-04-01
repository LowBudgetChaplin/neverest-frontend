import '../../../app/services/api_client.dart';
import '../domain/access_profile.dart';

class AccessRepository {
  AccessRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AccessProfile> resolve() async {
    String subject = 'anonymous';
    bool authenticated = false;
    List<String> authorities = const [];

    try {
      final meResponse = await _apiClient.get(
        '/api/v1/auth/me',
        skipAuthFailureHandling: true,
      );
      final payload = meResponse.data;
      if (payload is Map<String, dynamic>) {
        subject = payload['subject'] as String? ?? subject;
        authenticated = payload['authenticated'] as bool? ?? authenticated;
        authorities = (payload['authorities'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList();
      }
    } on ApiException catch (error) {
      // When backend runs in strict auth mode and user is not logged in.
      if (error.statusCode != 401 && error.statusCode != 403) {
        rethrow;
      }
    }

    bool canOpenAdminCenter = false;
    try {
      await _apiClient.get(
        '/api/v1/admin/audit-logs',
        queryParameters: {'limit': 1},
        skipAuthFailureHandling: true,
      );
      canOpenAdminCenter = true;
    } on ApiException catch (error) {
      if (error.statusCode != 401 && error.statusCode != 403) {
        rethrow;
      }
    }

    return AccessProfile(
      subject: subject,
      authenticated: authenticated,
      authorities: authorities,
      canOpenAdminCenter: canOpenAdminCenter,
    );
  }
}
