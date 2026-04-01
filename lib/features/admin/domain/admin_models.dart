import '../../dashboard/domain/dashboard_data.dart';

class AuditLogItem {
  const AuditLogItem({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.actor,
    required this.success,
    required this.message,
    required this.metadata,
  });

  factory AuditLogItem.fromJson(Map<String, dynamic> json) {
    return AuditLogItem(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      action: json['action'] as String? ?? '',
      actor: json['actor'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      metadata: (json['metadata'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
    );
  }

  final String id;
  final String timestamp;
  final String action;
  final String actor;
  final bool success;
  final String message;
  final Map<String, String> metadata;
}

class AuthMeInfo {
  const AuthMeInfo({
    required this.subject,
    required this.authenticated,
    required this.authorities,
  });

  factory AuthMeInfo.fromJson(Map<String, dynamic> json) {
    return AuthMeInfo(
      subject: json['subject'] as String? ?? 'unknown',
      authenticated: json['authenticated'] as bool? ?? false,
      authorities: (json['authorities'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  final String subject;
  final bool authenticated;
  final List<String> authorities;
}

class UserAdminItem {
  const UserAdminItem({
    required this.id,
    required this.displayName,
    required this.qrCode,
    required this.authSubject,
    required this.totalPoints,
    required this.availablePoints,
  });

  factory UserAdminItem.fromJson(Map<String, dynamic> json) {
    return UserAdminItem(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      authSubject: json['authSubject'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      availablePoints: (json['availablePoints'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String displayName;
  final String qrCode;
  final String? authSubject;
  final int totalPoints;
  final int availablePoints;
}

class AnnouncementDispatchItem {
  const AnnouncementDispatchItem({
    required this.channel,
    required this.attempted,
    required this.success,
    required this.statusCode,
    required this.detail,
  });

  factory AnnouncementDispatchItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementDispatchItem(
      channel: json['channel'] as String? ?? 'UNKNOWN',
      attempted: json['attempted'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      detail: json['detail'] as String? ?? '',
    );
  }

  final String channel;
  final bool attempted;
  final bool success;
  final int? statusCode;
  final String detail;
}

class EventCreationResult {
  const EventCreationResult({
    required this.event,
    required this.announcements,
  });

  factory EventCreationResult.fromJson(Map<String, dynamic> json) {
    final eventJson = json['event'];
    final announcementsJson =
        json['announcements'] as List<dynamic>? ?? const [];
    return EventCreationResult(
      event: eventJson is Map<String, dynamic>
          ? EventSummary.fromJson(eventJson)
          : const EventSummary(
              id: '',
              title: '',
              activityType: '',
              location: '',
              startsAt: '',
              pointsReward: 0,
            ),
      announcements: announcementsJson
          .whereType<Map<String, dynamic>>()
          .map(AnnouncementDispatchItem.fromJson)
          .toList(),
    );
  }

  final EventSummary event;
  final List<AnnouncementDispatchItem> announcements;
}
