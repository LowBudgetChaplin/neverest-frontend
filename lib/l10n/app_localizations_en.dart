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
  String get increase_version => 'Please update the application to the latest version.';

  @override
  String get internal_server_error => 'An unexpected server error occurred. Please try again later.';

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

  @override
  String get navHome => 'Home';

  @override
  String get navEvents => 'Events';

  @override
  String get navChallenges => 'Goals';

  @override
  String get navLeaderboard => 'Ranks';

  @override
  String get navRewards => 'Perks';

  @override
  String get commonAll => 'All';

  @override
  String get commonNew => 'New';

  @override
  String get commonOverall => 'Overall';

  @override
  String get commonPoints => 'Points';

  @override
  String get commonPointsShort => 'pts';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonEdit => 'Edit';

  @override
  String get activityRunning => 'Running';

  @override
  String get activityPadel => 'Padel';

  @override
  String get activityMountain => 'Mountain';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingAlreadyHaveAccount => 'I already have an account';

  @override
  String get onboardingHeadline1 => 'NO SUMMIT.\nNO LIMIT.';

  @override
  String get onboardingSubtitle1 => 'A club for movement, mountains, and mornings worth showing up to.';

  @override
  String get onboardingCta1 => 'Get started';

  @override
  String get onboardingHeadline2 => 'MOVE.\nEARN POINTS.';

  @override
  String get onboardingSubtitle2 => 'Run, hike. Show up at events. Hit weekly challenges. Every move counts.';

  @override
  String get onboardingCta2 => 'Sounds good';

  @override
  String get onboardingHeadline3 => 'SPEND THEM\nLOCALLY.';

  @override
  String get onboardingSubtitle3 => 'Cărturești, Tiny Cup, Eden House, your favorite coach, etc';

  @override
  String get onboardingCta3 => 'Let\'s go';

  @override
  String onboardingStep(int current, int total) {
    return '$current / $total';
  }

  @override
  String get homeLiveNow => 'Live now';

  @override
  String get homeThisWeek => 'This week';

  @override
  String get homeActivities => 'Activities';

  @override
  String get homeStreak => 'Streak';

  @override
  String get homeStartChallenge => 'Start challenge';

  @override
  String get homeFindEvents => 'Find events';

  @override
  String get homeTrackingLive => 'Tracking · live';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeSpendPoints => 'Spend your points';

  @override
  String get homeAvailableToSpend => 'to spend';

  @override
  String get homeNothingAffordable => 'Keep earning — no perks within reach yet.';

  @override
  String homeActiveCount(int count) {
    return '$count active';
  }

  @override
  String homeThisWeekCount(int count) {
    return '$count this week';
  }

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsEmptyState => 'No events match this filter.';

  @override
  String get eventsGoingLabel => 'going';

  @override
  String eventsSubtitle(int count, int attending) {
    return '$count this week · $attending attending';
  }

  @override
  String get profilePhone => 'Phone number';

  @override
  String get eventWhen => 'When';

  @override
  String get eventWhere => 'Where';

  @override
  String get eventReward => 'Reward';

  @override
  String get eventRecurrence => 'Recurrence';

  @override
  String get eventAbout => 'About';

  @override
  String get eventStravaClub => 'Join Strava Club →';

  @override
  String get eventWhatsappGroup => 'Join WhatsApp Group →';

  @override
  String get eventRoute => 'Route';

  @override
  String get eventOpenRoute => 'Open in Maps';

  @override
  String get eventParticipants => 'Participants';

  @override
  String get eventYouGoing => 'You\'re going';

  @override
  String get eventAdminCheckIn => 'Admin check-in';

  @override
  String get eventImGoing => 'I\'m going';

  @override
  String get eventGoing => 'You\'re in';

  @override
  String eventAttendeesCount(int count) {
    return '$count going';
  }

  @override
  String eventSpotsLeft(int count) {
    return '$count spots left';
  }

  @override
  String get eventFull => 'Full';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesSubtitle => 'Earn points your way';

  @override
  String get challengesEarned => 'Earned';

  @override
  String get challengesNoCompleted => 'You haven\'t completed any challenge yet.';

  @override
  String get challengesCompletedTag => 'Completed';

  @override
  String get challengesPartnerFilter => 'Partners';

  @override
  String challengesActiveCount(int count) {
    return 'Active · $count';
  }

  @override
  String challengesCompletedCount(int count) {
    return 'Completed · $count';
  }

  @override
  String get challengeLiveTracking => 'Live tracking';

  @override
  String get challengeRouteSubtitle => 'Walk or run · 7.4 km';

  @override
  String get challengeDistanceSubtitle => 'Any activity · all surfaces';

  @override
  String get challengeMorningSubtitle => 'Move before 8AM · 3 days';

  @override
  String get challengePadelSubtitle => 'Logged at events';

  @override
  String get challengeForestSubtitle => '6 km · marked route';

  @override
  String get challengeDeadlineSun => 'Ends Sun';

  @override
  String get challengeDeadlineJune => 'Ends Jun 1';

  @override
  String get challengeAlwaysOn => 'Always on';

  @override
  String get challengeProgress23 => '2/3 done';

  @override
  String challengeDeadlineDays(int days) {
    return '$days days left';
  }

  @override
  String get yourPointsHome => 'YOUR POINTS';

  @override
  String get challengePaused => 'Paused';

  @override
  String get challengeGpsLive => 'GPS · Live';

  @override
  String get challengeDestination => 'Destination';

  @override
  String get challengeDestinationValue => 'Arcul de Triumf';

  @override
  String challengeRemainingKm(Object distance) {
    return '$distance km to go';
  }

  @override
  String get challengeRouteHeadline => '● Challenge · Centrul Vechi → Arcul de Triumf';

  @override
  String challengeOnFinishPoints(int points) {
    return '+$points pts on finish';
  }

  @override
  String challengeProgressLine(int percent, Object currentKm, Object totalKm) {
    return '$percent% · $currentKm/$totalKm km';
  }

  @override
  String get challengeTime => 'Time';

  @override
  String get challengePace => 'Pace';

  @override
  String get challengeSteps => 'Steps';

  @override
  String get challengeResume => 'Resume';

  @override
  String get challengePause => 'Pause';

  @override
  String get challengeAdminReviewMode => 'Admin review mode';

  @override
  String get challengeAdminReviewSubtitle => 'Enable to list all submissions and review.';

  @override
  String get challengeNoSubmissions => 'No submissions yet.';

  @override
  String get challengeNoPersonalSubmissions => 'No personal submissions yet.';

  @override
  String get challengeProofRequired => 'Proof text is required.';

  @override
  String get challengeMetricMustBeNumeric => 'Metric value must be numeric.';

  @override
  String get challengeAdminRequired => 'Admin role is required for submission review.';

  @override
  String get challengeApproveSubmission => 'Approve submission';

  @override
  String get challengeRejectSubmission => 'Reject submission';

  @override
  String get challengeReviewerNoteOptional => 'Reviewer note (optional)';

  @override
  String get challengeSubmitProgress => 'Submit progress';

  @override
  String get challengeProofLabel => 'Proof text';

  @override
  String get challengeMetricLabel => 'Metric value (optional)';

  @override
  String get challengeSubmit => 'Submit challenge';

  @override
  String challengeSubmissionId(Object id) {
    return 'Submission $id';
  }

  @override
  String get challengeProofField => 'Proof';

  @override
  String get challengeMetricField => 'Metric value';

  @override
  String get challengeAwardedPoints => 'Awarded points';

  @override
  String get challengeReviewerNote => 'Reviewer note';

  @override
  String get challengeApprove => 'Approve';

  @override
  String get challengeReject => 'Reject';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'Updates every minute';

  @override
  String get offersSectionTitle => 'Partner offers';

  @override
  String get partnerCenterTitle => 'Partner Center';

  @override
  String get partnerAccessRequired => 'Partner account required.';

  @override
  String get partnerPublishOffer => 'Publish an offer / ad';

  @override
  String get partnerEditOffer => 'Edit offer';

  @override
  String get partnerBrand => 'Brand';

  @override
  String get partnerOfferTitleField => 'Product / offer title';

  @override
  String get partnerDescriptionField => 'Description';

  @override
  String get partnerDiscountHint => 'Discount (e.g. -20%)';

  @override
  String get partnerLinkOptional => 'Link (optional)';

  @override
  String get partnerChangePhoto => 'Change photo';

  @override
  String get partnerAddPhoto => 'Add photo';

  @override
  String get partnerFrom => 'From';

  @override
  String get partnerUntil => 'Until';

  @override
  String get partnerPublish => 'Publish';

  @override
  String get partnerSave => 'Save';

  @override
  String get partnerMyOffers => 'My offers';

  @override
  String get partnerNoOffers => 'You haven\'t published any offer yet.';

  @override
  String get partnerBrandTitleRequired => 'Brand and title are required.';

  @override
  String get partnerOfferUpdated => 'Offer updated.';

  @override
  String get partnerOfferPublished => 'Offer published.';

  @override
  String get partnerCreateChallenge => 'Create a challenge';

  @override
  String get partnerEditChallenge => 'Edit challenge';

  @override
  String get partnerActivity => 'Activity';

  @override
  String get partnerBenefitLabel => 'Benefit (no points)';

  @override
  String get partnerNoChallenges => 'You haven\'t created any challenge yet.';

  @override
  String get partnerChallengeRequired => 'Title and benefit are required.';

  @override
  String get commonError => 'Error';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsWallet => 'Wallet';

  @override
  String get rewardsHistory => 'History';

  @override
  String get rewardsRedeem => 'Redeem';

  @override
  String get rewardEditTitle => 'Edit reward';

  @override
  String get rewardEditChangePhoto => 'Change photo';

  @override
  String get rewardEditRemovePhoto => 'Remove photo';

  @override
  String get rewardEditFieldTitle => 'Title';

  @override
  String get rewardEditFieldPartner => 'Partner';

  @override
  String get rewardEditFieldDescription => 'Description';

  @override
  String get rewardEditFieldPoints => 'Points cost';

  @override
  String get rewardEditFieldStock => 'Stock';

  @override
  String get rewardEditStockHint => 'empty = unlimited';

  @override
  String get rewardEditFieldAddress => 'Address';

  @override
  String get rewardEditValidation => 'Title, partner and a positive points cost are required.';

  @override
  String get rewardsCategoryBooks => 'Books';

  @override
  String get rewardsCategoryCafe => 'Café';

  @override
  String get rewardsCategoryMusic => 'Music';

  @override
  String get rewardsCategoryGoods => 'Goods';

  @override
  String get rewardsCategoryPrint => 'Print';

  @override
  String get rewardsHistoryEmpty => 'No claimed rewards yet.';

  @override
  String rewardsSubtitle(int points) {
    return '$points pts available';
  }

  @override
  String get rewardUnlimited => 'Unlimited';

  @override
  String get rewardLocalPartner => 'local partner';

  @override
  String get rewardCost => 'Cost';

  @override
  String get rewardYourBalance => 'Your balance';

  @override
  String get rewardHowItWorks => 'How it works';

  @override
  String get rewardStep1Title => 'Tap redeem · points held';

  @override
  String get rewardStep1Subtitle => 'Code generated for in-store use';

  @override
  String get rewardStep2Title => 'Show code at the counter';

  @override
  String get rewardStep2Subtitle => 'Valid 24h after redeem';

  @override
  String get rewardStep3Title => 'Staff confirms · points spent';

  @override
  String get rewardStep3Subtitle => 'Receipt saved to your wallet';

  @override
  String get rewardLocationAddress => 'Strada Pictor Verona 13–15';

  @override
  String rewardLocationSchedule(Object stock) {
    return 'Bucharest · Stock: $stock';
  }

  @override
  String rewardRedeemButton(int points) {
    return 'Redeem · $points pts';
  }

  @override
  String rewardNeedMore(int points) {
    return '$points more points needed';
  }

  @override
  String get rewardRedeemedLabel => 'Redeemed';

  @override
  String get rewardValidUntil => 'Valid until tomorrow 18:00';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLevelLabel => 'Climber · Lvl 7';

  @override
  String get profileTotalPoints => 'Total pts';

  @override
  String get profileDayStreak => 'Day streak';

  @override
  String get profileGlobalRank => 'Global rank';

  @override
  String get profileByActivity => 'By activity';

  @override
  String get profileGames => 'games';

  @override
  String get profileConnections => 'Connections';

  @override
  String get profileConnectionStrava => 'Auto-sync activities';

  @override
  String get profileConnectionWhatsapp => 'Event announcements';

  @override
  String get profileConnectionComingSoon => 'Coming soon';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileShowMyQr => 'Show my QR';

  @override
  String get profileAdminCenter => 'Admin center';

  @override
  String get profileLinked => 'Linked';

  @override
  String get profileConnect => 'Connect';

  @override
  String get profileDarkTheme => 'Dark theme';

  @override
  String get profileDarkThemeSubtitle => 'Easier on the eyes after dark';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSystemLanguage => 'System';

  @override
  String get profileSync => 'Sync profile';

  @override
  String get profileSyncFailed => 'Profile sync failed';

  @override
  String profileRankValue(int rank) {
    return '#$rank general';
  }

  @override
  String get authTitle => 'Account access';

  @override
  String get authLoginSubtitle => 'Sign in to sync profile, rewards, and event progress.';

  @override
  String get authRegisterSubtitle => 'Create a Neverest account in a few seconds.';

  @override
  String get authTabLogin => 'Login';

  @override
  String get authTabRegister => 'Register';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authDisplayNameLabel => 'Display name (optional)';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authRegisterButton => 'Create account';

  @override
  String get authSwitchToRegister => 'Need an account? Register';

  @override
  String get authSwitchToLogin => 'Already have an account? Log in';

  @override
  String get authCredentialsRequired => 'Email and password are required.';

  @override
  String get authPhoneRequired => 'Phone number is required.';

  @override
  String get authPhotoOptional => 'Add a photo (optional)';

  @override
  String get authPasswordMinLength => 'Password must have at least 6 characters.';

  @override
  String get authPasswordsMismatch => 'Passwords do not match.';

  @override
  String get authSessionActive => 'Active session';

  @override
  String authSignedAs(Object identity) {
    return 'Signed in as $identity';
  }

  @override
  String get authContinue => 'Continue';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authManageSession => 'Manage account';

  @override
  String get authCardTitle => 'Account';

  @override
  String get authCardSubtitle => 'Log in or register to sync your profile and points.';

  @override
  String get qrSignInRequired => 'Sign in required';

  @override
  String get qrSignInSubtitle => 'Sign in first to load your QR code.';

  @override
  String get qrNotAvailable => 'QR not available';

  @override
  String get qrUnavailableSubtitle => 'Profile QR is not available yet.';

  @override
  String get qrMemberId => 'Member ID';

  @override
  String get qrShowAtGate => 'SHOW THIS\nAT THE GATE';

  @override
  String get qrScanHint => 'Organizer scans → points credited';

  @override
  String qrRefreshCountdown(String time) {
    return 'Refreshes in $time';
  }

  @override
  String get adminScanHeader => '● Admin · Sunrise Run';

  @override
  String get adminScanHint => 'Align member QR inside the frame';

  @override
  String get adminScanManualCheckin => 'Simulate check-in';

  @override
  String get adminScanManualInput => 'Manual code input';

  @override
  String get adminScanSubmit => 'Submit check-in';

  @override
  String get adminScanReset => 'Scan again';

  @override
  String get adminScanFailed => 'Check-in failed.';

  @override
  String get adminScanCheckedIn => 'Checked in';

  @override
  String adminScanPointsCredited(int points) {
    return '+$points pts credited';
  }

  @override
  String adminScanCheckedInCount(int count) {
    return 'Checked in · $count';
  }

  @override
  String adminScanCapacity(int count) {
    return '$count cap';
  }

  @override
  String adminScanSpots(int count, int capacity) {
    return '$count / $capacity spots';
  }

  @override
  String get adminScanCapacityExceeded => 'Number of spots exceeded';

  @override
  String get adminScanNext => 'Next scan';

  @override
  String get dashboardLoadFailed => 'Could not load dashboard data.';
}
