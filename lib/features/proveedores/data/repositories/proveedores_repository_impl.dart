import '../../domain/entities/proveedores_response.dart';
import '../../domain/repositories/proveedores_repository.dart';
import '../datasources/proveedores_remote_datasource.dart';

class ProveedoresRepositoryImpl implements ProveedoresRepository {
  final ProveedoresRemoteDatasource remoteDatasource;

  ProveedoresRepositoryImpl({required this.remoteDatasource});

  @override
  Future<ProveedoresResponse> getProveedores({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  }) async {
    try {
      final dto = await remoteDatasource.getProveedores(
        clienteId: clienteId,
        pageNumber: pageNumber,
        pageSize: pageSize,
        search: search,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
