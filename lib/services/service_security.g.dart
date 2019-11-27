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
  Computed<int> _$lastAppUnlockTsComputed;

  @override
  int get lastAppUnlockTs =>
      (_$lastAppUnlockTsComputed ??= Computed<int>(() => super.lastAppUnlockTs))
          .value;
}
