// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Neverest';

  @override
  String get no_internet_connection => 'Nu există conexiune la internet.';

  @override
  String get increase_version => 'Vă rugăm să actualizați aplicația la cea mai recentă versiune.';

  @override
  String get internal_server_error => 'A apărut o eroare neașteptată pe server. Încercați din nou mai târziu.';

  @override
  String get unknown_error => 'A apărut o eroare necunoscută.';

  @override
  String get unauthorized => 'Sesiunea a expirat. Vă rugăm să vă autentificați din nou.';

  @override
  String get home => 'Acasă';

  @override
  String get rewards => 'Premii';

  @override
  String get challenges => 'Challenges';

  @override
  String get social => 'Social';

  @override
  String get wallet => 'Portofel';
}
