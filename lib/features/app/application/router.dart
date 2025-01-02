import 'package:awesome_period_tracker/features/home/presentation/home_screen.dart';
import 'package:awesome_period_tracker/features/pin_login/domain/auth_repository.dart';
import 'package:awesome_period_tracker/features/pin_login/presentation/pin_login_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

abstract class Routes {
  static const root = '/';
  static const pinLogin = '/pin-login';
  static const home = '/home';
}

@module
abstract class RouterRegister {
  @singleton
  GoRouter get instance {
    return GoRouter(
      observers: [
        // TODO Add observers
      ],
      redirect: (context, state) {
        final isLoggedIn = GetIt.I<AuthRepository>().isLoggedIn();
        final location = state.uri.toString();

        if (location == Routes.root && isLoggedIn ||
            location == Routes.pinLogin && isLoggedIn) {
          return Routes.home;
        }

        if (location == Routes.root && !isLoggedIn ||
            location == Routes.home && !isLoggedIn) {
          return Routes.pinLogin;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: Routes.root,
          redirect: (context, state) => Routes.home,
        ),
        GoRoute(
          path: Routes.pinLogin,
          builder: (context, state) => const PinLoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}
