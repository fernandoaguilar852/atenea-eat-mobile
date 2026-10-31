import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
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
          _FacturasScreen(),
          _MovimientosScreen(),
          DashboardScreen(),
          _ReportesScreen(),
          ChatScreen(),
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
          // 0: Facturas
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: 24.sp),
            label: 'Facturas',
          ),
          // 1: Movimientos
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz, size: 24.sp),
            label: 'Movimientos',
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
          // 3: Reportes
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart, size: 24.sp),
            label: 'Reportes',
          ),
          // 4: Chat IA
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy, size: 24.sp),
            label: 'Chat IA',
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class _FacturasScreen extends StatelessWidget {
  const _FacturasScreen();

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Facturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
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
              'Gestión de Facturas',
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

class _MovimientosScreen extends StatelessWidget {
  const _MovimientosScreen();

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Movimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Movimientos',
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

class _ReportesScreen extends StatelessWidget {
  const _ReportesScreen();

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80.sp,
              color: const Color(0xFF808080).withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gestión de Reportes',
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
