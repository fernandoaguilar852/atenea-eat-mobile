import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Fila de venta agregada por producto
class VentaRow extends Equatable {
  final int productoId;
  final String productoNombre;
  final String? categoriaNombre;
  final num cantidadVendida;
  final num precioPromedio;
  final num subtotalVentas;
  final num descuentosAplicados;
  final num impuestosAplicados;
  final num totalVentas;
  final int numeroTransacciones;

  const VentaRow({
    required this.productoId,
    required this.productoNombre,
    this.categoriaNombre,
    required this.cantidadVendida,
    required this.precioPromedio,
    required this.subtotalVentas,
    required this.descuentosAplicados,
    required this.impuestosAplicados,
    required this.totalVentas,
    required this.numeroTransacciones,
  });

  @override
  List<Object?> get props => [
        productoId,
        productoNombre,
        categoriaNombre,
        cantidadVendida,
        precioPromedio,
        subtotalVentas,
        descuentosAplicados,
        impuestosAplicados,
        totalVentas,
        numeroTransacciones,
      ];
}

/// Resumen de ventas
class VentasResumen extends Equatable {
  final int totalProductosVendidos;
  final int totalTransacciones;
  final num subtotalGeneral;
  final num descuentosGeneral;
  final num impuestosGeneral;
  final num totalGeneral;

  const VentasResumen({
    required this.totalProductosVendidos,
    required this.totalTransacciones,
    required this.subtotalGeneral,
    required this.descuentosGeneral,
    required this.impuestosGeneral,
    required this.totalGeneral,
  });

  @override
  List<Object?> get props => [
        totalProductosVendidos,
        totalTransacciones,
        subtotalGeneral,
        descuentosGeneral,
        impuestosGeneral,
        totalGeneral,
      ];
}

/// Reporte completo de ventas
class VentasReporte extends Equatable {
  final Encabezado encabezado;
  final List<VentaRow> ventas;
  final VentasResumen resumen;
  final Pagination pagination;

  const VentasReporte({
    required this.encabezado,
    required this.ventas,
    required this.resumen,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
        encabezado,
        ventas,
        resumen,
        pagination,
      ];
}
