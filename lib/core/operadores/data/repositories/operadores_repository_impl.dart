import '../../domain/entities/operador.dart';
import '../../domain/repositories/operadores_repository.dart';
import '../datasources/operadores_remote_datasource.dart';

class OperadoresRepositoryImpl implements OperadoresRepository {
  final OperadoresRemoteDatasource remoteDatasource;

  OperadoresRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Operador>> searchOperadores({
    required int clienteId,
    required String search,
    int pageSize = 100,
    int pageNumber = 1,
  }) async {
    try {
      final dtos = await remoteDatasource.searchOperadores(
        clienteId: clienteId,
        search: search,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
