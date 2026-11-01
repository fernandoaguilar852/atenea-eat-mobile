import '../entities/movimientos_response.dart';

abstract class MovimientosRepository {
  Future<MovimientosResponse> getMovimientos({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? fechaDesde,
    String? fechaHasta,
    int? productoId,
    int? insumoId,
  });
}
