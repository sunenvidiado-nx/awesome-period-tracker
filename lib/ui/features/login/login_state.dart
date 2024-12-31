part of 'login_state_manager.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = InitialLoginState;
  const factory LoginState.loading() = LoadingLoginState;
  const factory LoginState.error([String? errorMessage]) = ErrorLoginState;
  const factory LoginState.data() = DataLoginState;
}
