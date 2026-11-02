import '../entities/operador.dart';

abstract class OperadoresRepository {
  Future<List<Operador>> searchOperadores({
    required int clienteId,
    required String search,
    int pageSize = 100,
    int pageNumber = 1,
  });
}
