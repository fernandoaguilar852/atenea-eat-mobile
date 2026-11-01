import '../../domain/entities/venta_detallada.dart';
import 'venta_pago_dto.dart';
import 'venta_detalle_dto.dart';

class VentaDetalladaDto {
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
  final List<VentaPagoDto> pagos;
  final List<VentaDetalleDto> detalles;

  VentaDetalladaDto({
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

  factory VentaDetalladaDto.fromJson(Map<String, dynamic> json) {
    return VentaDetalladaDto(
      ventaId: json['ventaId'] as int,
      clienteId: json['clienteId'] as int,
      ordenId: json['ordenId'] as int?,
      operadorId: json['operadorId'] as int?,
      consumidorId: json['consumidorId'] as int?,
      cajaId: json['cajaId'] as int,
      formaPago: json['formaPago'] as String?,
      fechaVencimiento: json['fechaVencimiento'] as String?,
      codigoVoucher: json['codigoVoucher'] as String?,
      subtotalSinImpuestos: json['subtotalSinImpuestos'] as String,
      totalDescuentos: json['totalDescuentos'] as String,
      totalImpuestos: json['totalImpuestos'] as String,
      totalIva: json['totalIva'] as String,
      totalInc: json['totalInc'] as String,
      totalIca: json['totalIca'] as String,
      total: json['total'] as String,
      porcentajePropina: json['porcentajePropina'] as String,
      valorPropina: json['valorPropina'] as String,
      estado: json['estado'] as String,
      observacion: json['observacion'] as String,
      tipoDocumento: json['tipoDocumento'] as String?,
      prefijoFactura: json['prefijoFactura'] as String?,
      numeroFactura: json['numeroFactura'] as String,
      fechaEmision: json['fechaEmision'] as String,
      cufe: json['cufe'] as String?,
      qrCode: json['qrCode'] as String?,
      estadoDian: json['estadoDian'] as String?,
      dianTrackId: json['dianTrackId'] as String?,
      createdAt: json['createdAt'] as String,
      pagos: (json['pagos'] as List<dynamic>)
          .map((e) => VentaPagoDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      detalles: (json['detalles'] as List<dynamic>)
          .map((e) => VentaDetalleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  VentaDetallada toEntity() {
    return VentaDetallada(
      ventaId: ventaId,
      clienteId: clienteId,
      ordenId: ordenId,
      operadorId: operadorId,
      consumidorId: consumidorId,
      cajaId: cajaId,
      formaPago: formaPago,
      fechaVencimiento: fechaVencimiento,
      codigoVoucher: codigoVoucher,
      subtotalSinImpuestos: subtotalSinImpuestos,
      totalDescuentos: totalDescuentos,
      totalImpuestos: totalImpuestos,
      totalIva: totalIva,
      totalInc: totalInc,
      totalIca: totalIca,
      total: total,
      porcentajePropina: porcentajePropina,
      valorPropina: valorPropina,
      estado: estado,
      observacion: observacion,
      tipoDocumento: tipoDocumento,
      prefijoFactura: prefijoFactura,
      numeroFactura: numeroFactura,
      fechaEmision: fechaEmision,
      cufe: cufe,
      qrCode: qrCode,
      estadoDian: estadoDian,
      dianTrackId: dianTrackId,
      createdAt: createdAt,
      pagos: pagos.map((dto) => dto.toEntity()).toList(),
      detalles: detalles.map((dto) => dto.toEntity()).toList(),
    );
  }
}
