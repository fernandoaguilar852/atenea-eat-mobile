import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notificaciones_drawer.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      endDrawer: const NotificacionesDrawer(),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          _MesasScreen(),
          _OrdenesScreen(),
          DashboardScreen(),
          _FacturacionScreen(),
          _InventarioScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(mainScreenIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF808080),
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: [
          // 0: Mesas
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant, size: 24.sp),
            label: 'Mesas',
          ),
          // 1: Órdenes
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant, size: 24.sp),
            label: 'Órdenes',
          ),
          // 2: Dashboard (Center with special design)
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: currentIndex == 2
                    ? const LinearGradient(
                        colors: [Color(0xFF0d6efd), Color(0xFF0a58ca)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: currentIndex == 2 ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: currentIndex == 2
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0d6efd).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.home,
                color: currentIndex == 2 ? Colors.white : const Color(0xFF808080),
                size: 28.sp,
              ),
            ),
            label: '',
          ),
          // 3: Facturación
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: 24.sp),
            label: 'Facturación',
          ),
          // 4: Inventario
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, size: 24.sp),
            label: 'Inventario',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class _MesasScreen extends StatelessWidget {
  const _MesasScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Mesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_restaurant,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Mesas',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Módulo en desarrollo',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdenesScreen extends StatelessWidget {
  const _OrdenesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Órdenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Órdenes',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Módulo en desarrollo',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacturacionScreen extends StatelessWidget {
  const _FacturacionScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Facturación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Facturación',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Módulo en desarrollo',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventarioScreen extends StatelessWidget {
  const _InventarioScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Inventario',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Módulo en desarrollo',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFB0B0B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
