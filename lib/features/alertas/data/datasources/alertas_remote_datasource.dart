import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/alertas_response_dto.dart';

abstract class AlertasRemoteDatasource {
  Future<AlertasResponseDto> getAlertas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}

class AlertasRemoteDatasourceImpl implements AlertasRemoteDatasource {
  final Dio dio;

  const AlertasRemoteDatasourceImpl({required this.dio});

  @override
  Future<AlertasResponseDto> getAlertas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.alertasStock),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return AlertasResponseDto.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Error al obtener alertas - Status: ${response.statusCode}');
    }
  }
}
