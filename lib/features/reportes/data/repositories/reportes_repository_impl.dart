import '../../domain/entities/ventas_reporte.dart';
import '../../domain/entities/inventario_reporte.dart';
import '../../domain/entities/arqueo_reporte.dart';
import '../../domain/entities/stock_productos_reporte.dart';
import '../../domain/entities/stock_insumos_reporte.dart';
import '../../domain/entities/costo_beneficio_reporte.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../datasources/reportes_remote_datasource.dart';

class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesRemoteDatasource remoteDatasource;

  ReportesRepositoryImpl({required this.remoteDatasource});

  @override
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
  }) async {
    try {
      final dto = await remoteDatasource.getReporteVentas(
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
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InventarioReporte> getReporteInventarioConsumido({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getReporteInventarioConsumido(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        tipoMovimiento: tipoMovimiento,
        productoId: productoId,
        insumoId: insumoId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ArqueoReporte> getReporteArqueoCaja({
    required int clienteId,
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getReporteArqueoCaja(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        tipoPago: tipoPago,
        cajaId: cajaId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockProductosReporte> getReporteStockProductos({
    required int clienteId,
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getReporteStockProductos(
        clienteId: clienteId,
        nombreProducto: nombreProducto,
        tipoProductoId: tipoProductoId,
        activo: activo,
        stockBajo: stockBajo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockInsumosReporte> getReporteStockInsumos({
    required int clienteId,
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getReporteStockInsumos(
        clienteId: clienteId,
        nombreInsumo: nombreInsumo,
        activo: activo,
        stockBajo: stockBajo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CostoBeneficioReporte> getReporteCostoBeneficio({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    required int pageSize,
    required int pageNumber,
  }) async {
    try {
      final dto = await remoteDatasource.getReporteCostoBeneficio(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        tipoProductoId: tipoProductoId,
        activo: activo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
