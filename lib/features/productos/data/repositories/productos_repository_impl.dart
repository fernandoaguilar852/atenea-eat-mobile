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
  }) async {
    final dto = await remoteDatasource.getProductos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
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
}
