import '../../domain/entities/insumo.dart';

class InsumoDto {
  final int insumoId;
  final int clienteId;
  final String nombre;
  final String unidadBase;
  final String stockActual;
  final String stockMinimo;
  final String stockReservado;
  final String costoPromedio;
  final bool activo;
  final String creadoEn;

  InsumoDto({
    required this.insumoId,
    required this.clienteId,
    required this.nombre,
    required this.unidadBase,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockReservado,
    required this.costoPromedio,
    required this.activo,
    required this.creadoEn,
  });

  factory InsumoDto.fromJson(Map<String, dynamic> json) {
    return InsumoDto(
      insumoId: json['insumoId'] as int,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String,
      unidadBase: json['unidadBase'] as String,
      stockActual: json['stockActual'] as String,
      stockMinimo: json['stockMinimo'] as String,
      stockReservado: json['stockReservado'] as String,
      costoPromedio: json['costoPromedio'] as String,
      activo: json['activo'] as bool,
      creadoEn: json['creadoEn'] as String,
    );
  }

  Insumo toEntity() {
    return Insumo(
      insumoId: insumoId,
      clienteId: clienteId,
      nombre: nombre,
      unidadBase: unidadBase,
      stockActual: double.tryParse(stockActual) ?? 0.0,
      stockMinimo: double.tryParse(stockMinimo) ?? 0.0,
      stockReservado: double.tryParse(stockReservado) ?? 0.0,
      costoPromedio: double.tryParse(costoPromedio) ?? 0.0,
      activo: activo,
      creadoEn: creadoEn,
    );
  }
}
