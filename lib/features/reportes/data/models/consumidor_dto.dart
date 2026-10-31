import '../../domain/entities/consumidor.dart';
import '../../domain/entities/consumidores_response.dart';
import 'pagination_dto.dart';

class ConsumidorDto {
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
  final String creadoEn;

  ConsumidorDto({
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
    required this.creadoEn,
  });

  factory ConsumidorDto.fromJson(Map<String, dynamic> json) {
    return ConsumidorDto(
      consumidorId: json['consumidorId'] as int,
      clienteId: json['clienteId'] as int,
      tipoIdentificacion: json['tipoIdentificacion'] as String,
      numeroIdentificacion: json['numeroIdentificacion'] as String,
      digitoVerificacion: json['digitoVerificacion'] as String?,
      nombreRazonSocial: json['nombreRazonSocial'] as String,
      direccion: json['direccion'] as String?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      ciudadId: json['ciudadId'] as int?,
      activo: json['activo'] as bool,
      creadoEn: json['creadoEn'] as String,
    );
  }

  Consumidor toEntity() {
    return Consumidor(
      consumidorId: consumidorId,
      clienteId: clienteId,
      tipoIdentificacion: tipoIdentificacion,
      numeroIdentificacion: numeroIdentificacion,
      digitoVerificacion: digitoVerificacion,
      nombreRazonSocial: nombreRazonSocial,
      direccion: direccion,
      email: email,
      telefono: telefono,
      ciudadId: ciudadId,
      activo: activo,
      creadoEn: creadoEn,
    );
  }
}

class ConsumidoresResponseDto {
  final List<ConsumidorDto> consumidores;
  final PaginationDto pagination;

  ConsumidoresResponseDto({
    required this.consumidores,
    required this.pagination,
  });

  factory ConsumidoresResponseDto.fromJson(Map<String, dynamic> json) {
    final consumidoresJson = json['data'] as List<dynamic>;
    final consumidores = consumidoresJson
        .map((consumidorJson) => ConsumidorDto.fromJson(consumidorJson as Map<String, dynamic>))
        .toList();

    return ConsumidoresResponseDto(
      consumidores: consumidores,
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  ConsumidoresResponse toEntity() {
    return ConsumidoresResponse(
      consumidores: consumidores.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
