import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Neverest'**
  String get appTitle;

  /// No description provided for @no_internet_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet_connection;

  /// No description provided for @increase_version.
  ///
  /// In en, this message translates to:
  /// **'Please update the application to the latest version.'**
  String get increase_version;

  /// No description provided for @internal_server_error.
  ///
  /// In en, this message translates to:
  /// **'An unexpected server error occurred. Please try again later.'**
  String get internal_server_error;

  /// No description provided for @unknown_error.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknown_error;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get unauthorized;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navChallenges.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navChallenges;

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get navLeaderboard;

  /// No description provided for @navRewards.
  ///
  /// In en, this message translates to:
  /// **'Perks'**
  String get navRewards;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @commonOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get commonOverall;

  /// No description provided for @commonPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get commonPoints;

  /// No description provided for @commonPointsShort.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get commonPointsShort;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @activityRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityRunning;

  /// No description provided for @activityPadel.
  ///
  /// In en, this message translates to:
  /// **'Padel'**
  String get activityPadel;

  /// No description provided for @activityMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get activityMountain;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingHeadline1.
  ///
  /// In en, this message translates to:
  /// **'NO SUMMIT.\nNO LIMIT.'**
  String get onboardingHeadline1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'A club for movement, mountains, and mornings worth showing up to.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingCta1.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingCta1;

  /// No description provided for @onboardingHeadline2.
  ///
  /// In en, this message translates to:
  /// **'MOVE.\nEARN POINTS.'**
  String get onboardingHeadline2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Run, hike, play padel. Show up at events. Hit weekly challenges. Every move counts.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingCta2.
  ///
  /// In en, this message translates to:
  /// **'Sounds good'**
  String get onboardingCta2;

  /// No description provided for @onboardingHeadline3.
  ///
  /// In en, this message translates to:
  /// **'SPEND THEM\nLOCALLY.'**
  String get onboardingHeadline3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Cărturești, Origo, MOCA, your favorite coach. Real perks from real Bucharest.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingCta3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingCta3;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @homeLiveNow.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get homeLiveNow;

  /// No description provided for @homeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeThisWeek;

  /// No description provided for @homeActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get homeActivities;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get homeStreak;

  /// No description provided for @homeStartChallenge.
  ///
  /// In en, this message translates to:
  /// **'Start challenge'**
  String get homeStartChallenge;

  /// No description provided for @homeFindEvents.
  ///
  /// In en, this message translates to:
  /// **'Find events'**
  String get homeFindEvents;

  /// No description provided for @homeTrackingLive.
  ///
  /// In en, this message translates to:
  /// **'Tracking · live'**
  String get homeTrackingLive;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeSpendPoints.
  ///
  /// In en, this message translates to:
  /// **'Spend your points'**
  String get homeSpendPoints;

  /// No description provided for @homeActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String homeActiveCount(int count);

  /// No description provided for @homeThisWeekCount.
  ///
  /// In en, this message translates to:
  /// **'{count} this week'**
  String homeThisWeekCount(int count);

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @eventsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No events match this filter.'**
  String get eventsEmptyState;

  /// No description provided for @eventsGoingLabel.
  ///
  /// In en, this message translates to:
  /// **'going'**
  String get eventsGoingLabel;

  /// No description provided for @eventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} this week · {attending} attending'**
  String eventsSubtitle(int count, int attending);

  /// No description provided for @eventWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get eventWhen;

  /// No description provided for @eventWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get eventWhere;

  /// No description provided for @eventHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get eventHost;

  /// No description provided for @eventReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get eventReward;

  /// No description provided for @eventAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get eventAbout;

  /// No description provided for @eventAboutSample.
  ///
  /// In en, this message translates to:
  /// **'Easy 8K with mid-pace and recovery groups. Coffee at Origo after. Rain or shine. Show your QR at the gate to claim points.'**
  String get eventAboutSample;

  /// No description provided for @eventWhatsappSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-posted to #announcements and Neverest Strava Club'**
  String get eventWhatsappSync;

  /// No description provided for @eventRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get eventRoute;

  /// No description provided for @eventAdminCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Admin check-in'**
  String get eventAdminCheckIn;

  /// No description provided for @eventImGoing.
  ///
  /// In en, this message translates to:
  /// **'I\'m going'**
  String get eventImGoing;

  /// No description provided for @eventGoing.
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get eventGoing;

  /// No description provided for @eventAttendeesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} going'**
  String eventAttendeesCount(int count);

  /// No description provided for @eventSpotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} spots left'**
  String eventSpotsLeft(int count);

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// No description provided for @challengesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn points your way'**
  String get challengesSubtitle;

  /// No description provided for @challengesEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get challengesEarned;

  /// No description provided for @challengesActiveCount.
  ///
  /// In en, this message translates to:
  /// **'Active · {count}'**
  String challengesActiveCount(int count);

  /// No description provided for @challengesCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed · {count}'**
  String challengesCompletedCount(int count);

  /// No description provided for @challengeLiveTracking.
  ///
  /// In en, this message translates to:
  /// **'Live tracking'**
  String get challengeLiveTracking;

  /// No description provided for @challengeRouteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Walk or run · 7.4 km'**
  String get challengeRouteSubtitle;

  /// No description provided for @challengeDistanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Any activity · all surfaces'**
  String get challengeDistanceSubtitle;

  /// No description provided for @challengeMorningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move before 8AM · 3 days'**
  String get challengeMorningSubtitle;

  /// No description provided for @challengePadelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Logged at events'**
  String get challengePadelSubtitle;

  /// No description provided for @challengeForestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'6 km · marked route'**
  String get challengeForestSubtitle;

  /// No description provided for @challengeDeadlineSun.
  ///
  /// In en, this message translates to:
  /// **'Ends Sun'**
  String get challengeDeadlineSun;

  /// No description provided for @challengeDeadlineJune.
  ///
  /// In en, this message translates to:
  /// **'Ends Jun 1'**
  String get challengeDeadlineJune;

  /// No description provided for @challengeAlwaysOn.
  ///
  /// In en, this message translates to:
  /// **'Always on'**
  String get challengeAlwaysOn;

  /// No description provided for @challengeProgress23.
  ///
  /// In en, this message translates to:
  /// **'2/3 done'**
  String get challengeProgress23;

  /// No description provided for @challengeDeadlineDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String challengeDeadlineDays(int days);

  /// No description provided for @challengePaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get challengePaused;

  /// No description provided for @challengeGpsLive.
  ///
  /// In en, this message translates to:
  /// **'GPS · Live'**
  String get challengeGpsLive;

  /// No description provided for @challengeDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get challengeDestination;

  /// No description provided for @challengeDestinationValue.
  ///
  /// In en, this message translates to:
  /// **'Arcul de Triumf'**
  String get challengeDestinationValue;

  /// No description provided for @challengeRemainingKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km to go'**
  String challengeRemainingKm(Object distance);

  /// No description provided for @challengeRouteHeadline.
  ///
  /// In en, this message translates to:
  /// **'● Challenge · Centrul Vechi → Arcul de Triumf'**
  String get challengeRouteHeadline;

  /// No description provided for @challengeOnFinishPoints.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts on finish'**
  String challengeOnFinishPoints(int points);

  /// No description provided for @challengeProgressLine.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · {currentKm}/{totalKm} km'**
  String challengeProgressLine(int percent, Object currentKm, Object totalKm);

  /// No description provided for @challengeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get challengeTime;

  /// No description provided for @challengePace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get challengePace;

  /// No description provided for @challengeSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get challengeSteps;

  /// No description provided for @challengeResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get challengeResume;

  /// No description provided for @challengePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get challengePause;

  /// No description provided for @challengeAdminReviewMode.
  ///
  /// In en, this message translates to:
  /// **'Admin review mode'**
  String get challengeAdminReviewMode;

  /// No description provided for @challengeAdminReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable to list all submissions and review.'**
  String get challengeAdminReviewSubtitle;

  /// No description provided for @challengeNoSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet.'**
  String get challengeNoSubmissions;

  /// No description provided for @challengeNoPersonalSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No personal submissions yet.'**
  String get challengeNoPersonalSubmissions;

  /// No description provided for @challengeProofRequired.
  ///
  /// In en, this message translates to:
  /// **'Proof text is required.'**
  String get challengeProofRequired;

  /// No description provided for @challengeMetricMustBeNumeric.
  ///
  /// In en, this message translates to:
  /// **'Metric value must be numeric.'**
  String get challengeMetricMustBeNumeric;

  /// No description provided for @challengeAdminRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin role is required for submission review.'**
  String get challengeAdminRequired;

  /// No description provided for @challengeApproveSubmission.
  ///
  /// In en, this message translates to:
  /// **'Approve submission'**
  String get challengeApproveSubmission;

  /// No description provided for @challengeRejectSubmission.
  ///
  /// In en, this message translates to:
  /// **'Reject submission'**
  String get challengeRejectSubmission;

  /// No description provided for @challengeReviewerNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Reviewer note (optional)'**
  String get challengeReviewerNoteOptional;

  /// No description provided for @challengeSubmitProgress.
  ///
  /// In en, this message translates to:
  /// **'Submit progress'**
  String get challengeSubmitProgress;

  /// No description provided for @challengeProofLabel.
  ///
  /// In en, this message translates to:
  /// **'Proof text'**
  String get challengeProofLabel;

  /// No description provided for @challengeMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Metric value (optional)'**
  String get challengeMetricLabel;

  /// No description provided for @challengeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit challenge'**
  String get challengeSubmit;

  /// No description provided for @challengeSubmissionId.
  ///
  /// In en, this message translates to:
  /// **'Submission {id}'**
  String challengeSubmissionId(Object id);

  /// No description provided for @challengeProofField.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get challengeProofField;

  /// No description provided for @challengeMetricField.
  ///
  /// In en, this message translates to:
  /// **'Metric value'**
  String get challengeMetricField;

  /// No description provided for @challengeAwardedPoints.
  ///
  /// In en, this message translates to:
  /// **'Awarded points'**
  String get challengeAwardedPoints;

  /// No description provided for @challengeReviewerNote.
  ///
  /// In en, this message translates to:
  /// **'Reviewer note'**
  String get challengeReviewerNote;

  /// No description provided for @challengeApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get challengeApprove;

  /// No description provided for @challengeReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get challengeReject;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updates every minute'**
  String get leaderboardSubtitle;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewardsWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get rewardsWallet;

  /// No description provided for @rewardsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get rewardsHistory;

  /// No description provided for @rewardsRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get rewardsRedeem;

  /// No description provided for @rewardsCategoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get rewardsCategoryBooks;

  /// No description provided for @rewardsCategoryCafe.
  ///
  /// In en, this message translates to:
  /// **'Café'**
  String get rewardsCategoryCafe;

  /// No description provided for @rewardsCategoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get rewardsCategoryMusic;

  /// No description provided for @rewardsCategoryGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get rewardsCategoryGoods;

  /// No description provided for @rewardsCategoryPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get rewardsCategoryPrint;

  /// No description provided for @rewardsHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No claimed rewards yet.'**
  String get rewardsHistoryEmpty;

  /// No description provided for @rewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{points} pts available'**
  String rewardsSubtitle(int points);

  /// No description provided for @rewardUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get rewardUnlimited;

  /// No description provided for @rewardLocalPartner.
  ///
  /// In en, this message translates to:
  /// **'local partner'**
  String get rewardLocalPartner;

  /// No description provided for @rewardCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get rewardCost;

  /// No description provided for @rewardYourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get rewardYourBalance;

  /// No description provided for @rewardHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get rewardHowItWorks;

  /// No description provided for @rewardStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Tap redeem · points held'**
  String get rewardStep1Title;

  /// No description provided for @rewardStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Code generated for in-store use'**
  String get rewardStep1Subtitle;

  /// No description provided for @rewardStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Show code at the counter'**
  String get rewardStep2Title;

  /// No description provided for @rewardStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Valid 24h after redeem'**
  String get rewardStep2Subtitle;

  /// No description provided for @rewardStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Staff confirms · points spent'**
  String get rewardStep3Title;

  /// No description provided for @rewardStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt saved to your wallet'**
  String get rewardStep3Subtitle;

  /// No description provided for @rewardLocationAddress.
  ///
  /// In en, this message translates to:
  /// **'Strada Pictor Verona 13–15'**
  String get rewardLocationAddress;

  /// No description provided for @rewardLocationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Bucharest · Stock: {stock}'**
  String rewardLocationSchedule(Object stock);

  /// No description provided for @rewardRedeemButton.
  ///
  /// In en, this message translates to:
  /// **'Redeem · {points} pts'**
  String rewardRedeemButton(int points);

  /// No description provided for @rewardNeedMore.
  ///
  /// In en, this message translates to:
  /// **'{points} more points needed'**
  String rewardNeedMore(int points);

  /// No description provided for @rewardRedeemedLabel.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get rewardRedeemedLabel;

  /// No description provided for @rewardValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until tomorrow 18:00'**
  String get rewardValidUntil;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Climber · Lvl 7'**
  String get profileLevelLabel;

  /// No description provided for @profileTotalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total pts'**
  String get profileTotalPoints;

  /// No description provided for @profileDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get profileDayStreak;

  /// No description provided for @profileGlobalRank.
  ///
  /// In en, this message translates to:
  /// **'Global rank'**
  String get profileGlobalRank;

  /// No description provided for @profileByActivity.
  ///
  /// In en, this message translates to:
  /// **'By activity'**
  String get profileByActivity;

  /// No description provided for @profileGames.
  ///
  /// In en, this message translates to:
  /// **'games'**
  String get profileGames;

  /// No description provided for @profileConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get profileConnections;

  /// No description provided for @profileConnectionStrava.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync activities'**
  String get profileConnectionStrava;

  /// No description provided for @profileConnectionWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Event announcements'**
  String get profileConnectionWhatsapp;

  /// No description provided for @profileConnectionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get profileConnectionComingSoon;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileShowMyQr.
  ///
  /// In en, this message translates to:
  /// **'Show my QR'**
  String get profileShowMyQr;

  /// No description provided for @profileAdminCenter.
  ///
  /// In en, this message translates to:
  /// **'Admin center'**
  String get profileAdminCenter;

  /// No description provided for @profileLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get profileLinked;

  /// No description provided for @profileConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get profileConnect;

  /// No description provided for @profileDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get profileDarkTheme;

  /// No description provided for @profileDarkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easier on the eyes after dark'**
  String get profileDarkThemeSubtitle;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileSystemLanguage;

  /// No description provided for @profileSync.
  ///
  /// In en, this message translates to:
  /// **'Sync profile'**
  String get profileSync;

  /// No description provided for @profileSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile sync failed'**
  String get profileSyncFailed;

  /// No description provided for @profileRankValue.
  ///
  /// In en, this message translates to:
  /// **'#{rank} general'**
  String profileRankValue(int rank);

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get authTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync profile, rewards, and event progress.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Neverest account in a few seconds.'**
  String get authRegisterSubtitle;

  /// No description provided for @authTabLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authTabLogin;

  /// No description provided for @authTabRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authTabRegister;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get authDisplayNameLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterButton;

  /// No description provided for @authSwitchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Register'**
  String get authSwitchToRegister;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get authSwitchToLogin;

  /// No description provided for @authCredentialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required.'**
  String get authCredentialsRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 6 characters.'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsMismatch;

  /// No description provided for @authSessionActive.
  ///
  /// In en, this message translates to:
  /// **'Active session'**
  String get authSessionActive;

  /// No description provided for @authSignedAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {identity}'**
  String authSignedAs(Object identity);

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authManageSession.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get authManageSession;

  /// No description provided for @authCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authCardTitle;

  /// No description provided for @authCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in or register to sync your profile and points.'**
  String get authCardSubtitle;

  /// No description provided for @qrSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get qrSignInRequired;

  /// No description provided for @qrSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to load your QR code.'**
  String get qrSignInSubtitle;

  /// No description provided for @qrNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'QR not available'**
  String get qrNotAvailable;

  /// No description provided for @qrUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile QR is not available yet.'**
  String get qrUnavailableSubtitle;

  /// No description provided for @qrMemberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get qrMemberId;

  /// No description provided for @qrShowAtGate.
  ///
  /// In en, this message translates to:
  /// **'SHOW THIS\nAT THE GATE'**
  String get qrShowAtGate;

  /// No description provided for @qrScanHint.
  ///
  /// In en, this message translates to:
  /// **'Organizer scans → points credited'**
  String get qrScanHint;

  /// No description provided for @qrRefreshCountdown.
  ///
  /// In en, this message translates to:
  /// **'Refreshes in 0:42'**
  String get qrRefreshCountdown;

  /// No description provided for @adminScanHeader.
  ///
  /// In en, this message translates to:
  /// **'● Admin · Sunrise Run'**
  String get adminScanHeader;

  /// No description provided for @adminScanHint.
  ///
  /// In en, this message translates to:
  /// **'Align member QR inside the frame'**
  String get adminScanHint;

  /// No description provided for @adminScanManualCheckin.
  ///
  /// In en, this message translates to:
  /// **'Simulate check-in'**
  String get adminScanManualCheckin;

  /// No description provided for @adminScanManualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual QR input'**
  String get adminScanManualInput;

  /// No description provided for @adminScanSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit check-in'**
  String get adminScanSubmit;

  /// No description provided for @adminScanReset.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get adminScanReset;

  /// No description provided for @adminScanFailed.
  ///
  /// In en, this message translates to:
  /// **'Check-in failed.'**
  String get adminScanFailed;

  /// No description provided for @adminScanCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get adminScanCheckedIn;

  /// No description provided for @adminScanPointsCredited.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts credited'**
  String adminScanPointsCredited(int points);

  /// No description provided for @adminScanCheckedInCount.
  ///
  /// In en, this message translates to:
  /// **'Checked in · {count}'**
  String adminScanCheckedInCount(int count);

  /// No description provided for @adminScanCapacity.
  ///
  /// In en, this message translates to:
  /// **'{count} cap'**
  String adminScanCapacity(int count);

  /// No description provided for @adminScanNext.
  ///
  /// In en, this message translates to:
  /// **'Next scan'**
  String get adminScanNext;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load dashboard data.'**
  String get dashboardLoadFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ro': return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
