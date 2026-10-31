import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Insumo con stock
class StockInsumo extends Equatable {
  final int insumoId;
  final String nombre;
  final String unidadBase;
  final num stockActual;
  final num stockReservado;
  final num stockDisponible;
  final num stockMinimo;
  final bool requiereReposicion;
  final num? costoPromedio;
  final num? valorInventario;
  final bool activo;
  final List<String> productosRelacionados;

  const StockInsumo({
    required this.insumoId,
    required this.nombre,
    required this.unidadBase,
    required this.stockActual,
    required this.stockReservado,
    required this.stockDisponible,
    required this.stockMinimo,
    required this.requiereReposicion,
    this.costoPromedio,
    this.valorInventario,
    required this.activo,
    required this.productosRelacionados,
  });

  @override
  List<Object?> get props => [
        insumoId,
        nombre,
        unidadBase,
        stockActual,
        stockReservado,
        stockDisponible,
        stockMinimo,
        requiereReposicion,
        costoPromedio,
        valorInventario,
        activo,
        productosRelacionados,
      ];
}

/// Resumen de stock de insumos
class StockInsumosResumen extends Equatable {
  final int totalInsumos;
  final int insumosStockBajo;
  final num valorInventario;

  const StockInsumosResumen({
    required this.totalInsumos,
    required this.insumosStockBajo,
    required this.valorInventario,
  });

  @override
  List<Object?> get props => [
        totalInsumos,
        insumosStockBajo,
        valorInventario,
      ];
}

/// Reporte completo de stock de insumos
class StockInsumosReporte extends Equatable {
  final Encabezado encabezado;
  final List<StockInsumo> insumos;
  final StockInsumosResumen resumen;
  final Pagination pagination;

  const StockInsumosReporte({
    required this.encabezado,
    required this.insumos,
    required this.resumen,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
        encabezado,
        insumos,
        resumen,
        pagination,
      ];
}
