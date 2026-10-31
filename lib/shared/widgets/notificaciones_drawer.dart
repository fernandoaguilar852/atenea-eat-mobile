import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../features/notificaciones/presentation/providers/notificaciones_provider.dart';

class NotificacionesDrawer extends ConsumerStatefulWidget {
  const NotificacionesDrawer({super.key});

  @override
  ConsumerState<NotificacionesDrawer> createState() =>
      _NotificacionesDrawerState();
}

class _NotificacionesDrawerState extends ConsumerState<NotificacionesDrawer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Cargar notificaciones pendientes al iniciar
    Future.microtask(() => ref.read(notificacionesProvider.notifier).loadNotificaciones());
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final nuevoEstado = _tabController.index == 0 ? 'PENDIENTE' : 'LEIDA';
    ref.read(notificacionesProvider.notifier).cambiarFiltro(nuevoEstado);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificacionesState = ref.watch(notificacionesProvider);
    final totalNotificaciones = notificacionesState.notificaciones.length;

    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 0,
              left: 16.w,
              right: 16.w,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a1a),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF363636),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '$totalNotificaciones ${_tabController.index == 0 ? "pendientes" : "leídas"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                // TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14.sp,
                  ),
                  tabs: const [
                    Tab(text: 'Pendientes'),
                    Tab(text: 'Leídas'),
                  ],
                ),
              ],
            ),
          ),

          // TabBarView con las listas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Pendientes
                _buildNotificacionesList(),
                // Tab Leídas
                _buildNotificacionesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificacionesList() {
    final notificacionesState = ref.watch(notificacionesProvider);

    if (notificacionesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0d6efd),
        ),
      );
    }

    if (notificacionesState.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
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
                'Error al cargar notificaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                notificacionesState.error!,
                style: TextStyle(
                  color: const Color(0xFF808080),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (notificacionesState.notificaciones.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64.sp,
                color: const Color(0xFF6c757d).withValues(alpha: 0.4),
              ),
              SizedBox(height: 16.h),
              Text(
                notificacionesState.estadoFiltro == 'PENDIENTE'
                    ? 'No hay notificaciones pendientes'
                    : 'No hay notificaciones leídas',
                style: TextStyle(
                  color: const Color(0xFF6c757d),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: notificacionesState.notificaciones.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notificacion = notificacionesState.notificaciones[index];
        return _NotificacionItem(
          notificacionId: notificacion.notificacionId,
          titulo: notificacion.titulo,
          mensaje: notificacion.mensaje,
          tipo: notificacion.tipo,
          prioridad: notificacion.prioridad,
          fecha: notificacion.createdAt,
          isPendiente: notificacion.estado == 'PENDIENTE',
        );
      },
    );
  }
}

class _NotificacionItem extends ConsumerWidget {
  final int notificacionId;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String prioridad;
  final DateTime fecha;
  final bool isPendiente;

  const _NotificacionItem({
    required this.notificacionId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.prioridad,
    required this.fecha,
    required this.isPendiente,
  });

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'CRITICA':
        return const Color(0xFFdc3545); // Red
      case 'ALTA':
        return const Color(0xFFff6b6b); // Orange-Red
      case 'MEDIA':
        return const Color(0xFFffc107); // Yellow
      case 'BAJA':
        return const Color(0xFF0d6efd); // Blue
      default:
        return const Color(0xFF6c757d); // Gray
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'NUMERACION_BAJA':
        return Icons.receipt_long;
      case 'MESA':
        return Icons.table_restaurant;
      case 'COCINA':
        return Icons.restaurant;
      case 'INVENTARIO':
      case 'STOCK_BAJO':
        return Icons.inventory;
      case 'FACTURA':
        return Icons.receipt_long;
      case 'SISTEMA':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con prioridad e icono
          Row(
            children: [
              // Indicador de prioridad
              Container(
                width: 4.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: _getPrioridadColor(prioridad),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              // Icono del tipo
              Icon(
                _getTipoIcon(tipo),
                color: _getPrioridadColor(prioridad),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              // Título y prioridad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getPrioridadColor(prioridad).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        prioridad,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: _getPrioridadColor(prioridad),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Mensaje
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFB0B0B0),
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          // Fecha
          Text(
            dateFormat.format(fecha),
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF808080),
            ),
          ),
          SizedBox(height: 12.h),
          // Acciones según estado
          if (isPendiente)
            // Botón para marcar como leída
            TextButton.icon(
              onPressed: () async {
                final success = await ref.read(notificacionesProvider.notifier).marcarComoLeida(notificacionId);
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificación marcada como leída'),
                      backgroundColor: Color(0xFF198754),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al marcar como leída'),
                      backgroundColor: Color(0xFFdc3545),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(Icons.check_circle_outline, size: 16.sp),
              label: Text('Marcar como leída', style: TextStyle(fontSize: 12.sp)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                foregroundColor: const Color(0xFF198754),
              ),
            )
          else
            // Botón para eliminar
            TextButton.icon(
              onPressed: () async {
                final success = await ref.read(notificacionesProvider.notifier).eliminarNotificacion(notificacionId);
                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificación eliminada'),
                      backgroundColor: Color(0xFF198754),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error al eliminar notificación'),
                      backgroundColor: Color(0xFFdc3545),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(Icons.delete_outline, size: 16.sp),
              label: Text('Eliminar', style: TextStyle(fontSize: 12.sp)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                foregroundColor: const Color(0xFFdc3545),
              ),
            ),
        ],
      ),
    );
  }
}
