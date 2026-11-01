import '../entities/ventas_response.dart';
import '../entities/venta_detallada.dart';

abstract class VentasRepository {
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
  });

  Future<VentaDetallada> getVentaDetalle({
    required int ventaId,
    required int clienteId,
  });
}
