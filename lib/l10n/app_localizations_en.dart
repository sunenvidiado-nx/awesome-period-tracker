// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get periodReminderChannelName => 'Period Reminders';

  @override
  String get periodReminderChannelDescription => 'Notifications for upcoming periods';

  @override
  String get pinVerification => 'PIN Verification';

  @override
  String get toGetStartedEnterTheDesignatedPin => 'To get started, enter the designated PIN.';

  @override
  String todayDate(String date) {
    return 'Today, $date';
  }

  @override
  String flowLevel(String level) {
    return 'Flow level:\n$level';
  }

  @override
  String get logCycleEvent => 'Log cycle event';

  @override
  String get today => 'Today';

  @override
  String get whatWouldYouLikeToLog => 'What would you like to log?';

  @override
  String get fertility => 'Fertility';

  @override
  String get logPeriod => 'Log period';

  @override
  String get logSymptoms => 'Log symptoms';

  @override
  String get logIntimacy => 'Log intimacy';

  @override
  String get logPeriodForToday => 'Log period for today';

  @override
  String get logSymptomsExperiencedToday => 'Log symptoms experienced today';

  @override
  String get logIntimateActivityForToday => 'Log intimate activity for today';

  @override
  String get cycleEventLoggedSuccessfully => 'Cycle event logged successfully';

  @override
  String get anErrorOccurredWhileProcessingYourRequest => 'An error occurred while processing your request.';

  @override
  String get crampsHeadachesSorenessEtc => 'Cramps, headaches, soreness, etc.';

  @override
  String get insomniaFatigueAcneNauseaEtc => 'Insomnia, fatigue, acne, nausea, etc.';

  @override
  String get moodSwingsIrritabilityAnxietyEtc => 'Mood swings, irritability, anxiety, etc.';

  @override
  String get anySymptomNotListedOrCategorized => 'Symptoms not listed or categorized.';

  @override
  String get describeOtherSymptomsOptional => 'Describe other symptoms (optional)';

  @override
  String get usedProtection => 'Used protection';

  @override
  String get didNotUseProtection => 'Did not use protection';

  @override
  String get longGenericError => 'An error occurred while processing your request.';

  @override
  String get genericError => 'An error has occurred.';

  @override
  String get shortGenericError => 'Error occurred.';

  @override
  String get veryShortGenericError => 'Error.';

  @override
  String get cycleDay => 'Cycle day';

  @override
  String dayN(int n) {
    return 'Day $n';
  }

  @override
  String get phase => 'Phase';

  @override
  String currentlyInThePhasePhase(String phase) {
    return 'Currently in the $phase phase';
  }

  @override
  String get fertileWindow => 'Fertile window';

  @override
  String inNDays(int n) {
    return 'In $n days';
  }

  @override
  String get inOneDay => 'In 1 day';

  @override
  String chancesOfGettingPregnant(String chance) {
    return '$chance chances of getting pregnant';
  }

  @override
  String get low => 'Low';

  @override
  String get high => 'High';

  @override
  String get intimacy => 'Intimacy';

  @override
  String usedProtectionYesOrNo(String yesOrNo) {
    return 'Used protection: $yesOrNo';
  }

  @override
  String get cycleInsights => 'Cycle insights';

  @override
  String get cycleMetrics => 'Cycle metrics';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get noSymptomsLogged => 'No symptoms logged';

  @override
  String get noPeriodLoggedForThisDay => 'No period logged for this day';

  @override
  String get expectedToday => 'Expected today';

  @override
  String get periodLogged => 'Period logged';

  @override
  String get noLogs => 'No logs';

  @override
  String get gotFreaky => 'Got freaky';

  @override
  String get noFreaky => 'No freaky';

  @override
  String get noIntimateActivitiesLoggedForToday => 'No intimate activities logged for today';

  @override
  String get period => 'Period';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get selectPeriodFlowLevel => 'Select period flow level';

  @override
  String get removeLog => 'Remove log';

  @override
  String get cycleEventsHaveBeenUpdated => 'Cycle events have been updated.';

  @override
  String get addSymptom => 'Add symptom';

  @override
  String get addNewSymptom => 'Add new symptom';

  @override
  String get fieldCantBeEmpty => 'Field can\'t be empty';

  @override
  String get symptom => 'Symptom';

  @override
  String get incorrectPinError => 'Incorrect PIN.';

  @override
  String get firebaseGenericError => 'An error occurred. Please try again later.';

  @override
  String get dioGenericError => 'An error occurred with the API. Please try again later.';

  @override
  String get insightsGenericError => 'An error occurred while generating insights. Please try again later.';

  @override
  String get upcomingPeriodNotificationTitle => 'Upcoming Period';

  @override
  String get upcomingPeriodNotificationBody => 'Your next period is expected to start in one week';
}
