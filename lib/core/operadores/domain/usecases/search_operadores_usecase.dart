import '../entities/operador.dart';
import '../repositories/operadores_repository.dart';

class SearchOperadoresUseCase {
  final OperadoresRepository repository;

  SearchOperadoresUseCase(this.repository);

  Future<List<Operador>> call({
    required int clienteId,
    required String search,
    int pageSize = 100,
    int pageNumber = 1,
  }) {
    return repository.searchOperadores(
      clienteId: clienteId,
      search: search,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
