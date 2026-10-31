import '../../domain/entities/ventas_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class VentaRowDto {
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

  VentaRowDto({
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

  factory VentaRowDto.fromJson(Map<String, dynamic> json) {
    return VentaRowDto(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      categoriaNombre: json['categoriaNombre'] as String?,
      cantidadVendida: json['cantidadVendida'] as num,
      precioPromedio: json['precioPromedio'] as num,
      subtotalVentas: json['subtotalVentas'] as num,
      descuentosAplicados: json['descuentosAplicados'] as num,
      impuestosAplicados: json['impuestosAplicados'] as num,
      totalVentas: json['totalVentas'] as num,
      numeroTransacciones: json['numeroTransacciones'] as int,
    );
  }

  VentaRow toEntity() {
    return VentaRow(
      productoId: productoId,
      productoNombre: productoNombre,
      categoriaNombre: categoriaNombre,
      cantidadVendida: cantidadVendida,
      precioPromedio: precioPromedio,
      subtotalVentas: subtotalVentas,
      descuentosAplicados: descuentosAplicados,
      impuestosAplicados: impuestosAplicados,
      totalVentas: totalVentas,
      numeroTransacciones: numeroTransacciones,
    );
  }
}

class VentasResumenDto {
  final int totalProductosVendidos;
  final int totalTransacciones;
  final num subtotalGeneral;
  final num descuentosGeneral;
  final num impuestosGeneral;
  final num totalGeneral;

  VentasResumenDto({
    required this.totalProductosVendidos,
    required this.totalTransacciones,
    required this.subtotalGeneral,
    required this.descuentosGeneral,
    required this.impuestosGeneral,
    required this.totalGeneral,
  });

  factory VentasResumenDto.fromJson(Map<String, dynamic> json) {
    return VentasResumenDto(
      totalProductosVendidos: json['totalProductosVendidos'] as int,
      totalTransacciones: json['totalTransacciones'] as int,
      subtotalGeneral: json['subtotalGeneral'] as num,
      descuentosGeneral: json['descuentosGeneral'] as num,
      impuestosGeneral: json['impuestosGeneral'] as num,
      totalGeneral: json['totalGeneral'] as num,
    );
  }

  VentasResumen toEntity() {
    return VentasResumen(
      totalProductosVendidos: totalProductosVendidos,
      totalTransacciones: totalTransacciones,
      subtotalGeneral: subtotalGeneral,
      descuentosGeneral: descuentosGeneral,
      impuestosGeneral: impuestosGeneral,
      totalGeneral: totalGeneral,
    );
  }
}

class VentasReporteResponseDto {
  final EncabezadoDto encabezado;
  final List<VentaRowDto> reporteVentas;
  final VentasResumenDto resumen;
  final PaginationDto pagination;

  VentasReporteResponseDto({
    required this.encabezado,
    required this.reporteVentas,
    required this.resumen,
    required this.pagination,
  });

  factory VentasReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return VentasReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      reporteVentas: (json['reporteVentas'] as List)
          .map((e) => VentaRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: VentasResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  VentasReporte toEntity() {
    return VentasReporte(
      encabezado: encabezado.toEntity(),
      ventas: reporteVentas.map((e) => e.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination.toEntity(),
    );
  }
}
