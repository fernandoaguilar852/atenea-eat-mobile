import '../../domain/entities/tipo_producto.dart';
import 'pagination_dto.dart';

class TipoProductoDto {
  final int tipoProductoId;
  final int clienteId;
  final String nombre;
  final String descripcion;
  final bool activo;
  final String createdAt;

  TipoProductoDto({
    required this.tipoProductoId,
    required this.clienteId,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.createdAt,
  });

  factory TipoProductoDto.fromJson(Map<String, dynamic> json) {
    return TipoProductoDto(
      tipoProductoId: json['tipoProductoId'] as int,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      activo: json['activo'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  TipoProducto toEntity() {
    return TipoProducto(
      tipoProductoId: tipoProductoId,
      clienteId: clienteId,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
      createdAt: createdAt,
    );
  }
}

class TiposProductoResponseDto {
  final List<TipoProductoDto> tiposProducto;
  final PaginationDto pagination;

  TiposProductoResponseDto({
    required this.tiposProducto,
    required this.pagination,
  });

  factory TiposProductoResponseDto.fromJson(Map<String, dynamic> json) {
    final tiposProductoJson = json['data'] as List<dynamic>;
    final tiposProducto = tiposProductoJson
        .map((tipoJson) => TipoProductoDto.fromJson(tipoJson as Map<String, dynamic>))
        .toList();

    return TiposProductoResponseDto(
      tiposProducto: tiposProducto,
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  List<TipoProducto> toEntities() {
    return tiposProducto.map((dto) => dto.toEntity()).toList();
  }
}
