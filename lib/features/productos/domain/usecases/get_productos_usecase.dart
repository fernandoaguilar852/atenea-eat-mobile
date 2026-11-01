import '../repositories/productos_repository.dart';
import '../entities/productos_response.dart';

class GetProductosUseCase {
  final ProductosRepository repository;

  GetProductosUseCase(this.repository);

  Future<ProductosResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) {
    return repository.getProductos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
