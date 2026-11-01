import '../entities/movimientos_response.dart';
import '../repositories/movimientos_repository.dart';

class GetMovimientosUseCase {
  final MovimientosRepository repository;

  GetMovimientosUseCase(this.repository);

  Future<MovimientosResponse> call({
    required int clienteId,
    int pageSize = 20,
    int pageNumber = 1,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  }) {
    return repository.getMovimientos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      productoId: productoId,
      insumoId: insumoId,
    );
  }
}
