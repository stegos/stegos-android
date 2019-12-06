import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/account/screen_account.dart';
import 'package:stegos_wallet/ui/dev/screen_dev_menu.dart';
import 'package:stegos_wallet/ui/pay/screen_pay.dart';
import 'package:stegos_wallet/ui/pinprotect/screen_pin_protect.dart';
import 'package:stegos_wallet/ui/recover/screen_recover.dart';
import 'package:stegos_wallet/ui/settings/screen_settings.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/username/screen_username.dart';
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
        final ss = env.securityService;
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

        final initialRoute = untracked<RouteSettings>(() {
          if (!ss.hasPinProtectedPassword) {
            return const RouteSettings(name: Routes.pinprotect);
          } else if (ss.needAppUnlock) {
            return const RouteSettings(name: Routes.unlock);
          } else if (store.needWelcome) {
            return const RouteSettings(name: Routes.welcome);
          } else {
            return const RouteSettings(name: Routes.wallet);
          }
        });

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

        return widget.routeFactoryFn(initialRoute).builder(context);
      });
}

mixin Routes {
  static const root = '/';
  static const accounts = 'accounts';
  static const account = 'account';
  static const devmenu = 'devmenu';
  static const pinprotect = 'pinprotect';
  static const recover = 'recover';
  static const settings = 'settings';
  static const splash = 'splash';
  static const unlock = 'unlock';
  static const wallet = 'wallet';
  static const welcome = 'welcome';
  static const username = 'username';
  static const pay = 'pay';

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

      final welcomeRoute = untracked<RouteSettings>(() {
        if (env.store.needWelcome) {
          return const RouteSettings(name: Routes.welcome);
        } else {
          return const RouteSettings(name: Routes.wallet);
        }
      });

      switch (name) {
        // Remember selected screen, todo: review
        // case accounts:
        //   unawaited(env.store.persistNextRoute(settings));
        //   break;
      }
      switch (name) {
        case root:
          return MaterialPageRoute(builder: buildInitialRouteScreen);
        case pinprotect:
        case unlock:
          {
            final arguments = settings.arguments as Map<String, dynamic> ?? {};
            var nextRoute = welcomeRoute;
            if (arguments['nextRoute'] is RouteSettings) {
              nextRoute = arguments['nextRoute'] as RouteSettings;
            }
            return MaterialPageRoute(
                maintainState: false,
                builder: (BuildContext context) => PinProtectScreen(
                      nextRoute: nextRoute,
                      unlock: unlock == name,
                    ));
          }
        case welcome:
          return MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen());
        case account:
          final arguments = settings.arguments as int;
          return MaterialPageRoute(builder: (BuildContext context) => AccountScreen(id: arguments));
        case wallet:
          return MaterialPageRoute(builder: (BuildContext context) => WalletScreen());
        case recover:
          return MaterialPageRoute(builder: (BuildContext context) => RecoverScreen());
        case splash:
          return MaterialPageRoute(
              maintainState: false,
              builder: (BuildContext context) => SplashScreen(nextRoute: welcomeRoute));
        case Routes.settings:
          final arguments = settings.arguments as int;
          return MaterialPageRoute(
              builder: (BuildContext context) => SettingsScreen(id: arguments));
        case Routes.username:
          final arguments = settings.arguments as int;
          return MaterialPageRoute(
              builder: (BuildContext context) => UsernameScreen(id: arguments));
        case Routes.devmenu:
          return MaterialPageRoute(builder: (BuildContext context) => DevMenuScreen());
        case pay:
          return MaterialPageRoute(builder: (BuildContext context) => PayScreen());
        default:
          return MaterialPageRoute(
              maintainState: false,
              builder: (BuildContext context) => buildInvalidRouteScreen(context, settings));
      }
    };
  }
}
