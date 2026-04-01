class AppProfile {
  const AppProfile({
    required this.id,
    required this.displayName,
    required this.qrCode,
    required this.authSubject,
    required this.totalPoints,
    required this.availablePoints,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Unknown',
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
