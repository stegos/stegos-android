import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/splash/screen_splash.dart';

class StegosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Stegos Wallet',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreen(),
      );
}
