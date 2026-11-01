import '../entities/movimientos_response.dart';
import '../entities/movimiento.dart';
import '../entities/movimiento_detalle.dart';

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

  Future<Movimiento> registrarMovimiento({
    int? productoId,
    int? insumoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    required String tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required int cantidad,
    required String observacion,
    required String fecha,
  });

  Future<MovimientoDetalle> getMovimientoDetalle({
    required int movimientoId,
    required int clienteId,
  });
}
