import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';

void main() {
  Log.initialize();
  final log = Log('main');
  Logger.root.level = Level.ALL;

  runZoned<Future<void>>(() async {
    runApp(await createEnv().open());
  }, onError: (err, StackTrace st) async {
    log.severe('Uncaught exception', err, st);
  });
}

Env createEnv() => StegosEnv();
