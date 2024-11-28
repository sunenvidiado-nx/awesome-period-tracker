import 'package:awesome_period_tracker/features/home/presentation/home_screen.dart';
import 'package:awesome_period_tracker/features/login/domain/auth_repository.dart';
import 'package:awesome_period_tracker/features/login/presentation/login_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

abstract class Routes {
  static const root = '/';
  static const login = '/login';
  static const home = '/home';
}

abstract class Router {
  static GoRouter get instance {
    return GoRouter(
      observers: [
        // TODO Add observers
      ],
      redirect: (context, state) {
        final isLoggedIn = GetIt.I<AuthRepository>().isLoggedIn();
        final location = state.uri.toString();

        if (location == Routes.root && isLoggedIn ||
            location == Routes.login && isLoggedIn) {
          return Routes.home;
        }

        if (location == Routes.root && !isLoggedIn ||
            location == Routes.home && !isLoggedIn) {
          return Routes.login;
        }

        return null;
      },
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
      ],
    );
  }
}
