import '../entities/insumos_response.dart';
import '../entities/insumo.dart';

abstract class InsumosRepository {
  Future<InsumosResponse> getInsumos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
  });

  Future<Insumo> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  });
}
