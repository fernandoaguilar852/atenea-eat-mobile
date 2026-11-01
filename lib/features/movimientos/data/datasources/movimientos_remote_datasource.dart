import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/movimientos_response_dto.dart';
import '../models/registrar_movimiento_request_dto.dart';
import '../models/actualizar_movimiento_request_dto.dart';
import '../models/eliminar_movimiento_request_dto.dart';
import '../models/movimiento_dto.dart';
import '../models/movimiento_detalle_dto.dart';

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

  Future<MovimientoDto> registrarMovimiento({
    required RegistrarMovimientoRequestDto request,
  });

  Future<MovimientoDetalleDto> getMovimientoDetalle({
    required int movimientoId,
    required int clienteId,
  });

  Future<MovimientoDetalleDto> actualizarMovimiento({
    required int movimientoId,
    required int clienteId,
    required ActualizarMovimientoRequestDto request,
  });

  Future<void> eliminarMovimiento({
    required int movimientoId,
    required int clienteId,
    required EliminarMovimientoRequestDto request,
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

  @override
  Future<MovimientoDto> registrarMovimiento({
    required RegistrarMovimientoRequestDto request,
  }) async {
    print('📝 Registrando movimiento: ${request.toJson()}');

    final response = await dio.post(
      ApiConstants.buildUrl(ApiConstants.movimientosInventario),
      data: request.toJson(),
    );

    if (response.statusCode == 201) {
      return MovimientoDto.fromJson(response.data['data']);
    } else {
      throw Exception('Error al registrar movimiento - Status: ${response.statusCode}');
    }
  }

  @override
  Future<MovimientoDetalleDto> getMovimientoDetalle({
    required int movimientoId,
    required int clienteId,
  }) async {
    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.movimientosInventario}/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200) {
      return MovimientoDetalleDto.fromJson(response.data['data']);
    } else {
      throw Exception('Error al obtener detalle del movimiento - Status: ${response.statusCode}');
    }
  }

  @override
  Future<MovimientoDetalleDto> actualizarMovimiento({
    required int movimientoId,
    required int clienteId,
    required ActualizarMovimientoRequestDto request,
  }) async {
    print('📝 Actualizando movimiento $movimientoId: ${request.toJson()}');

    final response = await dio.patch(
      ApiConstants.buildUrl('${ApiConstants.movimientosInventario}/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      return MovimientoDetalleDto.fromJson(response.data['data']);
    } else {
      throw Exception('Error al actualizar movimiento - Status: ${response.statusCode}');
    }
  }

  @override
  Future<void> eliminarMovimiento({
    required int movimientoId,
    required int clienteId,
    required EliminarMovimientoRequestDto request,
  }) async {
    print('🗑️ Eliminando movimiento $movimientoId: ${request.toJson()}');

    final response = await dio.delete(
      ApiConstants.buildUrl('${ApiConstants.movimientosInventario}/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
      data: request.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar movimiento - Status: ${response.statusCode}');
    }
  }
}
