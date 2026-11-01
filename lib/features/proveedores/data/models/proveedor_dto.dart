import '../../domain/entities/proveedor.dart';

class ProveedorDto {
  final int proveedorId;
  final int clienteId;
  final String nombre;
  final String razonSocial;
  final String nit;
  final String digitoVerificacion;
  final String tipoPersona;
  final String regimen;
  final String codigoCiiu;
  final String telefono;
  final String email;
  final String direccion;
  final int ciudadId;
  final String codigoPostal;
  final int plazoPagoDias;
  final String contactoPrincipal;
  final bool activo;
  final String createdAt;

  ProveedorDto({
    required this.proveedorId,
    required this.clienteId,
    required this.nombre,
    required this.razonSocial,
    required this.nit,
    required this.digitoVerificacion,
    required this.tipoPersona,
    required this.regimen,
    required this.codigoCiiu,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.ciudadId,
    required this.codigoPostal,
    required this.plazoPagoDias,
    required this.contactoPrincipal,
    required this.activo,
    required this.createdAt,
  });

  factory ProveedorDto.fromJson(Map<String, dynamic> json) {
    return ProveedorDto(
      proveedorId: json['proveedorId'] as int,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String? ?? '',
      razonSocial: json['razonSocial'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
      digitoVerificacion: json['digitoVerificacion'] as String? ?? '',
      tipoPersona: json['tipoPersona'] as String? ?? '',
      regimen: json['regimen'] as String? ?? '',
      codigoCiiu: json['codigoCiiu'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['email'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      ciudadId: json['ciudadId'] as int? ?? 0,
      codigoPostal: json['codigoPostal'] as String? ?? '',
      plazoPagoDias: json['plazoPagoDias'] as int? ?? 0,
      contactoPrincipal: json['contactoPrincipal'] as String? ?? '',
      activo: json['activo'] as bool? ?? true,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Proveedor toEntity() {
    return Proveedor(
      proveedorId: proveedorId,
      clienteId: clienteId,
      nombre: nombre,
      razonSocial: razonSocial,
      nit: nit,
      digitoVerificacion: digitoVerificacion,
      tipoPersona: tipoPersona,
      regimen: regimen,
      codigoCiiu: codigoCiiu,
      telefono: telefono,
      email: email,
      direccion: direccion,
      ciudadId: ciudadId,
      codigoPostal: codigoPostal,
      plazoPagoDias: plazoPagoDias,
      contactoPrincipal: contactoPrincipal,
      activo: activo,
      createdAt: createdAt,
    );
  }
}
