import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../insumos/domain/entities/insumo.dart';
import 'entrada_insumo_form_screen.dart';
import 'salida_insumo_form_screen.dart';

class InsumoDetailScreen extends StatelessWidget {
  final Insumo insumo;

  const InsumoDetailScreen({
    super.key,
    required this.insumo,
  });

  @override
  Widget build(BuildContext context) {
    final stockDisponible = insumo.stockActual - insumo.stockReservado;
    final stockBajo = stockDisponible <= insumo.stockMinimo;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_outlined,
                  color: const Color(0xFF0d6efd),
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Detalle del Insumo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                  iconSize: 24.sp,
                ),
              ],
            ),
          ),

          // Contenido
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono del insumo
                  Center(
                    child: Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFF404040),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_outlined,
                        color: const Color(0xFF0d6efd),
                        size: 80.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Nombre del insumo
                  Text(
                    insumo.nombre,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Unidad: ${insumo.unidadBase}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Información de stock
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFF404040),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildStockRow(
                          'Stock Actual',
                          '${insumo.stockActual.toStringAsFixed(2)} ${insumo.unidadBase}',
                          const Color(0xFF0d6efd),
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.1), height: 24.h),
                        _buildStockRow(
                          'Stock Reservado',
                          '${insumo.stockReservado.toStringAsFixed(2)} ${insumo.unidadBase}',
                          Colors.orange,
                        ),
                        Divider(color: Colors.white.withValues(alpha: 0.1), height: 24.h),
                        _buildStockRow(
                          'Stock Disponible',
                          '${stockDisponible.toStringAsFixed(2)} ${insumo.unidadBase}',
                          stockBajo ? Colors.red : Colors.green,
                        ),
                        if (stockBajo) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, color: Colors.orange, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Stock bajo (mínimo: ${insumo.stockMinimo.toStringAsFixed(2)})',
                                  style: TextStyle(color: Colors.orange, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => EntradaInsumoFormScreen(insumo: insumo),
                            );

                            // Si se registró exitosamente, cerrar el detalle e indicar que se debe recargar
                            if (result == true) {
                              Navigator.pop(context, true);
                            }
                          },
                          icon: Icon(Icons.add_circle_outline, size: 20.sp),
                          label: Text('Entrada', style: TextStyle(fontSize: 14.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF198754),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => SalidaInsumoFormScreen(insumo: insumo),
                            );

                            // Si se registró exitosamente, cerrar el detalle e indicar que se debe recargar
                            if (result == true) {
                              Navigator.pop(context, true);
                            }
                          },
                          icon: Icon(Icons.remove_circle_outline, size: 20.sp),
                          label: Text('Salida', style: TextStyle(fontSize: 14.sp)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFdc3545),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
