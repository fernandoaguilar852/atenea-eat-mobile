import '../../domain/entities/categorias_response.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../datasources/categorias_remote_datasource.dart';

class CategoriasRepositoryImpl implements CategoriasRepository {
  final CategoriasRemoteDatasource remoteDatasource;

  CategoriasRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CategoriasResponse> getCategorias({
    required int clienteId,
  }) async {
    try {
      final dto = await remoteDatasource.getCategorias(clienteId: clienteId);
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
