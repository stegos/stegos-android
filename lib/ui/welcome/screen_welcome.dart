import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/themes.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.baseTheme,
        child: Scaffold(
          body: Container(alignment: Alignment.center, child: Text('Welcome screen')),
        ),
      );
}
