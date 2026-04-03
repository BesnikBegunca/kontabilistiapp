import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String hash(String plain) {
    return sha256.convert(utf8.encode(plain)).toString();
  }

  static bool verify(String plain, String hashed) {
    return hash(plain) == hashed;
  }
}
