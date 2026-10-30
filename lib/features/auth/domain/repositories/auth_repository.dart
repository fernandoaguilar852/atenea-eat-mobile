import '../entities/user.dart';

abstract class AuthRepository {
  Future<({String accessToken, String refreshToken, User user})> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}
