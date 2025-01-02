import 'package:flutter/foundation.dart';

/// Base class for state managers.
abstract class StateManager<T> {
  /// The state notifier that will be used to manage the state.
  final ValueNotifier<T> notifier;

  /// Constructor that initializes the notifier with an initial state.
  StateManager(T initialState) : notifier = ValueNotifier(initialState);

  /// Updates the state of the state manager.
  set state(T newState) => notifier.value = newState;

  /// Returns the current state of the state manager.
  T get state => notifier.value;

  /// Releases allocated resources and cleans up the state manager.
  ///
  /// Must be called when the state manager is no longer needed to prevent memory leaks.
  /// Typically called from the [dispose] method of the parent widget or when
  /// cleaning up a service locator/dependency injection container.
  @mustCallSuper
  void dispose() {
    notifier.dispose();
  }
}
