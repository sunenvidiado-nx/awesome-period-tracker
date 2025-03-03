import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:envied/envied.dart';
import 'package:injectable/injectable.dart';

part 'prod_env.g.dart';

@Envied(path: '.env', useConstantCase: true)
@Singleton(as: Env)
class ProdEnv implements Env {
  @override
  @EnviedField(obfuscate: true)
  final String loginEmail = _ProdEnv.loginEmail;

  @override
  @EnviedField(obfuscate: true)
  final String geminiApiKey = _ProdEnv.geminiApiKey;

  @override
  @EnviedField(obfuscate: true)
  final String systemId = _ProdEnv.systemId;

  @override
  @EnviedField(obfuscate: true)
  final String cyclePhaseApiKey = _ProdEnv.cyclePhaseApiKey;

  @override
  @EnviedField(obfuscate: true)
  final String cyclePhaseApiUrl = _ProdEnv.cyclePhaseApiUrl;
}
