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
    final bajoPorDebajo = porcentajeStockMinimo < 100;

    Color getStatusColor() {
      if (!insumo.activo) return const Color(0xFF6c757d);
      if (bajoPorDebajo) {
        if (porcentajeStockMinimo <= 50) return const Color(0xFFdc3545);
        return const Color(0xFFffc107);
      }
      return const Color(0xFF198754);
    }

    String getStatusText() {
      if (!insumo.activo) return 'Inactivo';
      if (bajoPorDebajo) {
        if (porcentajeStockMinimo <= 50) return 'Stock Crítico';
        return 'Stock Bajo';
      }
      return 'Stock Normal';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estado
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    insumo.activo ? Icons.science : Icons.block,
                    color: getStatusColor(),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insumo.nombre,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: getStatusColor(),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          getStatusText(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Unidad base
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d6efd).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF0d6efd),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    insumo.unidadBase.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0d6efd),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Stock actual y mínimo
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.inventory_2,
                        label: 'Stock Actual',
                        value: numberFormat.format(insumo.stockActual),
                        color: const Color(0xFF17a2b8),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.warning_amber,
                        label: 'Stock Mínimo',
                        value: numberFormat.format(insumo.stockMinimo),
                        color: const Color(0xFFffc107),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Stock reservado y disponible
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.lock,
                        label: 'Reservado',
                        value: numberFormat.format(insumo.stockReservado),
                        color: const Color(0xFF6610f2),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.check_circle,
                        label: 'Disponible',
                        value: numberFormat.format(stockDisponible),
                        color: const Color(0xFF198754),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Barra de progreso del stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nivel de Stock',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${porcentajeStockMinimo.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: (porcentajeStockMinimo / 100).clamp(0.0, 1.0),
                        minHeight: 8.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          porcentajeStockMinimo <= 50
                              ? const Color(0xFFdc3545)
                              : porcentajeStockMinimo < 100
                                  ? const Color(0xFFffc107)
                                  : const Color(0xFF198754),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Costo promedio
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF404040),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: const Color(0xFF28a745),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Costo Promedio: ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '\$${numberFormat.format(insumo.costoPromedio)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF28a745),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF363636),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Botón Editar
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
                // Botón Eliminar
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
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
