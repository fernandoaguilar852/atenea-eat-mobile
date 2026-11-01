import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../insumos/presentation/providers/insumos_provider.dart';
import '../../../insumos/domain/entities/insumo.dart';
import 'insumo_detail_screen.dart';

class InsumosTab extends ConsumerStatefulWidget {
  const InsumosTab({super.key});

  @override
  ConsumerState<InsumosTab> createState() => _InsumosTabState();
}

class _InsumosTabState extends ConsumerState<InsumosTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(insumosListProvider.notifier).loadInsumos();
    });
  }

  void _showInsumoDetail(Insumo insumo) {
    showDialog(
      context: context,
      builder: (context) => InsumoDetailScreen(insumo: insumo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insumosListProvider);

    if (state.isLoading && state.insumosResponse == null) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF0d6efd),
        ),
      );
    }

    if (state.error != null && state.insumosResponse == null) {
      return Center(
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
              'Error al cargar insumos',
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
                ref.read(insumosListProvider.notifier).loadInsumos();
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final insumos = state.insumosResponse?.insumos ?? [];
    final pagination = state.insumosResponse?.pagination;

    if (insumos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No hay insumos disponibles',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: insumos.length,
            itemBuilder: (context, index) {
              final insumo = insumos[index];
              final stockDisponible = insumo.stockActual - insumo.stockReservado;
              final stockBajo = stockDisponible <= insumo.stockMinimo;

              return Card(
                color: const Color(0xFF1a1a1a),
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: const Color(0xFF404040),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showInsumoDetail(insumo),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        // Icono del insumo
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: const Color(0xFF0d6efd),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.inventory_outlined,
                            color: const Color(0xFF0d6efd),
                            size: 32.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Información del insumo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insumo.nombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2,
                                    size: 14.sp,
                                    color: stockBajo ? Colors.red : Colors.green,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Stock: ${stockDisponible.toStringAsFixed(2)} ${insumo.unidadBase}',
                                    style: TextStyle(
                                      color: stockBajo ? Colors.red : Colors.green,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (stockBajo) ...[
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(color: Colors.orange, width: 1),
                                      ),
                                      child: Text(
                                        'BAJO',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Total: ${insumo.stockActual.toStringAsFixed(2)} | Reservado: ${insumo.stockReservado.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: const Color(0xFF0d6efd),
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Paginación
        if (pagination != null)
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
                ElevatedButton.icon(
                  onPressed: state.currentPage > 1
                      ? () => ref.read(insumosListProvider.notifier).previousPage()
                      : null,
                  icon: Icon(Icons.chevron_left, size: 18.sp),
                  label: Text('Anterior', style: TextStyle(fontSize: 13.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d6efd),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2a2a2a),
                    disabledForegroundColor: const Color(0xFF808080),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Text(
                  'Página ${state.currentPage}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: pagination.hasMoreElements
                      ? () => ref.read(insumosListProvider.notifier).nextPage()
                      : null,
                  icon: Icon(Icons.chevron_right, size: 18.sp),
                  label: Text('Siguiente', style: TextStyle(fontSize: 13.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d6efd),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2a2a2a),
                    disabledForegroundColor: const Color(0xFF808080),
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
