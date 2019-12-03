import 'dart:async';

import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node.dart';
import 'package:stegos_wallet/services/service_node_client.dart';
import 'package:stegos_wallet/services/service_security.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/widgets/widget_lifecycle.dart';

class StegosUserException implements Exception {
  StegosUserException(this.message);
  final String message;
}

FutureOr<T> Function(T, StackTrace) defaultErrorHandler<T>(StegosEnv env) => (err, StackTrace st) {
      if (err is StegosUserException) {
        env.setError(err.message);
      }
      return Future<T>.error(err, st);
    };

/// Stegos wallet app environment.
///
class StegosEnv extends Env<Widget> {
  StegosEnv() : super() {
    // fixme:
    Log('StegosStore').level = Level.FINE;
    Log('StegosNodeClient').level = Level.FINE;
    Log('NodeService').level = Level.FINE;
  }

  /// Environment name
  @override
  String get name => 'stegos';

  /// Get splash screen timeout.
  int get configSplashScreenTimeoutMs => 2000;

  /// Minimal splash screen show period.
  int get configSlashScreenMinTimeoutMs => 300;

  /// Minimal stegos node next connect attempt in milliseconds
  int get configNodeWsEndpointMinReconnectTimeoutMs => 1000;

  /// Maximal stegos node next connect attempt in milliseconds
  int get configNodeWsEndpointMaxReconnectTimeoutMs => 15000;

  /// User fingerprint wallet protection
  bool get configAllowFingerprintWalletProtection => false;

  /// Length of random generated passwords
  int get configGeneratedPasswordsLength => 15;

  /// Max unlocked app period in milleseconds
  int get configMaxAppUnlockedPeriod => 5 * 60 * 1000; // 5min

  /// Maximum number of messages awaiting sending to stegos node
  int get configNodeMaxPendingMessages => 1024;

  /// Maximum period of time in milliseconds
  /// to wait for specific reply for message from stegos node.
  int get configNodeMaxAwaitMessageResponseMs => 30 * 60 * 1000; // 30min

  /// Stegos node websocket endpoint
  String get configNodeWsEndpoint => 'ws://10.0.2.2:3145';

  /// Stegos node API access token
  String get configNodeWsEndpointApiToken => 'xPM4oRn0/GintAaKOZA6Qw==';

  /// Shared security service
  SecurityService securityService;

  NodeService get nodeService => _store.nodeService;

  /// Use database in given [fn] function.
  /// This method don't leave database in open state
  /// if it was not opened before.
  Future<T> useDb<T>(Future<T> Function(EJDB2 db) fn) {
    final own = _db == null;
    return getDb().then(fn).whenComplete(() async {
      if (own) {
        await _closeDb();
      }
    });
  }

  /// Main app state store.
  StegosStore get store => _store ??= StegosStore(this);

  /// Get database handle
  Future<EJDB2> getDb() async => _db ??= await EJDB2Builder('stegos_wallet.db').open();

  /// Get stegos node websocket client
  StegosNodeClient get nodeClient => _client ??= StegosNodeClient.open(this);

  /// Get broadcast stream of stegos node messages
  Stream<StegosNodeMessage> get nodeStream => nodeClient.stream;

  @override
  void setError(String error) {
    if (_store != null) {
      _store.setError(error);
    } else {
      log.severe(error);
    }
  }

  @override
  void resetError() {
    if (_store != null) {
      _store.resetError();
    }
  }

  /// Bring environment to operational state
  Future<void> activate() async {
    await getDb();
    securityService ??= SecurityService(this);
    unawaited(nodeClient.ensureOpened());
  }

  /// Create initial application widget.
  @override
  Future<Widget> openWidget() async => MultiProvider(
        providers: [
          Provider<StegosEnv>.value(value: this),
          Provider<StegosStore>(create: (_) => store),
        ],
        child: LifecycleWatcher(builder: (context, state) {
          switch (state) {
            case AppLifecycleState.paused:
            case AppLifecycleState.inactive:
            case AppLifecycleState.suspending:
              if (!_suspended) {
                _suspended = true;
                unawaited(_suspend(state));
              }
              // Dot not show anything
              return const SizedBox.shrink();
            default:
              if (_suspended) {
                _suspended = false;
                // App resume
                unawaited(activate());
              }
              return StegosApp(
                showSplash: state == null,
              );
          }
        }),
      );

  //
  // Private staff
  //

  /// Database handle.
  EJDB2 _db;

  /// Root store
  StegosStore _store;

  /// Is mobile app suspended
  bool _suspended = false;

  /// Websocket stegos node client
  StegosNodeClient _client;

  Future<void> _closeDb() {
    if (_db != null) {
      final db = _db;
      _db = null;
      return db.close().catchError((err, StackTrace st) {
        log.severe('Error closing db', err, st);
      });
    }
    return Future.value();
  }

  Future<void> _suspend(AppLifecycleState state) async {
    log.info('Suspending environment');
    if (_client != null) {
      await _client.close(dispose: false).catchError((err) {
        log.warning('', err);
      });
    }
    return store.disposeAsync().whenComplete(_closeDb);
  }
}
