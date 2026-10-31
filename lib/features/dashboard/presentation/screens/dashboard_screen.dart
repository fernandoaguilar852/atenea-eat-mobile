import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al iniciar
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadEstadisticas());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: dashboardState.isLoading && dashboardState.estadisticas == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0d6efd),
                ),
              )
            : dashboardState.error != null && dashboardState.estadisticas == null
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
                          'Error al cargar estadísticas',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          dashboardState.error!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF808080),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(dashboardProvider.notifier).loadEstadisticas();
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Saludo
                        _buildGreeting(),
                        SizedBox(height: 24.h),

                        // Tarjetas de estadísticas
                        _buildStatsGrid(dashboardState.estadisticas),
                        SizedBox(height: 24.h),

                        // Actividad reciente
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Resumen de operaciones del día',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(estadisticas) {
    // Si no hay datos, mostrar valores por defecto
    if (estadisticas == null) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
        children: [
          _StatCard(
            title: 'Mesas',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.table_restaurant,
            color: const Color(0xFF0d6efd),
          ),
          _StatCard(
            title: 'Facturación',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.payments,
            color: const Color(0xFF198754),
          ),
          _StatCard(
            title: 'Reservas',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.event_available,
            color: const Color(0xFF17a2b8),
          ),
          _StatCard(
            title: 'Órdenes',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.restaurant_menu,
            color: const Color(0xFF6610f2),
          ),
          _StatCard(
            title: 'Cocina',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.restaurant,
            color: const Color(0xFFffc107),
          ),
          _StatCard(
            title: 'Alertas',
            value: '--',
            subtitle: 'Cargando...',
            icon: Icons.notifications_active,
            color: const Color(0xFFdc3545),
          ),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Mesas',
          value: '${estadisticas.totalMesasOcupadas}',
          subtitle: 'de ${estadisticas.totalMesas} ocupadas',
          icon: Icons.table_restaurant,
          color: const Color(0xFF0d6efd),
        ),
        _StatCard(
          title: 'Facturación',
          value: currencyFormat.format(estadisticas.totalIngresos),
          subtitle: '${estadisticas.cantidadFacturas} facturas',
          icon: Icons.payments,
          color: const Color(0xFF198754),
        ),
        _StatCard(
          title: 'Reservas',
          value: '${estadisticas.totalReservasConfirmadas}',
          subtitle: 'de ${estadisticas.totalReservas} totales',
          icon: Icons.event_available,
          color: const Color(0xFF17a2b8),
        ),
        _StatCard(
          title: 'Órdenes',
          value: '${estadisticas.totalOrdenesAbiertas}',
          subtitle: '${estadisticas.totalOrdenesEnProceso} en proceso',
          icon: Icons.restaurant_menu,
          color: const Color(0xFF6610f2),
        ),
        _StatCard(
          title: 'Cocina',
          value: '${estadisticas.totalComandasPendientes}',
          subtitle: 'Pendientes',
          icon: Icons.restaurant,
          color: const Color(0xFFffc107),
        ),
        _StatCard(
          title: 'Alertas',
          value: '${estadisticas.cantidadAlertas}',
          subtitle: estadisticas.cantidadAlertas > 0 ? 'Requieren atención' : 'Todo bien',
          icon: Icons.notifications_active,
          color: const Color(0xFFdc3545),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF363636),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.table_restaurant,
                title: 'Mesa 5 ocupada',
                subtitle: 'Hace 5 minutos',
                color: const Color(0xFF0d6efd),
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.receipt_long,
                title: 'Factura #1234 emitida',
                subtitle: 'Hace 12 minutos',
                color: const Color(0xFF198754),
              ),
              const Divider(height: 1),
              _ActivityItem(
                icon: Icons.restaurant,
                title: 'Comanda #45 completada',
                subtitle: 'Hace 18 minutos',
                color: const Color(0xFFffc107),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _refreshData() async {
    await ref.read(dashboardProvider.notifier).refresh();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB0B0B0),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  size: 24.sp,
                  color: color,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF808080),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF808080),
        ),
      ),
    );
  }
}

