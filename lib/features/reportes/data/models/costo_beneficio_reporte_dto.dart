import '../../domain/entities/costo_beneficio_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class CostoBeneficioRowDto {
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
  final String tipoCalculo;

  CostoBeneficioRowDto({
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

  factory CostoBeneficioRowDto.fromJson(Map<String, dynamic> json) {
    return CostoBeneficioRowDto(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      categoriaNombre: json['categoriaNombre'] as String?,
      manejaStock: json['manejaStock'] as bool,
      usaReceta: json['usaReceta'] as bool,
      cantidadVendida: json['cantidadVendida'] as num,
      costoUnitario: json['costoUnitario'] as num,
      costoTotal: json['costoTotal'] as num,
      precioPromedioVenta: json['precioPromedioVenta'] as num,
      ingresosTotal: json['ingresosTotal'] as num,
      margenPesos: json['margenPesos'] as num,
      margenPorcentaje: json['margenPorcentaje'] as num,
      numeroTransacciones: json['numeroTransacciones'] as int,
      tipoCalculo: json['tipoCalculo'] as String,
    );
  }

  CostoBeneficioRow toEntity() {
    return CostoBeneficioRow(
      productoId: productoId,
      productoNombre: productoNombre,
      categoriaNombre: categoriaNombre,
      manejaStock: manejaStock,
      usaReceta: usaReceta,
      cantidadVendida: cantidadVendida,
      costoUnitario: costoUnitario,
      costoTotal: costoTotal,
      precioPromedioVenta: precioPromedioVenta,
      ingresosTotal: ingresosTotal,
      margenPesos: margenPesos,
      margenPorcentaje: margenPorcentaje,
      numeroTransacciones: numeroTransacciones,
      tipoCalculo: tipoCalculo,
    );
  }
}

class CostoBeneficioResumenDto {
  final int totalProductosAnalizados;
  final num cantidadTotalVendida;
  final num costoTotalGeneral;
  final num ingresosTotalGeneral;
  final num margenTotalPesos;
  final num margenTotalPorcentaje;
  final int totalTransacciones;

  CostoBeneficioResumenDto({
    required this.totalProductosAnalizados,
    required this.cantidadTotalVendida,
    required this.costoTotalGeneral,
    required this.ingresosTotalGeneral,
    required this.margenTotalPesos,
    required this.margenTotalPorcentaje,
    required this.totalTransacciones,
  });

  factory CostoBeneficioResumenDto.fromJson(Map<String, dynamic> json) {
    return CostoBeneficioResumenDto(
      totalProductosAnalizados: json['totalProductosAnalizados'] as int,
      cantidadTotalVendida: json['cantidadTotalVendida'] as num,
      costoTotalGeneral: json['costoTotalGeneral'] as num,
      ingresosTotalGeneral: json['ingresosTotalGeneral'] as num,
      margenTotalPesos: json['margenTotalPesos'] as num,
      margenTotalPorcentaje: json['margenTotalPorcentaje'] as num,
      totalTransacciones: json['totalTransacciones'] as int,
    );
  }

  CostoBeneficioResumen toEntity() {
    return CostoBeneficioResumen(
      totalProductosAnalizados: totalProductosAnalizados,
      cantidadTotalVendida: cantidadTotalVendida,
      costoTotalGeneral: costoTotalGeneral,
      ingresosTotalGeneral: ingresosTotalGeneral,
      margenTotalPesos: margenTotalPesos,
      margenTotalPorcentaje: margenTotalPorcentaje,
      totalTransacciones: totalTransacciones,
    );
  }
}

class CostoBeneficioReporteResponseDto {
  final EncabezadoDto encabezado;
  final List<CostoBeneficioRowDto> productos;
  final CostoBeneficioResumenDto resumen;
  final PaginationDto pagination;

  CostoBeneficioReporteResponseDto({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    required this.pagination,
  });

  factory CostoBeneficioReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return CostoBeneficioReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      productos: (json['productos'] as List)
          .map((e) => CostoBeneficioRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: CostoBeneficioResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  CostoBeneficioReporte toEntity() {
    return CostoBeneficioReporte(
      encabezado: encabezado.toEntity(),
      productos: productos.map((e) => e.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination.toEntity(),
    );
  }
}
