import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'log/loggable.dart';

enum EnvType { DEVELOPMENT, STAGING, PRODUCTION, TESTING }

abstract class Env<W extends Widget> with Loggable<Env> {
  static EnvType type = EnvType.DEVELOPMENT;

  static Future<void> resetOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  Directory dataDirectory;
  Directory tempDirectory;

  Future<W> open() async {
    await initLogging();
    dataDirectory = await getApplicationDocumentsDirectory();
    tempDirectory = await getTemporaryDirectory();
    await Env.resetOrientation();
    final rootWidget = await openImpl();
    log.info('Application initialized');
    return rootWidget;
  }

  @protected
  Future<void> initLogging() async {
    Log.initialize();
    log.info('Opening Env...');
  }

  @protected
  Future<W> openImpl();
}
