import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/store/common.dart';

part 'store.g.dart';

class StegosStore = _StegosStore with _$StegosStore;

abstract class _StegosStore extends StoreSupport {
  final StegosEnv env;

  _StegosStore(this.env);

  Future<void> activate() async {
    // todo:
  }
}
