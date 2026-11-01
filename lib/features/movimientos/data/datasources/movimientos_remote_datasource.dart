import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/movimientos_response_dto.dart';

abstract class MovimientosRemoteDatasource {
  Future<MovimientosResponseDto> getMovimientos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  });
}

class MovimientosRemoteDatasourceImpl implements MovimientosRemoteDatasource {
  final Dio dio;

  MovimientosRemoteDatasourceImpl({required this.dio});

  @override
  Future<MovimientosResponseDto> getMovimientos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (fechaDesde != null) {
      queryParameters['fechaDesde'] = fechaDesde;
    }
    if (fechaHasta != null) {
      queryParameters['fechaHasta'] = fechaHasta;
    }
    if (productoId != null) {
      queryParameters['productoId'] = productoId;
    }
    if (insumoId != null) {
      queryParameters['insumoId'] = insumoId;
    }

    // Debug log
    print('🔍 Movimientos Query Parameters: $queryParameters');

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.movimientosInventario),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return MovimientosResponseDto.fromJson(response.data);
    } else {
      throw Exception('Error al obtener movimientos - Status: ${response.statusCode}');
    }
  }
}
