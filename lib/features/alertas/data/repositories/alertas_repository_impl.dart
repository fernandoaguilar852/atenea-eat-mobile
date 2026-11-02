import '../../domain/entities/alertas_response.dart';
import '../../domain/repositories/alertas_repository.dart';
import '../datasources/alertas_remote_datasource.dart';

class AlertasRepositoryImpl implements AlertasRepository {
  final AlertasRemoteDatasource remoteDatasource;

  const AlertasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<AlertasResponse> getAlertas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    final dto = await remoteDatasource.getAlertas(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    return dto.toEntity();
  }
}
