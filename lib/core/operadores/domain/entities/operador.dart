class Operador {
  final int operadorId;
  final int clienteId;
  final String nombre;
  final String? numeroDocumento;
  final String? telefono;
  final bool tienePin;
  final bool activo;
  final String createdAt;

  Operador({
    required this.operadorId,
    required this.clienteId,
    required this.nombre,
    this.numeroDocumento,
    this.telefono,
    required this.tienePin,
    required this.activo,
    required this.createdAt,
  });

  Operador copyWith({
    int? operadorId,
    int? clienteId,
    String? nombre,
    String? numeroDocumento,
    String? telefono,
    bool? tienePin,
    bool? activo,
    String? createdAt,
  }) {
    return Operador(
      operadorId: operadorId ?? this.operadorId,
      clienteId: clienteId ?? this.clienteId,
      nombre: nombre ?? this.nombre,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      telefono: telefono ?? this.telefono,
      tienePin: tienePin ?? this.tienePin,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
