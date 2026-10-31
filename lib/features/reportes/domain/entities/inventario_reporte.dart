import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Producto consumido directamente
class InventarioProductoRow extends Equatable {
  final int productoId;
  final String productoNombre;
  final num cantidadConsumida;
  final String unidadMedida;
  final num stockActual;
  final num stockMinimo;
  final bool requiereReposicion;
  final int numeroMovimientos;

  const InventarioProductoRow({
    required this.productoId,
    required this.productoNombre,
    required this.cantidadConsumida,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.requiereReposicion,
    required this.numeroMovimientos,
  });

  @override
  List<Object?> get props => [
        productoId,
        productoNombre,
        cantidadConsumida,
        unidadMedida,
        stockActual,
        stockMinimo,
        requiereReposicion,
        numeroMovimientos,
      ];
}

/// Insumo consumido (por recetas)
class InventarioInsumoRow extends Equatable {
  final int insumoId;
  final String insumoNombre;
  final num cantidadConsumida;
  final String unidadMedida;
  final num stockActual;
  final num stockMinimo;
  final bool requiereReposicion;
  final List<String> productosRelacionados;
  final int numeroMovimientos;

  const InventarioInsumoRow({
    required this.insumoId,
    required this.insumoNombre,
    required this.cantidadConsumida,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.requiereReposicion,
    required this.productosRelacionados,
    required this.numeroMovimientos,
  });

  @override
  List<Object?> get props => [
        insumoId,
        insumoNombre,
        cantidadConsumida,
        unidadMedida,
        stockActual,
        stockMinimo,
        requiereReposicion,
        productosRelacionados,
        numeroMovimientos,
      ];
}

/// Resumen de inventario consumido
class InventarioResumen extends Equatable {
  final int totalProductosConsumidos;
  final int totalInsumosConsumidos;
  final int totalMovimientos;
  final int itemsRequierenReposicion;

  const InventarioResumen({
    required this.totalProductosConsumidos,
    required this.totalInsumosConsumidos,
    required this.totalMovimientos,
    required this.itemsRequierenReposicion,
  });

  @override
  List<Object?> get props => [
        totalProductosConsumidos,
        totalInsumosConsumidos,
        totalMovimientos,
        itemsRequierenReposicion,
      ];
}

/// Reporte completo de inventario consumido
class InventarioReporte extends Equatable {
  final Encabezado encabezado;
  final List<InventarioProductoRow> productosDirectos;
  final List<InventarioInsumoRow> insumosConsumidos;
  final InventarioResumen resumen;
  final Pagination pagination;

  const InventarioReporte({
    required this.encabezado,
    required this.productosDirectos,
    required this.insumosConsumidos,
    required this.resumen,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
        encabezado,
        productosDirectos,
        insumosConsumidos,
        resumen,
        pagination,
      ];
}
