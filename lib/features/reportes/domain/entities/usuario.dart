class Usuario {
  final int usuarioId;
  final int clienteId;
  final int rolId;
  final String nombre;
  final String email;
  final bool activo;
  final String createdAt;

  Usuario({
    required this.usuarioId,
    required this.clienteId,
    required this.rolId,
    required this.nombre,
    required this.email,
    required this.activo,
    required this.createdAt,
  });
}
