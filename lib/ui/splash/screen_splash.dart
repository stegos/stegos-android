import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key, this.nextRoute, this.timeoutMilliseconds = 3000}) : super(key: key);

  /// Optional next route after timeout.
  final String nextRoute;

  /// Timeout before next route
  final int timeoutMilliseconds;

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.nextRoute != null) {
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.splashTheme,
        child: Material(
          child: Center(child: const AppIconWidget(image: 'assets/icons/logo.png')),
        ),
      );

  Timer startTimer() => Timer(Duration(milliseconds: widget.timeoutMilliseconds), () {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute);
      });
}
