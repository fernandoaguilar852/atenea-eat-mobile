import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para controlar el índice actual del BottomNavigationBar
/// 0: Mesas
/// 1: Órdenes
/// 2: Dashboard (centro)
/// 3: Facturación
/// 4: Inventario
final mainScreenIndexProvider = StateProvider<int>((ref) => 2); // Inicia en Dashboard
