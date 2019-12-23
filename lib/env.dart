import 'dart:io';

import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'log/loggable.dart';

enum EnvType { DEVELOPMENT, STAGING, PRODUCTION, TESTING }

abstract class Env<W extends Widget> {
  Env() {
    log = Log(name ?? runtimeType.toString());
  }

  static Future<void> resetOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  static Future<void> setPortrait() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  EnvType type = EnvType.DEVELOPMENT;
  Log log;
  Directory dataDirectory;
  Directory tempDirectory;
  Directory downloadDirectory;
  String get name;

  Future<W> open() async {
    await initLogging();
    dataDirectory = await getApplicationDocumentsDirectory();
    tempDirectory = await getTemporaryDirectory();
    downloadDirectory = await DownloadsPathProvider.downloadsDirectory;
    await Env.setPortrait();
    final widget = await openWidget();
    log.info('Application initialized');
    return widget;
  }

  void setError(String error);
  void resetError();

  @mustCallSuper
  @protected
  Future<void> initLogging() async {
    Log.initialize();
    log.info('Opening Env...');
  }

  @protected
  Future<W> openWidget();
}
