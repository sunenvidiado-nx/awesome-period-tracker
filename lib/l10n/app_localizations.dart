import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
    Locale('en')
  ];

  /// No description provided for @periodReminderChannelName.
  ///
  /// In en, this message translates to:
  /// **'Period Reminders'**
  String get periodReminderChannelName;

  /// No description provided for @periodReminderChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for upcoming periods'**
  String get periodReminderChannelDescription;

  /// No description provided for @pinVerification.
  ///
  /// In en, this message translates to:
  /// **'PIN Verification'**
  String get pinVerification;

  /// No description provided for @toGetStartedEnterTheDesignatedPin.
  ///
  /// In en, this message translates to:
  /// **'To get started, enter the designated PIN.'**
  String get toGetStartedEnterTheDesignatedPin;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String todayDate(String date);

  /// No description provided for @flowLevel.
  ///
  /// In en, this message translates to:
  /// **'Flow level:\n{level}'**
  String flowLevel(String level);

  /// No description provided for @logCycleEvent.
  ///
  /// In en, this message translates to:
  /// **'Log cycle event'**
  String get logCycleEvent;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @whatWouldYouLikeToLog.
  ///
  /// In en, this message translates to:
  /// **'What would you like to log?'**
  String get whatWouldYouLikeToLog;

  /// No description provided for @fertility.
  ///
  /// In en, this message translates to:
  /// **'Fertility'**
  String get fertility;

  /// No description provided for @logPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log period'**
  String get logPeriod;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms'**
  String get logSymptoms;

  /// No description provided for @logIntimacy.
  ///
  /// In en, this message translates to:
  /// **'Log intimacy'**
  String get logIntimacy;

  /// No description provided for @logPeriodForToday.
  ///
  /// In en, this message translates to:
  /// **'Log period for today'**
  String get logPeriodForToday;

  /// No description provided for @logSymptomsExperiencedToday.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms experienced today'**
  String get logSymptomsExperiencedToday;

  /// No description provided for @logIntimateActivityForToday.
  ///
  /// In en, this message translates to:
  /// **'Log intimate activity for today'**
  String get logIntimateActivityForToday;

  /// No description provided for @cycleEventLoggedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Cycle event logged successfully'**
  String get cycleEventLoggedSuccessfully;

  /// No description provided for @anErrorOccurredWhileProcessingYourRequest.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing your request.'**
  String get anErrorOccurredWhileProcessingYourRequest;

  /// No description provided for @crampsHeadachesSorenessEtc.
  ///
  /// In en, this message translates to:
  /// **'Cramps, headaches, soreness, etc.'**
  String get crampsHeadachesSorenessEtc;

  /// No description provided for @insomniaFatigueAcneNauseaEtc.
  ///
  /// In en, this message translates to:
  /// **'Insomnia, fatigue, acne, nausea, etc.'**
  String get insomniaFatigueAcneNauseaEtc;

  /// No description provided for @moodSwingsIrritabilityAnxietyEtc.
  ///
  /// In en, this message translates to:
  /// **'Mood swings, irritability, anxiety, etc.'**
  String get moodSwingsIrritabilityAnxietyEtc;

  /// No description provided for @anySymptomNotListedOrCategorized.
  ///
  /// In en, this message translates to:
  /// **'Symptoms not listed or categorized.'**
  String get anySymptomNotListedOrCategorized;

  /// No description provided for @describeOtherSymptomsOptional.
  ///
  /// In en, this message translates to:
  /// **'Describe other symptoms (optional)'**
  String get describeOtherSymptomsOptional;

  /// No description provided for @usedProtection.
  ///
  /// In en, this message translates to:
  /// **'Used protection'**
  String get usedProtection;

  /// No description provided for @didNotUseProtection.
  ///
  /// In en, this message translates to:
  /// **'Did not use protection'**
  String get didNotUseProtection;

  /// No description provided for @longGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing your request.'**
  String get longGenericError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred.'**
  String get genericError;

  /// No description provided for @shortGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred.'**
  String get shortGenericError;

  /// No description provided for @veryShortGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error.'**
  String get veryShortGenericError;

  /// No description provided for @cycleDay.
  ///
  /// In en, this message translates to:
  /// **'Cycle day'**
  String get cycleDay;

  /// No description provided for @dayN.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String dayN(int n);

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @currentlyInThePhasePhase.
  ///
  /// In en, this message translates to:
  /// **'Currently in the {phase} phase'**
  String currentlyInThePhasePhase(String phase);

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get fertileWindow;

  /// No description provided for @inNDays.
  ///
  /// In en, this message translates to:
  /// **'In {n} days'**
  String inNDays(int n);

  /// No description provided for @inOneDay.
  ///
  /// In en, this message translates to:
  /// **'In 1 day'**
  String get inOneDay;

  /// No description provided for @chancesOfGettingPregnant.
  ///
  /// In en, this message translates to:
  /// **'{chance} chances of getting pregnant'**
  String chancesOfGettingPregnant(String chance);

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @intimacy.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get intimacy;

  /// No description provided for @usedProtectionYesOrNo.
  ///
  /// In en, this message translates to:
  /// **'Used protection: {yesOrNo}'**
  String usedProtectionYesOrNo(String yesOrNo);

  /// No description provided for @cycleInsights.
  ///
  /// In en, this message translates to:
  /// **'Cycle insights'**
  String get cycleInsights;

  /// No description provided for @cycleMetrics.
  ///
  /// In en, this message translates to:
  /// **'Cycle metrics'**
  String get cycleMetrics;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @noSymptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged'**
  String get noSymptomsLogged;

  /// No description provided for @noPeriodLoggedForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No period logged for this day'**
  String get noPeriodLoggedForThisDay;

  /// No description provided for @expectedToday.
  ///
  /// In en, this message translates to:
  /// **'Expected today'**
  String get expectedToday;

  /// No description provided for @periodLogged.
  ///
  /// In en, this message translates to:
  /// **'Period logged'**
  String get periodLogged;

  /// No description provided for @noLogs.
  ///
  /// In en, this message translates to:
  /// **'No logs'**
  String get noLogs;

  /// No description provided for @gotFreaky.
  ///
  /// In en, this message translates to:
  /// **'Got freaky'**
  String get gotFreaky;

  /// No description provided for @noFreaky.
  ///
  /// In en, this message translates to:
  /// **'No freaky'**
  String get noFreaky;

  /// No description provided for @noIntimateActivitiesLoggedForToday.
  ///
  /// In en, this message translates to:
  /// **'No intimate activities logged for today'**
  String get noIntimateActivitiesLoggedForToday;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @selectPeriodFlowLevel.
  ///
  /// In en, this message translates to:
  /// **'Select period flow level'**
  String get selectPeriodFlowLevel;

  /// No description provided for @removeLog.
  ///
  /// In en, this message translates to:
  /// **'Remove log'**
  String get removeLog;

  /// No description provided for @cycleEventsHaveBeenUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cycle events have been updated.'**
  String get cycleEventsHaveBeenUpdated;

  /// No description provided for @addSymptom.
  ///
  /// In en, this message translates to:
  /// **'Add symptom'**
  String get addSymptom;

  /// No description provided for @addNewSymptom.
  ///
  /// In en, this message translates to:
  /// **'Add new symptom'**
  String get addNewSymptom;

  /// No description provided for @fieldCantBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Field can\'t be empty'**
  String get fieldCantBeEmpty;

  /// No description provided for @symptom.
  ///
  /// In en, this message translates to:
  /// **'Symptom'**
  String get symptom;

  /// No description provided for @incorrectPinError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get incorrectPinError;

  /// No description provided for @firebaseGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later.'**
  String get firebaseGenericError;

  /// No description provided for @dioGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred with the API. Please try again later.'**
  String get dioGenericError;

  /// No description provided for @insightsGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while generating insights. Please try again later.'**
  String get insightsGenericError;

  /// No description provided for @upcomingPeriodNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Period'**
  String get upcomingPeriodNotificationTitle;

  /// No description provided for @upcomingPeriodNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your next period is expected to start in one week'**
  String get upcomingPeriodNotificationBody;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
