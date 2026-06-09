import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Neverest';

  @override
  String get no_internet_connection => 'Nu exista conexiune la internet';

  @override
  String get increase_version => 'Te rugam sa actualizezi aplicatia la cea mai noua versiune.';

  @override
  String get internal_server_error => 'A aparut o eroare de server. Incearca din nou mai tarziu.';

  @override
  String get unknown_error => 'A aparut o eroare necunoscuta.';

  @override
  String get unauthorized => 'Sesiunea a expirat. Te rugam sa te autentifici din nou.';

  @override
  String get home => 'Acasa';

  @override
  String get rewards => 'Recompense';

  @override
  String get challenges => 'Provocari';

  @override
  String get social => 'Social';

  @override
  String get wallet => 'Portofel';

  @override
  String get navHome => 'Acasa';

  @override
  String get navEvents => 'Evenimente';

  @override
  String get navChallenges => 'Obiective';

  @override
  String get navLeaderboard => 'Clasament';

  @override
  String get navRewards => 'Beneficii';

  @override
  String get commonAll => 'Toate';

  @override
  String get commonNew => 'Noi';

  @override
  String get commonOverall => 'General';

  @override
  String get commonPoints => 'Puncte';

  @override
  String get commonPointsShort => 'pct';

  @override
  String get commonRefresh => 'Reimprospateaza';

  @override
  String get commonRetry => 'Reincearca';

  @override
  String get commonClose => 'Inchide';

  @override
  String get commonCancel => 'Anuleaza';

  @override
  String get commonConfirm => 'Confirma';

  @override
  String get commonEdit => 'Editeaza';

  @override
  String get activityRunning => 'Alergare';

  @override
  String get activityPadel => 'Padel';

  @override
  String get activityMountain => 'Munte';

  @override
  String get onboardingSkip => 'Sari';

  @override
  String get onboardingAlreadyHaveAccount => 'Am deja cont';

  @override
  String get onboardingHeadline1 => 'FARA VARF.\nFARA LIMITA.';

  @override
  String get onboardingSubtitle1 => 'Un club pentru miscare, munte si dimineti pentru care merita sa te ridici.';

  @override
  String get onboardingCta1 => 'Incepe';

  @override
  String get onboardingHeadline2 => 'MISCATE.\nCASTIGA PUNCTE.';

  @override
  String get onboardingSubtitle2 => 'Alearga, urca pe munte, joaca padel. Participa la evenimente. Bifeaza provocari saptamanale. Fiecare miscare conteaza.';

  @override
  String get onboardingCta2 => 'Suna bine';

  @override
  String get onboardingHeadline3 => 'CHELTUIESTE\nLOCAL.';

  @override
  String get onboardingSubtitle3 => 'Carturesti, Origo, MOCA, antrenorul tau preferat. Beneficii reale din Bucuresti.';

  @override
  String get onboardingCta3 => 'Hai sa mergem';

  @override
  String onboardingStep(int current, int total) {
    return '$current / $total';
  }

  @override
  String get homeLiveNow => 'Live acum';

  @override
  String get homeThisWeek => 'Saptamana asta';

  @override
  String get homeActivities => 'Activitati';

  @override
  String get homeStreak => 'Streak';

  @override
  String get homeStartChallenge => 'Incepe provocare';

  @override
  String get homeFindEvents => 'Gaseste evenimente';

  @override
  String get homeTrackingLive => 'Tracking · live';

  @override
  String get homeSeeAll => 'Vezi tot';

  @override
  String get homeSpendPoints => 'Cheltuie punctele';

  @override
  String get homeAvailableToSpend => 'de cheltuit';

  @override
  String get homeNothingAffordable => 'Continua sa aduni puncte — inca niciun beneficiu accesibil.';

  @override
  String homeActiveCount(int count) {
    return '$count active';
  }

  @override
  String homeThisWeekCount(int count) {
    return '$count saptamana asta';
  }

  @override
  String get eventsTitle => 'Evenimente';

  @override
  String get eventsEmptyState => 'Nu exista evenimente pentru acest filtru.';

  @override
  String get eventsGoingLabel => 'participanti';

  @override
  String eventsSubtitle(int count, int attending) {
    return '$count saptamana asta · $attending participanti';
  }

  @override
  String get profilePhone => 'Numar de telefon';

  @override
  String get eventWhen => 'Cand';

  @override
  String get eventWhere => 'Unde';

  @override
  String get eventReward => 'Recompensa';

  @override
  String get eventRecurrence => 'Recurenta';

  @override
  String get eventAbout => 'Despre';

  @override
  String get eventStravaClub => 'Alatura-te pe Strava →';

  @override
  String get eventWhatsappGroup => 'Alatura-te pe WhatsApp →';

  @override
  String get eventRoute => 'Traseu';

  @override
  String get eventOpenRoute => 'Deschide in Maps';

  @override
  String get eventParticipants => 'Participanti';

  @override
  String get eventYouGoing => 'Participi';

  @override
  String get eventAdminCheckIn => 'Check-in admin';

  @override
  String get eventImGoing => 'Particip';

  @override
  String get eventGoing => 'Esti inscris';

  @override
  String eventAttendeesCount(int count) {
    return '$count participanti';
  }

  @override
  String eventSpotsLeft(int count) {
    return '$count locuri ramase';
  }

  @override
  String get eventFull => 'Complet';

  @override
  String get challengesTitle => 'Provocari';

  @override
  String get challengesSubtitle => 'Castiga puncte in stilul tau';

  @override
  String get challengesEarned => 'Castigate';

  @override
  String get challengesNoCompleted => 'Nu ai finalizat nicio provocare inca.';

  @override
  String get challengesCompletedTag => 'Finalizat';

  @override
  String challengesActiveCount(int count) {
    return 'Active · $count';
  }

  @override
  String challengesCompletedCount(int count) {
    return 'Finalizate · $count';
  }

  @override
  String get challengeLiveTracking => 'Tracking live';

  @override
  String get challengeRouteSubtitle => 'Mers sau alergare · 7.4 km';

  @override
  String get challengeDistanceSubtitle => 'Orice activitate · orice suprafata';

  @override
  String get challengeMorningSubtitle => 'Muta-te inainte de 8AM · 3 zile';

  @override
  String get challengePadelSubtitle => 'Inregistrat la evenimente';

  @override
  String get challengeForestSubtitle => '6 km · traseu marcat';

  @override
  String get challengeDeadlineSun => 'Se termina Duminica';

  @override
  String get challengeDeadlineJune => 'Se termina 1 Iun';

  @override
  String get challengeAlwaysOn => 'Permanent';

  @override
  String get challengeProgress23 => '2/3 completate';

  @override
  String challengeDeadlineDays(int days) {
    return '$days zile ramase';
  }

  @override
  String get yourPointsHome => 'PUNCTELE TALE';

  @override
  String get challengePaused => 'Pauza';

  @override
  String get challengeGpsLive => 'GPS · Live';

  @override
  String get challengeDestination => 'Destinatie';

  @override
  String get challengeDestinationValue => 'Arcul de Triumf';

  @override
  String challengeRemainingKm(Object distance) {
    return '$distance km ramasi';
  }

  @override
  String get challengeRouteHeadline => '● Provocare · Centrul Vechi → Arcul de Triumf';

  @override
  String challengeOnFinishPoints(int points) {
    return '+$points pct la final';
  }

  @override
  String challengeProgressLine(int percent, Object currentKm, Object totalKm) {
    return '$percent% · $currentKm/$totalKm km';
  }

  @override
  String get challengeTime => 'Timp';

  @override
  String get challengePace => 'Ritm';

  @override
  String get challengeSteps => 'Pasi';

  @override
  String get challengeResume => 'Reia';

  @override
  String get challengePause => 'Pauza';

  @override
  String get challengeAdminReviewMode => 'Mod revizie admin';

  @override
  String get challengeAdminReviewSubtitle => 'Activeaza pentru a vedea toate trimiterile si a le revizui.';

  @override
  String get challengeNoSubmissions => 'Nu exista trimiteri inca.';

  @override
  String get challengeNoPersonalSubmissions => 'Nu ai trimiteri personale inca.';

  @override
  String get challengeProofRequired => 'Textul de dovada este obligatoriu.';

  @override
  String get challengeMetricMustBeNumeric => 'Valoarea metrica trebuie sa fie numerica.';

  @override
  String get challengeAdminRequired => 'Rolul de admin este necesar pentru revizia trimiterilor.';

  @override
  String get challengeApproveSubmission => 'Aproba trimiterea';

  @override
  String get challengeRejectSubmission => 'Respinge trimiterea';

  @override
  String get challengeReviewerNoteOptional => 'Nota evaluator (optional)';

  @override
  String get challengeSubmitProgress => 'Trimite progres';

  @override
  String get challengeProofLabel => 'Text dovada';

  @override
  String get challengeMetricLabel => 'Valoare metrica (optional)';

  @override
  String get challengeSubmit => 'Trimite provocarea';

  @override
  String challengeSubmissionId(Object id) {
    return 'Trimitere $id';
  }

  @override
  String get challengeProofField => 'Dovada';

  @override
  String get challengeMetricField => 'Valoare metrica';

  @override
  String get challengeAwardedPoints => 'Puncte acordate';

  @override
  String get challengeReviewerNote => 'Nota evaluator';

  @override
  String get challengeApprove => 'Aproba';

  @override
  String get challengeReject => 'Respinge';

  @override
  String get leaderboardTitle => 'Clasament';

  @override
  String get leaderboardSubtitle => 'Actualizare in fiecare minut';

  @override
  String get rewardsTitle => 'Recompense';

  @override
  String get rewardsWallet => 'Portofel';

  @override
  String get rewardsHistory => 'Istoric';

  @override
  String get rewardsRedeem => 'Revendica';

  @override
  String get rewardEditTitle => 'Editeaza recompensa';

  @override
  String get rewardEditChangePhoto => 'Schimba poza';

  @override
  String get rewardEditRemovePhoto => 'Elimina poza';

  @override
  String get rewardEditFieldTitle => 'Titlu';

  @override
  String get rewardEditFieldPartner => 'Partener';

  @override
  String get rewardEditFieldDescription => 'Descriere';

  @override
  String get rewardEditFieldPoints => 'Cost puncte';

  @override
  String get rewardEditFieldStock => 'Stoc';

  @override
  String get rewardEditStockHint => 'gol = nelimitat';

  @override
  String get rewardEditFieldAddress => 'Adresa';

  @override
  String get rewardEditValidation => 'Titlul, partenerul si un cost pozitiv de puncte sunt obligatorii.';

  @override
  String get rewardsCategoryBooks => 'Carti';

  @override
  String get rewardsCategoryCafe => 'Cafea';

  @override
  String get rewardsCategoryMusic => 'Muzica';

  @override
  String get rewardsCategoryGoods => 'Produse';

  @override
  String get rewardsCategoryPrint => 'Print';

  @override
  String get rewardsHistoryEmpty => 'Nu ai recompense revendicate inca.';

  @override
  String rewardsSubtitle(int points) {
    return '$points pct disponibile';
  }

  @override
  String get rewardUnlimited => 'Nelimitat';

  @override
  String get rewardLocalPartner => 'partener local';

  @override
  String get rewardCost => 'Cost';

  @override
  String get rewardYourBalance => 'Soldul tau';

  @override
  String get rewardHowItWorks => 'Cum functioneaza';

  @override
  String get rewardStep1Title => 'Apasa redeem · punctele se blocheaza';

  @override
  String get rewardStep1Subtitle => 'Cod generat pentru folosire in locatie';

  @override
  String get rewardStep2Title => 'Arata codul la casa';

  @override
  String get rewardStep2Subtitle => 'Valabil 24h dupa redeem';

  @override
  String get rewardStep3Title => 'Staff confirma · punctele se consuma';

  @override
  String get rewardStep3Subtitle => 'Bon salvat in portofel';

  @override
  String get rewardLocationAddress => 'Strada Pictor Verona 13–15';

  @override
  String rewardLocationSchedule(Object stock) {
    return 'Bucuresti · Stoc: $stock';
  }

  @override
  String rewardRedeemButton(int points) {
    return 'Revendica · $points pct';
  }

  @override
  String rewardNeedMore(int points) {
    return 'Mai ai nevoie de $points puncte';
  }

  @override
  String get rewardRedeemedLabel => 'Revendicat';

  @override
  String get rewardValidUntil => 'Valabil pana maine la 18:00';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLevelLabel => 'Climber · Nivel 7';

  @override
  String get profileTotalPoints => 'Puncte totale';

  @override
  String get profileDayStreak => 'Streak zile';

  @override
  String get profileGlobalRank => 'Pozitie globala';

  @override
  String get profileByActivity => 'Pe activitate';

  @override
  String get profileGames => 'meciuri';

  @override
  String get profileConnections => 'Conexiuni';

  @override
  String get profileConnectionStrava => 'Sincronizare automata activitati';

  @override
  String get profileConnectionWhatsapp => 'Anunturi evenimente';

  @override
  String get profileConnectionComingSoon => 'In curand';

  @override
  String get profileSettings => 'Setari';

  @override
  String get profileShowMyQr => 'Arata QR-ul meu';

  @override
  String get profileAdminCenter => 'Centru admin';

  @override
  String get profileLinked => 'Conectat';

  @override
  String get profileConnect => 'Conecteaza';

  @override
  String get profileDarkTheme => 'Tema intunecata';

  @override
  String get profileDarkThemeSubtitle => 'Mai usor pentru ochi dupa lasarea serii';

  @override
  String get profileLanguage => 'Limba';

  @override
  String get profileSystemLanguage => 'Sistem';

  @override
  String get profileSync => 'Sincronizeaza profilul';

  @override
  String get profileSyncFailed => 'Sincronizarea profilului a esuat';

  @override
  String profileRankValue(int rank) {
    return '#$rank general';
  }

  @override
  String get authTitle => 'Acces cont';

  @override
  String get authLoginSubtitle => 'Autentifica-te pentru a sincroniza profilul, recompensele si progresul la evenimente.';

  @override
  String get authRegisterSubtitle => 'Creeaza un cont Neverest in cateva secunde.';

  @override
  String get authTabLogin => 'Login';

  @override
  String get authTabRegister => 'Inregistrare';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Parola';

  @override
  String get authConfirmPasswordLabel => 'Confirma parola';

  @override
  String get authDisplayNameLabel => 'Nume afisat (optional)';

  @override
  String get authLoginButton => 'Autentificare';

  @override
  String get authRegisterButton => 'Creeaza cont';

  @override
  String get authSwitchToRegister => 'Nu ai cont? Inregistreaza-te';

  @override
  String get authSwitchToLogin => 'Ai deja cont? Autentifica-te';

  @override
  String get authCredentialsRequired => 'Email-ul si parola sunt obligatorii.';

  @override
  String get authPhoneRequired => 'Numarul de telefon este obligatoriu.';

  @override
  String get authPhotoOptional => 'Adauga o poza (optional)';

  @override
  String get authPasswordMinLength => 'Parola trebuie sa aiba cel putin 6 caractere.';

  @override
  String get authPasswordsMismatch => 'Parolele nu coincid.';

  @override
  String get authSessionActive => 'Sesiune activa';

  @override
  String authSignedAs(Object identity) {
    return 'Autentificat ca $identity';
  }

  @override
  String get authContinue => 'Continua';

  @override
  String get authSignOut => 'Deconectare';

  @override
  String get authManageSession => 'Gestioneaza contul';

  @override
  String get authCardTitle => 'Cont';

  @override
  String get authCardSubtitle => 'Autentifica-te sau inregistreaza-te pentru a sincroniza profilul si punctele.';

  @override
  String get qrSignInRequired => 'Autentificare necesara';

  @override
  String get qrSignInSubtitle => 'Autentifica-te mai intai pentru a incarca codul QR.';

  @override
  String get qrNotAvailable => 'QR indisponibil';

  @override
  String get qrUnavailableSubtitle => 'QR-ul profilului nu este disponibil inca.';

  @override
  String get qrMemberId => 'ID membru';

  @override
  String get qrShowAtGate => 'ARATA ACESTA\nLA INTRARE';

  @override
  String get qrScanHint => 'Organizatorul scaneaza → punctele sunt creditate';

  @override
  String qrRefreshCountdown(String time) {
    return 'Se reimprospateaza in $time';
  }

  @override
  String get adminScanHeader => '● Admin · Sunrise Run';

  @override
  String get adminScanHint => 'Aliniaza QR-ul membrului in interiorul ramei';

  @override
  String get adminScanManualCheckin => 'Simuleaza check-in';

  @override
  String get adminScanManualInput => 'Introducere manuala cod participant';

  @override
  String get adminScanSubmit => 'Trimite check-in';

  @override
  String get adminScanReset => 'Scaneaza din nou';

  @override
  String get adminScanFailed => 'Check-in esuat.';

  @override
  String get adminScanCheckedIn => 'Check-in realizat';

  @override
  String adminScanPointsCredited(int points) {
    return '+$points pct creditate';
  }

  @override
  String adminScanCheckedInCount(int count) {
    return 'Check-in · $count';
  }

  @override
  String adminScanCapacity(int count) {
    return '$count capacitate';
  }

  @override
  String adminScanSpots(int count, int capacity) {
    return '$count / $capacity locuri';
  }

  @override
  String get adminScanCapacityExceeded => 'Numarul de locuri a fost depasit';

  @override
  String get adminScanNext => 'Scanare urmatoare';

  @override
  String get dashboardLoadFailed => 'Datele dashboard nu au putut fi incarcate.';
}
