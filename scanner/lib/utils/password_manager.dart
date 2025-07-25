import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString(); // hex string
  }

  static bool verifyPassword(String password, String storedHash) {
    return hashPassword(password) == storedHash;
  }
}
