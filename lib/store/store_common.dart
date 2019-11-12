import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

abstract class StoreSupport implements Store {
  StoreSupport() {
    activated = ObservableFuture<void>(activate());
  }

  ObservableFuture<void> activated;

  @protected
  Future<void> activate();
}
