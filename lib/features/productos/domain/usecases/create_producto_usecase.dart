import '../entities/producto.dart';
import '../repositories/productos_repository.dart';

class CreateProductoUseCase {
  final ProductosRepository repository;

  const CreateProductoUseCase({required this.repository});

  Future<Producto> call({
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
    return await repository.createProducto(
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
      ivaId: ivaId,
      imagenBase64: imagenBase64,
      imagenTipo: imagenTipo,
    );
  }
}
