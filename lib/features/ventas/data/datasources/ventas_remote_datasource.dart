import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ventas_response_dto.dart';
import '../models/venta_detallada_dto.dart';

abstract class VentasRemoteDatasource {
  Future<VentasResponseDto> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  });

  Future<VentaDetalladaDto> getVentaDetalle({
    required int ventaId,
    required int clienteId,
  });

  Future<String> getMetodoPago({
    required int pagoId,
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
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (startDate != null && startDate.isNotEmpty) {
      queryParameters['startDate'] = startDate;
    }

    if (endDate != null && endDate.isNotEmpty) {
      queryParameters['endDate'] = endDate;
    }

    if (estado != null && estado.isNotEmpty) {
      queryParameters['estado'] = estado;
    }

    if (cajaId != null) {
      queryParameters['cajaId'] = cajaId;
    }

    if (operadorId != null) {
      queryParameters['operadorId'] = operadorId;
    }

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

  @override
  Future<VentaDetalladaDto> getVentaDetalle({
    required int ventaId,
    required int clienteId,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
    };

    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.ventas}/$ventaId'),
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return VentaDetalladaDto.fromJson(response.data['data']);
    } else {
      throw Exception('Error al obtener detalle de venta - Status: ${response.statusCode}');
    }
  }

  @override
  Future<String> getMetodoPago({
    required int pagoId,
  }) async {
    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.pagos}/$pagoId'),
    );

    if (response.statusCode == 200) {
      return response.data['data']['metodo'] as String;
    } else {
      throw Exception('Error al obtener método de pago - Status: ${response.statusCode}');
    }
  }
}
