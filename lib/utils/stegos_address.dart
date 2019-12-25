final RegExp _stegosAddressRegExp = RegExp(
  r'^st[rgt]1[ac-hj-np-z02-9]{8,87}$',
  caseSensitive: false,
  multiLine: false,
);

bool validateStegosAddress(String address) {
  if (address == null) {
    return false;
  } else {
    return _stegosAddressRegExp.hasMatch(address);
  }
}
