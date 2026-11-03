import '../entities/resoluciones_response.dart';

abstract class ResolucionesRepository {
  Future<ResolucionesResponse> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  });

  Future<void> crearResolucion({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required String fechaResolucion,
    required String fechaVencimiento,
    required bool activo,
  });

  Future<void> updateResolucion({
    required int resolucionId,
    required int clienteId,
    required String prefijo,
    required int numeroHasta,
    required int numeroActual,
    required String fechaVencimiento,
    required bool activo,
  });

  Future<void> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  });
}
