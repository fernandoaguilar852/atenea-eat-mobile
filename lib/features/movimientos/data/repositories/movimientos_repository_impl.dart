import '../../domain/entities/movimientos_response.dart';
import '../../domain/repositories/movimientos_repository.dart';
import '../datasources/movimientos_remote_datasource.dart';

class MovimientosRepositoryImpl implements MovimientosRepository {
  final MovimientosRemoteDatasource remoteDatasource;

  MovimientosRepositoryImpl({required this.remoteDatasource});

  @override
  Future<MovimientosResponse> getMovimientos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  }) async {
    try {
      final dto = await remoteDatasource.getMovimientos(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        productoId: productoId,
        insumoId: insumoId,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
