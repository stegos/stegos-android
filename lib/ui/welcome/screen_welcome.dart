import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/routes.dart';
import 'package:stegos_wallet/ui/themes.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.welcomeTheme,
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/welcome_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: const AssetImage('assets/images/logo.png'),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () => onNewUser(context),
                          child: const Text('I`M NEW USER'),
                        ),
                        FlatButton(
                          textTheme: ButtonTextTheme.accent,
                          onPressed: () => onHaveAccount(context),
                          child: const Text(
                            'I ALREADY HAVE ACCOUNT',
                          ),
                        )
                      ],
                    )),
              ],
            ),
          ),
        ),
      );

  void onHaveAccount(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.accounts);
  }

  void onNewUser(BuildContext context) {
    //
  }
}
