import '../../domain/repositories/productos_repository.dart';
import '../../domain/entities/productos_response.dart';
import '../../domain/entities/producto.dart';
import '../datasources/productos_remote_datasource.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final ProductosRemoteDatasource remoteDatasource;

  ProductosRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ProductosResponse> getProductos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? search,
    int? tipoProductoId,
    bool? activo,
    bool? usaReceta,
  }) async {
    final dto = await remoteDatasource.getProductos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      search: search,
      tipoProductoId: tipoProductoId,
      activo: activo,
      usaReceta: usaReceta,
    );
    return dto.toEntity();
  }

  @override
  Future<Producto> getProductoDetail({
    required int clienteId,
    required int productoId,
  }) async {
    final dto = await remoteDatasource.getProductoDetail(
      clienteId: clienteId,
      productoId: productoId,
    );
    return dto.toEntity();
  }

  @override
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
  }) async {
    final dto = await remoteDatasource.createProducto(
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
    return dto.toEntity();
  }

  @override
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
    String? imagenBase64,
    String? imagenTipo,
  }) async {
    final dto = await remoteDatasource.updateProducto(
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
    return dto.toEntity();
  }

  @override
  Future<void> deleteProducto({
    required int productoId,
    required int clienteId,
  }) async {
    await remoteDatasource.deleteProducto(
      productoId: productoId,
      clienteId: clienteId,
    );
  }
}
