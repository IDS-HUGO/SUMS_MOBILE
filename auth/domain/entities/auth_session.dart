import 'user.dart';

class AuthSession {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  bool get isAuthenticated => token.isNotEmpty;
}
