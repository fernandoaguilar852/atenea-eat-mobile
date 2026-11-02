import '../entities/alertas_response.dart';
import '../repositories/alertas_repository.dart';

class GetAlertasUseCase {
  final AlertasRepository repository;

  const GetAlertasUseCase(this.repository);

  Future<AlertasResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    return await repository.getAlertas(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
