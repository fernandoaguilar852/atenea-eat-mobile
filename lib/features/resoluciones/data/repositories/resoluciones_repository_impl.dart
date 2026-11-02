import '../../domain/entities/resoluciones_response.dart';
import '../../domain/repositories/resoluciones_repository.dart';
import '../datasources/resoluciones_remote_datasource.dart';

class ResolucionesRepositoryImpl implements ResolucionesRepository {
  final ResolucionesRemoteDatasource remoteDatasource;

  const ResolucionesRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ResolucionesResponse> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  }) async {
    final dto = await remoteDatasource.getResoluciones(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      activo: activo,
      startDate: startDate,
      endDate: endDate,
    );
    return dto.toEntity();
  }

  @override
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
  }) async {
    await remoteDatasource.crearResolucion(
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
