import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/config.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/accounts/screen_accounts.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

import 'error/screen_error.dart';

// don't store external state for StatelessWidget except some rare cases
int _splashStart = 0;

mixin Routes {
  static const root = '/';
  static const splash = 'splash';
  static const welcome = 'welcome';
  static const accounts = 'accounts';

  static RouteFactory createRouteFactory(StegosEnv env, bool showSplash) {
    Widget buildHomeScreen(BuildContext context) => Observer(
          builder: (context) {
            switch (env.store.activated.status) {
              case FutureStatus.pending:
                _splashStart = DateTime.now().millisecondsSinceEpoch;
                return const SplashScreen();
              case FutureStatus.rejected:
                return ErrorScreen(
                  message: '${env.store.activated.error}', // todo:
                );
              default:
                break;
            }

            String nextRoute = env.store.lastRoute.value?.name;
            nextRoute ??= !env.store.needWelcome ? Routes.accounts : Routes.welcome;

            if (showSplash) {
              int timeoutMilliseconds = Config.splashScreenTimeout;
              if (_splashStart > 0) {
                timeoutMilliseconds -= DateTime.now().millisecondsSinceEpoch - _splashStart;
                _splashStart = 0;
              }
              // Application opened for the first time
              return SplashScreen(
                  key: UniqueKey(),
                  nextRoute: nextRoute,
                  timeoutMilliseconds: timeoutMilliseconds > 0 ? timeoutMilliseconds : 0);
            }

            if (env.store.needWelcome) {
              return WelcomeScreen();
            } else {
              return AccountsScreen();
            }
          },
        );

    Widget buildErrorScreen(BuildContext context, RouteSettings settings) {
      return Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      );
    }

    return (RouteSettings settings) {
      final name = settings.name;
      if (name != null && name != root) {
        unawaited(env.store.updateLastRoute(settings));
      }
      switch (name) {
        case root:
          return MaterialPageRoute(builder: buildHomeScreen);
        case welcome:
          return MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen());
        case accounts:
          return MaterialPageRoute(builder: (BuildContext context) => AccountsScreen());
        case splash:
          return MaterialPageRoute(builder: (BuildContext context) => const SplashScreen());
        default:
          return MaterialPageRoute(
              maintainState: false,
              builder: (BuildContext context) => buildErrorScreen(context, settings));
      }
    };
  }
}
