import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/ventas_provider.dart';
import '../widgets/venta_detalle_modal.dart';

class VentasScreen extends ConsumerStatefulWidget {
  const VentasScreen({super.key});

  @override
  ConsumerState<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends ConsumerState<VentasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ventasProvider.notifier).loadVentas();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getFormaPagoColor(String formaPago) {
    switch (formaPago.toLowerCase()) {
      case 'efectivo':
        return const Color(0xFF198754);
      case 'transferencia':
        return const Color(0xFF0d6efd);
      case 'varios':
        return const Color(0xFFffc107);
      default:
        return const Color(0xFF6c757d);
    }
  }

  void _showVentaDetalle(int ventaId) async {
    await ref.read(ventasProvider.notifier).loadVentaDetalle(ventaId: ventaId);

    final state = ref.read(ventasProvider);

    if (state.ventaDetallada != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => VentaDetalleModal(
          venta: state.ventaDetallada!,
        ),
      ).then((_) {
        ref.read(ventasProvider.notifier).clearVentaDetalle();
      });
    } else if (state.errorDetail != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar detalle: ${state.errorDetail}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ventasProvider);
    final ventas = state.ventasResponse?.ventas ?? [];
    final pagination = state.ventasResponse?.pagination;

    return Container(
      color: Colors.black,
      child: state.isLoading && state.ventasResponse == null
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF0d6efd),
              ),
            )
          : state.error != null && state.ventasResponse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error al cargar ventas',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.error!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFB0B0B0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(ventasProvider.notifier).loadVentas();
                        },
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : ventas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80.sp,
                            color: const Color(0xFF808080).withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No hay ventas disponibles',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFFB0B0B0),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Lista de ventas
                          ...ventas.map((venta) {
                            final estadoColor = _getEstadoColor(venta.estado);
                            final formaPagoColor = _getFormaPagoColor(venta.formaPago ?? 'N/A');

                              return InkWell(
                                onTap: () => _showVentaDetalle(venta.ventaId),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Card(
                                  color: const Color(0xFF1a1a1a),
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: const Color(0xFF404040),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header: Número de factura y estado
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.receipt,
                                            color: const Color(0xFF0d6efd),
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${venta.prefijoFactura ?? ''}-${venta.numeroFactura}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: estadoColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4.r),
                                              border: Border.all(color: estadoColor, width: 1),
                                            ),
                                            child: Text(
                                              venta.estado.toUpperCase(),
                                              style: TextStyle(
                                                color: estadoColor,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),

                                      // Cliente
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16.sp,
                                            color: const Color(0xFF808080),
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              venta.consumidor?.nombreRazonSocial ?? 'Sin consumidor',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),

                                      // Forma de pago y total
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: formaPagoColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.payment,
                                                  size: 14.sp,
                                                  color: formaPagoColor,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  (venta.formaPago ?? 'N/A').toUpperCase(),
                                                  style: TextStyle(
                                                    color: formaPagoColor,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            '\$${double.parse(venta.total).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: const Color(0xFF0d6efd),
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),

                                      // Fecha
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14.sp,
                                            color: const Color(0xFF808080),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            _formatDate(venta.fechaEmision),
                                            style: TextStyle(
                                              color: const Color(0xFF808080),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                          }),

                          // Paginación
                          if (pagination != null) ...[
                            SizedBox(height: 16.h),
                            Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a1a),
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFF404040),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: state.currentPage > 1
                                      ? () {
                                          final newPage = state.currentPage - 1;
                                          ref.read(ventasProvider.notifier).loadVentas(pageNumber: newPage);
                                        }
                                      : null,
                                  icon: Icon(Icons.chevron_left, size: 20.sp),
                                  label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: state.currentPage > 1
                                        ? const Color(0xFF0d6efd)
                                        : const Color(0xFF6c757d),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  ),
                                ),
                                Text(
                                  'Página ${state.currentPage} de ${(pagination.totalElement / 20).ceil()}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: pagination.hasMoreElements
                                      ? () {
                                          final newPage = state.currentPage + 1;
                                          ref.read(ventasProvider.notifier).loadVentas(pageNumber: newPage);
                                        }
                                      : null,
                                  label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                                  icon: Icon(Icons.chevron_right, size: 20.sp),
                                  style: TextButton.styleFrom(
                                    foregroundColor: pagination.hasMoreElements
                                        ? const Color(0xFF0d6efd)
                                        : const Color(0xFF6c757d),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
    );
  }
}
