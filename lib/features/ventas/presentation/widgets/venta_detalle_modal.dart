import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/ventas_provider.dart';

class VentaDetalleModal extends ConsumerWidget {
  const VentaDetalleModal({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ventasProvider);
    final venta = state.ventaDetallada;

    if (venta == null) {
      return Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: const Color(0xFF0d6efd)),
              SizedBox(height: 16.h),
              Text(
                'Cargando detalle...',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    final numberFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 0.85.sh,
          maxWidth: 0.9.sw,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Factura #${venta.numeroFactura}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Estado: ${venta.estado}',
                        style: TextStyle(
                          color: _getEstadoColor(venta.estado),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información general
                    _buildSectionTitle('Información General'),
                    SizedBox(height: 8.h),
                    _buildInfoRow('Fecha de Emisión:', _formatDate(venta.fechaEmision)),
                    _buildInfoRow('Forma de Pago:', venta.formaPago ?? 'N/A'),
                    if (venta.tipoDocumento != null)
                      _buildInfoRow('Tipo de Documento:', venta.tipoDocumento!),
                    if (venta.prefijoFactura != null)
                      _buildInfoRow('Prefijo:', venta.prefijoFactura!),
                    if (venta.observacion.isNotEmpty)
                      _buildInfoRow('Observación:', venta.observacion),

                    SizedBox(height: 16.h),

                    // Detalles de productos
                    _buildSectionTitle('Detalle de Productos'),
                    SizedBox(height: 8.h),
                    ...venta.detalles.map((detalle) {
                      return Card(
                        color: const Color(0xFF2A2A2A),
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detalle.productoNombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cant: ${detalle.cantidad}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    'P.Unit: ${numberFormat.format(double.tryParse(detalle.precioUnitario) ?? 0)}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Desc: ${numberFormat.format(double.tryParse(detalle.descuentoValor) ?? 0)}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    'Total: ${numberFormat.format(double.tryParse(detalle.totalLinea) ?? 0)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: 16.h),

                    // Totales
                    _buildSectionTitle('Resumen de Totales'),
                    SizedBox(height: 8.h),
                    Card(
                      color: const Color(0xFF2A2A2A),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          children: [
                            _buildTotalRow('Subtotal:', venta.subtotalSinImpuestos, false),
                            _buildTotalRow('Descuentos:', venta.totalDescuentos, false),
                            _buildTotalRow('IVA:', venta.totalIva, false),
                            _buildTotalRow('INC:', venta.totalInc, false),
                            _buildTotalRow('ICA:', venta.totalIca, false),
                            _buildTotalRow('Impuestos:', venta.totalImpuestos, false),
                            _buildTotalRow('Propina:', venta.valorPropina, false),
                            Divider(color: Colors.grey[600], height: 16.h),
                            _buildTotalRow('TOTAL:', venta.total, true),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Pagos
                    if (venta.pagos.isNotEmpty) ...[
                      _buildSectionTitle('Medios de Pago'),
                      SizedBox(height: 8.h),
                      ...venta.pagos.map((pago) {
                        return Card(
                          color: const Color(0xFF2A2A2A),
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pago.metodo == null
                                        ? 'Cargando método...'
                                        : pago.metodo == 'Desconocido'
                                            ? 'MÉTODO DESCONOCIDO'
                                            : pago.metodo!.toUpperCase(),
                                      style: TextStyle(
                                        color: pago.metodo == null
                                            ? Colors.grey[500]
                                            : Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (pago.numeroComprobante != null)
                                      Text(
                                        'Comp: ${pago.numeroComprobante}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  numberFormat.format(double.tryParse(pago.valor) ?? 0),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],

                    // Información DIAN
                    if (venta.estadoDian != null) ...[
                      SizedBox(height: 16.h),
                      _buildSectionTitle('Información DIAN'),
                      SizedBox(height: 8.h),
                      _buildInfoRow('Estado DIAN:', venta.estadoDian!),
                      if (venta.cufe != null)
                        _buildInfoRow('CUFE:', venta.cufe!, isSmall: true),
                      if (venta.dianTrackId != null)
                        _buildInfoRow('Track ID:', venta.dianTrackId!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isSmall = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130.w,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 11.sp : 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, bool isBold) {
    final numberFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.grey[400],
              fontSize: isBold ? 16.sp : 13.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            numberFormat.format(double.tryParse(value) ?? 0),
            style: TextStyle(
              color: Colors.white,
              fontSize: isBold ? 16.sp : 13.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
