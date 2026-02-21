import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Extension-compatible password-based encryption for settings.enc.
///
/// Format (same as GitSyncMarks extension lib/crypto.js):
///   gitsyncmarks-enc:v1\n<base64-salt>\n<base64-iv>\n<base64-ciphertext>
/// PBKDF2: 100_000 iterations, SHA-256, salt 16 bytes
/// AES-256-GCM, IV 12 bytes
class SettingsCrypto {
  SettingsCrypto._();

  static const String _prefix = 'gitsyncmarks-enc:v1';
  static const int _pbkdf2Iterations = 100000;
  static const int _saltLen = 16;
  static const int _ivLen = 12;

  /// Encrypts plaintext with the given password. Output format matches the
  /// GitSyncMarks browser extension.
  static Future<String> encryptWithPassword(String plaintext, String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password is required');
    }
    final salt = _secureRandom(_saltLen);
    final iv = _secureRandom(_ivLen);
    final key = _deriveKey(password, salt);
    final cipher = _createEncryptCipher(key, iv);
    final plainBytes = utf8.encode(plaintext);
    final cipherBytes = cipher.process(Uint8List.fromList(plainBytes));
    return [
      _prefix,
      base64Encode(salt),
      base64Encode(iv),
      base64Encode(cipherBytes),
    ].join('\n');
  }

  /// Decrypts a string produced by encryptWithPassword (or by the extension).
  /// Throws if password is wrong or format is invalid.
  static Future<String> decryptWithPassword(String encrypted, String password) async {
    if (password.isEmpty) {
      throw ArgumentError('Password is required');
    }
    final lines = encrypted.trim().split('\n');
    if (lines.length < 4 || lines[0] != _prefix) {
      throw const FormatException('Invalid encrypted format');
    }
    final salt = base64Decode(lines[1]);
    final iv = base64Decode(lines[2]);
    final cipherBytes = base64Decode(lines[3]);
    final key = _deriveKey(password, salt);
    final cipher = _createDecryptCipher(key, iv);
    try {
      final plainBytes = cipher.process(Uint8List.fromList(cipherBytes));
      return utf8.decode(plainBytes);
    } catch (_) {
      throw const FormatException('Decryption failed. Wrong password?');
    }
  }

  static Uint8List _secureRandom(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _pbkdf2Iterations, 32);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(params);
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  static GCMBlockCipher _createEncryptCipher(Uint8List key, Uint8List iv) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher;
  }

  static GCMBlockCipher _createDecryptCipher(Uint8List key, Uint8List iv) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher;
  }
}
