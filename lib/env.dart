import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';
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

  Injector injector = Injector.appInstance;
  Directory dataDirectory;
  Directory tempDirectory;

  T getDependency<T>({String dependencyName = ""}) =>
      injector.getDependency<T>(dependencyName: dependencyName);

  Future<W> open() async {
    injector = Injector.appInstance;
    await initLogging();
    injector.registerDependency<Env>((_) => this);

    dataDirectory = await getApplicationDocumentsDirectory();
    tempDirectory = await getTemporaryDirectory();

    await Env.resetOrientation();

    final rootWidget = await openImpl(injector);
    log.info('Application initialized');
    return rootWidget;
  }

  @protected
  Future<void> initLogging() async {
    Log.initialize();
    log.info('Opening Env...');
  }

  @protected
  Future<W> openImpl(Injector injector);
}
