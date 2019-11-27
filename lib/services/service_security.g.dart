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

  final _$_cachedAccountPasswordAtom =
      Atom(name: '_SecurityService._cachedAccountPassword');

  @override
  String get _cachedAccountPassword {
    _$_cachedAccountPasswordAtom.context
        .enforceReadPolicy(_$_cachedAccountPasswordAtom);
    _$_cachedAccountPasswordAtom.reportObserved();
    return super._cachedAccountPassword;
  }

  @override
  set _cachedAccountPassword(String value) {
    _$_cachedAccountPasswordAtom.context.conditionallyRunInAction(() {
      super._cachedAccountPassword = value;
      _$_cachedAccountPasswordAtom.reportChanged();
    }, _$_cachedAccountPasswordAtom,
        name: '${_$_cachedAccountPasswordAtom.name}_set');
  }
}
