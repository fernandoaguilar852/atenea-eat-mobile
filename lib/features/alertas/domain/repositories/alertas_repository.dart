import '../entities/alertas_response.dart';

abstract class AlertasRepository {
  Future<AlertasResponse> getAlertas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}
