import '../repositories/productos_repository.dart';
import '../entities/producto.dart';

class GetProductoDetailUseCase {
  final ProductosRepository repository;

  GetProductoDetailUseCase(this.repository);

  Future<Producto> call({
    required int clienteId,
    required int productoId,
  }) {
    return repository.getProductoDetail(
      clienteId: clienteId,
      productoId: productoId,
    );
  }
}
