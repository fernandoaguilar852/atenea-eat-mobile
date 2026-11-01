class RegistrarMovimientoRequestDto {
  final int productoId;
  final int? insumoId;
  final int usuarioId;
  final int clienteId;
  final int? proveedorId;
  final String tipo; // "entrada" o "salida"
  final double costo;
  final double impuesto;
  final double descuentoUnidad;
  final int cantidad;
  final String observacion;
  final String fecha; // formato: "2026-07-29T17:05" o "2026-01-10"

  RegistrarMovimientoRequestDto({
    required this.productoId,
    this.insumoId,
    required this.usuarioId,
    required this.clienteId,
    this.proveedorId,
    required this.tipo,
    required this.costo,
    required this.impuesto,
    required this.descuentoUnidad,
    required this.cantidad,
    required this.observacion,
    required this.fecha,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'productoId': productoId,
      'usuarioId': usuarioId,
      'clienteId': clienteId,
      'tipo': tipo,
      'costo': costo,
      'impuesto': impuesto,
      'descuentoUnidad': descuentoUnidad,
      'cantidad': cantidad,
      'observacion': observacion,
      'fecha': fecha,
    };

    if (insumoId != null) {
      map['insumoId'] = insumoId;
    }

    if (proveedorId != null) {
      map['proveedorId'] = proveedorId;
    }

    return map;
  }
}
