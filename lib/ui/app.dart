import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/accounts/screen_accounts.dart';
import 'package:stegos_wallet/ui/error/screen_error.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';
import 'package:stegos_wallet/ui/welcome/screen_welcome.dart';

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
                return const SplashScreen();
              case FutureStatus.rejected:
                return ErrorScreen(
                  message: '${env.store.activated.error}', // todo:
                );
              default:
                break;
            }
            if (initial) {
              // Application opened for the first time
              return SplashScreen(
                  nextRoute: env.store.loggedIn ? Routes.accounts : Routes.welcome,
                  timeoutMilliseconds: 3000);
            }
            if (env.store.loggedIn) {
              return AccountsScreen();
            } else {
              return WelcomeScreen();
            }
          },
        );

    return MaterialApp(
      debugShowCheckedModeBanner: env.type != EnvType.PRODUCTION,
      title: 'Stegos Wallet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: buildHomeScreen(),
      routes: Routes.routes,
    );
  }
}
