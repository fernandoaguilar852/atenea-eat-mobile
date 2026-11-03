import '../entities/insumo.dart';
import '../repositories/insumos_repository.dart';

class CreateInsumoUseCase {
  final InsumosRepository repository;

  const CreateInsumoUseCase({required this.repository});

  Future<Insumo> call({
    required int clienteId,
    required String nombre,
    required String unidadBase,
    required double stockActual,
    required double stockMinimo,
    required double costoPromedio,
    required bool activo,
  }) async {
    return await repository.createInsumo(
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
