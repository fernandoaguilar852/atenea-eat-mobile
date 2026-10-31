import '../../domain/entities/stock_insumos_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class StockInsumoDto {
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

  StockInsumoDto({
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

  factory StockInsumoDto.fromJson(Map<String, dynamic> json) {
    return StockInsumoDto(
      insumoId: json['insumoId'] as int,
      nombre: json['nombre'] as String,
      unidadBase: json['unidadBase'] as String,
      stockActual: json['stockActual'] as num,
      stockReservado: json['stockReservado'] as num,
      stockDisponible: json['stockDisponible'] as num,
      stockMinimo: json['stockMinimo'] as num,
      requiereReposicion: json['requiereReposicion'] as bool,
      costoPromedio: json['costoPromedio'] as num?,
      valorInventario: json['valorInventario'] as num?,
      activo: json['activo'] as bool,
      productosRelacionados: (json['productosRelacionados'] as List).map((e) => e.toString()).toList(),
    );
  }

  StockInsumo toEntity() => StockInsumo(
        insumoId: insumoId,
        nombre: nombre,
        unidadBase: unidadBase,
        stockActual: stockActual,
        stockReservado: stockReservado,
        stockDisponible: stockDisponible,
        stockMinimo: stockMinimo,
        requiereReposicion: requiereReposicion,
        costoPromedio: costoPromedio,
        valorInventario: valorInventario,
        activo: activo,
        productosRelacionados: productosRelacionados,
      );
}

class StockInsumosResumenDto {
  final int totalInsumos;
  final int insumosStockBajo;
  final num valorInventario;

  StockInsumosResumenDto({
    required this.totalInsumos,
    required this.insumosStockBajo,
    required this.valorInventario,
  });

  factory StockInsumosResumenDto.fromJson(Map<String, dynamic> json) {
    return StockInsumosResumenDto(
      totalInsumos: json['totalInsumos'] as int,
      insumosStockBajo: json['insumosStockBajo'] as int,
      valorInventario: json['valorInventario'] as num,
    );
  }

  StockInsumosResumen toEntity() => StockInsumosResumen(
        totalInsumos: totalInsumos,
        insumosStockBajo: insumosStockBajo,
        valorInventario: valorInventario,
      );
}

class StockInsumosReporteResponseDto {
  final EncabezadoDto encabezado;
  final List<StockInsumoDto> insumos;
  final StockInsumosResumenDto resumen;
  final PaginationDto pagination;

  StockInsumosReporteResponseDto({
    required this.encabezado,
    required this.insumos,
    required this.resumen,
    required this.pagination,
  });

  factory StockInsumosReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return StockInsumosReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      insumos: (json['insumos'] as List)
          .map((e) => StockInsumoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: StockInsumosResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  StockInsumosReporte toEntity() => StockInsumosReporte(
        encabezado: encabezado.toEntity(),
        insumos: insumos.map((e) => e.toEntity()).toList(),
        resumen: resumen.toEntity(),
        pagination: pagination.toEntity(),
      );
}
