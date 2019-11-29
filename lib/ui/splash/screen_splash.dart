import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stegos_wallet/ui/themes.dart';
import 'package:stegos_wallet/widgets/widget_app_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key, this.nextRoute, this.timeoutMilliseconds = 3000}) : super(key: key);

  /// Optional next route after timeout.
  final RouteSettings nextRoute;

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
        child: const Material(
          child: Center(child: AppIconWidget(image: 'assets/icons/logo.png')),
        ),
      );

  Timer startTimer() => Timer(Duration(milliseconds: widget.timeoutMilliseconds), () {
        if (context != null) {
          Navigator.of(context)
              .pushReplacementNamed(widget.nextRoute.name, arguments: widget.nextRoute.arguments);
        }
      });
}
