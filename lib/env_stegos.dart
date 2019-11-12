import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';
import 'package:provider/provider.dart';
import 'package:stegos_wallet/env.dart';
import 'package:stegos_wallet/store/store.dart';
import 'package:stegos_wallet/widgets/lifecycle_watcher_widget.dart';

class StegosEnv extends Env<Widget> {
  @override
  Future<Widget> openImpl(Injector injector) async {
    final rootStore = StegosStore(this);
    injector.registerSingleton<StegosStore>((_) => rootStore);
    return MultiProvider(
      providers: [
        Provider<Injector>.value(value: injector),
        Provider<StegosEnv>.value(value: this),
        Provider<StegosStore>.value(value: rootStore),
      ],
      child: LifecycleWatcher(stateHandler: (state) async {
        switch (state) {
          case AppLifecycleState.resumed:
            // TODO: Handle this case.
            break;
          case AppLifecycleState.inactive:
            // TODO: Handle this case.
            break;
          case AppLifecycleState.paused:
            // TODO: Handle this case.
            break;
          case AppLifecycleState.suspending:
            // TODO: Handle this case.
            break;
        }
      }, builder: (context, state) {
        // TODO:
        return Text('');
      }),
    );
  }
}
