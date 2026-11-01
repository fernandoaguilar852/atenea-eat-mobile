import 'package:dio/dio.dart';
import '../models/productos_response_dto.dart';
import '../models/producto_dto.dart';
import '../../../../core/constants/api_constants.dart';

abstract class ProductosRemoteDatasource {
  Future<ProductosResponseDto> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });

  Future<ProductoDto> getProductoDetail({
    required int clienteId,
    required int productoId,
  });
}

class ProductosRemoteDatasourceImpl implements ProductosRemoteDatasource {
  final Dio dio;

  ProductosRemoteDatasourceImpl({required this.dio});

  @override
  Future<ProductosResponseDto> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final queryParameters = {
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    print('🔍 Productos Query Parameters: $queryParameters');

    final response = await dio.get(
      ApiConstants.buildUrl(ApiConstants.products),
      queryParameters: queryParameters,
    );

    return ProductosResponseDto.fromJson(response.data);
  }

  @override
  Future<ProductoDto> getProductoDetail({
    required int clienteId,
    required int productoId,
  }) async {
    final queryParameters = {
      'clienteId': clienteId,
    };

    print('🔍 Producto Detail Query Parameters: $queryParameters');

    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.products}/$productoId'),
      queryParameters: queryParameters,
    );

    return ProductoDto.fromJson(response.data['data']);
  }
}
