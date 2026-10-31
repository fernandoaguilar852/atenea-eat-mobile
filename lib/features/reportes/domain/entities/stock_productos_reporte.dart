import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Producto con stock
class StockProducto extends Equatable {
  final int productoId;
  final String nombre;
  final int? tipoProductoId;
  final String? tipoProductoNombre;
  final String? codigoBarras;
  final String unidadMedida;
  final num stockTotal;
  final num stockReservado;
  final num stockDisponible;
  final num stockMinimo;
  final bool requiereReposicion;
  final num? precio;
  final bool activo;

  const StockProducto({
    required this.productoId,
    required this.nombre,
    this.tipoProductoId,
    this.tipoProductoNombre,
    this.codigoBarras,
    required this.unidadMedida,
    required this.stockTotal,
    required this.stockReservado,
    required this.stockDisponible,
    required this.stockMinimo,
    required this.requiereReposicion,
    this.precio,
    required this.activo,
  });

  @override
  List<Object?> get props => [
        productoId,
        nombre,
        tipoProductoId,
        tipoProductoNombre,
        codigoBarras,
        unidadMedida,
        stockTotal,
        stockReservado,
        stockDisponible,
        stockMinimo,
        requiereReposicion,
        precio,
        activo,
      ];
}

/// Resumen de stock de productos
class StockProductosResumen extends Equatable {
  final int totalProductos;
  final int productosStockBajo;
  final num valorInventario;

  const StockProductosResumen({
    required this.totalProductos,
    required this.productosStockBajo,
    required this.valorInventario,
  });

  @override
  List<Object?> get props => [
        totalProductos,
        productosStockBajo,
        valorInventario,
      ];
}

/// Reporte completo de stock de productos
class StockProductosReporte extends Equatable {
  final Encabezado encabezado;
  final List<StockProducto> productos;
  final StockProductosResumen resumen;
  final Pagination pagination;

  const StockProductosReporte({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
        encabezado,
        productos,
        resumen,
        pagination,
      ];
}
