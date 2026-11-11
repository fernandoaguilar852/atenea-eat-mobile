import '../../domain/entities/producto.dart';

class ProductoDto {
  final int productoId;
  final int clienteId;
  final int tipoProductoId;
  final String nombre;
  final String codExterno;
  final String codBarras;
  final String? imagen;
  final double precio;
  final String unidadMedida;
  final String sigla;
  final double stockTotal;
  final double stockReservado;
  final double stockMinimo;
  final bool manejaStock;
  final bool usaReceta;
  final bool activo;
  final int? ivaId;

  ProductoDto({
    required this.productoId,
    required this.clienteId,
    required this.tipoProductoId,
    required this.nombre,
    required this.codExterno,
    required this.codBarras,
    this.imagen,
    required this.precio,
    required this.unidadMedida,
    required this.sigla,
    required this.stockTotal,
    required this.stockReservado,
    required this.stockMinimo,
    required this.manejaStock,
    required this.usaReceta,
    required this.activo,
    this.ivaId,
  });

  factory ProductoDto.fromJson(Map<String, dynamic> json) {
    return ProductoDto(
      productoId: json['productoId'] as int,
      clienteId: json['clienteId'] as int,
      tipoProductoId: json['tipoProductoId'] as int,
      nombre: json['nombre'] as String,
      codExterno: json['codExterno'] as String,
      codBarras: json['codBarras'] as String,
      imagen: json['imagen'] as String?,
      precio: (json['precio'] is int)
          ? (json['precio'] as int).toDouble()
          : json['precio'] as double,
      unidadMedida: json['unidadMedida'] as String,
      sigla: json['sigla'] as String,
      stockTotal: (json['stockTotal'] as num).toDouble(),
      stockReservado: (json['stockReservado'] as num).toDouble(),
      stockMinimo: (json['stockMinimo'] as num).toDouble(),
      manejaStock: json['manejaStock'] as bool,
      usaReceta: json['usaReceta'] as bool,
      activo: json['activo'] as bool,
      ivaId: json['ivaId'] as int?,
    );
  }

  Producto toEntity() {
    return Producto(
      productoId: productoId,
      clienteId: clienteId,
      tipoProductoId: tipoProductoId,
      nombre: nombre,
      codExterno: codExterno,
      codBarras: codBarras,
      imagen: imagen,
      precio: precio,
      unidadMedida: unidadMedida,
      sigla: sigla,
      stockTotal: stockTotal,
      stockReservado: stockReservado,
      stockMinimo: stockMinimo,
      manejaStock: manejaStock,
      usaReceta: usaReceta,
      activo: activo,
      ivaId: ivaId,
    );
  }
}
