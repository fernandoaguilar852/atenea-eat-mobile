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
  });

  Future<InsumoDto> getInsumoDetail({
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
  }) async {
    try {
      print('📦 Obteniendo insumos - clienteId: $clienteId, page: $pageNumber');

      final queryParams = <String, dynamic>{
        'clienteId': clienteId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      };

      if (activo != null) {
        queryParams['activo'] = activo;
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
      print('❌ Error en getInsumos: $e');
      rethrow;
    }
  }

  @override
  Future<InsumoDto> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  }) async {
    try {
      print('📦 Obteniendo detalle de insumo - insumoId: $insumoId, clienteId: $clienteId');

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
      print('❌ Error en getInsumoDetail: $e');
      rethrow;
    }
  }
}
