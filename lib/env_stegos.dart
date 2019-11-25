import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/services/service_node_client.dart';
import 'package:stegos_wallet/services/service_security.dart';
import 'package:stegos_wallet/store/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/widgets/widget_lifecycle.dart';

/// Stegos wallet app environment.
///
class StegosEnv extends Env<Widget> {
  StegosEnv() : super() {
    // fixme:
    Log('StegosStore').level = Level.FINE;
  }

  /// Main app state store.
  StegosStore store;

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
  int get configMaxAppUnlockedPeriod => 60 * 60 * 1000; // 1h

  /// Maximum number of messages awaiting sending to stegos node
  int get configNodeMaxPendingMessages => 1024;

  /// Maximum period of time in millisconds
  /// to wait for specific reply for message from stegos node.
  int get configNodeMaxAwaitNodeResponseMs => 30 * 60 * 1000; // 30min

  /// Stegos node websocket endpoint
  String get configNodeWsEndpoint => 'ws://10.0.2.2:3145';

  /// Stegos node API access token
  String get configNodeWsEndpointApiToken => 'xPM4oRn0/GintAaKOZA6Qw==';

  /// Shared security service
  SecurityService securityService;

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

  /// Get database handle
  Future<EJDB2> getDb() async => _db ??= await EJDB2Builder('stegos_wallet.db').open();

  /// Get broadcast stream of stegos node messages
  Stream<StegosNodeMessage> get nodeStream => (_client ??= StegosNodeClient.open(this)).stream;

  /// Bring environment to operational state
  Future<void> activate() async {
    await getDb();
    securityService ??= SecurityService(this);
    if (_client == null) {
      _client = StegosNodeClient.open(this);
    } else {
      await _client.ensureOpened();
    }
  }

  /// Create initial application widget.
  @override
  Future<Widget> openWidget() async {
    store = StegosStore(this);
    return MultiProvider(
      providers: [
        Provider<StegosEnv>.value(value: this),
        Provider<StegosStore>.value(value: store),
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
  }

  //
  // Private staff
  //

  /// Database handle.
  EJDB2 _db;

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
