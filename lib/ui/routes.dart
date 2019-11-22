import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/pinprotect/screen_pin_protect.dart';
import 'package:stegos_wallet/ui/recover/screen_recover.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/wallet/screen_wallet.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

import 'error/screen_error.dart';

// fixme: don't store external state for StatelessWidget except some rare cases
int _splashStart = 0;

class _InitialRouteScreen extends StatefulWidget {
  const _InitialRouteScreen({Key key, this.env, this.routeFactoryFn, this.showSplash})
      : super(key: key);

  final bool showSplash;

  final StegosEnv env;

  final MaterialPageRoute Function(RouteSettings settings) routeFactoryFn;

  @override
  State<StatefulWidget> createState() => _InitialRouteScreenState();
}

class _InitialRouteScreenState extends State<_InitialRouteScreen> {
  @override
  Widget build(BuildContext context) => Observer(builder: (BuildContext context) {
        final env = widget.env;
        final store = env.store;
        switch (store.activated.status) {
          case FutureStatus.pending:
            _splashStart = DateTime.now().millisecondsSinceEpoch;
            return const SplashScreen();
          case FutureStatus.rejected:
            return ErrorScreen(
              message: '${store.activated.error}', // todo:
            );
          default:
            break;
        }
        String initialRoute;
        if (!store.hasPinProtectedPassword) {
          initialRoute = Routes.pinprotect;
        } else if (store.needWelcome) {
          initialRoute = Routes.welcome;
        } else {
          // should be untracked!
          // nextRoute = store.lastRoute.value?.name; todo:
          initialRoute = Routes.accounts;
        }
        if (widget.showSplash) {
          int timeoutMs = env.configSplashScreenTimeoutMs;
          if (_splashStart > 0) {
            timeoutMs -= DateTime.now().millisecondsSinceEpoch - _splashStart;
            _splashStart = 0;
          }
          if (timeoutMs >= env.configSlashScreenMinTimeoutMs) {
            // Application opened for the first time
            return SplashScreen(
                key: UniqueKey(), nextRoute: initialRoute, timeoutMilliseconds: timeoutMs);
          }
        }
        return widget.routeFactoryFn(RouteSettings(name: initialRoute)).builder(context);
      });
}

mixin Routes {
  static const root = '/';
  static const splash = 'splash';
  static const pinprotect = 'pinprotect';
  static const welcome = 'welcome';
  static const accounts = 'accounts';
  static const wallet = 'wallet';
  static const recover = 'recover';

  static RouteFactory createRouteFactory(StegosEnv env, bool showSplash) {
    MaterialPageRoute Function(RouteSettings settings) routeFactoryFn;

    Widget buildInitialRouteScreen(BuildContext context) =>
        _InitialRouteScreen(env: env, showSplash: showSplash, routeFactoryFn: routeFactoryFn);

    Widget buildInvalidRouteScreen(BuildContext context, RouteSettings settings) => ErrorScreen(
          message: 'No route defined for ${settings.name}',
        );

    return routeFactoryFn = (RouteSettings settings) {
      final name = settings.name;
      env.store.resetError();
      switch (name) {
        // Remember selected screen, todo: review
        case accounts:
          unawaited(env.store.persistNextRoute(settings));
          break;
      }
      switch (name) {
        case root:
          return MaterialPageRoute(builder: buildInitialRouteScreen);
        case pinprotect:
          return MaterialPageRoute(
              maintainState: false,
              builder: (BuildContext context) => const PinProtectScreen(
                    nextRoute: welcome,
                  ));
        case welcome:
          return MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen());
        case wallet:
          return MaterialPageRoute(builder: (BuildContext context) => WalletScreen());
        case recover:
          return MaterialPageRoute(builder: (BuildContext context) => RecoverScreen());
        case splash:
          return MaterialPageRoute(
              maintainState: false, builder: (BuildContext context) => const SplashScreen());
        default:
          return MaterialPageRoute(
              maintainState: false,
              builder: (BuildContext context) => buildInvalidRouteScreen(context, settings));
      }
    };
  }
}
