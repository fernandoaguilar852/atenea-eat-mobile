import '../entities/resoluciones_response.dart';
import '../repositories/resoluciones_repository.dart';

class GetResolucionesUseCase {
  final ResolucionesRepository repository;

  const GetResolucionesUseCase(this.repository);

  Future<ResolucionesResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    return await repository.getResoluciones(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
