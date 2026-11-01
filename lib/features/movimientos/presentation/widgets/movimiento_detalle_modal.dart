import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/movimientos_provider.dart';
import '../../domain/entities/movimiento_detalle.dart';
import '../screens/editar_movimiento_form_screen.dart';

class MovimientoDetalleModal extends ConsumerStatefulWidget {
  final int movimientoId;

  const MovimientoDetalleModal({
    super.key,
    required this.movimientoId,
  });

  @override
  ConsumerState<MovimientoDetalleModal> createState() => _MovimientoDetalleModalState();
}

class _MovimientoDetalleModalState extends ConsumerState<MovimientoDetalleModal> {
  MovimientoDetalle? _detalle;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        setState(() {
          _error = 'No se encontró el cliente ID';
          _isLoading = false;
        });
        return;
      }

      final useCase = ref.read(getMovimientoDetalleUseCaseProvider);
      final detalle = await useCase(
        movimientoId: widget.movimientoId,
        clienteId: clienteId,
      );

      setState(() {
        _detalle = detalle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _mostrarAlertaTipoVenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFFffc107), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: const Color(0xFFffc107), size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Acción no permitida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Los movimientos de tipo VENTA no se pueden editar ni eliminar.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFffc107),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Entendido',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: const Color(0xFFdc3545), width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: const Color(0xFFdc3545), size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Confirmar Eliminación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar este movimiento?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFF404040)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _detalle?.nombre ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tipo: ${_detalle?.tipo.toUpperCase() ?? ''} | Cantidad: ${_detalle?.cantidad ?? 0}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Motivo de eliminación *',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            TextField(
              controller: motivoController,
              maxLines: 2,
              style: TextStyle(color: Colors.white, fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Ingresa el motivo de la eliminación...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12.sp),
                filled: true,
                fillColor: const Color(0xFF2a2a2a),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: const Color(0xFF404040)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: BorderSide(color: const Color(0xFFdc3545)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                isDense: true,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: const Color(0xFFdc3545),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              motivoController.dispose();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validar que se ingresó un motivo
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor ingresa el motivo de la eliminación'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop(); // Cerrar diálogo de confirmación

              try {
                // Obtener usuarioId del authProvider
                final authState = ref.read(authProvider);
                final usuarioId = authState.user?.usuarioId;
                final clienteId = authState.user?.clienteId;

                if (usuarioId == null || clienteId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: Usuario no identificado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  motivoController.dispose();
                  return;
                }

                // Mostrar indicador de carga
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(color: const Color(0xFFdc3545)),
                  ),
                );

                // Llamar al API de eliminación
                final useCase = ref.read(eliminarMovimientoUseCaseProvider);
                await useCase(
                  movimientoId: _detalle!.movimientoId,
                  clienteId: clienteId,
                  deletedByUsuarioId: usuarioId,
                  deleteReason: motivoController.text.trim(),
                );

                motivoController.dispose();

                // Cerrar indicador de carga
                Navigator.of(context).pop();

                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Movimiento eliminado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Cerrar modal de detalle y recargar lista
                Navigator.pop(context);
                ref.read(movimientosProvider.notifier).loadMovimientos();
              } catch (e) {
                motivoController.dispose();

                // Cerrar indicador de carga si está abierto
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFdc3545),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF0d6efd), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0d6efd),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Detalle de Movimiento',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                    iconSize: 20.sp,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Contenido
            Flexible(
              child: _isLoading
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.h),
                        child: CircularProgressIndicator(color: const Color(0xFF0d6efd)),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              'Error: $_error',
                              style: TextStyle(color: Colors.red, fontSize: 14.sp),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _detalle != null
                          ? SingleChildScrollView(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre e ID
                                  _buildSection(
                                    title: _detalle!.nombre,
                                    subtitle: 'ID: ${_detalle!.movimientoId}',
                                    icon: _detalle!.productoId != null ? Icons.inventory_2 : Icons.science,
                                    iconColor: _detalle!.tipo == 'entrada' ? Colors.green : Colors.red,
                                  ),
                                  SizedBox(height: 16.h),

                                  // Tipo y Cantidad
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Tipo',
                                          value: _detalle!.tipo.toUpperCase(),
                                          color: _detalle!.tipo == 'entrada' ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Cantidad',
                                          value: '${_detalle!.cantidad}',
                                          color: const Color(0xFF0d6efd),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // Costo e Impuesto
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Costo',
                                          value: '\$${_detalle!.costo.toStringAsFixed(2)}',
                                          color: Colors.orange,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Impuesto',
                                          value: '\$${_detalle!.impuesto.toStringAsFixed(2)}',
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // Descuento y Proveedor
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Descuento',
                                          value: '\$${_detalle!.descuentoUnidad.toStringAsFixed(2)}',
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: _buildInfoCard(
                                          label: 'Proveedor ID',
                                          value: _detalle!.proveedorId?.toString() ?? 'N/A',
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // Fecha
                                  _buildInfoCard(
                                    label: 'Fecha',
                                    value: _formatDate(_detalle!.fecha),
                                    color: const Color(0xFF0d6efd),
                                  ),
                                  SizedBox(height: 12.h),

                                  // Observación
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2a2a2a),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: const Color(0xFF404040)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Observación',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          _detalle!.observacion,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),

                                  // Timestamps
                                  _buildInfoCard(
                                    label: 'Creado',
                                    value: _formatDateTime(_detalle!.createdAt),
                                    color: Colors.grey,
                                  ),
                                  if (_detalle!.updatedAt != null) ...[
                                    SizedBox(height: 12.h),
                                    _buildInfoCard(
                                      label: 'Actualizado',
                                      value: _formatDateTime(_detalle!.updatedAt!),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                'No se encontró información',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14.sp),
                              ),
                            ),
            ),

            // Botones de acción
            if (_detalle != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  border: Border(
                    top: BorderSide(color: const Color(0xFF404040), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Validar si es tipo venta
                          if (_detalle!.tipo.toLowerCase() == 'venta') {
                            _mostrarAlertaTipoVenta(context);
                            return;
                          }

                          // Cerrar el modal de detalle
                          Navigator.pop(context);

                          // Abrir formulario de edición
                          final resultado = await showDialog(
                            context: context,
                            builder: (context) => EditarMovimientoFormScreen(
                              detalle: _detalle!,
                            ),
                          );

                          // Si se actualizó, recargar la lista y el detalle
                          if (resultado == true && mounted) {
                            ref.read(movimientosProvider.notifier).loadMovimientos();
                            _loadDetalle(); // Recargar detalle en el modal
                          }
                        },
                        icon: Icon(Icons.edit, size: 18.sp),
                        label: Text('Editar', style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFffc107),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Validar si es tipo venta
                          if (_detalle!.tipo.toLowerCase() == 'venta') {
                            _mostrarAlertaTipoVenta(context);
                            return;
                          }

                          _mostrarDialogoEliminar(context);
                        },
                        icon: Icon(Icons.delete, size: 18.sp),
                        label: Text('Eliminar', style: TextStyle(fontSize: 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFdc3545),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
