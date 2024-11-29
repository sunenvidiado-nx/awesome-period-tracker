import 'package:awesome_period_tracker/core/infrastructure/state_manager.dart';
import 'package:awesome_period_tracker/features/login/domain/auth_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

part 'set_user_name_state.dart';

@injectable
class SetUserNameStateManager extends StateManager<SetUserNameState> {
  SetUserNameStateManager(
    this._authRepository,
    this._firebaseAnalytics,
  ) : super(const SetUserNameState());

  final AuthRepository _authRepository;
  final FirebaseAnalytics _firebaseAnalytics;

  Future<void> setUserName(String userName) async {
    try {
      notifier.value = notifier.value.copyWith(isLoading: true);
      await _authRepository.setUserName(userName);
      _firebaseAnalytics.logEvent(name: 'set_user_name');
    } catch (e) {
      // TODO Handle error
    } finally {
      notifier.value = notifier.value.copyWith(isLoading: false);
    }
  }
}
