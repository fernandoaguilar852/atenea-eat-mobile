import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Fila de análisis costo-beneficio
class CostoBeneficioRow extends Equatable {
  final int productoId;
  final String productoNombre;
  final String? categoriaNombre;
  final bool manejaStock;
  final bool usaReceta;
  final num cantidadVendida;
  final num costoUnitario;
  final num costoTotal;
  final num precioPromedioVenta;
  final num ingresosTotal;
  final num margenPesos;
  final num margenPorcentaje;
  final int numeroTransacciones;
  final String tipoCalculo; // 'receta' | 'movimiento' | 'sin_costo'

  const CostoBeneficioRow({
    required this.productoId,
    required this.productoNombre,
    this.categoriaNombre,
    required this.manejaStock,
    required this.usaReceta,
    required this.cantidadVendida,
    required this.costoUnitario,
    required this.costoTotal,
    required this.precioPromedioVenta,
    required this.ingresosTotal,
    required this.margenPesos,
    required this.margenPorcentaje,
    required this.numeroTransacciones,
    required this.tipoCalculo,
  });

  @override
  List<Object?> get props => [
        productoId,
        productoNombre,
        categoriaNombre,
        manejaStock,
        usaReceta,
        cantidadVendida,
        costoUnitario,
        costoTotal,
        precioPromedioVenta,
        ingresosTotal,
        margenPesos,
        margenPorcentaje,
        numeroTransacciones,
        tipoCalculo,
      ];
}

/// Resumen de costo-beneficio
class CostoBeneficioResumen extends Equatable {
  final int totalProductosAnalizados;
  final num cantidadTotalVendida;
  final num costoTotalGeneral;
  final num ingresosTotalGeneral;
  final num margenTotalPesos;
  final num margenTotalPorcentaje;
  final int totalTransacciones;

  const CostoBeneficioResumen({
    required this.totalProductosAnalizados,
    required this.cantidadTotalVendida,
    required this.costoTotalGeneral,
    required this.ingresosTotalGeneral,
    required this.margenTotalPesos,
    required this.margenTotalPorcentaje,
    required this.totalTransacciones,
  });

  @override
  List<Object?> get props => [
        totalProductosAnalizados,
        cantidadTotalVendida,
        costoTotalGeneral,
        ingresosTotalGeneral,
        margenTotalPesos,
        margenTotalPorcentaje,
        totalTransacciones,
      ];
}

/// Reporte completo de costo-beneficio
class CostoBeneficioReporte extends Equatable {
  final Encabezado encabezado;
  final List<CostoBeneficioRow> productos;
  final CostoBeneficioResumen resumen;
  final Pagination pagination;

  const CostoBeneficioReporte({
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
