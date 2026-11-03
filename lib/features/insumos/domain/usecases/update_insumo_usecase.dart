import '../repositories/insumos_repository.dart';

class UpdateInsumoUseCase {
  final InsumosRepository repository;

  const UpdateInsumoUseCase({required this.repository});

  Future<void> call({
    required int insumoId,
    required int clienteId,
    required String nombre,
    required String unidadBase,
    required double stockActual,
    required double stockMinimo,
    required double costoPromedio,
    required bool activo,
  }) async {
    return await repository.updateInsumo(
      insumoId: insumoId,
      clienteId: clienteId,
      nombre: nombre,
      unidadBase: unidadBase,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      costoPromedio: costoPromedio,
      activo: activo,
    );
  }
}
