import '../entities/ventas_reporte.dart';
import '../entities/inventario_reporte.dart';
import '../entities/arqueo_reporte.dart';
import '../entities/stock_productos_reporte.dart';
import '../entities/stock_insumos_reporte.dart';
import '../entities/costo_beneficio_reporte.dart';

abstract class ReportesRepository {
  Future<VentasReporte> getReporteVentas({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    int? operadorId,
    required int pageSize,
    required int pageNumber,
  });

  Future<InventarioReporte> getReporteInventarioConsumido({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    required int pageSize,
    required int pageNumber,
  });

  Future<ArqueoReporte> getReporteArqueoCaja({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
  });

  Future<StockProductosReporte> getReporteStockProductos({
    required int clienteId,
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  });

  Future<StockInsumosReporte> getReporteStockInsumos({
    required int clienteId,
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  });

  Future<CostoBeneficioReporte> getReporteCostoBeneficio({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    required int pageSize,
    required int pageNumber,
  });
}
