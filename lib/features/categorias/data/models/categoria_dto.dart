import '../../domain/entities/categoria.dart';

class CategoriaDto {
  final int tipoProductoId;
  final int clienteId;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final String createdAt;

  CategoriaDto({
    required this.tipoProductoId,
    required this.clienteId,
    required this.nombre,
    this.descripcion,
    required this.activo,
    required this.createdAt,
  });

  factory CategoriaDto.fromJson(Map<String, dynamic> json) {
    return CategoriaDto(
      tipoProductoId: json['tipoProductoId'] as int,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Categoria toEntity() {
    return Categoria(
      tipoProductoId: tipoProductoId,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }
}
