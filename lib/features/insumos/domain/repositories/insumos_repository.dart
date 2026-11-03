import '../entities/insumos_response.dart';
import '../entities/insumo.dart';

abstract class InsumosRepository {
  Future<InsumosResponse> getInsumos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? nombre,
  });

  Future<Insumo> getInsumoDetail({
    required int insumoId,
    required int clienteId,
  });

  Future<void> updateInsumo({
    required int insumoId,
    required int clienteId,
    required String nombre,
    required String unidadBase,
    required double stockMinimo,
    required bool activo,
  });

  Future<void> deleteInsumo({
    required int insumoId,
    required int clienteId,
  });
}
