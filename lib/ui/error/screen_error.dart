import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../themes.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key key, @required this.message, this.fallbackRoute = '/'}) : super(key: key);

  final String message;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          padding: StegosThemes.defaultPadding,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/welcome_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                'Oops, something went wrong...',
                style: TextStyle(fontWeight: FontWeight.w100, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Expanded(
                flex: 3,
                child: Material(
                  borderRadius: BorderRadius.circular(3),
                  elevation: 4,
                  child: SingleChildScrollView(
                    padding: StegosThemes.defaultPadding,
                    child: SelectableText(
                      message,
                      style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(fallbackRoute, (Route<dynamic> route) => false);
                    },
                    child: const Text('Close'),
                  ))
            ],
          ),
        ),
      );
}
