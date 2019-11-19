import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/accounts/screen_accounts.dart';
import 'package:stegos_wallet/ui/recover/screen_recover.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/wallet/screen_wallet.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

import 'error/screen_error.dart';

// don't store external state for StatelessWidget except some rare cases
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
  ReactionDisposer _disposer;

  FutureStatus _status;

  @override
  void dispose() {
    if (_disposer != null) {
      _disposer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = widget.env;
    if (_disposer == null) {
      _status = env.store.activated.status;
      _disposer = reaction<FutureStatus>((_) => env.store.activated.status, (s) {
        setState(() {
          _status = s;
        });
      });
    }
    switch (_status) {
      case FutureStatus.pending:
        _splashStart = DateTime.now().millisecondsSinceEpoch;
        return const SplashScreen();
        break;
      case FutureStatus.rejected:
        return ErrorScreen(
          message: '${env.store.activated.error}', // todo:
        );
        break;
      default:
        break;
    }

    String nextRoute = Routes.welcome;
    // todo: enabled it
    // nextRoute = env.store.lastRoute.value?.name;
    // if (nextRoute == Routes.root) {
    //   nextRoute = null;
    // }
    // nextRoute ??= env.store.needWelcome ? Routes.welcome : Routes.accounts;

    if (widget.showSplash) {
      int timeoutMilliseconds = env.configSplashScreenTimeout;
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

    return widget.routeFactoryFn(RouteSettings(name: nextRoute)).builder(context);
  }
}

mixin Routes {
  static const root = '/';
  static const splash = 'splash';
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
      switch (name) {
        // Remember selected screen, todo: review
        case accounts:
          unawaited(env.store.persistLastRoute(settings));
          break;
      }
      switch (name) {
        case root:
          return MaterialPageRoute(builder: buildInitialRouteScreen);
        case welcome:
          return MaterialPageRoute(builder: (BuildContext context) => WelcomeScreen());
        case accounts:
          return MaterialPageRoute(builder: (BuildContext context) => AccountsScreen());
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
