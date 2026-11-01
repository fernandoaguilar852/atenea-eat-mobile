import '../entities/insumo.dart';
import '../repositories/insumos_repository.dart';

class GetInsumoDetailUseCase {
  final InsumosRepository repository;

  GetInsumoDetailUseCase(this.repository);

  Future<Insumo> call({
    required int insumoId,
    required int clienteId,
  }) {
    return repository.getInsumoDetail(
      insumoId: insumoId,
      clienteId: clienteId,
    );
  }
}
