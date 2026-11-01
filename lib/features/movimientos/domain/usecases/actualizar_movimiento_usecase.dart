import '../entities/movimiento_detalle.dart';
import '../repositories/movimientos_repository.dart';

class ActualizarMovimientoUseCase {
  final MovimientosRepository repository;

  ActualizarMovimientoUseCase(this.repository);

  Future<MovimientoDetalle> call({
    required int movimientoId,
    required int clienteId,
    required double cantidad,
    required String observacion,
    required int updatedByUsuarioId,
  }) {
    return repository.actualizarMovimiento(
      movimientoId: movimientoId,
      clienteId: clienteId,
      cantidad: cantidad,
      observacion: observacion,
      updatedByUsuarioId: updatedByUsuarioId,
    );
  }
}
