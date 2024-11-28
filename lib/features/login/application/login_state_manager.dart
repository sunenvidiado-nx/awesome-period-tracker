import 'package:awesome_period_tracker/core/infrastructure/state_manager.dart';
import 'package:awesome_period_tracker/features/login/domain/auth_repository.dart';
import 'package:injectable/injectable.dart';

part 'login_state.dart';

@injectable
class LoginStateManager extends StateManager<LoginState> {
  LoginStateManager(
    this._authRepository,
  ) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<void> login(String email, String password) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);
      await _authRepository.logInWithEmailAndPassword(email, password);
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }
}
