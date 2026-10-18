
class DemoAuthService {
  DemoAuthService._();

  /// Demo-only authentication.
  /// No credentials or account information are saved.
  static Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    return email.trim().contains('@') &&
        password.trim().length >= 6 &&
        role.trim().isNotEmpty;
  }

  /// Demo-only registration.
  /// This does not create or persist an account.
  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return name.trim().isNotEmpty &&
        email.trim().contains('@') &&
        password.length >= 6 &&
        role.trim().isNotEmpty;
  }
}
