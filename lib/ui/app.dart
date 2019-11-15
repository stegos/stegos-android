import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/config.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/accounts/screen_accounts.dart';
import 'package:stegos_wallet/ui/error/screen_error.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

// don't store external state for StatelessWidget except some rare cases
int _splashStart = 0;

class StegosApp extends StatelessWidget {
  const StegosApp({Key key, this.initial}) : super(key: key);

  final bool initial;

  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);

    Widget buildHomeScreen() => Observer(
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
            if (initial) {
              int timeoutMilliseconds = Config.splashScreenTimeout;
              if (_splashStart > 0) {
                timeoutMilliseconds -= DateTime.now().millisecondsSinceEpoch - _splashStart;
                _splashStart = 0;
              }
              // Application opened for the first time
              return SplashScreen(
                  key: UniqueKey(),
                  nextRoute: !env.store.needWelcome ? Routes.accounts : Routes.welcome,
                  timeoutMilliseconds: timeoutMilliseconds > 0 ? timeoutMilliseconds : 0);
            }
            if (env.store.needWelcome) {
              return WelcomeScreen();
            } else {
              return AccountsScreen();
            }
          },
        );

    return MaterialApp(
      debugShowCheckedModeBanner: env.type != EnvType.PRODUCTION,
      title: 'Stegos Wallet',
      theme: StegosThemes.baseTheme,
      home: buildHomeScreen(),
      routes: Routes.routes,
    );
  }
}
