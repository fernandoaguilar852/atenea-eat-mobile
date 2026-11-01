import '../../domain/entities/ventas_response.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/ventas_remote_datasource.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasRemoteDatasource remoteDatasource;

  VentasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getVentas(
        clienteId: clienteId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
