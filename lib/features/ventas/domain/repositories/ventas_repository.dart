import '../entities/ventas_response.dart';
import '../entities/venta_detallada.dart';

abstract class VentasRepository {
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageSize,
    required int pageNumber,
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  });

  Future<VentaDetallada> getVentaDetalle({
    required int ventaId,
    required int clienteId,
  });
}
