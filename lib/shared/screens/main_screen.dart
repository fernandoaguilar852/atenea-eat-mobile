import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/movimientos/presentation/screens/movimientos_screen.dart';
import '../../features/ventas/presentation/screens/ventas_screen.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notificaciones_drawer.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenIndexProvider);

    // Títulos para cada pantalla
    final titles = ['Facturas', 'Movimientos', 'Dashboard', 'Reportes', 'Chat IA'];

    return Scaffold(
      drawer: const AppDrawer(),
      endDrawer: const NotificacionesDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(titles[currentIndex]),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          if (currentIndex == 4) // Chat IA
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref.read(chatProvider.notifier).clearMessages();
              },
              tooltip: 'Limpiar conversación',
            ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [
          VentasScreen(),
          MovimientosScreen(),
          DashboardScreen(),
          ReportesScreen(),
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
