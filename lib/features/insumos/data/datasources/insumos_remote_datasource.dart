import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/insumos_response_dto.dart';
import '../models/insumo_dto.dart';

abstract class InsumosRemoteDatasource {
  Future<InsumosResponseDto> getInsumos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? nombre,
  });

  Future<InsumoDto> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  });

  Future<void> updateInsumo({
    required int insumoId,
    required int clienteId,
    required String nombre,
    required String unidadBase,
    required double stockMinimo,
    required bool activo,
  });

  Future<void> deleteInsumo({
    required int insumoId,
    required int clienteId,
  });
}

class InsumosRemoteDatasourceImpl implements InsumosRemoteDatasource {
  final Dio dio;

  InsumosRemoteDatasourceImpl({required this.dio});

  @override
  Future<InsumosResponseDto> getInsumos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? nombre,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'clienteId': clienteId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      };

      if (activo != null) {
        queryParams['activo'] = activo;
      }

      if (nombre != null && nombre.isNotEmpty) {
        queryParams['nombre'] = nombre;
      }

      final response = await dio.get(
        ApiConstants.buildUrl(ApiConstants.insumos),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return InsumosResponseDto.fromJson(response.data);
      } else {
        throw Exception('Error al obtener insumos - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InsumoDto> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.buildUrl('${ApiConstants.insumos}/$insumoId'),
        queryParameters: {
          'clienteId': clienteId,
        },
      );

      if (response.statusCode == 200) {
        return InsumoDto.fromJson(response.data['data']);
      } else {
        throw Exception('Error al obtener detalle del insumo - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateInsumo({
    required int insumoId,
    required int clienteId,
    required String nombre,
    required String unidadBase,
    required double stockMinimo,
    required bool activo,
  }) async {
    try {
      final body = {
        'nombre': nombre,
        'unidadBase': unidadBase,
        'stockMinimo': stockMinimo,
        'activo': activo,
      };

      final response = await dio.patch(
        ApiConstants.buildUrl('${ApiConstants.insumos}/$insumoId?clienteId=$clienteId'),
        data: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar insumo - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteInsumo({
    required int insumoId,
    required int clienteId,
  }) async {
    try {
      final response = await dio.delete(
        ApiConstants.buildUrl('${ApiConstants.insumos}/$insumoId?clienteId=$clienteId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar insumo - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
