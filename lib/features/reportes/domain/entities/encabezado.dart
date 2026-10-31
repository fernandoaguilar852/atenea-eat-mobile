import 'package:equatable/equatable.dart';

/// Encabezado común para todos los reportes
/// Contiene información del negocio
class Encabezado extends Equatable {
  final String nombreNegocio;
  final String nit;
  final String? digitoVerificacion;
  final String ciudad;
  final String? departamento;
  final String moneda;
  final String? monedaNombre;

  const Encabezado({
    required this.nombreNegocio,
    required this.nit,
    this.digitoVerificacion,
    required this.ciudad,
    this.departamento,
    required this.moneda,
    this.monedaNombre,
  });

  @override
  List<Object?> get props => [
        nombreNegocio,
        nit,
        digitoVerificacion,
        ciudad,
        departamento,
        moneda,
        monedaNombre,
      ];
}
