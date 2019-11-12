import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stegos_wallet/widgets/widget_app_icon.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(child: const AppIconWidget(image: 'assets/icons/logo.png')),
    );
  }

  Timer startTimer() {
    final duration = Duration(milliseconds: 3000);
    return Timer(duration, navigate);
  }

  navigate() async {
    // todo:
  }
}
