import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

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
