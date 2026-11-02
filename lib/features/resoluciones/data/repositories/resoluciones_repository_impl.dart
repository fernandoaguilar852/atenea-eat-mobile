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
  }) async {
    final dto = await remoteDatasource.getResoluciones(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    return dto.toEntity();
  }
}
