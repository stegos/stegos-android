// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_screen_pay.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PayScreenStore on _PayScreenStore, Store {
  final _$senderAccountAtom = Atom(name: '_PayScreenStore.senderAccount');

  @override
  AccountStore get senderAccount {
    _$senderAccountAtom.context.enforceReadPolicy(_$senderAccountAtom);
    _$senderAccountAtom.reportObserved();
    return super.senderAccount;
  }

  @override
  set senderAccount(AccountStore value) {
    _$senderAccountAtom.context.conditionallyRunInAction(() {
      super.senderAccount = value;
      _$senderAccountAtom.reportChanged();
    }, _$senderAccountAtom, name: '${_$senderAccountAtom.name}_set');
  }

  final _$toAddressAtom = Atom(name: '_PayScreenStore.toAddress');

  @override
  String get toAddress {
    _$toAddressAtom.context.enforceReadPolicy(_$toAddressAtom);
    _$toAddressAtom.reportObserved();
    return super.toAddress;
  }

  @override
  set toAddress(String value) {
    _$toAddressAtom.context.conditionallyRunInAction(() {
      super.toAddress = value;
      _$toAddressAtom.reportChanged();
    }, _$toAddressAtom, name: '${_$toAddressAtom.name}_set');
  }

  final _$amountAtom = Atom(name: '_PayScreenStore.amount');

  @override
  double get amount {
    _$amountAtom.context.enforceReadPolicy(_$amountAtom);
    _$amountAtom.reportObserved();
    return super.amount;
  }

  @override
  set amount(double value) {
    _$amountAtom.context.conditionallyRunInAction(() {
      super.amount = value;
      _$amountAtom.reportChanged();
    }, _$amountAtom, name: '${_$amountAtom.name}_set');
  }

  final _$feeAtom = Atom(name: '_PayScreenStore.fee');

  @override
  double get fee {
    _$feeAtom.context.enforceReadPolicy(_$feeAtom);
    _$feeAtom.reportObserved();
    return super.fee;
  }

  @override
  set fee(double value) {
    _$feeAtom.context.conditionallyRunInAction(() {
      super.fee = value;
      _$feeAtom.reportChanged();
    }, _$feeAtom, name: '${_$feeAtom.name}_set');
  }

  final _$generateCertificateAtom =
      Atom(name: '_PayScreenStore.generateCertificate');

  @override
  bool get generateCertificate {
    _$generateCertificateAtom.context
        .enforceReadPolicy(_$generateCertificateAtom);
    _$generateCertificateAtom.reportObserved();
    return super.generateCertificate;
  }

  @override
  set generateCertificate(bool value) {
    _$generateCertificateAtom.context.conditionallyRunInAction(() {
      super.generateCertificate = value;
      _$generateCertificateAtom.reportChanged();
    }, _$generateCertificateAtom,
        name: '${_$generateCertificateAtom.name}_set');
  }

  final _$_PayScreenStoreActionController =
      ActionController(name: '_PayScreenStore');

  @override
  void reset() {
    final _$actionInfo = _$_PayScreenStoreActionController.startAction();
    try {
      return super.reset();
    } finally {
      _$_PayScreenStoreActionController.endAction(_$actionInfo);
    }
  }
}
