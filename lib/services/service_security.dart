import 'dart:convert';
import 'dart:math' as Math;

import 'package:mobx/mobx.dart';
import 'package:random_string/random_string.dart';
import 'package:stegos_wallet/env_stegos.dart';
import 'package:stegos_wallet/log/loggable.dart';
import 'package:stegos_wallet/stores/store_stegos.dart';
import 'package:stegos_wallet/ui/pinprotect/screen_pin_protect.dart';
import 'package:stegos_wallet/utils/cont.dart';
import 'package:stegos_wallet/utils/crypto.dart';
import 'package:stegos_wallet/utils/crypto_aes.dart';
import 'package:stegos_wallet/utils/dialogs.dart';

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

  /// Cached app password / pin pair
  @observable
  Pair<String, String> _cachedPwPin;

  bool get needAppUnlock => !(_cachedPwPin != null &&
      DateTime.now().millisecondsSinceEpoch - (store.settings['lastAppUnlockTs'] as int ?? 0) <
          env.configMaxAppUnlockedPeriod);

  Future<void> checkAppPin() => acquirePasswordForApp(forceUnlock: true);

  Future<Pair<String, String>> acquirePasswordForApp({bool forceUnlock = false}) async {
    if (!hasPinProtectedPassword) {
      final pwpin = await appShowDialog<Pair<String, String>>(
          builder: (context) => const PinProtectScreen(unlock: false));
      runInAction(() {
        _cachedPwPin = pwpin;
      });
      return pwpin;
    } else if (forceUnlock || needAppUnlock) {
      final pwpin = await appShowDialog<Pair<String, String>>(
          builder: (context) => const PinProtectScreen(unlock: true));
      runInAction(() {
        _cachedPwPin = pwpin;
      });
      return _cachedPwPin;
    } else {
      return _cachedPwPin;
    }
  }

  /// Create new random generated password
  String createRandomPassword() =>
      randomAlphaNumeric(env.configGeneratedPasswordsLength, provider: _provider);

  Pair<String, String> setupPinProtectedPassword(String password, String pin) {
    const utf8Encoder = Utf8Encoder();
    final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
    final iv = const StegosCryptKey().genDartRaw(16);
    final encyptedPassword =
        StegosAesCrypt(key).encrypt(utf8Encoder.convert('stegos:${password}'), iv);
    return Pair(base64Encode(encyptedPassword), base64Encode(iv));
  }

  Future<String> setupAppPassword(String password, String pin) => env.useDb((db) async {
        final pp = setupPinProtectedPassword(password, pin);
        await store.mergeSettings({
          'password': pp.first,
          'iv': pp.second,
          'lastAppUnlockTs': DateTime.now().millisecondsSinceEpoch
        });
        return password;
      });

  Pair<String, String> recoverPinProtectedPassword(String pin, String password, String iv) {
    if (pin == null || password == null || iv == null) {
      throw Exception('Invalid password recovery data');
    }
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();
    final key = base64Encode(utf8Encoder.convert(pin.padRight(32, '@')));
    final pw = utf8Decoder.convert(StegosAesCrypt(key).decrypt(base64Decode(password), iv));
    if (!pw.startsWith('stegos:')) {
      throw Exception('Invalid password recovered');
    }
    return Pair(pw.substring('stegos:'.length), pin);
  }

  /// Recover pin protected password.
  Future<String> recoverAppPassword(String pin) async {
    final password = store.settings['password'] as String;
    final iv = store.settings['iv'] as String;
    final pwpin = recoverPinProtectedPassword(pin, password, iv);
    runInAction(() {
      _cachedPwPin = pwpin;
    });
    return _touchAppUnlockedPeriod().then((_) => pwpin.first);
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
