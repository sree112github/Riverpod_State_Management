// lib/services/encryption_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {

  static String encrypt(String plainText, String bleKey) {
    print("Encryption key is : $bleKey");
    final keyBytes = Uint8List.fromList(hex.decode(bleKey));
    final key = KeyParameter(keyBytes);
    final iv = Uint8List(12)..setAll(0, List.generate(12, (_) => Random.secure().nextInt(256)));

    final gcmParams = AEADParameters(key, 128, iv, Uint8List(0));
    final cipher = GCMBlockCipher(AESEngine())..init(true,gcmParams);
    final cipherText = cipher.process(Uint8List.fromList(utf8.encode(plainText)));

    final output = Uint8List(iv.length + cipherText.length)
      ..setRange(0, iv.length, iv)
      ..setRange(iv.length, iv.length + cipherText.length, cipherText);
    print("the encrypted text: ${base64Encode(output)}");
    return base64Encode(output);
  }

  String decrypt(String base64CipherText,String bleKey) {
    final encryptedBytes = base64Decode(base64CipherText);
    final iv = encryptedBytes.sublist(0, 12);
    final cipherTextWithTag = encryptedBytes.sublist(12);

    final keyBytes = Uint8List.fromList(hex.decode(bleKey));
    final key = KeyParameter(keyBytes);

    final gcmParams = AEADParameters(key, 128, iv, Uint8List(0));
    final cipher = GCMBlockCipher(AESEngine())..init(false, gcmParams);
    final decryptedBytes = cipher.process(cipherTextWithTag);

    return utf8.decode(decryptedBytes);
  }



}
