import 'package:mobx/mobx.dart';

part 'store_screen_recover.g.dart';

class RecoverScreenStore = _RecoverScreenStore with _$RecoverScreenStore;

abstract class _RecoverScreenStore with Store {
  _RecoverScreenStore(int numKeys) {
    keys.addAll(List<String>.filled(numKeys, ''));
  }

  final keys = ObservableList<String>();

  @action
  void setKey(int idx, String key) {
    keys[idx] = key;
  }

  @action
  void clearKeys() {
    keys.forEach((k) => k = '');
  }

  @computed
  bool get valid => keys.firstWhere((v) => v.isEmpty, orElse: () => null) == null;

  @observable
  bool recovering = false;
}
