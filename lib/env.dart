import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'log/loggable.dart';

enum EnvType { DEVELOPMENT, STAGING, PRODUCTION, TESTING }

abstract class Env<W extends Widget> {
  Env() {
    log = Log(runtimeType.toString());
  }

  static EnvType type = EnvType.DEVELOPMENT;

  static Future<void> resetOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  Log log;
  Directory dataDirectory;
  Directory tempDirectory;

  Future<W> open() async {
    await initLogging();
    dataDirectory = await getApplicationDocumentsDirectory();
    tempDirectory = await getTemporaryDirectory();
    await Env.resetOrientation();
    final widget = await openImpl();
    log.info('Application initialized');
    return widget;
  }

  @protected
  Future<void> initLogging() async {
    Log.initialize();
    log.info('Opening Env...');
  }

  @protected
  Future<W> openImpl();
}
