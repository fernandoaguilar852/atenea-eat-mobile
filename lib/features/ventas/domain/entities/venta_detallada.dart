import 'venta_pago.dart';
import 'venta_detalle.dart';

class VentaDetallada {
  final int ventaId;
  final int clienteId;
  final int? ordenId;
  final int? operadorId;
  final int? consumidorId;
  final int cajaId;
  final String? formaPago;
  final String? fechaVencimiento;
  final String? codigoVoucher;
  final String subtotalSinImpuestos;
  final String totalDescuentos;
  final String totalImpuestos;
  final String totalIva;
  final String totalInc;
  final String totalIca;
  final String total;
  final String porcentajePropina;
  final String valorPropina;
  final String estado;
  final String observacion;
  final String? tipoDocumento;
  final String? prefijoFactura;
  final String numeroFactura;
  final String fechaEmision;
  final String? cufe;
  final String? qrCode;
  final String? estadoDian;
  final String? dianTrackId;
  final String createdAt;
  final List<VentaPago> pagos;
  final List<VentaDetalle> detalles;

  VentaDetallada({
    required this.ventaId,
    required this.clienteId,
    this.ordenId,
    this.operadorId,
    this.consumidorId,
    required this.cajaId,
    this.formaPago,
    this.fechaVencimiento,
    this.codigoVoucher,
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.totalIva,
    required this.totalInc,
    required this.totalIca,
    required this.total,
    required this.porcentajePropina,
    required this.valorPropina,
    required this.estado,
    required this.observacion,
    this.tipoDocumento,
    this.prefijoFactura,
    required this.numeroFactura,
    required this.fechaEmision,
    this.cufe,
    this.qrCode,
    this.estadoDian,
    this.dianTrackId,
    required this.createdAt,
    required this.pagos,
    required this.detalles,
  });
}
