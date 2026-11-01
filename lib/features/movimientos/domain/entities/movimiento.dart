class Movimiento {
  final int movimientoId;
  final int? productoId;
  final int usuarioId;
  final int clienteId;
  final int? proveedorId;
  final int? insumoId;
  final String nombre;
  final String tipo;
  final double? costo;
  final double? impuesto;
  final double? descuentoUnidad;
  final double cantidad;
  final String observacion;
  final String fecha;
  final String createdAt;
  final String? updatedAt;
  final int? updatedByUsuarioId;
  final String? deletedAt;
  final int? deletedByUsuarioId;
  final String? deleteReason;

  Movimiento({
    required this.movimientoId,
    this.productoId,
    required this.usuarioId,
    required this.clienteId,
    this.proveedorId,
    this.insumoId,
    required this.nombre,
    required this.tipo,
    this.costo,
    this.impuesto,
    this.descuentoUnidad,
    required this.cantidad,
    required this.observacion,
    required this.fecha,
    required this.createdAt,
    this.updatedAt,
    this.updatedByUsuarioId,
    this.deletedAt,
    this.deletedByUsuarioId,
    this.deleteReason,
  });
}
