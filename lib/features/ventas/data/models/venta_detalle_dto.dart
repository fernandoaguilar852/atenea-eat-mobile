import '../../domain/entities/venta_detalle.dart';

class VentaDetalleDto {
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

  VentaDetalleDto({
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

  factory VentaDetalleDto.fromJson(Map<String, dynamic> json) {
    return VentaDetalleDto(
      ventaDetalleId: json['ventaDetalleId'] as int,
      clienteId: json['clienteId'] as int,
      ventaId: json['ventaId'] as int,
      productoId: json['productoId'] as int,
      productoNombre: json['productoNombre'] as String,
      descripcion: json['descripcion'] as String,
      cantidad: json['cantidad'] as String,
      precioUnitario: json['precioUnitario'] as String,
      subtotal: json['subtotal'] as String,
      descuentoValor: json['descuentoValor'] as String,
      descuentoPorcentaje: json['descuentoPorcentaje'] as String,
      codigoImpuesto: json['codigoImpuesto'] as String,
      porcentajeImpuesto: json['porcentajeImpuesto'] as String,
      valorImpuesto: json['valorImpuesto'] as String,
      totalLinea: json['totalLinea'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  VentaDetalle toEntity() {
    return VentaDetalle(
      ventaDetalleId: ventaDetalleId,
      clienteId: clienteId,
      ventaId: ventaId,
      productoId: productoId,
      productoNombre: productoNombre,
      descripcion: descripcion,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
      descuentoValor: descuentoValor,
      descuentoPorcentaje: descuentoPorcentaje,
      codigoImpuesto: codigoImpuesto,
      porcentajeImpuesto: porcentajeImpuesto,
      valorImpuesto: valorImpuesto,
      totalLinea: totalLinea,
      createdAt: createdAt,
    );
  }
}
