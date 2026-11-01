class EliminarMovimientoRequestDto {
  final int deletedByUsuarioId;
  final String deleteReason;

  EliminarMovimientoRequestDto({
    required this.deletedByUsuarioId,
    required this.deleteReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'deletedByUsuarioId': deletedByUsuarioId,
      'deleteReason': deleteReason,
    };
  }
}
