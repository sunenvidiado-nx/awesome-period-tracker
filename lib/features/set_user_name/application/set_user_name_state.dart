part of 'set_user_name_state_manager.dart';

class SetUserNameState {
  const SetUserNameState({this.isLoading = false});

  final bool isLoading;

  SetUserNameState copyWith({bool? isLoading}) {
    return SetUserNameState(isLoading: isLoading ?? this.isLoading);
  }

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is SetUserNameState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading;

  @override
  int get hashCode => isLoading.hashCode;
}
