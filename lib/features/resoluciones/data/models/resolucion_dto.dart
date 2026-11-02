import '../../domain/entities/resolucion.dart';

class ResolucionDto {
  final int resolucionId;
  final int clienteId;
  final String prefijo;
  final int numeroDesde;
  final int numeroHasta;
  final int numeroActual;
  final String numeroResolucion;
  final String fechaResolucion;
  final String fechaVencimiento;
  final bool activo;
  final String createdAt;

  const ResolucionDto({
    required this.resolucionId,
    required this.clienteId,
    required this.prefijo,
    required this.numeroDesde,
    required this.numeroHasta,
    required this.numeroActual,
    required this.numeroResolucion,
    required this.fechaResolucion,
    required this.fechaVencimiento,
    required this.activo,
    required this.createdAt,
  });

  factory ResolucionDto.fromJson(Map<String, dynamic> json) {
    return ResolucionDto(
      resolucionId: json['resolucionId'] as int,
      clienteId: json['clienteId'] as int,
      prefijo: json['prefijo'] as String,
      numeroDesde: json['numeroDesde'] as int,
      numeroHasta: json['numeroHasta'] as int,
      numeroActual: json['numeroActual'] as int,
      numeroResolucion: json['numeroResolucion'] as String,
      fechaResolucion: json['fechaResolucion'] as String,
      fechaVencimiento: json['fechaVencimiento'] as String,
      activo: json['activo'] as bool,
      createdAt: json['createdAt'] as String,
    );
  }

  Resolucion toEntity() {
    return Resolucion(
      resolucionId: resolucionId,
      clienteId: clienteId,
      prefijo: prefijo,
      numeroDesde: numeroDesde,
      numeroHasta: numeroHasta,
      numeroActual: numeroActual,
      numeroResolucion: numeroResolucion,
      fechaResolucion: fechaResolucion,
      fechaVencimiento: fechaVencimiento,
      activo: activo,
      createdAt: createdAt,
    );
  }
}
