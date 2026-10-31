import '../../domain/entities/stock_productos_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class StockProductoDto {
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

  StockProductoDto({
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

  factory StockProductoDto.fromJson(Map<String, dynamic> json) {
    return StockProductoDto(
      productoId: json['productoId'] as int,
      nombre: json['nombre'] as String,
      tipoProductoId: json['tipoProductoId'] as int?,
      tipoProductoNombre: json['tipoProductoNombre'] as String?,
      codigoBarras: json['codigoBarras'] as String?,
      unidadMedida: json['unidadMedida'] as String,
      stockTotal: json['stockTotal'] as num,
      stockReservado: json['stockReservado'] as num,
      stockDisponible: json['stockDisponible'] as num,
      stockMinimo: json['stockMinimo'] as num,
      requiereReposicion: json['requiereReposicion'] as bool,
      precio: json['precio'] as num?,
      activo: json['activo'] as bool,
    );
  }

  StockProducto toEntity() {
    return StockProducto(
      productoId: productoId,
      nombre: nombre,
      tipoProductoId: tipoProductoId,
      tipoProductoNombre: tipoProductoNombre,
      codigoBarras: codigoBarras,
      unidadMedida: unidadMedida,
      stockTotal: stockTotal,
      stockReservado: stockReservado,
      stockDisponible: stockDisponible,
      stockMinimo: stockMinimo,
      requiereReposicion: requiereReposicion,
      precio: precio,
      activo: activo,
    );
  }
}

class StockProductosResumenDto {
  final int totalProductos;
  final int productosStockBajo;
  final num valorInventario;

  StockProductosResumenDto({
    required this.totalProductos,
    required this.productosStockBajo,
    required this.valorInventario,
  });

  factory StockProductosResumenDto.fromJson(Map<String, dynamic> json) {
    return StockProductosResumenDto(
      totalProductos: json['totalProductos'] as int,
      productosStockBajo: json['productosStockBajo'] as int,
      valorInventario: json['valorInventario'] as num,
    );
  }

  StockProductosResumen toEntity() {
    return StockProductosResumen(
      totalProductos: totalProductos,
      productosStockBajo: productosStockBajo,
      valorInventario: valorInventario,
    );
  }
}

class StockProductosReporteResponseDto {
  final EncabezadoDto encabezado;
  final List<StockProductoDto> productos;
  final StockProductosResumenDto resumen;
  final PaginationDto pagination;

  StockProductosReporteResponseDto({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    required this.pagination,
  });

  factory StockProductosReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return StockProductosReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      productos: (json['productos'] as List)
          .map((e) => StockProductoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      resumen: StockProductosResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  StockProductosReporte toEntity() {
    return StockProductosReporte(
      encabezado: encabezado.toEntity(),
      productos: productos.map((e) => e.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination.toEntity(),
    );
  }
}
