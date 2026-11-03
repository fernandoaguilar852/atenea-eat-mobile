import '../repositories/insumos_repository.dart';

class DeleteInsumoUseCase {
  final InsumosRepository repository;

  const DeleteInsumoUseCase({required this.repository});

  Future<void> call({
    required int insumoId,
    required int clienteId,
  }) async {
    return await repository.deleteInsumo(
      insumoId: insumoId,
      clienteId: clienteId,
    );
  }
}
