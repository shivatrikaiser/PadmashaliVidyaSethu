abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const phone = '/phone';
  static const verify = '/verify';
  static const register = '/register';
  static const registrationComplete = '/register/complete';
  static const home = '/home';
  static const profilePattern = '/profile/:registrationId';
  static String profile(String registrationId) => '/profile/$registrationId';

  /// Reachable without signing in.
  static const public = {welcome, phone, verify};
}
