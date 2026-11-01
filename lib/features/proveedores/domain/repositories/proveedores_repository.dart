import '../entities/proveedores_response.dart';

abstract class ProveedoresRepository {
  Future<ProveedoresResponse> getProveedores({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? search,
  });
}
