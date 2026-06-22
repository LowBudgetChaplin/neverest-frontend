import '../../../app/services/api_client.dart';
import '../domain/notification_models.dart';

class NotificationRepository {
  NotificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AppNotification>> list() async {
    final response = await _apiClient.get('/api/v1/notifications/me');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
    }
    return const [];
  }

  Future<int> unreadCount() async {
    final response = await _apiClient.get('/api/v1/notifications/me/unread-count');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> markAllRead() async {
    await _apiClient.post('/api/v1/notifications/me/read');
  }
}
