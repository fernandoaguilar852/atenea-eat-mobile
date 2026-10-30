import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';

abstract class AuthRemoteDatasource {
  Future<LoginResponseDto> login(String email, String password);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;
  final Uuid uuid = const Uuid();

  AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<LoginResponseDto> login(String email, String password) async {
    try {
      final requestDto = LoginRequestDto(email: email, password: password);
      final messageUuid = uuid.v4();

      final response = await dio.post(
        ApiConstants.buildUrl(ApiConstants.login),
        data: requestDto.toJson(),
        options: Options(
          headers: {
            ApiConstants.headerContentType: 'application/json',
            ApiConstants.headerMessageUuid: messageUuid,
            ApiConstants.headerRequestAppId: ApiConstants.defaultAppId,
          },
        ),
      );

      if (response.statusCode == 200) {
        return LoginResponseDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data['messageResponse'] != null) {
          final messageResponse = data['messageResponse'];
          throw Exception(
            messageResponse['responseDetails'] ??
            messageResponse['responseMessage'] ??
            'Error en el login'
          );
        }
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      final messageUuid = uuid.v4();

      await dio.post(
        ApiConstants.buildUrl(ApiConstants.logout),
        data: {
          'refreshToken': refreshToken,
        },
        options: Options(
          headers: {
            ApiConstants.headerContentType: 'application/json',
            ApiConstants.headerMessageUuid: messageUuid,
            ApiConstants.headerRequestAppId: ApiConstants.defaultAppId,
          },
        ),
      );
    } catch (e) {
      // Ignorar errores de logout - siempre limpiamos local
      // incluso si el servidor falla
    }
  }
}
