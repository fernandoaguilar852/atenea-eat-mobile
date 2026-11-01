import '../entities/proveedores_response.dart';
import '../repositories/proveedores_repository.dart';

class GetProveedoresUseCase {
  final ProveedoresRepository repository;

  GetProveedoresUseCase(this.repository);

  Future<ProveedoresResponse> call({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  }) {
    return repository.getProveedores(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
    );
  }
}
