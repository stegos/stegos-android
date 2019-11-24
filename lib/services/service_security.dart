import 'dart:math' as Math;

import 'package:random_string/random_string.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';

/// Varios security related utility methods.
///
class SecurityService {
  SecurityService(this.env) : _provider = _RandomStringProvider();

  final StegosEnv env;

  final _RandomStringProvider _provider;

  /// Last known unlocked password
  String unlockedPassword;

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Future<void> setupAccountPassword(String password, String pin) => env.useDb((db) async {
        unlockedPassword = null;
        final ekey = '${pin.padRight(32, '@')}';
        final iv = CryptKey().genDart(16).substring(0, 16);
        final encyptedPassword = StegosAesCrypt(ekey).encrypt('pin:${password}', iv);
        await env.store.mergeSettings({
          'password': encyptedPassword,
          'iv': iv,
          'lastAppUnlockTs': DateTime.now().millisecondsSinceEpoch
        });
      });

  /// Recover pin protected password.
  Future<String> recoverAccountPassword(String pin) {
    final store = env.store;
    final ekey = pin.padRight(32, '@');
    final iv = store.settings['iv'] as String;
    final password = store.settings['password'] as String;
    if (password == null || iv == null) {
      return Future.error(Exception('Invalid settings'));
    }
    final pw = StegosAesCrypt(ekey).decrypt(password, iv);
    if (!pw.startsWith('pin:')) {
      return Future.error(Exception('Invalid password recovered'));
    }
    unlockedPassword = unlockedPassword;
    store.touchAppUnlockedPeriod();
    return Future.value(unlockedPassword);
  }
}

class _RandomStringProvider implements Provider {
  _RandomStringProvider() : _random = Math.Random.secure();

  final Math.Random _random;

  @override
  double nextDouble() => _random.nextDouble();
}
