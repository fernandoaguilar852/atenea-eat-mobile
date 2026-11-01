class ActualizarMovimientoRequestDto {
  final double cantidad;
  final String observacion;
  final int updatedByUsuarioId;

  ActualizarMovimientoRequestDto({
    required this.cantidad,
    required this.observacion,
    required this.updatedByUsuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cantidad': cantidad,
      'observacion': observacion,
      'updatedByUsuarioId': updatedByUsuarioId,
    };
  }
}
