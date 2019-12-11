import 'package:mobx/mobx.dart';
import 'package:pedantic/pedantic.dart';

mixin StoreLifecycle implements Store {
  Future<void> activate();
  Future<void> disposeAsync();
  @override
  void dispose() {
    unawaited(disposeAsync());
  }
}

abstract class MainStoreSupport with StoreLifecycle {
  ObservableFuture<void> activated;
}
