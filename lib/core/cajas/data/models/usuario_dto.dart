import '../../domain/entities/usuario.dart';

class UsuarioDto {
  final int usuarioId;
  final int clienteId;
  final int? rolId;
  final String nombre;
  final String? email;
  final bool? activo;
  final String? createdAt;

  UsuarioDto({
    required this.usuarioId,
    required this.clienteId,
    this.rolId,
    required this.nombre,
    this.email,
    this.activo,
    this.createdAt,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) {
    return UsuarioDto(
      usuarioId: json['usuarioId'] as int,
      clienteId: json['clienteId'] as int,
      rolId: json['rolId'] as int?,
      nombre: json['nombre'] as String,
      email: json['email'] as String?,
      activo: json['activo'] as bool?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'clienteId': clienteId,
      'rolId': rolId,
      'nombre': nombre,
      'email': email,
      'activo': activo,
      'createdAt': createdAt,
    };
  }

  Usuario toEntity() {
    return Usuario(
      usuarioId: usuarioId,
      clienteId: clienteId,
      nombre: nombre,
      email: email,
      rolId: rolId,
      activo: activo,
    );
  }
}
