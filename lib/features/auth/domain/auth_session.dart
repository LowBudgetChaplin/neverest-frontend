class AuthSession {
  const AuthSession({
    required this.token,
    this.uid,
    this.email,
    this.displayName,
    required this.isAnonymous,
    required this.isManualToken,
  });

  final String token;
  final String? uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final bool isManualToken;
}
