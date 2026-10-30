import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d6efd),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo
              _buildGreeting(),
              SizedBox(height: 24.h),

              // Tarjetas de estadísticas
              _buildStatsGrid(),
              SizedBox(height: 24.h),

              // Actividad reciente
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0d6efd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Text(
                  'ATENEA EAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Sistema POS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
          ),
          _DrawerItem(
            icon: Icons.table_restaurant,
            title: 'Mesas',
            onTap: () {},
          ),
          _DrawerItem(
            icon: Icons.restaurant,
            title: 'Comandas',
            onTap: () {},
          ),
          _DrawerItem(
            icon: Icons.receipt_long,
            title: 'Facturación',
            onTap: () {},
          ),
          _DrawerItem(
            icon: Icons.inventory,
            title: 'Inventario',
            onTap: () {},
          ),
          _DrawerItem(
            icon: Icons.assessment,
            title: 'Reportes',
            onTap: () {},
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {},
          ),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {},
          ),
        ],
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
            color: const Color(0xFF212529),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Resumen de operaciones del día',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6c757d),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
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
          value: '8 Ocupadas',
          subtitle: '12 totales',
          icon: Icons.table_restaurant,
          color: const Color(0xFF0d6efd),
        ),
        _StatCard(
          title: 'Facturación',
          value: currencyFormat.format(1250000),
          subtitle: '24 facturas',
          icon: Icons.payments,
          color: const Color(0xFF198754),
        ),
        _StatCard(
          title: 'Cocina',
          value: '5 Pendientes',
          subtitle: '3 en preparación',
          icon: Icons.restaurant,
          color: const Color(0xFFffc107),
        ),
        _StatCard(
          title: 'Inventario',
          value: '127 Productos',
          subtitle: '5 bajo stock',
          icon: Icons.inventory,
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
            color: const Color(0xFF212529),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
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
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFF6c757d),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
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
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212529),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6c757d),
                ),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
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
          color: const Color(0xFF212529),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF6c757d),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
