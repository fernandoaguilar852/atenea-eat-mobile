import '../entities/insumos_response.dart';
import '../repositories/insumos_repository.dart';

class GetInsumosUseCase {
  final InsumosRepository repository;

  GetInsumosUseCase(this.repository);

  Future<InsumosResponse> call({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    bool? activo,
    String? nombre,
  }) {
    return repository.getInsumos(
      clienteId: clienteId,
      pageSize: pageSize,
      pageNumber: pageNumber,
      activo: activo,
      nombre: nombre,
    );
  }
}
