import 'package:mobx/mobx.dart';

part 'store_screen_pinprotect.g.dart';

class PinprotectScreenStore = _PinprotectScreenStore with _$PinprotectScreenStore;

abstract class _PinprotectScreenStore with Store {
  @observable
  String firstPin;

  @observable
  String secondPin;

  @computed
  String get title {
    if (firstPin == null) {
      return 'Protect wallet by PIN code';
    } else if (secondPin == null) {
      return 'Please confirm PIN code';
    } else if (firstPin != secondPin) {
      return 'Second PIN code doesn\'t match the first one';
    } else {
      return 'Protect wallet by PIN';
    }
  }
}
