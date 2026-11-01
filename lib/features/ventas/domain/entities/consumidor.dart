class Consumidor {
  final int consumidorId;
  final int clienteId;
  final String tipoIdentificacion;
  final String numeroIdentificacion;
  final String? digitoVerificacion;
  final String nombreRazonSocial;
  final String? direccion;
  final String? email;
  final String? telefono;
  final int? ciudadId;
  final bool activo;
  final String createdAt;

  Consumidor({
    required this.consumidorId,
    required this.clienteId,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    this.digitoVerificacion,
    required this.nombreRazonSocial,
    this.direccion,
    this.email,
    this.telefono,
    this.ciudadId,
    required this.activo,
    required this.createdAt,
  });
}
