import '../../domain/entities/encabezado.dart';

class EncabezadoDto {
  final String nombreNegocio;
  final String nit;
  final String? digitoVerificacion;
  final String ciudad;
  final String? departamento;
  final String moneda;
  final String? monedaNombre;

  EncabezadoDto({
    required this.nombreNegocio,
    required this.nit,
    this.digitoVerificacion,
    required this.ciudad,
    this.departamento,
    required this.moneda,
    this.monedaNombre,
  });

  factory EncabezadoDto.fromJson(Map<String, dynamic> json) {
    // Extraer datos de objetos anidados
    final ciudadObj = json['ciudad'] as Map<String, dynamic>?;
    final monedaObj = json['moneda'] as Map<String, dynamic>?;

    return EncabezadoDto(
      nombreNegocio: json['nombre'] as String? ?? json['razonSocial'] as String,
      nit: json['nit'] as String,
      digitoVerificacion: json['digitoVerificacion'] as String?,
      ciudad: ciudadObj?['nombre'] as String? ?? '',
      departamento: ciudadObj?['departamento'] as String?,
      moneda: monedaObj?['simbolo'] as String? ?? '',
      monedaNombre: monedaObj?['nombre'] as String?,
    );
  }

  Encabezado toEntity() {
    return Encabezado(
      nombreNegocio: nombreNegocio,
      nit: nit,
      digitoVerificacion: digitoVerificacion,
      ciudad: ciudad,
      departamento: departamento,
      moneda: moneda,
      monedaNombre: monedaNombre,
    );
  }
}
