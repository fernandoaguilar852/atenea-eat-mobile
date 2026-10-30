class UserEntity {
  final int usuarioId;
  final int clienteId;
  final String email;
  final String nombre;
  final String rol;
  final int rolId;

  const UserEntity({
    required this.usuarioId,
    required this.clienteId,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.rolId,
  });
}
