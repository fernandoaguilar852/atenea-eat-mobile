import '../entities/resoluciones_response.dart';
import '../repositories/resoluciones_repository.dart';

class GetResolucionesUseCase {
  final ResolucionesRepository repository;

  const GetResolucionesUseCase(this.repository);

  Future<ResolucionesResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  }) async {
    return await repository.getResoluciones(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      activo: activo,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
