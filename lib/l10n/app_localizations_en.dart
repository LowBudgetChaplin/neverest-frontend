// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Neverest';

  @override
  String get no_internet_connection => 'No internet connection';

  @override
  String get increase_version =>
      'Please update the application to the latest version.';

  @override
  String get internal_server_error =>
      'An unexpected server error occurred. Please try again later.';

  @override
  String get unknown_error => 'An unknown error occurred.';

  @override
  String get unauthorized => 'Your session has expired. Please log in again.';

  @override
  String get home => 'Home';

  @override
  String get rewards => 'Rewards';

  @override
  String get challenges => 'Challenges';

  @override
  String get social => 'Social';

  @override
  String get wallet => 'Wallet';
}
