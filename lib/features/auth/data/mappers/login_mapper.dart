import 'package:jwt_decode/jwt_decode.dart';
import '../../domain/entities/user.dart';
import '../models/login_response_dto.dart';

class LoginMapper {
  static User fromDto(LoginResponseDto dto) {
    // Decodificar el JWT para obtener los datos del usuario
    final payload = Jwt.parseJwt(dto.data.accessToken);

    // Calcular fecha de expiración del token
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
  }

  static Map<String, String> toAuthHeaders(LoginData data) {
    return {
      'Authorization': '${data.tokenType} ${data.accessToken}',
    };
  }
}

