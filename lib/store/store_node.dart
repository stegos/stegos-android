

import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/store/store_common.dart';
import 'package:stegos_wallet/store/store_stegos.dart';

part 'store_node.g.dart';

class StegosNodeStore = _StegosNodeStore with _$StegosNodeStore;

abstract class _StegosNodeStore extends StoreSupport with Store, Loggable<StegosNodeStore> {

  _StegosNodeStore(this.parent);

  final StegosStore parent;

  @override
  @action
  Future<void> activate() async {
    final env = parent.env;

  }

  @override
  Future<void> disposeAsync() async {

  }
}