// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_screen_edit_contact.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EditContactScreenStore on _EditContactScreenStore, Store {
  final _$nameAtom = Atom(name: '_EditContactScreenStore.name');

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

  final _$addressAtom = Atom(name: '_EditContactScreenStore.address');

  @override
  String get address {
    _$addressAtom.context.enforceReadPolicy(_$addressAtom);
    _$addressAtom.reportObserved();
    return super.address;
  }

  @override
  set address(String value) {
    _$addressAtom.context.conditionallyRunInAction(() {
      super.address = value;
      _$addressAtom.reportChanged();
    }, _$addressAtom, name: '${_$addressAtom.name}_set');
  }

  final _$_EditContactScreenStoreActionController =
      ActionController(name: '_EditContactScreenStore');

  @override
  void reset() {
    final _$actionInfo =
        _$_EditContactScreenStoreActionController.startAction();
    try {
      return super.reset();
    } finally {
      _$_EditContactScreenStoreActionController.endAction(_$actionInfo);
    }
  }
}
