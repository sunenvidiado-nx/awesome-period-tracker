import 'package:awesome_period_tracker/config/state_manager.dart';
import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';
part 'login_state_manager.freezed.dart';

@injectable
class LoginStateManager extends StateManager<LoginState> {
  LoginStateManager(
    this._authRepository,
    this._firebaseAnalytics,
  ) : super(const LoginState.initial());

  final AuthRepository _authRepository;
  final FirebaseAnalytics _firebaseAnalytics;

  Future<void> login(String email, String password) async {
    try {
      notifier.value = const LoginState.loading();

      await _authRepository.logInWithEmailAndPassword(email, password);
      _firebaseAnalytics.logLogin();

      notifier.value = const LoginState.data();
    } catch (e) {
      notifier.value = LoginState.error(e.toString());
    }
  }
}
