// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_node.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStore, Store {
  Computed<String> _$humanNameComputed;

  @override
  String get humanName =>
      (_$humanNameComputed ??= Computed<String>(() => super.humanName)).value;

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

  final _$balanceIsFinalAtom = Atom(name: '_AccountStore.balanceIsFinal');

  @override
  bool get balanceIsFinal {
    _$balanceIsFinalAtom.context.enforceReadPolicy(_$balanceIsFinalAtom);
    _$balanceIsFinalAtom.reportObserved();
    return super.balanceIsFinal;
  }

  @override
  set balanceIsFinal(bool value) {
    _$balanceIsFinalAtom.context.conditionallyRunInAction(() {
      super.balanceIsFinal = value;
      _$balanceIsFinalAtom.reportChanged();
    }, _$balanceIsFinalAtom, name: '${_$balanceIsFinalAtom.name}_set');
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

  final _$balanceStakeCurrentAtom =
      Atom(name: '_AccountStore.balanceStakeCurrent');

  @override
  int get balanceStakeCurrent {
    _$balanceStakeCurrentAtom.context
        .enforceReadPolicy(_$balanceStakeCurrentAtom);
    _$balanceStakeCurrentAtom.reportObserved();
    return super.balanceStakeCurrent;
  }

  @override
  set balanceStakeCurrent(int value) {
    _$balanceStakeCurrentAtom.context.conditionallyRunInAction(() {
      super.balanceStakeCurrent = value;
      _$balanceStakeCurrentAtom.reportChanged();
    }, _$balanceStakeCurrentAtom,
        name: '${_$balanceStakeCurrentAtom.name}_set');
  }

  final _$balanceStakeAvailableAtom =
      Atom(name: '_AccountStore.balanceStakeAvailable');

  @override
  int get balanceStakeAvailable {
    _$balanceStakeAvailableAtom.context
        .enforceReadPolicy(_$balanceStakeAvailableAtom);
    _$balanceStakeAvailableAtom.reportObserved();
    return super.balanceStakeAvailable;
  }

  @override
  set balanceStakeAvailable(int value) {
    _$balanceStakeAvailableAtom.context.conditionallyRunInAction(() {
      super.balanceStakeAvailable = value;
      _$balanceStakeAvailableAtom.reportChanged();
    }, _$balanceStakeAvailableAtom,
        name: '${_$balanceStakeAvailableAtom.name}_set');
  }

  final _$balancePublicCurrentAtom =
      Atom(name: '_AccountStore.balancePublicCurrent');

  @override
  int get balancePublicCurrent {
    _$balancePublicCurrentAtom.context
        .enforceReadPolicy(_$balancePublicCurrentAtom);
    _$balancePublicCurrentAtom.reportObserved();
    return super.balancePublicCurrent;
  }

  @override
  set balancePublicCurrent(int value) {
    _$balancePublicCurrentAtom.context.conditionallyRunInAction(() {
      super.balancePublicCurrent = value;
      _$balancePublicCurrentAtom.reportChanged();
    }, _$balancePublicCurrentAtom,
        name: '${_$balancePublicCurrentAtom.name}_set');
  }

  final _$balancePublicAvailableAtom =
      Atom(name: '_AccountStore.balancePublicAvailable');

  @override
  int get balancePublicAvailable {
    _$balancePublicAvailableAtom.context
        .enforceReadPolicy(_$balancePublicAvailableAtom);
    _$balancePublicAvailableAtom.reportObserved();
    return super.balancePublicAvailable;
  }

  @override
  set balancePublicAvailable(int value) {
    _$balancePublicAvailableAtom.context.conditionallyRunInAction(() {
      super.balancePublicAvailable = value;
      _$balancePublicAvailableAtom.reportChanged();
    }, _$balancePublicAvailableAtom,
        name: '${_$balancePublicAvailableAtom.name}_set');
  }

  final _$balancePaymentCurrentAtom =
      Atom(name: '_AccountStore.balancePaymentCurrent');

  @override
  int get balancePaymentCurrent {
    _$balancePaymentCurrentAtom.context
        .enforceReadPolicy(_$balancePaymentCurrentAtom);
    _$balancePaymentCurrentAtom.reportObserved();
    return super.balancePaymentCurrent;
  }

  @override
  set balancePaymentCurrent(int value) {
    _$balancePaymentCurrentAtom.context.conditionallyRunInAction(() {
      super.balancePaymentCurrent = value;
      _$balancePaymentCurrentAtom.reportChanged();
    }, _$balancePaymentCurrentAtom,
        name: '${_$balancePaymentCurrentAtom.name}_set');
  }

  final _$balancePaymentAvailableAtom =
      Atom(name: '_AccountStore.balancePaymentAvailable');

  @override
  int get balancePaymentAvailable {
    _$balancePaymentAvailableAtom.context
        .enforceReadPolicy(_$balancePaymentAvailableAtom);
    _$balancePaymentAvailableAtom.reportObserved();
    return super.balancePaymentAvailable;
  }

  @override
  set balancePaymentAvailable(int value) {
    _$balancePaymentAvailableAtom.context.conditionallyRunInAction(() {
      super.balancePaymentAvailable = value;
      _$balancePaymentAvailableAtom.reportChanged();
    }, _$balancePaymentAvailableAtom,
        name: '${_$balancePaymentAvailableAtom.name}_set');
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void _updateFromJson(dynamic json) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super._updateFromJson(json);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateFromBalanceMessage(StegosNodeMessage msg) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super._updateFromBalanceMessage(msg);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$NodeService on _NodeService, Store {
  Computed<bool> _$connectedComputed;

  @override
  bool get connected =>
      (_$connectedComputed ??= Computed<bool>(() => super.connected)).value;
  Computed<bool> _$operableComputed;

  @override
  bool get operable =>
      (_$operableComputed ??= Computed<bool>(() => super.operable)).value;
  Computed<String> _$networkNameComputed;

  @override
  String get networkName =>
      (_$networkNameComputed ??= Computed<String>(() => super.networkName))
          .value;
  Computed<String> _$_accountsCollectonComputed;

  @override
  String get _accountsCollecton => (_$_accountsCollectonComputed ??=
          Computed<String>(() => super._accountsCollecton))
      .value;

  final _$synchronizedAtom = Atom(name: '_NodeService.synchronized');

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

  final _$networkAtom = Atom(name: '_NodeService.network');

  @override
  String get network {
    _$networkAtom.context.enforceReadPolicy(_$networkAtom);
    _$networkAtom.reportObserved();
    return super.network;
  }

  @override
  set network(String value) {
    _$networkAtom.context.conditionallyRunInAction(() {
      super.network = value;
      _$networkAtom.reportChanged();
    }, _$networkAtom, name: '${_$networkAtom.name}_set');
  }
}