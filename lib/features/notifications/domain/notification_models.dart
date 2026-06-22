class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    this.challengeId,
    this.submissionId,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'UNKNOWN',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      read: json['read'] as bool? ?? false,
      challengeId: json['challengeId'] as String?,
      submissionId: json['submissionId'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final String? challengeId;
  final String? submissionId;
  final String? createdAt;
}
