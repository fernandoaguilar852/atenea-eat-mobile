import '../../domain/entities/operador.dart';
import 'pagination_dto.dart';

class OperadorDto {
  final int operadorId;
  final int clienteId;
  final String nombre;
  final String? numeroDocumento;
  final String? telefono;
  final bool tienePin;
  final bool activo;
  final String createdAt;

  OperadorDto({
    required this.operadorId,
    required this.clienteId,
    required this.nombre,
    this.numeroDocumento,
    this.telefono,
    required this.tienePin,
    required this.activo,
    required this.createdAt,
  });

  factory OperadorDto.fromJson(Map<String, dynamic> json) {
    return OperadorDto(
      operadorId: json['operadorId'] as int,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String,
      numeroDocumento: json['numeroDocumento'] as String?,
      telefono: json['telefono'] as String?,
      tienePin: json['tienePin'] as bool,
      activo: json['activo'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Operador toEntity() {
    return Operador(
      operadorId: operadorId,
      clienteId: clienteId,
      nombre: nombre,
      numeroDocumento: numeroDocumento,
      telefono: telefono,
      tienePin: tienePin,
      activo: activo,
      createdAt: createdAt,
    );
  }
}

class OperadoresResponseDto {
  final List<OperadorDto> operadores;
  final PaginationDto pagination;

  OperadoresResponseDto({
    required this.operadores,
    required this.pagination,
  });

  factory OperadoresResponseDto.fromJson(Map<String, dynamic> json) {
    final operadoresJson = (json['data']['operadores'] as List<dynamic>);
    final operadores = operadoresJson
        .map((operadorJson) => OperadorDto.fromJson(operadorJson as Map<String, dynamic>))
        .toList();

    return OperadoresResponseDto(
      operadores: operadores,
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  List<Operador> toEntities() {
    return operadores.map((dto) => dto.toEntity()).toList();
  }
}
