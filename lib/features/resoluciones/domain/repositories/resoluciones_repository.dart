import '../entities/resoluciones_response.dart';

abstract class ResolucionesRepository {
  Future<ResolucionesResponse> getResoluciones({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}
