import 'package:flutter/foundation.dart';

/// Base class for state managers.
abstract class StateManager<T> {
  /// The state notifier that will be used to manage the state.
  ///
  /// Pass this to a [ValueListenableBuilder] to listen to changes in the state.
  final ValueNotifier<T> notifier;

  /// Constructor that initializes the notifier with an initial state.
  StateManager(T initialState) : notifier = ValueNotifier(initialState);

  /// Disposes the notifier to avoid memory leaks.
  @mustCallSuper
  void dispose() {
    notifier.dispose();
  }

  /// Updates the state with a new value.
  set state(T value) => notifier.value = value;

  /// Returns the current state.
  T get state => notifier.value;
}
