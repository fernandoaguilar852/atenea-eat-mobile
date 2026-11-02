import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/resoluciones_provider.dart';
import '../widgets/resolucion_card.dart';

class ResolucionesScreen extends ConsumerStatefulWidget {
  const ResolucionesScreen({super.key});

  @override
  ConsumerState<ResolucionesScreen> createState() => _ResolucionesScreenState();
}

class _ResolucionesScreenState extends ConsumerState<ResolucionesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar resoluciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resolucionesProvider.notifier).loadResoluciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resolucionesProvider);
    final resolucionesResponse = state.resolucionesResponse;

    return Container(
      color: Colors.black,
      child: state.isLoading && resolucionesResponse == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            )
          : state.error != null && resolucionesResponse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: const Color(0xFFdc3545),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error al cargar resoluciones',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.error!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF808080),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(resolucionesProvider.notifier).loadResoluciones();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resoluciones de Facturación (${resolucionesResponse?.pagination.totalElement ?? 0})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Lista de resoluciones
                      if (resolucionesResponse != null &&
                          resolucionesResponse.resoluciones.isNotEmpty)
                        ...resolucionesResponse.resoluciones.map((resolucion) {
                          return ResolucionCard(resolucion: resolucion);
                        })
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64.sp,
                                  color: Colors.white24,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No hay resoluciones registradas',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Paginación
                      if (resolucionesResponse != null &&
                          resolucionesResponse.pagination.totalElement > 0) ...[
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
                                onPressed: state.currentPage > 1
                                    ? () {
                                        ref.read(resolucionesProvider.notifier).previousPage();
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
                                'Página ${state.currentPage} de ${(resolucionesResponse.pagination.totalElement / 10).ceil()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: resolucionesResponse.pagination.hasMoreElements
                                    ? () {
                                        ref.read(resolucionesProvider.notifier).nextPage();
                                      }
                                    : null,
                                label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                                icon: Icon(Icons.chevron_right, size: 20.sp),
                                style: TextButton.styleFrom(
                                  foregroundColor: resolucionesResponse.pagination.hasMoreElements
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
