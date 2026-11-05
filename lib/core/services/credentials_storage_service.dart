import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class CredentialsStorageService {
  // Prefijo único para ATENEA EAT - Evita conflictos con otras apps
  static const String _appPrefix = 'atenea_eat_';

  // Credenciales guardadas
  static const String _keyEmail = '${_appPrefix}saved_email';
  static const String _keyPassword = '${_appPrefix}saved_password';
  static const String _keyRememberMe = '${_appPrefix}remember_me';

  // Tokens
  static const String _keyAccessToken = '${_appPrefix}access_token';
  static const String _keyRefreshToken = '${_appPrefix}refresh_token';

  // Cache de datos del usuario (del payload JWT)
  static const String _keyUserId = '${_appPrefix}user_id';
  static const String _keyClienteId = '${_appPrefix}cliente_id';
  static const String _keyRolId = '${_appPrefix}rol_id';
  static const String _keyNombre = '${_appPrefix}nombre';
  static const String _keyUserEmail = '${_appPrefix}user_email';
  static const String _keyActivo = '${_appPrefix}activo';
  static const String _keyNombreRol = '${_appPrefix}nombre_rol';
  static const String _keyPrefijo = '${_appPrefix}prefijo';
  static const String _keyEstadoPlan = '${_appPrefix}estado_plan';
  static const String _keyDiasActivos = '${_appPrefix}dias_activos';
  static const String _keySessionId = '${_appPrefix}session_id';
  static const String _keyCreatedAt = '${_appPrefix}created_at';
  static const String _keyTokenIssuedAt = '${_appPrefix}token_issued_at';
  static const String _keyTokenExpiresAt = '${_appPrefix}token_expires_at';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  CredentialsStorageService()
      : _secureStorage = const FlutterSecureStorage(),
        _localAuth = LocalAuthentication();

  /// Verifica si el dispositivo tiene biometría disponible
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Autentica con biometría (Face ID o huella)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final hasBiometrics = await isBiometricAvailable();
      if (!hasBiometrics) return true; // Sin biometría, permitir acceso

      return await _localAuth.authenticate(
        localizedReason: 'Verifica tu identidad para acceder',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Guarda las credenciales de forma segura
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _secureStorage.write(key: _keyEmail, value: email);
      await _secureStorage.write(key: _keyPassword, value: password);
      await _secureStorage.write(key: _keyRememberMe, value: 'true');
    } else {
      await clearCredentials();
    }
  }

  /// Obtiene las credenciales guardadas (requiere biometría si disponible)
  Future<SavedCredentials?> getCredentials() async {
    try {
      final rememberMe = await _secureStorage.read(key: _keyRememberMe);
      if (rememberMe != 'true') return null;

      // Verificar biometría si está disponible
      final hasBiometrics = await isBiometricAvailable();
      if (hasBiometrics) {
        final authenticated = await authenticateWithBiometrics();
        if (!authenticated) return null;
      }

      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);

      if (email != null && password != null) {
        return SavedCredentials(email: email, password: password);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si hay credenciales guardadas (sin autenticar)
  Future<bool> hasCredentials() async {
    final rememberMe = await _secureStorage.read(key: _keyRememberMe);
    return rememberMe == 'true';
  }

  /// Borra las credenciales guardadas
  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
    await _secureStorage.delete(key: _keyRememberMe);
  }

  // ==================== Métodos para Tokens ====================

  /// Guarda el access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _keyAccessToken, value: token);
  }

  /// Guarda el refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  /// Obtiene el access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Obtiene el refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  /// Borra los tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
  }

  // ==================== Cache de Datos del Usuario ====================

  /// Guarda todos los datos del usuario en cache (optimización)
  Future<void> saveUserData({
    required int usuarioId,
    required int clienteId,
    required int rolId,
    required String nombre,
    required String email,
    required bool activo,
    required String nombreRol,
    required String prefijo,
    required String estadoPlan,
    required int diasActivos,
    String? sessionId,
    DateTime? createdAt,
    DateTime? tokenIssuedAt,
    DateTime? tokenExpiresAt,
  }) async {
    await _secureStorage.write(key: _keyUserId, value: usuarioId.toString());
    await _secureStorage.write(key: _keyClienteId, value: clienteId.toString());
    await _secureStorage.write(key: _keyRolId, value: rolId.toString());
    await _secureStorage.write(key: _keyNombre, value: nombre);
    await _secureStorage.write(key: _keyUserEmail, value: email);
    await _secureStorage.write(key: _keyActivo, value: activo.toString());
    await _secureStorage.write(key: _keyNombreRol, value: nombreRol);
    await _secureStorage.write(key: _keyPrefijo, value: prefijo);
    await _secureStorage.write(key: _keyEstadoPlan, value: estadoPlan);
    await _secureStorage.write(key: _keyDiasActivos, value: diasActivos.toString());

    if (sessionId != null) {
      await _secureStorage.write(key: _keySessionId, value: sessionId);
    }
    if (createdAt != null) {
      await _secureStorage.write(key: _keyCreatedAt, value: createdAt.toIso8601String());
    }
    if (tokenIssuedAt != null) {
      await _secureStorage.write(key: _keyTokenIssuedAt, value: tokenIssuedAt.millisecondsSinceEpoch.toString());
    }
    if (tokenExpiresAt != null) {
      await _secureStorage.write(key: _keyTokenExpiresAt, value: tokenExpiresAt.millisecondsSinceEpoch.toString());
    }
  }

  /// Obtiene el ID del usuario del cache
  Future<int?> getUserId() async {
    final value = await _secureStorage.read(key: _keyUserId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Obtiene el ID del cliente del cache
  Future<int?> getClienteId() async {
    final value = await _secureStorage.read(key: _keyClienteId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Obtiene el ID del rol del cache
  Future<int?> getRolId() async {
    final value = await _secureStorage.read(key: _keyRolId);
    return value != null ? int.tryParse(value) : null;
  }

  /// Obtiene el nombre del usuario del cache
  Future<String?> getNombre() async {
    return await _secureStorage.read(key: _keyNombre);
  }

  /// Obtiene el email del usuario del cache
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: _keyUserEmail);
  }

  /// Obtiene el estado activo del usuario del cache
  Future<bool?> getActivo() async {
    final value = await _secureStorage.read(key: _keyActivo);
    return value != null ? value == 'true' : null;
  }

  /// Obtiene el nombre del rol del cache
  Future<String?> getNombreRol() async {
    return await _secureStorage.read(key: _keyNombreRol);
  }

  /// Obtiene el prefijo del cache
  Future<String?> getPrefijo() async {
    return await _secureStorage.read(key: _keyPrefijo);
  }

  /// Obtiene el estado del plan del cache
  Future<String?> getEstadoPlan() async {
    return await _secureStorage.read(key: _keyEstadoPlan);
  }

  /// Obtiene los días activos del cache
  Future<int?> getDiasActivos() async {
    final value = await _secureStorage.read(key: _keyDiasActivos);
    return value != null ? int.tryParse(value) : null;
  }

  /// Obtiene el session ID del cache
  Future<String?> getSessionId() async {
    return await _secureStorage.read(key: _keySessionId);
  }

  /// Obtiene la fecha de creación del cache
  Future<DateTime?> getCreatedAt() async {
    final value = await _secureStorage.read(key: _keyCreatedAt);
    return value != null ? DateTime.tryParse(value) : null;
  }

  /// Obtiene la fecha de emisión del token del cache
  Future<DateTime?> getTokenIssuedAt() async {
    final value = await _secureStorage.read(key: _keyTokenIssuedAt);
    return value != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(value)) : null;
  }

  /// Obtiene la fecha de expiración del token del cache
  Future<DateTime?> getTokenExpiresAt() async {
    final value = await _secureStorage.read(key: _keyTokenExpiresAt);
    return value != null ? DateTime.fromMillisecondsSinceEpoch(int.parse(value)) : null;
  }

  /// Borra todos los datos del usuario del cache
  Future<void> clearUserData() async {
    await _secureStorage.delete(key: _keyUserId);
    await _secureStorage.delete(key: _keyClienteId);
    await _secureStorage.delete(key: _keyRolId);
    await _secureStorage.delete(key: _keyNombre);
    await _secureStorage.delete(key: _keyUserEmail);
    await _secureStorage.delete(key: _keyActivo);
    await _secureStorage.delete(key: _keyNombreRol);
    await _secureStorage.delete(key: _keyPrefijo);
    await _secureStorage.delete(key: _keyEstadoPlan);
    await _secureStorage.delete(key: _keyDiasActivos);
    await _secureStorage.delete(key: _keySessionId);
    await _secureStorage.delete(key: _keyCreatedAt);
    await _secureStorage.delete(key: _keyTokenIssuedAt);
    await _secureStorage.delete(key: _keyTokenExpiresAt);
  }
}

class SavedCredentials {
  final String email;
  final String password;

  SavedCredentials({required this.email, required this.password});
}
