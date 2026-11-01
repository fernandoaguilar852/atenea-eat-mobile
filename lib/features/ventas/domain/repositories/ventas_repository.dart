import '../entities/ventas_response.dart';

abstract class VentasRepository {
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });
}
