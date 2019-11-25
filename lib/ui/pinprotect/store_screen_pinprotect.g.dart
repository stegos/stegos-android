// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_screen_pinprotect.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PinprotectScreenStore on _PinprotectScreenStore, Store {
  Computed<String> _$titleComputed;

  @override
  String get title =>
      (_$titleComputed ??= Computed<String>(() => super.title)).value;

  final _$unlockAttemptAtom =
      Atom(name: '_PinprotectScreenStore.unlockAttempt');

  @override
  int get unlockAttempt {
    _$unlockAttemptAtom.context.enforceReadPolicy(_$unlockAttemptAtom);
    _$unlockAttemptAtom.reportObserved();
    return super.unlockAttempt;
  }

  @override
  set unlockAttempt(int value) {
    _$unlockAttemptAtom.context.conditionallyRunInAction(() {
      super.unlockAttempt = value;
      _$unlockAttemptAtom.reportChanged();
    }, _$unlockAttemptAtom, name: '${_$unlockAttemptAtom.name}_set');
  }

  final _$firstPinAtom = Atom(name: '_PinprotectScreenStore.firstPin');

  @override
  String get firstPin {
    _$firstPinAtom.context.enforceReadPolicy(_$firstPinAtom);
    _$firstPinAtom.reportObserved();
    return super.firstPin;
  }

  @override
  set firstPin(String value) {
    _$firstPinAtom.context.conditionallyRunInAction(() {
      super.firstPin = value;
      _$firstPinAtom.reportChanged();
    }, _$firstPinAtom, name: '${_$firstPinAtom.name}_set');
  }

  final _$secondPinAtom = Atom(name: '_PinprotectScreenStore.secondPin');

  @override
  String get secondPin {
    _$secondPinAtom.context.enforceReadPolicy(_$secondPinAtom);
    _$secondPinAtom.reportObserved();
    return super.secondPin;
  }

  @override
  set secondPin(String value) {
    _$secondPinAtom.context.conditionallyRunInAction(() {
      super.secondPin = value;
      _$secondPinAtom.reportChanged();
    }, _$secondPinAtom, name: '${_$secondPinAtom.name}_set');
  }
}
