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
import 'package:steel_crypt/PointyCastleN/block/modes/cfb.dart';
import 'package:steel_crypt/PointyCastleN/block/modes/ecb.dart';
import 'package:steel_crypt/PointyCastleN/block/modes/ofb.dart';
import 'package:steel_crypt/PointyCastleN/stream/ctr.dart';
import 'package:steel_crypt/PointyCastleN/stream/sic.dart';

///Create symmetric encryption machine (Crypt).
class StegosAesCrypt {
  StegosAesCrypt(String key, [String intype = 'cbc', String padding = 'pkcs7']) {
    ///Creates 'Crypt', serves as encrypter/decrypter of text.
    _mode = intype;
    _key = key;
    _paddingName = padding;

    if (_mode == 'cbc') {
      _encrypter = CBCBlockCipher(AESFastEngine());
    } else if (_mode == 'sic') {
      _paddingName = 'none';
      _encrypter = SICStreamCipher(AESFastEngine());
    } else if (_mode == 'cfb') {
      _encrypter = CFBBlockCipher(AESFastEngine(), 64);
    } else if (_mode == 'ctr') {
      _paddingName = 'none';
      _encrypter = CTRStreamCipher(AESFastEngine());
    } else if (_mode == 'ecb') {
      _encrypter = ECBBlockCipher(AESFastEngine());
    } else if (_mode == 'ofb') {
      _encrypter = OFBBlockCipher(AESFastEngine(), 64);
    }
    _cipherName = 'AES/${_mode.toUpperCase()}/${_paddingName.toUpperCase()}';
  }

  String _mode;
  String _key;
  dynamic _encrypter;
  String _paddingName;
  String _cipherName;

  ///Get this AesCrypt's key;
  String get key => _key;

  ///Get this AesCrypt's type of padding.
  String get padding => _paddingName;

  ///Get this AesCrypt's mode of AES.
  String get mode => _mode;

  ///Encrypt (with iv) and return in base 64.
  String encrypt(String input, String iv) {
    const utf8Encoder = Utf8Encoder();

    if (_mode != 'ecb') {
      if (_paddingName == 'none') {
        final key = utf8Encoder.convert(_key);
        final liv = utf8Encoder.convert(iv);
        final linput = utf8Encoder.convert(input);
        final params = ParametersWithIV<KeyParameter>(KeyParameter(key), liv);
        _encrypter.init(true, params);
        final inter = _encrypter.process(linput) as Uint8List;
        return base64.encode(inter);
      } else {
        final key = utf8Encoder.convert(_key);
        final liv = utf8Encoder.convert(iv);
        final params = PaddedBlockCipherParameters(
            ParametersWithIV<KeyParameter>(KeyParameter(key), liv), null);
        final cipher = PaddedBlockCipher(_cipherName);
        cipher.init(true, params);
        final inter = cipher.process(utf8Encoder.convert(input));
        return base64.encode(inter);
      }
    } else {
      final key = utf8Encoder.convert(_key);
      final params = PaddedBlockCipherParameters(KeyParameter(key), null);
      final cipher = PaddedBlockCipher(_cipherName);
      cipher.init(true, params);
      final inter = cipher.process(utf8Encoder.convert(input));
      return base64.encode(inter);
    }
  }

  ///Decrypt base 64 (with iv) and return original.
  String decrypt(String encrypted, String iv) {
    const utf8Encoder = Utf8Encoder();
    const utf8Decoder = Utf8Decoder();

    if (_mode != 'ecb') {
      if (_paddingName == 'none') {
        final key = utf8Encoder.convert(_key);
        final liv = utf8Encoder.convert(iv);
        final linput = base64.decode(encrypted);
        final params = ParametersWithIV<KeyParameter>(KeyParameter(key), liv);
        _encrypter.init(false, params);
        final inter = _encrypter.process(linput) as Uint8List;
        return utf8Decoder.convert(inter);
      } else {
        final key = utf8Encoder.convert(_key);
        final liv = utf8Encoder.convert(iv);
        final params = PaddedBlockCipherParameters(ParametersWithIV(KeyParameter(key), liv), null);
        final cipher = PaddedBlockCipher(_cipherName);
        cipher.init(false, params);
        final inter = cipher.process(base64.decode(encrypted));
        return utf8Decoder.convert(inter);
      }
    } else {
      final key = utf8Encoder.convert(_key);
      final params = PaddedBlockCipherParameters(KeyParameter(key), null);
      final cipher = PaddedBlockCipher(_cipherName);
      cipher.init(false, params);
      final inter = cipher.process(base64.decode(encrypted));
      return utf8Decoder.convert(inter);
    }
  }
}

// void main() {
//   final aes = AesCrypt2('xPM4oRn0/GintAaKOZA6Qw==', 'cbc');
//   final data = aes.encrypt('test', '1111111111111111');
//   print('Data: ${data}');
// }
