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

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Future<void> setupAccountPassword(String pw, String pin) => env.useDb((db) async {
        const utf8Encoder = Utf8Encoder();
        final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
        final iv = const StegosCryptKey().genDartRaw(16);
        final encyptedPassword =
            StegosAesCrypt(key).encrypt(utf8Encoder.convert('stegos:${pw}'), iv);
        await env.store.mergeSettings({
          'password': base64Encode(encyptedPassword),
          'iv': base64Encode(iv),
        });
        return env.store.touchAppUnlockedPeriod(password: pw);
      });

  /// Recover pin protected password.
  Future<String> recoverAccountPassword(String pin) async {
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();

    final store = env.store;
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
    return store.touchAppUnlockedPeriod(password: pw).then((_) => pw);
  }
}

class _RandomStringProvider implements Provider {
  _RandomStringProvider() : _random = Math.Random.secure();

  final Math.Random _random;

  @override
  double nextDouble() => _random.nextDouble();
}
