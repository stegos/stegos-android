import 'package:ejdb2_flutter/ejdb2_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/store/store_stegos.dart';
import 'package:stegos_wallet/ui/app.dart';
import 'package:stegos_wallet/widgets/widget_lifecycle.dart';

/// Stegos wallet app environment.
///
class StegosEnv extends Env<Widget> {
  /// Root store.
  StegosStore store;

  EJDB2 _db;

  Future<T> useDb<T>(Future<T> Function(EJDB2 db) fn) {
    final own = _db == null;
    return getDb().then(fn).whenComplete(() async {
      if (own) {
        await _closeDb();
      }
    });
  }

  Future<EJDB2> getDb() async => _db ??= await EJDB2Builder('stegos_wallet.db').open();

  Future<void> _closeDb() => (_db != null)
      ? _db.close().catchError((err, StackTrace st) {
          log.severe('Error closing db', err, st);
        }).whenComplete(() {
          _db = null;
        })
      : Future.value();

  Future<void> _suspend(AppLifecycleState state) async {
    log.info('Suspending environment');
    return _closeDb();
  }

  @override
  Future<Widget> openImpl() async {
    await getDb();
    store = StegosStore(this);

    return MultiProvider(
      providers: [
        Provider<StegosEnv>.value(value: this),
        Provider<StegosStore>.value(value: store),
      ],
      child: LifecycleWatcher(stateHandler: (state) async {
        switch (state) {
          case AppLifecycleState.paused:
          case AppLifecycleState.inactive:
          case AppLifecycleState.suspending:
            return _suspend(state);
            break;
          default:
            break;
        }
      }, builder: (context, state) {
        switch (state) {
          case AppLifecycleState.paused:
          case AppLifecycleState.inactive:
          case AppLifecycleState.suspending:
            // Dot not show anything
            return const SizedBox.shrink();
          default:
            return StegosApp(
              initial: state == null,
            );
        }
      }),
    );
  }
}

class StegosEnvProduction extends StegosEnv {
  StegosEnvProduction() {
    type = EnvType.PRODUCTION;
  }
}
