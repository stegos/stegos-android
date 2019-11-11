import 'package:flutter/material.dart';

void main() => runApp(StegosApp());

class StegosApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stegos Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StegosMainPage(),
    );
  }
}

class StegosMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Page placeholder',
            ),
          ],
        ),
      ),
    );
  }
}
