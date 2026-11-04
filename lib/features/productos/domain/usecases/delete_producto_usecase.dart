import '../repositories/productos_repository.dart';

class DeleteProductoUseCase {
  final ProductosRepository repository;

  const DeleteProductoUseCase({required this.repository});

  Future<void> call({
    required int productoId,
    required int clienteId,
  }) async {
    return await repository.deleteProducto(
      productoId: productoId,
      clienteId: clienteId,
    );
  }
}
