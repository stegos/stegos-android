import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';

void mainEntry(Future<StegosEnv> Function() createEnv) {
  WidgetsFlutterBinding.ensureInitialized();
  Log.initialize();
  final log = Log('mainEntry');
  Logger.root.level = Level.ALL;
  StegosEnv env;
  unawaited(runZoned<Future<void>>(() async {
    env = await createEnv();
    runApp(await env.open());
  }, onError: (err, StackTrace st) async {
    if (env != null && err is StegosUserException) {
      env.setError(err.message);
    } else {
      log.severe('Uncaught exception', err, st);
    }
  }));
}
