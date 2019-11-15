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

class StegosApp extends StatelessWidget {
  const StegosApp({Key key, this.showSplash}) : super(key: key);

  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: env.type != EnvType.PRODUCTION,
      title: 'Stegos Wallet',
      theme: StegosThemes.baseTheme,
      onGenerateRoute: Routes.createRouteFactory(env, showSplash),
    );
  }
}
