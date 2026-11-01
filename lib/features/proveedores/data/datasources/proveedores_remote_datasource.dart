import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/proveedores_response_dto.dart';

abstract class ProveedoresRemoteDatasource {
  Future<ProveedoresResponseDto> getProveedores({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  });
}

class ProveedoresRemoteDatasourceImpl implements ProveedoresRemoteDatasource {
  final Dio dio;

  ProveedoresRemoteDatasourceImpl({required this.dio});

  @override
  Future<ProveedoresResponseDto> getProveedores({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'clienteId': clienteId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstants.buildUrl(ApiConstants.proveedores),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return ProveedoresResponseDto.fromJson(response.data);
      } else {
        throw Exception('Error al obtener proveedores - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
