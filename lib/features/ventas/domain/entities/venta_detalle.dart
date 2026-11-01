class VentaDetalle {
  final int ventaDetalleId;
  final int clienteId;
  final int ventaId;
  final int productoId;
  final String productoNombre;
  final String descripcion;
  final String cantidad;
  final String precioUnitario;
  final String subtotal;
  final String descuentoValor;
  final String descuentoPorcentaje;
  final String codigoImpuesto;
  final String porcentajeImpuesto;
  final String valorImpuesto;
  final String totalLinea;
  final String createdAt;

  VentaDetalle({
    required this.ventaDetalleId,
    required this.clienteId,
    required this.ventaId,
    required this.productoId,
    required this.productoNombre,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    required this.descuentoPorcentaje,
    required this.codigoImpuesto,
    required this.porcentajeImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    required this.createdAt,
  });
}
