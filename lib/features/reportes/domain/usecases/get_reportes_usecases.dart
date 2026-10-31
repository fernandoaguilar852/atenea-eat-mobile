import '../entities/ventas_reporte.dart';
import '../entities/inventario_reporte.dart';
import '../entities/arqueo_reporte.dart';
import '../entities/stock_productos_reporte.dart';
import '../entities/stock_insumos_reporte.dart';
import '../entities/costo_beneficio_reporte.dart';
import '../repositories/reportes_repository.dart';

/// Use case para obtener reporte de ventas
class GetReporteVentasUseCase {
  final ReportesRepository repository;

  GetReporteVentasUseCase(this.repository);

  Future<VentasReporte> call({
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
  }) {
    return repository.getReporteVentas(
      clienteId: clienteId,
      startDate: startDate,
      endDate: endDate,
      productoId: productoId,
      consumidorId: consumidorId,
      categoriaId: categoriaId,
      cajaId: cajaId,
      operadorId: operadorId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}

/// Use case para obtener reporte de inventario consumido
class GetReporteInventarioConsumidoUseCase {
  final ReportesRepository repository;

  GetReporteInventarioConsumidoUseCase(this.repository);

  Future<InventarioReporte> call({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    required int pageSize,
    required int pageNumber,
  }) {
    return repository.getReporteInventarioConsumido(
      clienteId: clienteId,
      startDate: startDate,
      endDate: endDate,
      tipoMovimiento: tipoMovimiento,
      productoId: productoId,
      insumoId: insumoId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}

/// Use case para obtener reporte de arqueo de caja
class GetReporteArqueoCajaUseCase {
  final ReportesRepository repository;

  GetReporteArqueoCajaUseCase(this.repository);

  Future<ArqueoReporte> call({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
  }) {
    return repository.getReporteArqueoCaja(
      clienteId: clienteId,
      startDate: startDate,
      endDate: endDate,
      tipoPago: tipoPago,
      cajaId: cajaId,
    );
  }
}

/// Use case para obtener reporte de stock de productos
class GetReporteStockProductosUseCase {
  final ReportesRepository repository;

  GetReporteStockProductosUseCase(this.repository);

  Future<StockProductosReporte> call({
    required int clienteId,
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) {
    return repository.getReporteStockProductos(
      clienteId: clienteId,
      nombreProducto: nombreProducto,
      tipoProductoId: tipoProductoId,
      activo: activo,
      stockBajo: stockBajo,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}

/// Use case para obtener reporte de stock de insumos
class GetReporteStockInsumosUseCase {
  final ReportesRepository repository;

  GetReporteStockInsumosUseCase(this.repository);

  Future<StockInsumosReporte> call({
    required int clienteId,
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) {
    return repository.getReporteStockInsumos(
      clienteId: clienteId,
      nombreInsumo: nombreInsumo,
      activo: activo,
      stockBajo: stockBajo,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}

/// Use case para obtener reporte de costo-beneficio
class GetReporteCostoBeneficioUseCase {
  final ReportesRepository repository;

  GetReporteCostoBeneficioUseCase(this.repository);

  Future<CostoBeneficioReporte> call({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    required int pageSize,
    required int pageNumber,
  }) {
    return repository.getReporteCostoBeneficio(
      clienteId: clienteId,
      startDate: startDate,
      endDate: endDate,
      productoId: productoId,
      tipoProductoId: tipoProductoId,
      activo: activo,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }
}
