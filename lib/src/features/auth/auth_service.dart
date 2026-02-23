/// Simple in-memory auth state.
/// Resets to false on every page load (no persistence by design).
class AuthService {
  AuthService._();

  static bool _authenticated = false;

  static bool get isAuthenticated => _authenticated;

  static void login() => _authenticated = true;

  static void logout() => _authenticated = false;
}
