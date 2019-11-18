import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';

void mainEntry(Future<StegosEnv> Function() createEnv) {
  Log.initialize();
  final log = Log('mainEntry');
  Logger.root.level = Level.ALL;
  unawaited(runZoned<Future<void>>(() async {
    final env = await createEnv();
    runApp(await env.open());
  }, onError: (err, StackTrace st) async {
    log.severe('Uncaught exception', err, st);
  }));
}
