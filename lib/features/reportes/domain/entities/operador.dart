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
}
