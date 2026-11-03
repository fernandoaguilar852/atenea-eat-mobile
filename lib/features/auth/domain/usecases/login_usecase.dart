import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<({String accessToken, String refreshToken, User user})> call({
    required String email,
    required String password,
  }) async {
    // Validaciones de negocio
    if (email.isEmpty) {
      throw Exception('El email es requerido');
    }

    if (password.isEmpty) {
      throw Exception('La contraseña es requerida');
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('El email no tiene un formato válido');
    }

    // Llamar al repository
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}
