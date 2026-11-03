import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/producto.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stockPercentage = producto.stockMinimo > 0
        ? (producto.stockTotal / producto.stockMinimo).clamp(0.0, 1.0)
        : 1.0;
    final stockDisponible = producto.stockTotal - producto.stockReservado;
    final stockBajo = stockDisponible <= producto.stockMinimo;

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
            // Fila principal: Imagen + Información
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del producto (izquierda)
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
                  child: producto.imagen != null && producto.imagen!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            producto.imagen!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.inventory_2,
                              color: const Color(0xFF0d6efd),
                              size: 30.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.inventory_2,
                          color: const Color(0xFF0d6efd),
                          size: 30.sp,
                        ),
                ),
                SizedBox(width: 12.w),

                // Información del producto (derecha)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // Código
                      Text(
                        'Código: ${producto.codExterno}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Precio
                      Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: const Color(0xFF0d6efd),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Stock
                      if (producto.manejaStock) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 14.sp,
                              color: stockBajo ? Colors.orange : Colors.green,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Stock: $stockDisponible ${producto.sigla}',
                              style: TextStyle(
                                color: stockBajo ? Colors.orange : Colors.green,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Barra de progreso del stock
                        LinearProgressIndicator(
                          value: stockPercentage,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStockColor(stockPercentage),
                          ),
                          minHeight: 3.h,
                        ),
                      ],

                      // Estado
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: producto.activo
                              ? const Color(0xFF198754).withValues(alpha: 0.2)
                              : const Color(0xFFdc3545).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: producto.activo
                                ? const Color(0xFF198754)
                                : const Color(0xFFdc3545),
                          ),
                        ),
                        child: Text(
                          producto.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: producto.activo
                                ? const Color(0xFF198754)
                                : const Color(0xFFdc3545),
                          ),
                        ),
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
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFffc107),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.edit, size: 16.sp),
                    label: Text(
                      'Editar',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFdc3545),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(Icons.delete, size: 16.sp),
                    label: Text(
                      'Eliminar',
                      style: TextStyle(fontSize: 12.sp),
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
