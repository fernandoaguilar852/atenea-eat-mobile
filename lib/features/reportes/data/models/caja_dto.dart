import '../../domain/entities/caja.dart';
import 'pagination_dto.dart';

class CajaDto {
  final int cajaId;
  final int clienteId;
  final int usuarioId;
  final String estado;
  final String fecha;
  final String saldoInicial;
  final String openedAt;
  final String? closedAt;

  CajaDto({
    required this.cajaId,
    required this.clienteId,
    required this.usuarioId,
    required this.estado,
    required this.fecha,
    required this.saldoInicial,
    required this.openedAt,
    this.closedAt,
  });

  factory CajaDto.fromJson(Map<String, dynamic> json) {
    return CajaDto(
      cajaId: json['cajaId'] as int,
      clienteId: json['clienteId'] as int,
      usuarioId: json['usuarioId'] as int,
      estado: json['estado'] as String,
      fecha: json['fecha'] as String,
      saldoInicial: json['saldoInicial'] as String,
      openedAt: json['openedAt'] as String,
      closedAt: json['closedAt'] as String?,
    );
  }

  Caja toEntity() {
    return Caja(
      cajaId: cajaId,
      clienteId: clienteId,
      usuarioId: usuarioId,
      estado: estado,
      fecha: fecha,
      saldoInicial: saldoInicial,
      openedAt: openedAt,
      closedAt: closedAt,
    );
  }
}

class CajasResponseDto {
  final List<CajaDto> cajas;
  final PaginationDto pagination;

  CajasResponseDto({
    required this.cajas,
    required this.pagination,
  });

  factory CajasResponseDto.fromJson(Map<String, dynamic> json) {
    final cajasJson = (json['data']['cajas'] as List<dynamic>);
    final cajas = cajasJson
        .map((cajaJson) => CajaDto.fromJson(cajaJson as Map<String, dynamic>))
        .toList();

    return CajasResponseDto(
      cajas: cajas,
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  List<Caja> toEntities() {
    return cajas.map((dto) => dto.toEntity()).toList();
  }
}
