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

  final _$_cachedPwpAtom = Atom(name: '_SecurityService._cachedPwp');

  @override
  Pair<String, String> get _cachedPwp {
    _$_cachedPwpAtom.context.enforceReadPolicy(_$_cachedPwpAtom);
    _$_cachedPwpAtom.reportObserved();
    return super._cachedPwp;
  }

  @override
  set _cachedPwp(Pair<String, String> value) {
    _$_cachedPwpAtom.context.conditionallyRunInAction(() {
      super._cachedPwp = value;
      _$_cachedPwpAtom.reportChanged();
    }, _$_cachedPwpAtom, name: '${_$_cachedPwpAtom.name}_set');
  }
}
