import '../entities/productos_response.dart';
import '../entities/producto.dart';

abstract class ProductosRepository {
  Future<ProductosResponse> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? search,
    int? tipoProductoId,
    bool? activo,
    bool? usaReceta,
  });

  Future<Producto> getProductoDetail({
    required int clienteId,
    required int productoId,
  });

  Future<Producto> createProducto({
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

  Future<Producto> updateProducto({
    required int productoId,
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
    required bool activo,
    String? imagenBase64,
    String? imagenTipo,
  });

  Future<void> deleteProducto({
    required int productoId,
    required int clienteId,
  });
}
