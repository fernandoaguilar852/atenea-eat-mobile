import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/alertas_provider.dart';
import '../widgets/alerta_card.dart';

class InsumosTab extends ConsumerWidget {
  const InsumosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertasProvider);
    final alertasResponse = state.alertasResponse;

    // Filtrar solo insumos (productoId == null)
    final insumos = alertasResponse?.alertas
            .where((alerta) => alerta.productoId == null)
            .toList() ??
        [];

    if (insumos.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science_outlined,
                size: 64.sp,
                color: Colors.white24,
              ),
              SizedBox(height: 16.h),
              Text(
                'No hay alertas de insumos',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas de Insumos (${alertasResponse?.pagination.totalElement ?? 0})',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Lista de insumos usando map
            ...insumos.map((alerta) => AlertaCard(alerta: alerta)),

            // Paginación dentro del scroll
            if (alertasResponse != null && alertasResponse.pagination.totalElement > 0) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a1a),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFF363636),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: state.insumosPage > 1
                          ? () {
                              ref.read(alertasProvider.notifier).previousPageInsumos();
                            }
                          : null,
                      icon: Icon(Icons.chevron_left, size: 20.sp),
                      label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: state.insumosPage > 1
                            ? const Color(0xFF0d6efd)
                            : const Color(0xFF6c757d),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                    Text(
                      'Página ${state.insumosPage} de ${(alertasResponse.pagination.totalElement / 10).ceil()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: alertasResponse.pagination.hasMoreElements
                          ? () {
                              ref.read(alertasProvider.notifier).nextPageInsumos();
                            }
                          : null,
                      label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                      icon: Icon(Icons.chevron_right, size: 20.sp),
                      style: TextButton.styleFrom(
                        foregroundColor: alertasResponse.pagination.hasMoreElements
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
