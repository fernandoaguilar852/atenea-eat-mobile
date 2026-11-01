import '../../domain/entities/consumidor.dart';

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
  final String createdAt;

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
    required this.createdAt,
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
      createdAt: json['createdAt'] as String,
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
      createdAt: createdAt,
    );
  }
}
