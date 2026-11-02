class Usuario {
  final int usuarioId;
  final int clienteId;
  final String nombre;
  final String? email;
  final int? rolId;
  final bool? activo;

  Usuario({
    required this.usuarioId,
    required this.clienteId,
    required this.nombre,
    this.email,
    this.rolId,
    this.activo,
  });
}
