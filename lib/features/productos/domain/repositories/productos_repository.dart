import '../entities/productos_response.dart';
import '../entities/producto.dart';

abstract class ProductosRepository {
  Future<ProductosResponse> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });

  Future<Producto> getProductoDetail({
    required int clienteId,
    required int productoId,
  });
}
