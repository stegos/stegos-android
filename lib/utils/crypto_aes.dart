//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at https://mozilla.org/MPL/2.0/.

// © 2019 Aditya Kishore

import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';

import 'package:steel_crypt/PointyCastleN/api.dart';
import 'package:steel_crypt/PointyCastleN/block/aes_fast.dart';
import 'package:steel_crypt/PointyCastleN/block/modes/cbc.dart';
import 'package:steel_crypt/PointyCastleN/stream/ctr.dart';

/// Create symmetric encryption machine (Crypt).
///
class StegosAesCrypt {
  /// [key] - base64 encoded key
  StegosAesCrypt(String key, [String intype = 'cbc', String padding = 'pkcs7']) {
    ///Creates 'Crypt', serves as encrypter/decrypter of text.
    _mode = intype;
    _key = base64.decode(key);
    _paddingName = padding;
    switch (_mode) {
      case 'cbc':
        _encrypter = CBCBlockCipher(AESFastEngine());
        break;
      case 'ctr':
        _paddingName = 'none';
        _encrypter = CTRStreamCipher(AESFastEngine());
        break;
      // Excluded as not needed to save app size
      // case 'sic':
      //   _paddingName = 'none';
      //   _encrypter = SICStreamCipher(AESFastEngine());
      //   break;
      // case 'cfb':
      //   _encrypter = CFBBlockCipher(AESFastEngine(), 64);
      //   break;
      // case 'ecb':
      //   _encrypter = ECBBlockCipher(AESFastEngine());
      //   break;
      // case 'ofb':
      //   _encrypter = OFBBlockCipher(AESFastEngine(), 64);
      //   break;
      default:
        throw Exception('Unknown cipher type: $intype');
    }
    _cipherName = 'AES/${_mode.toUpperCase()}/${_paddingName.toUpperCase()}';
  }

  String _mode;
  Uint8List _key;
  dynamic _encrypter;
  String _paddingName;
  String _cipherName;

  ///Encrypt (with iv) and return in base 64.
  /// [iv] base64 encoded initial vector or raw [Uint8List] data
  Uint8List encrypt(Uint8List input, dynamic iv) {
    if (_paddingName == 'none') {
      final liv = (iv is String) ? base64.decode(iv) : iv as Uint8List;
      final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), liv);
      _encrypter.init(true, params);
      return _encrypter.process(input) as Uint8List;
    } else {
      final liv = (iv is String) ? base64.decode(iv) : iv as Uint8List;
      final params = PaddedBlockCipherParameters(
          ParametersWithIV<KeyParameter>(KeyParameter(_key), liv), null);
      final cipher = PaddedBlockCipher(_cipherName);
      cipher.init(true, params);
      return cipher.process(input);
    }
  }

  ///Decrypt base 64 (with iv) and return original.
  /// [iv] base64 encoded initial vector or raw [Uint8List] data
  Uint8List decrypt(Uint8List encrypted, dynamic iv) {
    if (_paddingName == 'none') {
      final liv = (iv is String) ? base64.decode(iv) : iv as Uint8List;
      final params = ParametersWithIV<KeyParameter>(KeyParameter(_key), liv);
      _encrypter.init(false, params);
      return _encrypter.process(encrypted) as Uint8List;
    } else {
      final liv = (iv is String) ? base64.decode(iv) : iv as Uint8List;
      final params = PaddedBlockCipherParameters(ParametersWithIV(KeyParameter(_key), liv), null);
      final cipher = PaddedBlockCipher(_cipherName);
      cipher.init(false, params);
      return cipher.process(encrypted);
    }
  }
}
