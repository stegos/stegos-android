// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_node.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

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
