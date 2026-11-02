import '../entities/caja.dart';
import '../repositories/cajas_repository.dart';

class GetCajasUseCase {
  final CajasRepository repository;

  GetCajasUseCase(this.repository);

  Future<List<Caja>> call({
    required int clienteId,
  }) {
    return repository.getCajas(
      clienteId: clienteId,
    );
  }
}
