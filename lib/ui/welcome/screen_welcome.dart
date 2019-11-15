import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stegos_wallet/ui/themes.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Theme(
        data: StegosThemes.welcomeTheme,
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: const AssetImage('assets/images/image_placeholder.png'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      // todo:
                    },
                    child: const Text('I`M NEW USER', style: TextStyle(fontSize: 14)),
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: () {
                        // todo:
                      },
                      child: const Text(
                        'I ALREADY HAVE ACCOUNT',
                        style: TextStyle(color: Color(0xffff7b00)),
                      ),
                    ))
              ],
            ),
          ),
        ),
      );
}
