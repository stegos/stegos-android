import 'package:mobx/mobx.dart';
import 'package:stegos_wallet/utils/stegos_address.dart';

part 'store_screen_edit_contact.g.dart';

class EditContactScreenStore = _EditContactScreenStore
    with _$EditContactScreenStore;

abstract class _EditContactScreenStore with Store {
  @observable
  String name;

  @observable
  String address;

  @action
  void reset() {
    name = null;
    address = null;
  }

  bool get isValidForm {
    return name != null && name.isNotEmpty && validateStegosAddress(address);
  }
}
