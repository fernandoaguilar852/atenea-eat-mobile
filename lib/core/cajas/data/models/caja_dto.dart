import '../../domain/entities/caja.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'cajaId': cajaId,
      'clienteId': clienteId,
      'usuarioId': usuarioId,
      'estado': estado,
      'fecha': fecha,
      'saldoInicial': saldoInicial,
      'openedAt': openedAt,
      'closedAt': closedAt,
    };
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
