// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_node_client.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$StegosNodeClient on _StegosNodeClient, Store {
  final _$connectedAtom = Atom(name: '_StegosNodeClient.connected');

  @override
  bool get connected {
    _$connectedAtom.context.enforceReadPolicy(_$connectedAtom);
    _$connectedAtom.reportObserved();
    return super.connected;
  }

  @override
  set connected(bool value) {
    _$connectedAtom.context.conditionallyRunInAction(() {
      super.connected = value;
      _$connectedAtom.reportChanged();
    }, _$connectedAtom, name: '${_$connectedAtom.name}_set');
  }
}
