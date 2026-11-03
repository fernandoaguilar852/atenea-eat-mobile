import '../repositories/resoluciones_repository.dart';

class UpdateResolucionUseCase {
  final ResolucionesRepository repository;

  const UpdateResolucionUseCase({required this.repository});

  Future<void> call({
    required int resolucionId,
    required int clienteId,
    required String prefijo,
    required int numeroHasta,
    required int numeroActual,
    required String fechaVencimiento,
    required bool activo,
  }) async {
    return await repository.updateResolucion(
      resolucionId: resolucionId,
      clienteId: clienteId,
      prefijo: prefijo,
      numeroHasta: numeroHasta,
      numeroActual: numeroActual,
      fechaVencimiento: fechaVencimiento,
      activo: activo,
    );
  }
}
