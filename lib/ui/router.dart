import 'dart:async';

import 'package:awesome_period_tracker/data/repositories/auth_repository.dart';
import 'package:awesome_period_tracker/ui/features/home/widgets/home_screen.dart';
import 'package:awesome_period_tracker/ui/features/login/widgets/login_screen.dart';
import 'package:awesome_period_tracker/ui/features/set_user_name/widgets/set_user_name_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

abstract class Routes {
  static const root = '/';
  static const login = '/login';
  static const home = '/home';
  static const setUserName = '/set-user-name';
  static const createPartnership = '/create-partnership';
}

@module
abstract class RouterModule {
  @singleton
  GoRouter get router {
    return GoRouter(
      observers: [
        FirebaseAnalyticsObserver(analytics: GetIt.I<FirebaseAnalytics>()),
      ],
      redirect: _handleRedirect,
      routes: [
        GoRoute(
          path: Routes.root,
          redirect: (context, state) => Routes.home,
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.setUserName,
          builder: (context, state) => const SetUserNameScreen(),
        ),
      ],
    );
  }

  static Future<String?> _handleRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final auth = GetIt.I<AuthRepository>();
    final isLoggedIn = auth.isLoggedIn;
    final location = state.uri.toString();

    if (isLoggedIn && auth.shouldCreateUserName) {
      return Routes.setUserName;
    }

    if (location == Routes.root && isLoggedIn ||
        location == Routes.login && isLoggedIn) {
      return Routes.home;
    }

    if (location == Routes.root && !isLoggedIn ||
        location == Routes.home && !isLoggedIn) {
      return Routes.login;
    }

    return null;
  }
}
