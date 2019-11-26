import 'dart:convert';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:random_string/random_string.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/store/store_stegos.dart';
import 'package:stegos_wallet/ui/pinprotect/screen_pin_protect.dart';
import 'package:stegos_wallet/utils/crypto.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';

part 'service_security.g.dart';

class SecurityService extends _SecurityService with _$SecurityService {
  SecurityService(StegosEnv env) : super(env);
}

/// Varios security related utility methods.
///
abstract class _SecurityService with Store, Loggable<SecurityService> {
  _SecurityService(this.env) : _provider = _RandomStringProvider();

  final StegosEnv env;

  final _RandomStringProvider _provider;

  StegosStore get store => env.store;

  /// User has pin protected password
  @computed
  bool get hasPinProtectedPassword => store.settings['password'] != null;

  @computed
  int get lastAppUnlockTs => store.settings['lastAppUnlockTs'] as int ?? 0;

  bool get needAppUnlock =>
      _cachedAccountPassword == null ||
      DateTime.now().millisecondsSinceEpoch - lastAppUnlockTs >= env.configMaxAppUnlockedPeriod;

  String _cachedAccountPassword;

  Future<String> acquireAccountPassword(BuildContext context, [int accountId]) async {
    if (!hasPinProtectedPassword) {
      final password = await showDialog<String>(
          context: context, builder: (context) => const PinProtectScreen(unlock: false));
      return _cachedAccountPassword = password;
    } else if (needAppUnlock) {
      final password = await showDialog<String>(
          context: context, builder: (context) => const PinProtectScreen(unlock: true));
      return _cachedAccountPassword = password;
    } else {
      return _cachedAccountPassword;
    }
  }

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Future<String> setupAccountPassword(String pw, String pin) => env.useDb((db) async {
        const utf8Encoder = Utf8Encoder();
        final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
        final iv = const StegosCryptKey().genDartRaw(16);
        final encyptedPassword =
            StegosAesCrypt(key).encrypt(utf8Encoder.convert('stegos:${pw}'), iv);
        await store.mergeSettings({
          'password': base64Encode(encyptedPassword),
          'iv': base64Encode(iv),
          'lastAppUnlockTs': DateTime.now().millisecondsSinceEpoch
        });
        return pw;
      });

  /// Recover pin protected password.
  Future<String> recoverAccountPassword(String pin) async {
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();

    final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
    final iv = store.settings['iv'] as String;
    final password = store.settings['password'] as String;
    if (password == null || iv == null) {
      return Future.error(Exception('Invalid password recover data'));
    }
    var pw = utf8Decoder.convert(StegosAesCrypt(key).decrypt(base64Decode(password), iv));
    if (!pw.startsWith('stegos:')) {
      return Future.error(Exception('Invalid password recovered'));
    }
    pw = pw.substring('stegos:'.length);
    return _touchAppUnlockedPeriod().then((_) => pw);
  }

  Future<void> _touchAppUnlockedPeriod({int touchTs}) =>
      store.mergeSingle('lastAppUnlockTs', touchTs ?? DateTime.now().millisecondsSinceEpoch);
}

class _RandomStringProvider implements Provider {
  _RandomStringProvider() : _random = Math.Random.secure();

  final Math.Random _random;

  @override
  double nextDouble() => _random.nextDouble();
}
