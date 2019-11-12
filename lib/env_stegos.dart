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
  EJDB2 _db;

  Future<EJDB2> getDb() async => _db ??= await EJDB2Builder('stegos_wallet.db').open();

  Future<void> _suspend(AppLifecycleState state) async {
    log.info('Suspending environment');
    if (_db != null) {
      await _db.close().catchError((err, StackTrace st) {
        log.severe('Error during closing database', err, st);
      }).whenComplete(() {
        _db = null;
      });
    }
  }

  @override
  Future<Widget> openImpl() async {
    final store = StegosStore(this);
    return MultiProvider(
      providers: [
        Provider<StegosEnv>.value(value: this),
        Provider<StegosStore>.value(value: store),
      ],
      child: LifecycleWatcher(
          stateHandler: (state) async {
            switch (state) {
              case AppLifecycleState.paused:
              case AppLifecycleState.inactive:
              case AppLifecycleState.suspending:
                return _suspend(state);
                break;
              default:
                break;
            }
          },
          builder: (context, state) => StegosApp()),
    );
  }
}
