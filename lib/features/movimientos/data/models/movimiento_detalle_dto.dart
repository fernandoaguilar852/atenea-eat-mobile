import '../../domain/entities/movimiento_detalle.dart';

class MovimientoDetalleDto {
  final int movimientoId;
  final int? productoId;
  final int usuarioId;
  final int clienteId;
  final int? proveedorId;
  final int? insumoId;
  final String nombre;
  final String tipo;
  final double costo;
  final double impuesto;
  final double descuentoUnidad;
  final int cantidad;
  final String observacion;
  final String fecha;
  final String createdAt;
  final String? updatedAt;
  final int? updatedByUsuarioId;
  final String? deletedAt;
  final int? deletedByUsuarioId;
  final String? deleteReason;

  MovimientoDetalleDto({
    required this.movimientoId,
    this.productoId,
    required this.usuarioId,
    required this.clienteId,
    this.proveedorId,
    this.insumoId,
    required this.nombre,
    required this.tipo,
    required this.costo,
    required this.impuesto,
    required this.descuentoUnidad,
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

  factory MovimientoDetalleDto.fromJson(Map<String, dynamic> json) {
    return MovimientoDetalleDto(
      movimientoId: json['movimientoId'] as int,
      productoId: json['productoId'] as int?,
      usuarioId: json['usuarioId'] as int,
      clienteId: json['clienteId'] as int,
      proveedorId: json['proveedorId'] as int?,
      insumoId: json['insumoId'] as int?,
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String,
      costo: (json['costo'] as num).toDouble(),
      impuesto: (json['impuesto'] as num).toDouble(),
      descuentoUnidad: (json['descuentoUnidad'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      observacion: json['observacion'] as String,
      fecha: json['fecha'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      updatedByUsuarioId: json['updatedByUsuarioId'] as int?,
      deletedAt: json['deletedAt'] as String?,
      deletedByUsuarioId: json['deletedByUsuarioId'] as int?,
      deleteReason: json['deleteReason'] as String?,
    );
  }

  MovimientoDetalle toEntity() {
    return MovimientoDetalle(
      movimientoId: movimientoId,
      productoId: productoId,
      usuarioId: usuarioId,
      clienteId: clienteId,
      proveedorId: proveedorId,
      insumoId: insumoId,
      nombre: nombre,
      tipo: tipo,
      costo: costo,
      impuesto: impuesto,
      descuentoUnidad: descuentoUnidad,
      cantidad: cantidad,
      observacion: observacion,
      fecha: fecha,
      createdAt: createdAt,
      updatedAt: updatedAt,
      updatedByUsuarioId: updatedByUsuarioId,
      deletedAt: deletedAt,
      deletedByUsuarioId: deletedByUsuarioId,
      deleteReason: deleteReason,
    );
  }
}
