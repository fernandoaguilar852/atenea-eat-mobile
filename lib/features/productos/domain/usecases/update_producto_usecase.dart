import '../entities/producto.dart';
import '../repositories/productos_repository.dart';

class UpdateProductoUseCase {
  final ProductosRepository repository;

  const UpdateProductoUseCase({required this.repository});

  Future<Producto> call({
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
    String? imagenBase64,
    String? imagenTipo,
  }) async {
    return await repository.updateProducto(
      productoId: productoId,
      clienteId: clienteId,
      tipoProductoId: tipoProductoId,
      nombre: nombre,
      codExterno: codExterno,
      codBarras: codBarras,
      precio: precio,
      unidadMedida: unidadMedida,
      stockTotal: stockTotal,
      stockMinimo: stockMinimo,
      manejaStock: manejaStock,
      usaReceta: usaReceta,
      imagenBase64: imagenBase64,
      imagenTipo: imagenTipo,
    );
  }
}
