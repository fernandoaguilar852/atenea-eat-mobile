import 'package:jwt_decode/jwt_decode.dart' as jwt_decode;
import '../../../../core/services/credentials_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/login_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final CredentialsStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.storageService,
  });

  @override
  Future<({String accessToken, String refreshToken, User user})> login({
    required String email,
    required String password,
  }) async {
    try {
      // Llamar al API
      final response = await remoteDatasource.login(email, password);

      // Validar respuesta exitosa
      if (response.messageResponse.responseCode != '0000') {
        throw Exception(response.messageResponse.responseDetails);
      }

      // Convertir a entidad
      final user = LoginMapper.fromDto(response);

      // Guardar tokens en storage seguro
      await storageService.saveAccessToken(response.data.accessToken);
      await storageService.saveRefreshToken(response.data.refreshToken);

      // Guardar credenciales para biometría (siempre remember me por defecto)
      await storageService.saveCredentials(
        email: email,
        password: password,
        rememberMe: true,
      );

      return (
        accessToken: response.data.accessToken,
        refreshToken: response.data.refreshToken,
        user: user,
      );
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Llamar al API para logout
      await remoteDatasource.logout();
    } finally {
      // Limpiar storage local siempre
      await storageService.clearTokens();
      await storageService.clearCredentials();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await storageService.getAccessToken();
      if (token == null) return null;

      // Decodificar el token JWT para obtener los datos del usuario
      final payload = jwt_decode.Jwt.parseJwt(token);

      final iat = payload['iat'] as int?;
      final exp = payload['exp'] as int?;

      return User(
        usuarioId: payload['usuarioId'] as int,
        clienteId: payload['clienteId'] as int,
        rolId: payload['rolId'] as int,
        nombre: payload['nombre'] as String,
        email: payload['email'] as String,
        activo: payload['activo'] as bool? ?? true,
        nombreRol: payload['nombreRol'] as String,
        prefijo: payload['prefijo'] as String,
        estadoPlan: payload['estadoPlan'] as String,
        diasActivos: payload['diasActivos'] as int,
        sessionId: payload['sessionId'] as String?,
        createdAt: payload['createdAt'] != null
            ? DateTime.parse(payload['createdAt'] as String)
            : null,
        tokenIssuedAt: iat != null
            ? DateTime.fromMillisecondsSinceEpoch(iat * 1000)
            : null,
        tokenExpiresAt: exp != null
            ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
