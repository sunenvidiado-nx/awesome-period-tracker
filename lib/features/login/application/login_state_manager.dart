import 'package:awesome_period_tracker/core/infrastructure/state_manager.dart';
import 'package:awesome_period_tracker/features/login/domain/auth_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';

@injectable
class LoginStateManager extends StateManager<LoginState> {
  LoginStateManager(
    this._authRepository,
    this._firebaseAnalytics,
  ) : super(const LoginState());

  final AuthRepository _authRepository;
  final FirebaseAnalytics _firebaseAnalytics;

  Future<void> login(String email, String password) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);
      await _authRepository.logInWithEmailAndPassword(email, password);
      _firebaseAnalytics.logLogin();
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }
}
