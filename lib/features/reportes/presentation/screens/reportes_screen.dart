import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import 'ventas_tab_screen.dart';
import 'inventario_tab_screen.dart';
import 'arqueo_tab_screen.dart';
import 'stock_productos_tab_screen.dart';
import 'stock_insumos_tab_screen.dart';
import 'costo_beneficio_tab_screen.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(icon: Icon(Icons.point_of_sale), text: 'Ventas'),
    Tab(icon: Icon(Icons.inventory_2), text: 'Inv. Consumido'),
    Tab(icon: Icon(Icons.account_balance_wallet), text: 'Arqueo'),
    Tab(icon: Icon(Icons.category), text: 'Productos'),
    Tab(icon: Icon(Icons.science), text: 'Insumos'),
    Tab(icon: Icon(Icons.trending_up), text: 'C-B'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(reportesProvider.notifier).changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // TabBar
          Container(
            color: const Color(0xFF1a1a1a),
            child: TabBar(
              controller: _tabController,
              tabs: _tabs,
              indicatorColor: const Color(0xFF0d6efd),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              labelStyle: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 11.sp,
              ),
              isScrollable: true,
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                VentasTab(),
                InventarioTab(),
                ArqueoTab(),
                StockProductosTab(),
                StockInsumosTab(),
                CostoBeneficioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
