import '../entities/ventas_reporte.dart';
import '../entities/inventario_reporte.dart';
import '../entities/arqueo_reporte.dart';
import '../entities/stock_productos_reporte.dart';
import '../entities/stock_insumos_reporte.dart';
import '../entities/costo_beneficio_reporte.dart';
import '../entities/productos_response.dart';
import '../entities/consumidores_response.dart';
import '../entities/tipo_producto.dart';
import '../entities/caja.dart';
import '../entities/usuario.dart';
import '../entities/operador.dart';
import '../entities/insumo.dart';

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
    required int pageSize,
    required int pageNumber,
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

  Future<ProductosResponse> searchProductos({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<ConsumidoresResponse> searchConsumidores({
    required int clienteId,
    required String search,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<List<TipoProducto>> getTiposProducto({
    required int clienteId,
    bool activo = true,
    int pageSize = 100,
    int pageNumber = 1,
  });

  Future<List<Caja>> getCajas({
    required int clienteId,
    int pageSize = 10,
    int pageNumber = 1,
  });

  Future<Usuario> getUsuario({
    required int usuarioId,
    required int clienteId,
  });

  Future<List<Operador>> getOperadores({
    required int clienteId,
    int pageSize = 100,
    int pageNumber = 1,
  });

  Future<List<Insumo>> searchInsumos({
    required int clienteId,
    required String nombre,
    int pageSize = 20,
    int pageNumber = 1,
  });
}
