import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/resolucion.dart';

class ResolucionCard extends StatelessWidget {
  final Resolucion resolucion;

  const ResolucionCard({
    super.key,
    required this.resolucion,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final fechaResolucion = DateTime.parse(resolucion.fechaResolucion);
    final fechaVencimiento = DateTime.parse(resolucion.fechaVencimiento);
    final ahora = DateTime.now();
    final diasRestantes = fechaVencimiento.difference(ahora).inDays;
    final estaVencida = diasRestantes < 0;
    final proximaVencer = diasRestantes >= 0 && diasRestantes <= 30;

    Color getStatusColor() {
      if (!resolucion.activo) return const Color(0xFF6c757d);
      if (estaVencida) return const Color(0xFFdc3545);
      if (proximaVencer) return const Color(0xFFffc107);
      return const Color(0xFF198754);
    }

    String getStatusText() {
      if (!resolucion.activo) return 'Inactiva';
      if (estaVencida) return 'Vencida';
      if (proximaVencer) return 'Próxima a vencer';
      return 'Activa';
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
                    resolucion.activo ? Icons.check_circle : Icons.cancel,
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
                        'Resolución ${resolucion.numeroResolucion}',
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
                // Prefijo grande
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
                    resolucion.prefijo,
                    style: TextStyle(
                      fontSize: 18.sp,
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
                // Rango de numeración
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.tag,
                        label: 'Desde',
                        value: resolucion.numeroDesde.toString(),
                        color: const Color(0xFF17a2b8),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.tag,
                        label: 'Hasta',
                        value: resolucion.numeroHasta.toString(),
                        color: const Color(0xFF17a2b8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Número actual y disponibles
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.format_list_numbered,
                        label: 'Actual',
                        value: resolucion.numeroActual.toString(),
                        color: const Color(0xFF6610f2),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.inventory,
                        label: 'Disponibles',
                        value: resolucion.resolucionesDisponibles.toString(),
                        color: const Color(0xFF198754),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Utilizadas',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${resolucion.porcentajeUtilizado}%',
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
                        value: resolucion.porcentajeUtilizado / 100,
                        minHeight: 8.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          resolucion.porcentajeUtilizado >= 90
                              ? const Color(0xFFdc3545)
                              : resolucion.porcentajeUtilizado >= 70
                                  ? const Color(0xFFffc107)
                                  : const Color(0xFF198754),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.calendar_today,
                        label: 'Resolución',
                        value: dateFormat.format(fechaResolucion),
                        color: const Color(0xFF0d6efd),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.event,
                        label: 'Vencimiento',
                        value: dateFormat.format(fechaVencimiento),
                        color: estaVencida
                            ? const Color(0xFFdc3545)
                            : proximaVencer
                                ? const Color(0xFFffc107)
                                : const Color(0xFF198754),
                      ),
                    ),
                  ],
                ),

                // Días restantes (solo si está activa y no vencida)
                if (resolucion.activo && !estaVencida) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: proximaVencer
                          ? const Color(0xFFffc107).withValues(alpha: 0.1)
                          : const Color(0xFF198754).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: proximaVencer
                            ? const Color(0xFFffc107)
                            : const Color(0xFF198754),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          proximaVencer ? Icons.warning_amber : Icons.info,
                          color: proximaVencer
                              ? const Color(0xFFffc107)
                              : const Color(0xFF198754),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '$diasRestantes días restantes',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                // Botón Ver
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar ver detalle
                    },
                    icon: Icon(Icons.visibility, size: 18.sp),
                    label: Text('Ver', style: TextStyle(fontSize: 13.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0d6efd),
                      side: const BorderSide(color: Color(0xFF0d6efd)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Botón Editar
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar editar
                    },
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: Text('Editar', style: TextStyle(fontSize: 13.sp)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFffc107),
                      side: const BorderSide(color: Color(0xFFffc107)),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Botón Eliminar
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implementar eliminar
                    },
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
