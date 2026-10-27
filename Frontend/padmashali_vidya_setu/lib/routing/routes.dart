abstract final class Routes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const phone = '/phone';
  static const verify = '/verify';
  static const register = '/register';
  static const registrationComplete = '/register/complete';
  static const home = '/home';
  static const deleteAccount = '/account/delete';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const contact = '/contact';
  static const profilePattern = '/profile/:registrationId';
  static String profile(String registrationId) => '/profile/$registrationId';

  /// Information pages (menu, legal links): open in every session state, signed in or not.
  static const information = {privacy, terms, contact};

  /// Reachable without signing in.
  static const public = {welcome, phone, verify, ...information};
}
