import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/alertas_provider.dart';
import 'insumos_tab.dart';
import 'productos_tab.dart';

class AlertasScreen extends ConsumerStatefulWidget {
  const AlertasScreen({super.key});

  @override
  ConsumerState<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends ConsumerState<AlertasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listener para cambios de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(alertasProvider.notifier).changeTab(_tabController.index);
      }
    });

    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertasProvider.notifier).loadAlertas();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertasProvider);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Pestañas
          Container(
            color: const Color(0xFF1a1a1a),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF0d6efd),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              tabs: [
                Tab(
                  icon: Icon(Icons.category, size: 24.sp),
                  text: 'Productos',
                ),
                Tab(
                  icon: Icon(Icons.science, size: 24.sp),
                  text: 'Insumos',
                ),
              ],
            ),
          ),
          // Contenido de las pestañas
          Expanded(
            child: state.isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0d6efd),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Cargando alertas...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  )
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48.sp,
                                color: const Color(0xFFdc3545),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.error!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFdc3545),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(alertasProvider.notifier).loadAlertas();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0d6efd),
                                ),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: const [
                          ProductosTab(),
                          InsumosTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
