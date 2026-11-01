import '../repositories/movimientos_repository.dart';

class EliminarMovimientoUseCase {
  final MovimientosRepository repository;

  EliminarMovimientoUseCase(this.repository);

  Future<void> call({
    required int movimientoId,
    required int clienteId,
    required int deletedByUsuarioId,
    required String deleteReason,
  }) {
    return repository.eliminarMovimiento(
      movimientoId: movimientoId,
      clienteId: clienteId,
      deletedByUsuarioId: deletedByUsuarioId,
      deleteReason: deleteReason,
    );
  }
}
