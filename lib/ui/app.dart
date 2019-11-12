import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';

class StegosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final env = Provider.of<StegosEnv>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: env.type != EnvType.PRODUCTION,
      title: 'Stegos Wallet',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
