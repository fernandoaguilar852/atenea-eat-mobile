import 'package:dio/dio.dart';
import '../models/productos_response_dto.dart';
import '../models/producto_dto.dart';
import '../../../../core/constants/api_constants.dart';

abstract class ProductosRemoteDatasource {
  Future<ProductosResponseDto> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? search,
    int? tipoProductoId,
    bool? activo,
    bool? usaReceta,
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
    String? search,
    int? tipoProductoId,
    bool? activo,
    bool? usaReceta,
  }) async {
    final queryParameters = <String, dynamic>{
      'clienteId': clienteId,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    if (tipoProductoId != null) {
      queryParameters['tipoProductoId'] = tipoProductoId;
    }

    if (activo != null) {
      queryParameters['activo'] = activo;
    }

    if (usaReceta != null) {
      queryParameters['usaReceta'] = usaReceta;
    }

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

    final response = await dio.get(
      ApiConstants.buildUrl('${ApiConstants.products}/$productoId'),
      queryParameters: queryParameters,
    );

    return ProductoDto.fromJson(response.data['data']);
  }
}
