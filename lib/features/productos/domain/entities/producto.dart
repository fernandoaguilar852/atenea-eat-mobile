class Producto {
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
  final int stockTotal;
  final int stockReservado;
  final int stockMinimo;
  final bool manejaStock;
  final bool usaReceta;
  final bool activo;
  final int? ivaId;

  Producto({
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
}
