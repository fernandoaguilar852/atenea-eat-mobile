import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ventas_response_dto.dart';

abstract class VentasRemoteDatasource {
  Future<VentasResponseDto> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}

class VentasRemoteDatasourceImpl implements VentasRemoteDatasource {
  final Dio dio;

  VentasRemoteDatasourceImpl({required this.dio});

  @override
  Future<VentasResponseDto> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    print('🔍 Ventas Query Parameters: $queryParameters');

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.ventas),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return VentasResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener ventas - Status: ${response.statusCode}');
    }
  }
}
