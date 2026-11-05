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

      // OPTIMIZACIÓN: Guardar datos del usuario en cache para acceso rápido
      await storageService.saveUserData(
        usuarioId: user.usuarioId,
        clienteId: user.clienteId,
        rolId: user.rolId,
        nombre: user.nombre,
        email: user.email,
        activo: user.activo,
        nombreRol: user.nombreRol,
        prefijo: user.prefijo,
        estadoPlan: user.estadoPlan,
        diasActivos: user.diasActivos,
        sessionId: user.sessionId,
        createdAt: user.createdAt,
        tokenIssuedAt: user.tokenIssuedAt,
        tokenExpiresAt: user.tokenExpiresAt,
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
      // Obtener el refreshToken del storage
      final refreshToken = await storageService.getRefreshToken();

      // Llamar al API para logout si tenemos refreshToken
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await remoteDatasource.logout(refreshToken);
      }
    } finally {
      // Limpiar storage local siempre (incluso si el API falla)
      await storageService.clearTokens();
      await storageService.clearCredentials();
      await storageService.clearUserData(); // Limpiar cache de datos del usuario
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await storageService.getAccessToken();
      if (token == null) return null;

      // OPTIMIZACIÓN: Leer datos del cache en lugar de decodificar JWT
      final usuarioId = await storageService.getUserId();
      final clienteId = await storageService.getClienteId();
      final rolId = await storageService.getRolId();
      final nombre = await storageService.getNombre();
      final email = await storageService.getUserEmail();
      final activo = await storageService.getActivo();
      final nombreRol = await storageService.getNombreRol();
      final prefijo = await storageService.getPrefijo();
      final estadoPlan = await storageService.getEstadoPlan();
      final diasActivos = await storageService.getDiasActivos();
      final sessionId = await storageService.getSessionId();
      final createdAt = await storageService.getCreatedAt();
      final tokenIssuedAt = await storageService.getTokenIssuedAt();
      final tokenExpiresAt = await storageService.getTokenExpiresAt();

      // Si faltan datos en cache, retornar null
      if (usuarioId == null ||
          clienteId == null ||
          rolId == null ||
          nombre == null ||
          email == null ||
          nombreRol == null ||
          prefijo == null ||
          estadoPlan == null ||
          diasActivos == null) {
        return null;
      }

      return User(
        usuarioId: usuarioId,
        clienteId: clienteId,
        rolId: rolId,
        nombre: nombre,
        email: email,
        activo: activo ?? true,
        nombreRol: nombreRol,
        prefijo: prefijo,
        estadoPlan: estadoPlan,
        diasActivos: diasActivos,
        sessionId: sessionId,
        createdAt: createdAt,
        tokenIssuedAt: tokenIssuedAt,
        tokenExpiresAt: tokenExpiresAt,
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
