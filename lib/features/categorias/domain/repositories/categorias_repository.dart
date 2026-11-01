import '../entities/categorias_response.dart';

abstract class CategoriasRepository {
  Future<CategoriasResponse> getCategorias({
    required int clienteId,
  });
}
