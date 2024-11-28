import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

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
  @disposeMethod
  void dispose() {
    notifier.dispose();
  }
}
