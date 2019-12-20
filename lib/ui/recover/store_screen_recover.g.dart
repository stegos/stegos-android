// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_screen_recover.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RecoverScreenStore on _RecoverScreenStore, Store {
  Computed<bool> _$validComputed;

  @override
  bool get valid =>
      (_$validComputed ??= Computed<bool>(() => super.valid)).value;

  final _$recoveringAtom = Atom(name: '_RecoverScreenStore.recovering');

  @override
  bool get recovering {
    _$recoveringAtom.context.enforceReadPolicy(_$recoveringAtom);
    _$recoveringAtom.reportObserved();
    return super.recovering;
  }

  @override
  set recovering(bool value) {
    _$recoveringAtom.context.conditionallyRunInAction(() {
      super.recovering = value;
      _$recoveringAtom.reportChanged();
    }, _$recoveringAtom, name: '${_$recoveringAtom.name}_set');
  }

  final _$_RecoverScreenStoreActionController =
      ActionController(name: '_RecoverScreenStore');

  @override
  void setKey(int idx, String key) {
    final _$actionInfo = _$_RecoverScreenStoreActionController.startAction();
    try {
      return super.setKey(idx, key);
    } finally {
      _$_RecoverScreenStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearKeys() {
    final _$actionInfo = _$_RecoverScreenStoreActionController.startAction();
    try {
      return super.clearKeys();
    } finally {
      _$_RecoverScreenStoreActionController.endAction(_$actionInfo);
    }
  }
}
