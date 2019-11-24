import 'dart:math' as Math;

import 'package:random_string/random_string.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:stegos_wallet/env_stegos.dart';

/// Varios security related utility methods.
///
class SecurityService {
  SecurityService(this.env) : _provider = _RandomStringProvider();

  final StegosEnv env;

  final _RandomStringProvider _provider;

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Future<void> setupAccountPassword(String password, String pin) => env.useDb((db) async {
        final ekey = pin.padRight(32, '@');
        final iv = CryptKey().genDart(16);
        final encyptedPassword = AesCrypt(ekey, 'cfb-64', 'pkcs7').encrypt(password, iv);
        await env.store.mergeSettings({'password': encyptedPassword, 'iv': iv});
      });

  /// Recover pin protected password.
  /// Future will be resolved to an empty string if password cannot be recovered.
  Future<String> recoverAccountPassword(String pin) async {
    final store = env.store;
    final ekey = pin.padRight(32, '@');
    final iv = store.settings['iv'] as String;
    final password = store.settings['password'] as String;
    if (password == null || iv == null) {
      return '';
    }
    return AesCrypt(ekey, 'cfb-64', 'pkcs7').decrypt(password, iv);
  }
}

class _RandomStringProvider implements Provider {
  _RandomStringProvider() : _random = Math.Random.secure();

  final Math.Random _random;

  @override
  double nextDouble() => _random.nextDouble();
}
