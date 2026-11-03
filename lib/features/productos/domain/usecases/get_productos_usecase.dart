import '../repositories/productos_repository.dart';
import '../entities/productos_response.dart';

class GetProductosUseCase {
  final ProductosRepository repository;

  GetProductosUseCase(this.repository);

  Future<ProductosResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? search,
    int? tipoProductoId,
    bool? activo,
    bool? usaReceta,
  }) {
    return repository.getProductos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      search: search,
      tipoProductoId: tipoProductoId,
      activo: activo,
      usaReceta: usaReceta,
    );
  }
}
