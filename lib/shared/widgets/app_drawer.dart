import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // User Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1a1a1a),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF363636),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                // User name
                Text(
                  user?.nombre ?? 'Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                // Email
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerMenuItem(
                  icon: Icons.event_available,
                  title: 'Reservas',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a Reservas
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.restaurant_menu,
                  title: 'Órdenes',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a Órdenes
                  },
                ),
                ExpansionTile(
                  leading: const Icon(
                    Icons.business_center,
                    color: Color(0xFFB0B0B0),
                  ),
                  title: Text(
                    'Gestión',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                  iconColor: const Color(0xFFB0B0B0),
                  collapsedIconColor: const Color(0xFFB0B0B0),
                  children: [
                    _DrawerSubMenuItem(
                      icon: Icons.description,
                      title: 'Resoluciones',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(mainScreenIndexProvider.notifier).state = 6;
                      },
                    ),
                    _DrawerSubMenuItem(
                      icon: Icons.science,
                      title: 'Insumos',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(mainScreenIndexProvider.notifier).state = 7;
                      },
                    ),
                    _DrawerSubMenuItem(
                      icon: Icons.inventory_2,
                      title: 'Productos',
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(mainScreenIndexProvider.notifier).state = 8;
                      },
                    ),
                  ],
                ),
                _DrawerMenuItem(
                  icon: Icons.settings,
                  title: 'Configuración',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar a Configuración
                  },
                ),
                const Divider(),
                _DrawerMenuItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  iconColor: const Color(0xFFdc3545),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close drawer
              context.go('/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFdc3545),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFFB0B0B0),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _DrawerSubMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerSubMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF808080),
        size: 20.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.only(left: 32.w, right: 16.w),
    );
  }
}
