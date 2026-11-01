import '../entities/categorias_response.dart';
import '../repositories/categorias_repository.dart';

class GetCategoriasUseCase {
  final CategoriasRepository repository;

  GetCategoriasUseCase(this.repository);

  Future<CategoriasResponse> call({
    required int clienteId,
  }) async {
    return await repository.getCategorias(clienteId: clienteId);
  }
}
