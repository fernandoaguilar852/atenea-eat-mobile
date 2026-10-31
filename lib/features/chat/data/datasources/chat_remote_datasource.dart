import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/chat_query_request_dto.dart';
import '../models/chat_query_response_dto.dart';

abstract class ChatRemoteDatasource {
  Future<ChatQueryResponseDto> sendMessage({required String message});
}

class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  final Dio dio;
  final Uuid uuid = const Uuid();

  ChatRemoteDatasourceImpl({required this.dio});

  @override
  Future<ChatQueryResponseDto> sendMessage({required String message}) async {
    try {
      final requestDto = ChatQueryRequestDto(message: message);
      final messageUuid = uuid.v4();

      final response = await dio.post(
        ApiConstants.buildUrl(ApiConstants.chatQuery),
        data: requestDto.toJson(),
        options: Options(
          headers: {
            ApiConstants.headerContentType: 'application/json',
            ApiConstants.headerMessageUuid: messageUuid,
            ApiConstants.headerRequestAppId: ApiConstants.defaultAppId,
            // El Authorization header se agrega automáticamente por el interceptor
          },
        ),
      );

      if (response.statusCode == 200) {
        return ChatQueryResponseDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al enviar mensaje: ${response.statusCode}',
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
                'Error al enviar mensaje',
          );
        }
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
