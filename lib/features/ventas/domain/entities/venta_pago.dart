class VentaPago {
  final int ventaPagoId;
  final int ventaId;
  final int pagoId;
  final String valor;
  final String? numeroComprobante;
  final int? bancoId;
  final String createdAt;
  final String? metodo; // Método de pago obtenido del servicio de pagos

  VentaPago({
    required this.ventaPagoId,
    required this.ventaId,
    required this.pagoId,
    required this.valor,
    this.numeroComprobante,
    this.bancoId,
    required this.createdAt,
    this.metodo,
  });
}
