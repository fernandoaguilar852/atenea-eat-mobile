import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

// Configuración del Router
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ATENEA EAT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}
