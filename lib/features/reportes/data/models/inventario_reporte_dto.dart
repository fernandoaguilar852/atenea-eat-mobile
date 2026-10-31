import '../../domain/entities/inventario_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class InventarioProductoRowDto {
  final int productoId;
  final String productoNombre;
  final num cantidadConsumida;
  final String unidadMedida;
  final num stockActual;
  final num stockMinimo;
  final bool requiereReposicion;
  final int numeroMovimientos;

  InventarioProductoRowDto({
    required this.productoId,
    required this.productoNombre,
    required this.cantidadConsumida,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.requiereReposicion,
    required this.numeroMovimientos,
  });

  factory InventarioProductoRowDto.fromJson(Map<String, dynamic> json) {
    return InventarioProductoRowDto(
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      cantidadConsumida: json['cantidadConsumida'] as num,
      unidadMedida: json['unidadMedida'] as String,
      stockActual: json['stockActual'] as num,
      stockMinimo: json['stockMinimo'] as num,
      requiereReposicion: json['requiereReposicion'] as bool,
      numeroMovimientos: json['numeroMovimientos'] as int,
    );
  }

  InventarioProductoRow toEntity() => InventarioProductoRow(
        productoId: productoId,
        productoNombre: productoNombre,
        cantidadConsumida: cantidadConsumida,
        unidadMedida: unidadMedida,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        requiereReposicion: requiereReposicion,
        numeroMovimientos: numeroMovimientos,
      );
}

class InventarioInsumoRowDto {
  final int insumoId;
  final String insumoNombre;
  final num cantidadConsumida;
  final String unidadMedida;
  final num stockActual;
  final num stockMinimo;
  final bool requiereReposicion;
  final List<String> productosRelacionados;
  final int numeroMovimientos;

  InventarioInsumoRowDto({
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

  factory InventarioInsumoRowDto.fromJson(Map<String, dynamic> json) {
    return InventarioInsumoRowDto(
      insumoId: json['insumoId'] as int,
      insumoNombre: json['insumoNombre'] as String,
      cantidadConsumida: json['cantidadConsumida'] as num,
      unidadMedida: json['unidadMedida'] as String,
      stockActual: json['stockActual'] as num,
      stockMinimo: json['stockMinimo'] as num,
      requiereReposicion: json['requiereReposicion'] as bool,
      productosRelacionados: (json['productosRelacionados'] as List).map((e) => e.toString()).toList(),
      numeroMovimientos: json['numeroMovimientos'] as int,
    );
  }

  InventarioInsumoRow toEntity() => InventarioInsumoRow(
        insumoId: insumoId,
        insumoNombre: insumoNombre,
        cantidadConsumida: cantidadConsumida,
        unidadMedida: unidadMedida,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        requiereReposicion: requiereReposicion,
        productosRelacionados: productosRelacionados,
        numeroMovimientos: numeroMovimientos,
      );
}

class InventarioResumenDto {
  final int totalProductosConsumidos;
  final int totalInsumosConsumidos;
  final int totalMovimientos;
  final int itemsRequierenReposicion;

  InventarioResumenDto({
    required this.totalProductosConsumidos,
    required this.totalInsumosConsumidos,
    required this.totalMovimientos,
    required this.itemsRequierenReposicion,
  });

  factory InventarioResumenDto.fromJson(Map<String, dynamic> json) {
    return InventarioResumenDto(
      totalProductosConsumidos: json['totalProductosConsumidos'] as int,
      totalInsumosConsumidos: json['totalInsumosConsumidos'] as int,
      totalMovimientos: json['totalMovimientos'] as int,
      itemsRequierenReposicion: json['itemsRequierenReposicion'] as int,
    );
  }

  InventarioResumen toEntity() => InventarioResumen(
        totalProductosConsumidos: totalProductosConsumidos,
        totalInsumosConsumidos: totalInsumosConsumidos,
        totalMovimientos: totalMovimientos,
        itemsRequierenReposicion: itemsRequierenReposicion,
      );
}

class InventarioReporteResponseDto {
  final EncabezadoDto encabezado;
  final Map<String, dynamic> reporteInventario;
  final InventarioResumenDto resumen;
  final PaginationDto pagination;

  InventarioReporteResponseDto({
    required this.encabezado,
    required this.reporteInventario,
    required this.resumen,
    required this.pagination,
  });

  factory InventarioReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return InventarioReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      reporteInventario: json['reporteInventario'] as Map<String, dynamic>,
      resumen: InventarioResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  InventarioReporte toEntity() {
    final productos = (reporteInventario['productosDirectos'] as List? ?? [])
        .where((e) => e != null)
        .map((e) => InventarioProductoRowDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    final insumos = (reporteInventario['insumosConsumidos'] as List? ?? [])
        .where((e) => e != null)
        .map((e) => InventarioInsumoRowDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    return InventarioReporte(
      encabezado: encabezado.toEntity(),
      productosDirectos: productos,
      insumosConsumidos: insumos,
      resumen: resumen.toEntity(),
      pagination: pagination.toEntity(),
    );
  }
}
