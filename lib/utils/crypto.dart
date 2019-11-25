import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:steel_crypt/PointyCastleN/api.dart';
import 'package:steel_crypt/PointyCastleN/export.dart';

///Class for creating cryptographically secure strings.
class StegosCryptKey {
  const StegosCryptKey();

  static SecureRandom _getSecureRandom() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (i) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Generate cryptographically-secure random string using Fortuna algorithm.
  ///
  /// This should be used for all cases where privacy is of high importance.
  ///
  /// Defaults to length 32 (bytes).
  String genFortuna([int length = 32]) {
    final rand = _getSecureRandom();
    final values = rand.nextBytes(length);
    final stringer = base64.encode(values);
    return stringer;
  }

  /// Generate secure random String using Dart math.random.
  ///
  /// This is less secure than Fortuna, but faster. It can be used for IVs and salts,
  /// but never for keys.
  ///
  /// Defaults to length 16.
  String genDart([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (i) => rand.nextInt(256));
    return base64.encode(bytes);
  }
}
