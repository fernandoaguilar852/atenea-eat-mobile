import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/insumo.dart';

class InsumoCard extends StatelessWidget {
  final Insumo insumo;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InsumoCard({
    super.key,
    required this.insumo,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##0.00', 'es_ES');
    final stockDisponible = insumo.stockActual - insumo.stockReservado;
    final porcentajeStockMinimo = insumo.stockMinimo > 0
        ? (insumo.stockActual / insumo.stockMinimo) * 100
        : 100.0;
    final stockBajo = stockDisponible <= insumo.stockMinimo;
    final stockPercentage = insumo.stockMinimo > 0
        ? (insumo.stockActual / insumo.stockMinimo).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // Fila principal: Icono + Información
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del insumo (izquierda)
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  child: Icon(
                    Icons.science,
                    color: const Color(0xFF0d6efd),
                    size: 30.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // Información del insumo (derecha)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        insumo.nombre,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // Unidad base
                      Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            size: 12.sp,
                            color: const Color(0xFF0d6efd),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Unidad: ${insumo.unidadBase.toUpperCase()}',
                            style: TextStyle(
                              color: const Color(0xFF0d6efd),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Costo promedio
                      Text(
                        'Costo: \$${numberFormat.format(insumo.costoPromedio)}',
                        style: TextStyle(
                          color: const Color(0xFF28a745),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // Stock disponible con cálculo visible
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 14.sp,
                            color: stockBajo ? Colors.orange : Colors.green,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Disponible: ${numberFormat.format(insumo.stockActual)} - ${numberFormat.format(insumo.stockReservado)} = ${numberFormat.format(stockDisponible)}',
                              style: TextStyle(
                                color: stockBajo ? Colors.orange : Colors.green,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Stock reservado y mínimo
                      Padding(
                        padding: EdgeInsets.only(left: 18.w),
                        child: Row(
                          children: [
                            Text(
                              'Reservado: ${numberFormat.format(insumo.stockReservado)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Mínimo: ${numberFormat.format(insumo.stockMinimo)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Barra de progreso del stock con porcentaje
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: stockPercentage,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStockColor(stockPercentage),
                              ),
                              minHeight: 3.h,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${porcentajeStockMinimo.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: _getStockColor(stockPercentage),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Estado
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: insumo.activo
                                  ? const Color(0xFF198754).withValues(alpha: 0.2)
                                  : const Color(0xFFdc3545).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: insumo.activo
                                    ? const Color(0xFF198754)
                                    : const Color(0xFFdc3545),
                              ),
                            ),
                            child: Text(
                              insumo.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: insumo.activo
                                    ? const Color(0xFF198754)
                                    : const Color(0xFFdc3545),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Botones de acción (debajo de todo)
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: Text('Editar', style: TextStyle(fontSize: 13.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFffc107),
                      side: const BorderSide(color: Color(0xFFffc107)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, size: 18.sp),
                    label: Text('Eliminar', style: TextStyle(fontSize: 13.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFdc3545),
                      side: const BorderSide(color: Color(0xFFdc3545)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor(double percentage) {
    if (percentage <= 0.3) {
      return const Color(0xFFdc3545); // Rojo
    } else if (percentage <= 0.6) {
      return const Color(0xFFffc107); // Amarillo
    } else {
      return const Color(0xFF198754); // Verde
    }
  }
}
