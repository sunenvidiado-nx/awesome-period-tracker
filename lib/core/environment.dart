import 'package:envied/envied.dart';

part 'environment.g.dart';

@Envied()
abstract class Environment {
  @EnviedField(varName: 'LOGIN_EMAIL', obfuscate: true)
  static String loginEmail = _Environment.loginEmail;

  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static String geminiApiKey = _Environment.geminiApiKey;

  @EnviedField(varName: 'SYSTEM_ID', obfuscate: true)
  static String systemId = _Environment.systemId;

  @EnviedField(varName: 'CYCLE_EVENTS_PATH', obfuscate: true)
  static String cycleEventsPath = _Environment.cycleEventsPath;
}
