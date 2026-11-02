import '../repositories/resoluciones_repository.dart';

class CreateResolucionUseCase {
  final ResolucionesRepository repository;

  const CreateResolucionUseCase(this.repository);

  Future<void> call({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required String fechaResolucion,
    required String fechaVencimiento,
    required bool activo,
  }) async {
    return await repository.crearResolucion(
      clienteId: clienteId,
      prefijo: prefijo,
      numeroDesde: numeroDesde,
      numeroHasta: numeroHasta,
      numeroActual: numeroActual,
      numeroResolucion: numeroResolucion,
      fechaResolucion: fechaResolucion,
      fechaVencimiento: fechaVencimiento,
      activo: activo,
    );
  }
}
