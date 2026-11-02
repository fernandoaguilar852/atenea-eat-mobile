import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/resoluciones_response_dto.dart';

abstract class ResolucionesRemoteDatasource {
  Future<ResolucionesResponseDto> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}

class ResolucionesRemoteDatasourceImpl implements ResolucionesRemoteDatasource {
  final Dio dio;

  const ResolucionesRemoteDatasourceImpl({required this.dio});

  @override
  Future<ResolucionesResponseDto> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = {
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.resoluciones),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return ResolucionesResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener resoluciones - Status: ${response.statusCode}');
    }
  }
}
