import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';

void main() async {
  Log.initialize();
  final log = Log('main');
  Logger.root.level = Level.ALL;

  runZoned<Future<void>>(() async {
    runApp(await createEnv().open());
  }, onError: (err, st) async {
    log.severe('Uncaught exception', err, st);
  });
}

Env createEnv() => StegosEnv();

// import 'package:flutter/material.dart';
// void main() => runApp(StegosApp());
// class StegosApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Stegos Wallet',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StegosMainPage(),
//     );
//   }
// }
// class StegosMainPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Page placeholder',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
