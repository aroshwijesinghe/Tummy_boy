import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/services/storage_service.dart';

class PinService {
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> isPinSet() async {
    return await StorageService.isPinSet();
  }

  static Future<void> setupPin(String pin) async {
    final hash = hashPin(pin);
    await StorageService.savePinHash(hash);
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await StorageService.getPinHash();
    if (storedHash == null) return false;
    final hash = hashPin(pin);
    return hash == storedHash;
  }

  static Future<void> clearPin() async {
    await StorageService.clearPin();
  }
}
