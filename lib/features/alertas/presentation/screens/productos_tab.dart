import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/alertas_provider.dart';
import '../widgets/alerta_card.dart';

class ProductosTab extends ConsumerStatefulWidget {
  const ProductosTab({super.key});

  @override
  ConsumerState<ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends ConsumerState<ProductosTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Listener para mostrar/ocultar botón de scroll to top
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertasProvider);
    final alertasResponse = state.alertasResponse;

    // Filtrar solo productos (insumoId == null)
    final productos = alertasResponse?.alertas
            .where((alerta) => alerta.insumoId == null)
            .toList() ??
        [];

    if (productos.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64.sp,
                color: Colors.white24,
              ),
              SizedBox(height: 16.h),
              Text(
                'No hay alertas de productos',
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
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              'Alertas de Productos (${alertasResponse?.pagination.totalElement ?? 0})',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Lista de productos usando map
            ...productos.map((alerta) => AlertaCard(alerta: alerta)),

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
                      onPressed: state.productosPage > 1
                          ? () {
                              ref.read(alertasProvider.notifier).previousPageProductos();
                            }
                          : null,
                      icon: Icon(Icons.chevron_left, size: 20.sp),
                      label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: state.productosPage > 1
                            ? const Color(0xFF0d6efd)
                            : const Color(0xFF6c757d),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                    Text(
                      'Página ${state.productosPage} de ${(alertasResponse.pagination.totalElement / 10).ceil()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: alertasResponse.pagination.hasMoreElements
                          ? () {
                              ref.read(alertasProvider.notifier).nextPageProductos();
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

          // Botón de scroll to top
          if (_showScrollToTop)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Material(
                color: const Color(0xFF0d6efd),
                borderRadius: BorderRadius.circular(22.r),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
