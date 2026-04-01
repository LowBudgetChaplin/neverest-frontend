import 'package:equatable/equatable.dart';

class AccessProfile extends Equatable {
  const AccessProfile({
    required this.subject,
    required this.authenticated,
    required this.authorities,
    required this.canOpenAdminCenter,
  });

  final String subject;
  final bool authenticated;
  final List<String> authorities;
  final bool canOpenAdminCenter;

  bool get isAdmin =>
      authorities.any((value) => value.toUpperCase().contains('ROLE_ADMIN'));

  @override
  List<Object?> get props => [
        subject,
        authenticated,
        authorities,
        canOpenAdminCenter,
      ];
}
