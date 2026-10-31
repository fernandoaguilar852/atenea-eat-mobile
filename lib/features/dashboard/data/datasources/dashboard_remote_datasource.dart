import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/estadisticas_response_dto.dart';

abstract class DashboardRemoteDatasource {
  Future<EstadisticasResponseDto> getEstadisticas({
    required int clienteId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final Dio dio;
  final Uuid uuid = const Uuid();

  DashboardRemoteDatasourceImpl({required this.dio});

  @override
  Future<EstadisticasResponseDto> getEstadisticas({
    required int clienteId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final messageUuid = uuid.v4();
      final dateFormat = DateFormat('yyyy-MM-dd');

      final response = await dio.get(
        ApiConstants.buildUrl(ApiConstants.consultaEstadisticas),
        queryParameters: {
          'clienteId': clienteId,
          'startDate': dateFormat.format(startDate),
          'endDate': dateFormat.format(endDate),
        },
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
        return EstadisticasResponseDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Error al obtener estadísticas: ${response.statusCode}',
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
                'Error al obtener estadísticas',
          );
        }
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
