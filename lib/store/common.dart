import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

abstract class StoreSupport with Store {
  ObservableFuture<void> activated;

  StoreSupport() {
    activated = ObservableFuture<void>(activate());
  }

  @protected
  Future<void> activate();
}
