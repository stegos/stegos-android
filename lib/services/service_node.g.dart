// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_node.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TxStore on _TxStore, Store {
  Computed<bool> _$pendingComputed;

  @override
  bool get pending =>
      (_$pendingComputed ??= Computed<bool>(() => super.pending)).value;
  Computed<String> _$humanStatusComputed;

  @override
  String get humanStatus =>
      (_$humanStatusComputed ??= Computed<String>(() => super.humanStatus))
          .value;

  final _$hashAtom = Atom(name: '_TxStore.hash');

  @override
  String get hash {
    _$hashAtom.context.enforceReadPolicy(_$hashAtom);
    _$hashAtom.reportObserved();
    return super.hash;
  }

  @override
  set hash(String value) {
    _$hashAtom.context.conditionallyRunInAction(() {
      super.hash = value;
      _$hashAtom.reportChanged();
    }, _$hashAtom, name: '${_$hashAtom.name}_set');
  }

  final _$feeAtom = Atom(name: '_TxStore.fee');

  @override
  int get fee {
    _$feeAtom.context.enforceReadPolicy(_$feeAtom);
    _$feeAtom.reportObserved();
    return super.fee;
  }

  @override
  set fee(int value) {
    _$feeAtom.context.conditionallyRunInAction(() {
      super.fee = value;
      _$feeAtom.reportChanged();
    }, _$feeAtom, name: '${_$feeAtom.name}_set');
  }

  final _$statusAtom = Atom(name: '_TxStore.status');

  @override
  String get status {
    _$statusAtom.context.enforceReadPolicy(_$statusAtom);
    _$statusAtom.reportObserved();
    return super.status;
  }

  @override
  set status(String value) {
    _$statusAtom.context.conditionallyRunInAction(() {
      super.status = value;
      _$statusAtom.reportChanged();
    }, _$statusAtom, name: '${_$statusAtom.name}_set');
  }

  final _$_TxStoreActionController = ActionController(name: '_TxStore');

  @override
  void _updateFromJson(dynamic json) {
    final _$actionInfo = _$_TxStoreActionController.startAction();
    try {
      return super._updateFromJson(json);
    } finally {
      _$_TxStoreActionController.endAction(_$actionInfo);
    }
  }
}

mixin _$AccountStore on _AccountStore, Store {
  Computed<String> _$humanNameComputed;

  @override
  String get humanName =>
      (_$humanNameComputed ??= Computed<String>(() => super.humanName)).value;
  Computed<bool> _$hasPendingTransactionsComputed;

  @override
  bool get hasPendingTransactions => (_$hasPendingTransactionsComputed ??=
          Computed<bool>(() => super.hasPendingTransactions))
      .value;

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

  final _$ordinalAtom = Atom(name: '_AccountStore.ordinal');

  @override
  int get ordinal {
    _$ordinalAtom.context.enforceReadPolicy(_$ordinalAtom);
    _$ordinalAtom.reportObserved();
    return super.ordinal;
  }

  @override
  set ordinal(int value) {
    _$ordinalAtom.context.conditionallyRunInAction(() {
      super.ordinal = value;
      _$ordinalAtom.reportChanged();
    }, _$ordinalAtom, name: '${_$ordinalAtom.name}_set');
  }

  final _$backedUpAtom = Atom(name: '_AccountStore.backedUp');

  @override
  bool get backedUp {
    _$backedUpAtom.context.enforceReadPolicy(_$backedUpAtom);
    _$backedUpAtom.reportObserved();
    return super.backedUp;
  }

  @override
  set backedUp(bool value) {
    _$backedUpAtom.context.conditionallyRunInAction(() {
      super.backedUp = value;
      _$backedUpAtom.reportChanged();
    }, _$backedUpAtom, name: '${_$backedUpAtom.name}_set');
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void _registerTransaction(TxStore tx) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super._registerTransaction(tx);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _updateTransaction(int id, dynamic json) {
    final _$actionInfo = _$_AccountStoreActionController.startAction();
    try {
      return super._updateTransaction(id, json);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

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
  Computed<List<AccountStore>> _$accountsListComputed;

  @override
  List<AccountStore> get accountsList => (_$accountsListComputed ??=
          Computed<List<AccountStore>>(() => super.accountsList))
      .value;
  Computed<int> _$totalBalanceComputed;

  @override
  int get totalBalance =>
      (_$totalBalanceComputed ??= Computed<int>(() => super.totalBalance))
          .value;
  Computed<bool> _$connectedComputed;

  @override
  bool get connected =>
      (_$connectedComputed ??= Computed<bool>(() => super.connected)).value;
  Computed<bool> _$operableComputed;

  @override
  bool get operable =>
      (_$operableComputed ??= Computed<bool>(() => super.operable)).value;
  Computed<bool> _$synchronizedComputed;

  @override
  bool get synchronized =>
      (_$synchronizedComputed ??= Computed<bool>(() => super.synchronized))
          .value;
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
  Computed<String> _$_txsCollectionComputed;

  @override
  String get _txsCollection => (_$_txsCollectionComputed ??=
          Computed<String>(() => super._txsCollection))
      .value;
  Computed<bool> _$_syncAllowedComputed;

  @override
  bool get _syncAllowed =>
      (_$_syncAllowedComputed ??= Computed<bool>(() => super._syncAllowed))
          .value;

  final _$min_epochAtom = Atom(name: '_NodeService.min_epoch');

  @override
  int get min_epoch {
    _$min_epochAtom.context.enforceReadPolicy(_$min_epochAtom);
    _$min_epochAtom.reportObserved();
    return super.min_epoch;
  }

  @override
  set min_epoch(int value) {
    _$min_epochAtom.context.conditionallyRunInAction(() {
      super.min_epoch = value;
      _$min_epochAtom.reportChanged();
    }, _$min_epochAtom, name: '${_$min_epochAtom.name}_set');
  }

  final _$remote_epochAtom = Atom(name: '_NodeService.remote_epoch');

  @override
  int get remote_epoch {
    _$remote_epochAtom.context.enforceReadPolicy(_$remote_epochAtom);
    _$remote_epochAtom.reportObserved();
    return super.remote_epoch;
  }

  @override
  set remote_epoch(int value) {
    _$remote_epochAtom.context.conditionallyRunInAction(() {
      super.remote_epoch = value;
      _$remote_epochAtom.reportChanged();
    }, _$remote_epochAtom, name: '${_$remote_epochAtom.name}_set');
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

  final _$lastDeletedAccountNameAtom =
      Atom(name: '_NodeService.lastDeletedAccountName');

  @override
  String get lastDeletedAccountName {
    _$lastDeletedAccountNameAtom.context
        .enforceReadPolicy(_$lastDeletedAccountNameAtom);
    _$lastDeletedAccountNameAtom.reportObserved();
    return super.lastDeletedAccountName;
  }

  @override
  set lastDeletedAccountName(String value) {
    _$lastDeletedAccountNameAtom.context.conditionallyRunInAction(() {
      super.lastDeletedAccountName = value;
      _$lastDeletedAccountNameAtom.reportChanged();
    }, _$lastDeletedAccountNameAtom,
        name: '${_$lastDeletedAccountNameAtom.name}_set');
  }
}
