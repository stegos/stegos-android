import 'dart:convert';
import 'dart:math' as Math;

import 'package:random_string/random_string.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/utils/crypto.dart';
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
        const utf8Encoder = Utf8Encoder();
        final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
        final iv = const StegosCryptKey().genDart(16);
        final encyptedPassword =
            StegosAesCrypt(key).encrypt(utf8Encoder.convert('stegos:${password}'), iv);
        await env.store.mergeSettings({
          'password': base64Encode(encyptedPassword),
          'iv': iv,
          'lastAppUnlockTs': DateTime.now().millisecondsSinceEpoch
        });
      });

  /// Recover pin protected password.
  Future<String> recoverAccountPassword(String pin) {
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();

    final store = env.store;
    final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
    final iv = store.settings['iv'] as String;
    final password = store.settings['password'] as String;
    if (password == null || iv == null) {
      return Future.error(Exception('Invalid password recover data'));
    }
    final pw = utf8Decoder.convert(StegosAesCrypt(key).decrypt(base64Decode(password), iv));
    if (!pw.startsWith('stegos:')) {
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
