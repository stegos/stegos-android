// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_stegos.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ContactStore on _ContactStore, Store {
  final _$nameAtom = Atom(name: '_ContactStore.name');

  @override
  String get name {
    _$nameAtom.context.enforceReadPolicy(_$nameAtom);
    _$nameAtom.reportObserved();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.context.conditionallyRunInAction(() {
      super.name = value;
      _$nameAtom.reportChanged();
    }, _$nameAtom, name: '${_$nameAtom.name}_set');
  }
}

mixin _$StegosStore on _StegosStore, Store {
  Computed<List<ContactStore>> _$contactsListComputed;

  @override
  List<ContactStore> get contactsList => (_$contactsListComputed ??=
          Computed<List<ContactStore>>(() => super.contactsList))
      .value;
  Computed<bool> _$needWelcomeComputed;

  @override
  bool get needWelcome =>
      (_$needWelcomeComputed ??= Computed<bool>(() => super.needWelcome)).value;
  Computed<bool> _$embeddedNodeComputed;

  @override
  bool get embeddedNode =>
      (_$embeddedNodeComputed ??= Computed<bool>(() => super.embeddedNode))
          .value;
  Computed<bool> _$allowBiometricsProtectionComputed;

  @override
  bool get allowBiometricsProtection => (_$allowBiometricsProtectionComputed ??=
          Computed<bool>(() => super.allowBiometricsProtection))
      .value;
  Computed<String> _$nodeWsEndpointComputed;

  @override
  String get nodeWsEndpoint => (_$nodeWsEndpointComputed ??=
          Computed<String>(() => super.nodeWsEndpoint))
      .value;
  Computed<String> _$nodeWsEndpointApiTokenComputed;

  @override
  String get nodeWsEndpointApiToken => (_$nodeWsEndpointApiTokenComputed ??=
          Computed<String>(() => super.nodeWsEndpointApiToken))
      .value;

  final _$activateAsyncAction = AsyncAction('activate');

  @override
  Future<void> activate() {
    return _$activateAsyncAction.run(() => super.activate());
  }

  final _$addContactAsyncAction = AsyncAction('addContact');

  @override
  Future<void> addContact(String name, String pkey) {
    return _$addContactAsyncAction.run(() => super.addContact(name, pkey));
  }

  final _$editContactAsyncAction = AsyncAction('editContact');

  @override
  Future<void> editContact(int id, String name, String pkey) {
    return _$editContactAsyncAction
        .run(() => super.editContact(id, name, pkey));
  }

  final _$removeContactAsyncAction = AsyncAction('removeContact');

  @override
  Future<void> removeContact(int id) {
    return _$removeContactAsyncAction.run(() => super.removeContact(id));
  }

  final _$_StegosStoreActionController = ActionController(name: '_StegosStore');

  @override
  void resetError() {
    final _$actionInfo = _$_StegosStoreActionController.startAction();
    try {
      return super.resetError();
    } finally {
      _$_StegosStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setError(String errorText) {
    final _$actionInfo = _$_StegosStoreActionController.startAction();
    try {
      return super.setError(errorText);
    } finally {
      _$_StegosStoreActionController.endAction(_$actionInfo);
    }
  }
}
