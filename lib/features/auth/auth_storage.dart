
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Save the JWT token and user details securely.
  static Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );

    await _storage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  // Retrieve the saved authentication token.
  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  // Retrieve the saved user details.
  static Future<Map<String, dynamic>?> getUser() async {
    final value = await _storage.read(key: _userKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } on FormatException {
      return null;
    }
  }

  // Check whether a token is saved.
  static Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Remove saved credentials when the user logs out.
  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
