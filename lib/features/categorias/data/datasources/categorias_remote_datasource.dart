import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/categorias_response_dto.dart';

abstract class CategoriasRemoteDatasource {
  Future<CategoriasResponseDto> getCategorias({
    required int clienteId,
  });
}

class CategoriasRemoteDatasourceImpl implements CategoriasRemoteDatasource {
  final Dio dio;

  CategoriasRemoteDatasourceImpl({required this.dio});

  @override
  Future<CategoriasResponseDto> getCategorias({
    required int clienteId,
  }) async {
    final queryParameters = {
      'clienteId': clienteId,
      'pageNumber': 1,
      'pageSize': 100,
      'activo': true,
    };

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.tiposProducto),
      queryParameters: queryParameters,
    );

    return CategoriasResponseDto.fromJson(response.data);
  }
}
