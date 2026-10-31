import '../../domain/entities/insumo.dart';
import 'pagination_dto.dart';

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
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      stockReservado: stockReservado,
      costoPromedio: costoPromedio,
      activo: activo,
      creadoEn: creadoEn,
    );
  }
}

class InsumosResponseDto {
  final List<InsumoDto> insumos;
  final PaginationDto pagination;

  InsumosResponseDto({
    required this.insumos,
    required this.pagination,
  });

  factory InsumosResponseDto.fromJson(Map<String, dynamic> json) {
    final insumosJson = (json['data'] as List<dynamic>);
    final insumos = insumosJson
        .map((insumoJson) => InsumoDto.fromJson(insumoJson as Map<String, dynamic>))
        .toList();

    return InsumosResponseDto(
      insumos: insumos,
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  List<Insumo> toEntities() {
    return insumos.map((dto) => dto.toEntity()).toList();
  }
}
