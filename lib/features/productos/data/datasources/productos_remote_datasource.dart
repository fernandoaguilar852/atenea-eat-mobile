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

  Future<ProductoDto> createProducto({
    required int clienteId,
    required int tipoProductoId,
    required String nombre,
    required String codExterno,
    required String codBarras,
    required double precio,
    required String unidadMedida,
    required int stockTotal,
    required int stockMinimo,
    required bool manejaStock,
    required bool usaReceta,
    required int ivaId,
    String? imagenBase64,
    String? imagenTipo,
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

  @override
  Future<ProductoDto> createProducto({
    required int clienteId,
    required int tipoProductoId,
    required String nombre,
    required String codExterno,
    required String codBarras,
    required double precio,
    required String unidadMedida,
    required int stockTotal,
    required int stockMinimo,
    required bool manejaStock,
    required bool usaReceta,
    required int ivaId,
    String? imagenBase64,
    String? imagenTipo,
  }) async {
    try {
      final body = <String, dynamic>{
        'clienteId': clienteId,
        'tipoProductoId': tipoProductoId,
        'nombre': nombre,
        'codExterno': codExterno,
        'codBarras': codBarras,
        'precio': precio,
        'unidadMedida': unidadMedida,
        'stockTotal': stockTotal,
        'stockMinimo': stockMinimo,
        'manejaStock': manejaStock,
        'usaReceta': usaReceta,
        'ivaId': ivaId,
      };

      if (imagenBase64 != null && imagenBase64.isNotEmpty) {
        body['imagenBase64'] = imagenBase64;
      }

      if (imagenTipo != null && imagenTipo.isNotEmpty) {
        body['imagenTipo'] = imagenTipo;
      }

      final response = await dio.post(
        ApiConstants.buildUrl('${ApiConstants.products}?clienteId=$clienteId'),
        data: body,
      );

      if (response.statusCode == 201) {
        return ProductoDto.fromJson(response.data['data']);
      } else {
        throw Exception('Error al crear producto - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
