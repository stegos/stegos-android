// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_node.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStore, Store {
  final _$nameAtom = Atom(name: '_AccountStore.name');

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

  final _$balanceCurrentAtom = Atom(name: '_AccountStore.balanceCurrent');

  @override
  int get balanceCurrent {
    _$balanceCurrentAtom.context.enforceReadPolicy(_$balanceCurrentAtom);
    _$balanceCurrentAtom.reportObserved();
    return super.balanceCurrent;
  }

  @override
  set balanceCurrent(int value) {
    _$balanceCurrentAtom.context.conditionallyRunInAction(() {
      super.balanceCurrent = value;
      _$balanceCurrentAtom.reportChanged();
    }, _$balanceCurrentAtom, name: '${_$balanceCurrentAtom.name}_set');
  }

  final _$balanceAvailableAtom = Atom(name: '_AccountStore.balanceAvailable');

  @override
  int get balanceAvailable {
    _$balanceAvailableAtom.context.enforceReadPolicy(_$balanceAvailableAtom);
    _$balanceAvailableAtom.reportObserved();
    return super.balanceAvailable;
  }

  @override
  set balanceAvailable(int value) {
    _$balanceAvailableAtom.context.conditionallyRunInAction(() {
      super.balanceAvailable = value;
      _$balanceAvailableAtom.reportChanged();
    }, _$balanceAvailableAtom, name: '${_$balanceAvailableAtom.name}_set');
  }

  final _$sealedAtom = Atom(name: '_AccountStore.sealed');

  @override
  bool get sealed {
    _$sealedAtom.context.enforceReadPolicy(_$sealedAtom);
    _$sealedAtom.reportObserved();
    return super.sealed;
  }

  @override
  set sealed(bool value) {
    _$sealedAtom.context.conditionallyRunInAction(() {
      super.sealed = value;
      _$sealedAtom.reportChanged();
    }, _$sealedAtom, name: '${_$sealedAtom.name}_set');
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void _update(JBDOC doc) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super._update(doc);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$StegosNodeStore on _StegosNodeStore, Store {
  Computed<bool> _$connectedComputed;

  @override
  bool get connected =>
      (_$connectedComputed ??= Computed<bool>(() => super.connected)).value;
  Computed<bool> _$operableComputed;

  @override
  bool get operable =>
      (_$operableComputed ??= Computed<bool>(() => super.operable)).value;

  final _$synchronizedAtom = Atom(name: '_StegosNodeStore.synchronized');

  @override
  bool get synchronized {
    _$synchronizedAtom.context.enforceReadPolicy(_$synchronizedAtom);
    _$synchronizedAtom.reportObserved();
    return super.synchronized;
  }

  @override
  set synchronized(bool value) {
    _$synchronizedAtom.context.conditionallyRunInAction(() {
      super.synchronized = value;
      _$synchronizedAtom.reportChanged();
    }, _$synchronizedAtom, name: '${_$synchronizedAtom.name}_set');
  }
}
