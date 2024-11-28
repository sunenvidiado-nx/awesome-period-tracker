part of 'login_state_manager.dart';

class LoginState {
  const LoginState({
    this.errorMessage = '',
    this.isLoading = false,
  });

  final String errorMessage;
  final bool isLoading;

  LoginState copyWith({String? errorMessage, bool? isLoading}) {
    return LoginState(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginState &&
        other.errorMessage == errorMessage &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => errorMessage.hashCode ^ isLoading.hashCode;
}
