import '../entities/movimiento_detalle.dart';
import '../repositories/movimientos_repository.dart';

class GetMovimientoDetalleUseCase {
  final MovimientosRepository repository;

  GetMovimientoDetalleUseCase(this.repository);

  Future<MovimientoDetalle> call({
    required int movimientoId,
    required int clienteId,
  }) async {
    return await repository.getMovimientoDetalle(
      movimientoId: movimientoId,
      clienteId: clienteId,
    );
  }
}
