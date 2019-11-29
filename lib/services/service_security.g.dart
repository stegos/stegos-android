// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_security.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SecurityService on _SecurityService, Store {
  Computed<bool> _$hasPinProtectedPasswordComputed;

  @override
  bool get hasPinProtectedPassword => (_$hasPinProtectedPasswordComputed ??=
          Computed<bool>(() => super.hasPinProtectedPassword))
      .value;

  final _$_cachedPwPinAtom = Atom(name: '_SecurityService._cachedPwPin');

  @override
  Pair<String, String> get _cachedPwPin {
    _$_cachedPwPinAtom.context.enforceReadPolicy(_$_cachedPwPinAtom);
    _$_cachedPwPinAtom.reportObserved();
    return super._cachedPwPin;
  }

  @override
  set _cachedPwPin(Pair<String, String> value) {
    _$_cachedPwPinAtom.context.conditionallyRunInAction(() {
      super._cachedPwPin = value;
      _$_cachedPwPinAtom.reportChanged();
    }, _$_cachedPwPinAtom, name: '${_$_cachedPwPinAtom.name}_set');
  }
}
