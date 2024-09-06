import 'dart:convert';

import 'package:crypto/crypto.dart';

class CriptyHelper {
  CriptyHelper._();
  static String generateSha256Hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();
}
