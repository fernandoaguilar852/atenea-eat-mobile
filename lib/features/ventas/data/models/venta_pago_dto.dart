import '../../domain/entities/venta_pago.dart';

class VentaPagoDto {
  final int ventaPagoId;
  final int ventaId;
  final int pagoId;
  final String valor;
  final String? numeroComprobante;
  final int? bancoId;
  final String createdAt;

  VentaPagoDto({
    required this.ventaPagoId,
    required this.ventaId,
    required this.pagoId,
    required this.valor,
    this.numeroComprobante,
    this.bancoId,
    required this.createdAt,
  });

  factory VentaPagoDto.fromJson(Map<String, dynamic> json) {
    return VentaPagoDto(
      ventaPagoId: json['ventaPagoId'] as int,
      ventaId: json['ventaId'] as int,
      pagoId: json['pagoId'] as int,
      valor: json['valor'] as String,
      numeroComprobante: json['numeroComprobante'] as String?,
      bancoId: json['bancoId'] as int?,
      createdAt: json['createdAt'] as String,
    );
  }

  VentaPago toEntity() {
    return VentaPago(
      ventaPagoId: ventaPagoId,
      ventaId: ventaId,
      pagoId: pagoId,
      valor: valor,
      numeroComprobante: numeroComprobante,
      bancoId: bancoId,
      createdAt: createdAt,
    );
  }
}
