import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/entities/tipo_producto.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/operador.dart';
import 'package:intl/intl.dart';

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
    Tab(icon: Icon(Icons.inventory_2), text: 'Inventario'),
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
                _VentasTab(),
                _InventarioTab(),
                _ArqueoTab(),
                _StockProductosTab(),
                _StockInsumosTab(),
                _CostoBeneficioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VENTAS TAB
// ============================================================================
class _VentasTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VentasTab> createState() => _VentasTabState();
}

class _VentasTabState extends ConsumerState<_VentasTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _productSearchController = TextEditingController();
  final TextEditingController _consumidorSearchController = TextEditingController();

  @override
  void dispose() {
    _productSearchController.dispose();
    _consumidorSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.ventasReporte;
    final isLoading = reportesState.isLoadingVentas;
    final error = reportesState.errorVentas;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte de Ventas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Filtros
          _buildDateFilters(),

          SizedBox(height: 16.h),

          // Botones: Limpiar filtros y Consultar
          Row(
            children: [
              // Botón limpiar filtros
              IconButton(
                onPressed: _limpiarFiltros,
                icon: const Icon(Icons.clear_all),
                color: Colors.orange,
                iconSize: 32.sp,
                tooltip: 'Limpiar filtros',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  padding: EdgeInsets.all(12.w),
                ),
              ),

              SizedBox(width: 12.w),

              // Botón consultar
              Expanded(
                child: ElevatedButton(
                  onPressed: _startDate != null && _endDate != null
                      ? () => _consultarReporte()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Consultar Reporte',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Resultados
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: CircularProgressIndicator(
                  color: const Color(0xFF0d6efd),
                ),
              ),
            )
          else if (error != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (reporte != null)
            _buildReporteVentas(reporte)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 64.sp,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Selecciona las fechas y consulta el reporte',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Fecha inicio
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                _startDate != null
                    ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                    : 'Fecha inicio *',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Fecha fin
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                _endDate != null
                    ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                    : 'Fecha fin *',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Búsqueda de productos
            _buildProductSearch(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Búsqueda de consumidor
            _buildConsumidorSearch(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Selector de categoría
            _buildCategoriaSelector(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Selector de caja
            _buildCajaSelector(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Selector de operador
            _buildOperadorSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearch() {
    final productosState = ref.watch(productosSearchProvider);
    final selectedProducto = productosState.selectedProducto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buscar Producto',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (selectedProducto != null)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF0d6efd),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProducto.nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Código: ${selectedProducto.codExterno}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(productosSearchProvider.notifier).selectProducto(null);
                    _productSearchController.clear();
                  },
                ),
              ],
            ),
          )
        else
          TextField(
            controller: _productSearchController,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Escribe al menos 3 caracteres...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: productosState.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0d6efd),
                        ),
                      ),
                    )
                  : _productSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _productSearchController.clear();
                            ref.read(productosSearchProvider.notifier).clearSearch();
                          },
                        )
                      : null,
              filled: true,
              fillColor: const Color(0xFF2d2d2d),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3) {
                ref.read(productosSearchProvider.notifier).searchProductos(value);
              } else {
                ref.read(productosSearchProvider.notifier).clearSearch();
              }
            },
          ),

        // Resultados de búsqueda
        if (productosState.productos.isNotEmpty && selectedProducto == null) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: productosState.productos.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final producto = productosState.productos[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  title: Text(
                    producto.nombre,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  subtitle: Text(
                    'Código: ${producto.codExterno} - Precio: \$${producto.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                  onTap: () {
                    ref.read(productosSearchProvider.notifier).selectProducto(producto);
                    _productSearchController.text = producto.nombre;
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConsumidorSearch() {
    final consumidoresState = ref.watch(consumidoresSearchProvider);
    final selectedConsumidor = consumidoresState.selectedConsumidor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buscar Consumidor',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (selectedConsumidor != null)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF0d6efd),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedConsumidor.nombreRazonSocial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${selectedConsumidor.tipoIdentificacion}: ${selectedConsumidor.numeroIdentificacion}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(consumidoresSearchProvider.notifier).selectConsumidor(null);
                    _consumidorSearchController.clear();
                  },
                ),
              ],
            ),
          )
        else
          TextField(
            controller: _consumidorSearchController,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Escribe al menos 3 caracteres...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: consumidoresState.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0d6efd),
                        ),
                      ),
                    )
                  : _consumidorSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _consumidorSearchController.clear();
                            ref.read(consumidoresSearchProvider.notifier).clearSearch();
                          },
                        )
                      : null,
              filled: true,
              fillColor: const Color(0xFF2d2d2d),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length >= 3) {
                ref.read(consumidoresSearchProvider.notifier).searchConsumidores(value);
              } else {
                ref.read(consumidoresSearchProvider.notifier).clearSearch();
              }
            },
          ),

        // Resultados de búsqueda
        if (consumidoresState.consumidores.isNotEmpty && selectedConsumidor == null) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: consumidoresState.consumidores.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final consumidor = consumidoresState.consumidores[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  title: Text(
                    consumidor.nombreRazonSocial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  subtitle: Text(
                    '${consumidor.tipoIdentificacion}: ${consumidor.numeroIdentificacion}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                  onTap: () {
                    ref.read(consumidoresSearchProvider.notifier).selectConsumidor(consumidor);
                    _consumidorSearchController.text = consumidor.nombreRazonSocial;
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriaSelector() {
    final tiposProductoState = ref.watch(tiposProductoProvider);
    final selectedTipo = tiposProductoState.selectedTipo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (tiposProductoState.isLoading)
          Container(
            padding: EdgeInsets.all(16.w),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            ),
          )
        else if (tiposProductoState.error != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Text(
              'Error: ${tiposProductoState.error}',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          )
        else
          DropdownButtonFormField<TipoProducto>(
            value: selectedTipo,
            decoration: InputDecoration(
              hintText: 'Seleccionar categoría...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF2d2d2d),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            dropdownColor: const Color(0xFF2d2d2d),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: [
              DropdownMenuItem<TipoProducto>(
                value: null,
                child: Text(
                  'Todas las categorías',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ...tiposProductoState.tiposProducto.map((tipo) {
                return DropdownMenuItem<TipoProducto>(
                  value: tipo,
                  child: Text(
                    tipo.nombre,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                );
              }),
            ],
            onChanged: (TipoProducto? newValue) {
              ref.read(tiposProductoProvider.notifier).selectTipo(newValue);
            },
          ),
      ],
    );
  }

  Widget _buildCajaSelector() {
    final cajasState = ref.watch(cajasProvider);
    final selectedCaja = cajasState.selectedCaja;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caja',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (cajasState.isLoading)
          Container(
            padding: EdgeInsets.all(16.w),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            ),
          )
        else if (cajasState.error != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Text(
              'Error: ${cajasState.error}',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          )
        else
          DropdownButtonFormField<Caja>(
            value: selectedCaja,
            decoration: InputDecoration(
              hintText: 'Seleccionar caja...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF2d2d2d),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            dropdownColor: const Color(0xFF2d2d2d),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: [
              DropdownMenuItem<Caja>(
                value: null,
                child: Text(
                  'Todas las cajas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ...cajasState.cajas.map((caja) {
                return DropdownMenuItem<Caja>(
                  value: caja,
                  child: Row(
                    children: [
                      // Punto verde si está abierta
                      if (caja.isAbierta)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      // Texto con formato "CajaId - Nombre Usuario"
                      Expanded(
                        child: Text(
                          '${caja.cajaId} - ${caja.nombreUsuario ?? "Usuario desconocido"}',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (Caja? newValue) {
              ref.read(cajasProvider.notifier).selectCaja(newValue);
            },
          ),
      ],
    );
  }

  Widget _buildOperadorSelector() {
    final operadoresState = ref.watch(operadoresProvider);
    final selectedOperador = operadoresState.selectedOperador;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operador',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (operadoresState.isLoading)
          Container(
            padding: EdgeInsets.all(16.w),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            ),
          )
        else if (operadoresState.error != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Text(
              'Error: ${operadoresState.error}',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          )
        else
          DropdownButtonFormField<Operador>(
            value: selectedOperador,
            decoration: InputDecoration(
              hintText: 'Seleccionar operador...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF2d2d2d),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(
                  color: Color(0xFF0d6efd),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            dropdownColor: const Color(0xFF2d2d2d),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: [
              DropdownMenuItem<Operador>(
                value: null,
                child: Text(
                  'Todos los operadores',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ...operadoresState.operadores.map((operador) {
                return DropdownMenuItem<Operador>(
                  value: operador,
                  child: Row(
                    children: [
                      // Círculo verde si está activo
                      if (operador.activo)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(right: 8.w),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      // Nombre del operador
                      Expanded(
                        child: Text(
                          operador.nombre,
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (Operador? newValue) {
              ref.read(operadoresProvider.notifier).selectOperador(newValue);
            },
          ),
      ],
    );
  }

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    final startDateStr = _startDate!.toIso8601String().split('T')[0];
    final endDateStr = _endDate!.toIso8601String().split('T')[0];
    final productosState = ref.read(productosSearchProvider);
    final productoId = productosState.selectedProducto?.productoId;
    final consumidoresState = ref.read(consumidoresSearchProvider);
    final consumidorId = consumidoresState.selectedConsumidor?.consumidorId;
    final tiposProductoState = ref.read(tiposProductoProvider);
    final categoriaId = tiposProductoState.selectedTipo?.tipoProductoId;
    final cajasState = ref.read(cajasProvider);
    final cajaId = cajasState.selectedCaja?.cajaId;
    final operadoresState = ref.read(operadoresProvider);
    final operadorId = operadoresState.selectedOperador?.operadorId;

    ref.read(reportesProvider.notifier).loadReporteVentas(
          startDate: startDateStr,
          endDate: endDateStr,
          productoId: productoId,
          consumidorId: consumidorId,
          categoriaId: categoriaId,
          cajaId: cajaId,
          operadorId: operadorId,
        );
  }

  void _limpiarFiltros() {
    // Limpiar filtro de productos
    ref.read(productosSearchProvider.notifier).clearSearch();

    // Limpiar filtro de consumidores
    ref.read(consumidoresSearchProvider.notifier).clearSearch();

    // Limpiar filtro de categorías
    ref.read(tiposProductoProvider.notifier).selectTipo(null);

    // Limpiar filtro de cajas
    ref.read(cajasProvider.notifier).selectCaja(null);

    // Limpiar filtro de operadores
    ref.read(operadoresProvider.notifier).selectOperador(null);
  }

  Widget _buildReporteVentas(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado del negocio
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Text(
                  reporte.encabezado.nombreNegocio,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  'NIT: ${reporte.encabezado.nit}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '${reporte.encabezado.ciudad}, ${reporte.encabezado.departamento ?? ""}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Resumen del Período',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildSummaryRow('Productos Vendidos',
                    '${reporte.resumen.totalProductosVendidos}'),
                _buildSummaryRow(
                    'Transacciones', '${reporte.resumen.totalTransacciones}'),
                _buildSummaryRow('Subtotal',
                    '\$${reporte.resumen.subtotalGeneral.toStringAsFixed(2)}'),
                _buildSummaryRow('Descuentos',
                    '\$${reporte.resumen.descuentosGeneral.toStringAsFixed(2)}',
                    valueColor: Colors.red),
                _buildSummaryRow('Impuestos',
                    '\$${reporte.resumen.impuestosGeneral.toStringAsFixed(2)}'),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 24.h),
                _buildSummaryRow(
                  'TOTAL GENERAL',
                  '\$${reporte.resumen.totalGeneral.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Lista de ventas
        Row(
          children: [
            Icon(Icons.list_alt, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Detalle (${reporte.ventas.length} registros)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.ventas.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Text(
                  'No hay ventas en este período',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          )
        else
          ...reporte.ventas.map<Widget>((venta) {
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venta.productoNombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (venta.categoriaNombre != null)
                                Text(
                                  venta.categoriaNombre!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${venta.totalVentas.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF0d6efd),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cantidad vendida: ${venta.cantidadVendida.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          'Precio prom: \$${venta.precioPromedio.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal: \$${venta.subtotalVentas.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11.sp,
                          ),
                        ),
                        if (venta.descuentosAplicados > 0)
                          Text(
                            'Desc: -\$${venta.descuentosAplicados.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: const Color(0xFFffc107),
                              fontSize: 11.sp,
                            ),
                          ),
                        if (venta.impuestosAplicados > 0)
                          Text(
                            'Imp: +\$${venta.impuestosAplicados.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11.sp,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Transacciones: ${venta.numeroTransacciones}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControls(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControls(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteVentas(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),

          // Indicador de página
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),

          // Botón siguiente
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteVentas(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: isTotal ? 1.0 : 0.7),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (isTotal ? const Color(0xFF0d6efd) : Colors.white),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INVENTARIO TAB
// ============================================================================
class _InventarioTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InventarioTab> createState() => _InventarioTabState();
}

class _InventarioTabState extends ConsumerState<_InventarioTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _tipoMovimiento;

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.inventarioReporte;
    final isLoading = reportesState.isLoadingInventario;
    final error = reportesState.errorInventario;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventario Consumido',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          _buildFilters(),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? () => _consultarReporte()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          if (isLoading)
            Center(child: Padding(
              padding: EdgeInsets.all(32.h),
              child: CircularProgressIndicator(color: const Color(0xFF0d6efd)),
            ))
          else if (error != null)
            Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)))
          else if (reporte != null)
            _buildReporteInventario(reporte)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2, size: 64.sp, color: Colors.white.withValues(alpha: 0.3)),
                    SizedBox(height: 16.h),
                    Text(
                      'Selecciona fechas y consulta',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),

            // Fechas
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                _startDate != null ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : 'Fecha inicio *',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(
                _endDate != null ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : 'Fecha fin *',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _endDate = date);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Tipo movimiento
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.category, color: Colors.white),
              title: Text(
                _tipoMovimiento ?? 'Tipo de movimiento (opcional)',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final tipo = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a1a),
                    title: Text('Tipo de Movimiento', style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Todos', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, null),
                        ),
                        ListTile(
                          title: Text('Venta', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, 'venta'),
                        ),
                        ListTile(
                          title: Text('Salida', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, 'salida'),
                        ),
                        ListTile(
                          title: Text('Merma', style: TextStyle(color: Colors.white)),
                          onTap: () => Navigator.pop(context, 'merma'),
                        ),
                      ],
                    ),
                  ),
                );
                setState(() => _tipoMovimiento = tipo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    ref.read(reportesProvider.notifier).loadReporteInventarioConsumido(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
          tipoMovimiento: _tipoMovimiento,
        );
  }

  Widget _buildReporteInventario(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Resumen', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildRow('Productos Consumidos', '${reporte.resumen.totalProductosConsumidos}'),
                _buildRow('Insumos Consumidos', '${reporte.resumen.totalInsumosConsumidos}'),
                _buildRow('Total Movimientos', '${reporte.resumen.totalMovimientos}'),
                _buildRow('Requieren Reposición', '${reporte.resumen.itemsRequierenReposicion}',
                    valueColor: reporte.resumen.itemsRequierenReposicion > 0 ? Colors.red : null),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Productos directos
        if (reporte.productosDirectos.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.category, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Productos (${reporte.productosDirectos.length})',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          ...reporte.productosDirectos.map<Widget>((producto) {
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(producto.productoNombre, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consumido: ${producto.cantidadConsumida} ${producto.unidadMedida}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                    Text('Stock: ${producto.stockActual} (mín: ${producto.stockMinimo})',
                        style: TextStyle(
                          color: producto.requiereReposicion ? Colors.red : Colors.white.withValues(alpha: 0.6),
                        )),
                  ],
                ),
                trailing: producto.requiereReposicion
                    ? Icon(Icons.warning, color: Colors.red)
                    : null,
              ),
            );
          }).toList(),
        ],

        if (reporte.productosDirectos.isNotEmpty && reporte.insumosConsumidos.isNotEmpty)
          SizedBox(height: 16.h),

        // Insumos
        if (reporte.insumosConsumidos.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.science, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text('Insumos (${reporte.insumosConsumidos.length})',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          ...reporte.insumosConsumidos.map<Widget>((insumo) {
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(insumo.insumoNombre, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consumido: ${insumo.cantidadConsumida} ${insumo.unidadMedida}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                    Text('Stock: ${insumo.stockActual} (mín: ${insumo.stockMinimo})',
                        style: TextStyle(
                          color: insumo.requiereReposicion ? Colors.red : Colors.white.withValues(alpha: 0.6),
                        )),
                    if (insumo.productosRelacionados.isNotEmpty)
                      Text('Productos: ${insumo.productosRelacionados.join(", ")}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.sp)),
                  ],
                ),
                trailing: insumo.requiereReposicion
                    ? Icon(Icons.warning, color: Colors.red)
                    : null,
              ),
            );
          }).toList(),
        ],

        if (reporte.productosDirectos.isEmpty && reporte.insumosConsumidos.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: Text('No hay movimientos de inventario en este período',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              ),
            ),
          ),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsInventario(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsInventario(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteInventarioConsumido(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteInventarioConsumido(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

// ============================================================================
// ARQUEO TAB
// ============================================================================
class _ArqueoTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ArqueoTab> createState() => _ArqueoTabState();
}

class _ArqueoTabState extends ConsumerState<_ArqueoTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _tipoPago;

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.arqueoReporte;
    final isLoading = reportesState.isLoadingArqueo;
    final error = reportesState.errorArqueo;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Arqueo de Caja', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

          _buildFilters(),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null ? () => _consultarReporte() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          if (isLoading)
            Center(child: Padding(padding: EdgeInsets.all(32.h), child: CircularProgressIndicator(color: const Color(0xFF0d6efd))))
          else if (error != null)
            Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)))
          else if (reporte != null)
            _buildReporteArqueo(reporte)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 64.sp, color: Colors.white.withValues(alpha: 0.3)),
                    SizedBox(height: 16.h),
                    Text('Selecciona fechas y consulta', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),

            // Fechas (similar a anteriores)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(_startDate != null ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : 'Fecha inicio *',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020), lastDate: DateTime.now());
                if (date != null) setState(() => _startDate = date);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(_endDate != null ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : 'Fecha fin *',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2020), lastDate: DateTime.now());
                if (date != null) setState(() => _endDate = date);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Tipo de pago
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payment, color: Colors.white),
              title: Text(_tipoPago ?? 'Tipo de pago (opcional)', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final tipo = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a1a),
                    title: Text('Tipo de Pago', style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: Text('Todos', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, null)),
                        ListTile(title: Text('Caja', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'CAJA')),
                        ListTile(title: Text('Banco', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'BANCO')),
                      ],
                    ),
                  ),
                );
                setState(() => _tipoPago = tipo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
          tipoPago: _tipoPago,
        );
  }

  Widget _buildReporteArqueo(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Resumen', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildRow('Total Caja', '\$${reporte.resumen.totalCaja.toStringAsFixed(2)}', valueColor: const Color(0xFF198754)),
                _buildRow('Total Banco', '\$${reporte.resumen.totalBanco.toStringAsFixed(2)}', valueColor: const Color(0xFF0d6efd)),
                _buildRow('Transacciones', '${reporte.resumen.totalTransacciones}'),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 24.h),
                _buildRow('TOTAL GENERAL', '\$${reporte.resumen.totalGeneral.toStringAsFixed(2)}', isTotal: true),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Transacciones
        Row(
          children: [
            Icon(Icons.list_alt, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Transacciones (${reporte.transacciones.length})',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.transacciones.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(child: Text('No hay transacciones en este período',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))),
            ),
          )
        else
          ...reporte.transacciones.map<Widget>((tx) {
            final isCaja = tx.tipoPago == 'CAJA';
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: Icon(
                  isCaja ? Icons.account_balance_wallet : Icons.account_balance,
                  color: isCaja ? const Color(0xFF198754) : const Color(0xFF0d6efd),
                ),
                title: Text('${tx.tipoTransaccion} - ${tx.tipoPago}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.fechaTransaccion),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.sp)),
                    if (tx.metodoPago != null)
                      Text('Método: ${tx.metodoPago}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.sp)),
                  ],
                ),
                trailing: Text('\$${tx.valor.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsArqueo(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsArqueo(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              color: Colors.white.withValues(alpha: isTotal ? 1.0 : 0.7),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
              color: valueColor ?? (isTotal ? const Color(0xFF0d6efd) : Colors.white),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// ============================================================================
// STOCK PRODUCTOS TAB
// ============================================================================
class _StockProductosTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_StockProductosTab> createState() => _StockProductosTabState();
}

class _StockProductosTabState extends ConsumerState<_StockProductosTab> {
  String? _filtroStockBajo;

  @override
  void initState() {
    super.initState();
    // Cargar reporte al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportesProvider.notifier).loadReporteStockProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.stockProductosReporte;
    final isLoading = reportesState.isLoadingStockProductos;
    final error = reportesState.errorStockProductos;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock de Productos', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

          _buildFilters(),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _consultarReporte(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          if (isLoading)
            Center(child: Padding(padding: EdgeInsets.all(32.h), child: CircularProgressIndicator(color: const Color(0xFF0d6efd))))
          else if (error != null)
            Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)))
          else if (reporte != null)
            _buildReporteStock(reporte)
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.filter_list, color: Colors.white),
              title: Text(_filtroStockBajo == 'true' ? 'Solo stock bajo' : 'Todos los productos',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final filtro = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a1a),
                    title: Text('Filtrar Productos', style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: Text('Todos', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, null)),
                        ListTile(title: Text('Solo stock bajo', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'true')),
                      ],
                    ),
                  ),
                );
                setState(() => _filtroStockBajo = filtro);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _consultarReporte() {
    ref.read(reportesProvider.notifier).loadReporteStockProductos(
          stockBajo: _filtroStockBajo,
        );
  }

  Widget _buildReporteStock(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Resumen', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildRow('Total Productos', '${reporte.resumen.totalProductos}'),
                _buildRow('Stock Bajo', '${reporte.resumen.productosStockBajo}',
                    valueColor: reporte.resumen.productosStockBajo > 0 ? Colors.red : null),
                _buildRow('Valor Inventario', '\$${reporte.resumen.valorInventario.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF0d6efd)),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Lista de productos
        Row(
          children: [
            Icon(Icons.category, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Productos (${reporte.productos.length})',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.productos.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(child: Text('No hay productos para mostrar',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))),
            ),
          )
        else
          ...reporte.productos.map<Widget>((producto) {
            final stockBajo = producto.requiereReposicion;
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(producto.nombre,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                        if (stockBajo) Icon(Icons.warning, color: Colors.red, size: 20.sp),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (producto.tipoProductoNombre != null)
                      Text('Categoría: ${producto.tipoProductoNombre}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.sp)),
                    Text('Stock: ${producto.stockDisponible} ${producto.unidadMedida} (mín: ${producto.stockMinimo})',
                        style: TextStyle(color: stockBajo ? Colors.red : Colors.white.withValues(alpha: 0.7), fontSize: 12.sp)),
                    if (producto.precio != null)
                      Text('Precio: \$${producto.precio!.toStringAsFixed(2)}',
                          style: TextStyle(color: const Color(0xFF0d6efd), fontSize: 12.sp)),
                  ],
                ),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsStockProductos(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsStockProductos(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteStockProductos(
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteStockProductos(
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

// ============================================================================
// STOCK INSUMOS TAB
// ============================================================================
class _StockInsumosTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_StockInsumosTab> createState() => _StockInsumosTabState();
}

class _StockInsumosTabState extends ConsumerState<_StockInsumosTab> {
  String? _filtroStockBajo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportesProvider.notifier).loadReporteStockInsumos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.stockInsumosReporte;
    final isLoading = reportesState.isLoadingStockInsumos;
    final error = reportesState.errorStockInsumos;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock de Insumos', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

          _buildFilters(),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _consultarReporte(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          if (isLoading)
            Center(child: Padding(padding: EdgeInsets.all(32.h), child: CircularProgressIndicator(color: const Color(0xFF0d6efd))))
          else if (error != null)
            Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)))
          else if (reporte != null)
            _buildReporteStock(reporte)
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.filter_list, color: Colors.white),
              title: Text(_filtroStockBajo == 'true' ? 'Solo stock bajo' : 'Todos los insumos',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final filtro = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a1a),
                    title: Text('Filtrar Insumos', style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: Text('Todos', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, null)),
                        ListTile(title: Text('Solo stock bajo', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'true')),
                      ],
                    ),
                  ),
                );
                setState(() => _filtroStockBajo = filtro);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _consultarReporte() {
    ref.read(reportesProvider.notifier).loadReporteStockInsumos(
          stockBajo: _filtroStockBajo,
        );
  }

  Widget _buildReporteStock(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Resumen', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildRow('Total Insumos', '${reporte.resumen.totalInsumos}'),
                _buildRow('Stock Bajo', '${reporte.resumen.insumosStockBajo}',
                    valueColor: reporte.resumen.insumosStockBajo > 0 ? Colors.red : null),
                _buildRow('Valor Inventario', '\$${reporte.resumen.valorInventario.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF0d6efd)),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Lista de insumos
        Row(
          children: [
            Icon(Icons.science, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Insumos (${reporte.insumos.length})',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.insumos.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(child: Text('No hay insumos para mostrar',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))),
            ),
          )
        else
          ...reporte.insumos.map<Widget>((insumo) {
            final stockBajo = insumo.requiereReposicion;
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(insumo.nombre,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                        if (stockBajo) Icon(Icons.warning, color: Colors.red, size: 20.sp),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text('Stock: ${insumo.stockDisponible} ${insumo.unidadBase} (mín: ${insumo.stockMinimo})',
                        style: TextStyle(color: stockBajo ? Colors.red : Colors.white.withValues(alpha: 0.7), fontSize: 12.sp)),
                    if (insumo.valorInventario != null)
                      Text('Valor: \$${insumo.valorInventario!.toStringAsFixed(2)}',
                          style: TextStyle(color: const Color(0xFF0d6efd), fontSize: 12.sp)),
                    if (insumo.productosRelacionados.isNotEmpty)
                      Text('Productos: ${insumo.productosRelacionados.join(", ")}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.sp)),
                  ],
                ),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsStockInsumos(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsStockInsumos(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteStockInsumos(
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteStockInsumos(
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp)),
          Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 14.sp)),
        ],
      ),
    );
  }
}

// ============================================================================
// COSTO-BENEFICIO TAB
// ============================================================================
class _CostoBeneficioTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CostoBeneficioTab> createState() => _CostoBeneficioTabState();
}

class _CostoBeneficioTabState extends ConsumerState<_CostoBeneficioTab> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.costoBeneficioReporte;
    final isLoading = reportesState.isLoadingCostoBeneficio;
    final error = reportesState.errorCostoBeneficio;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Análisis Costo-Beneficio', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

          _buildDateFilters(),
          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null ? () => _consultarReporte() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF198754),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
            ),
          ),

          SizedBox(height: 24.h),

          if (isLoading)
            Center(child: Padding(padding: EdgeInsets.all(32.h), child: CircularProgressIndicator(color: const Color(0xFF0d6efd))))
          else if (error != null)
            Center(child: Text('Error: $error', style: TextStyle(color: Colors.red)))
          else if (reporte != null)
            _buildReporteCostoBeneficio(reporte)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(Icons.trending_up, size: 64.sp, color: Colors.white.withValues(alpha: 0.3)),
                    SizedBox(height: 16.h),
                    Text('Selecciona fechas y consulta', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Card(
      color: const Color(0xFF1a1a1a),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(_startDate != null ? 'Desde: ${DateFormat('dd/MM/yyyy').format(_startDate!)}' : 'Fecha inicio *',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020), lastDate: DateTime.now());
                if (date != null) setState(() => _startDate = date);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: Colors.white),
              title: Text(_endDate != null ? 'Hasta: ${DateFormat('dd/MM/yyyy').format(_endDate!)}' : 'Fecha fin *',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2020), lastDate: DateTime.now());
                if (date != null) setState(() => _endDate = date);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    ref.read(reportesProvider.notifier).loadReporteCostoBeneficio(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
        );
  }

  Widget _buildReporteCostoBeneficio(reporte) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          color: const Color(0xFF1a1a1a),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize, color: Color(0xFF0d6efd), size: 20.sp),
                    SizedBox(width: 8.w),
                    Text('Resumen General', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 12.h),
                _buildRow('Productos Analizados', '${reporte.resumen.totalProductosAnalizados}'),
                _buildRow('Cantidad Vendida', '${reporte.resumen.cantidadTotalVendida.toStringAsFixed(0)}'),
                _buildRow('Costo Total', '\$${reporte.resumen.costoTotalGeneral.toStringAsFixed(2)}', valueColor: Colors.red),
                _buildRow('Ingresos Total', '\$${reporte.resumen.ingresosTotalGeneral.toStringAsFixed(2)}', valueColor: const Color(0xFF198754)),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 24.h),
                _buildRow('Margen Total', '\$${reporte.resumen.margenTotalPesos.toStringAsFixed(2)}', isTotal: true),
                _buildRow('Margen %', '${reporte.resumen.margenTotalPorcentaje.toStringAsFixed(1)}%', isTotal: true),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Lista de productos
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Productos (${reporte.productos.length})',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.productos.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(child: Text('No hay datos para este período',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))),
            ),
          )
        else
          ...reporte.productos.map<Widget>((producto) {
            final margenPositivo = producto.margenPesos >= 0;
            final tieneAdvertencia = producto.tipoCalculo == 'sin_costo';

            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(producto.productoNombre,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                        if (tieneAdvertencia)
                          Icon(Icons.warning_amber, color: Colors.orange, size: 16.sp),
                      ],
                    ),
                    if (producto.categoriaNombre != null)
                      Text('${producto.categoriaNombre}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11.sp)),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vendido: ${producto.cantidadVendida.toStringAsFixed(0)}',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.sp)),
                            Text('Costo: \$${producto.costoTotal.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                            Text('Ingresos: \$${producto.ingresosTotal.toStringAsFixed(2)}',
                                style: TextStyle(color: const Color(0xFF198754), fontSize: 12.sp)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Margen',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.sp)),
                            Text('\$${producto.margenPesos.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: margenPositivo ? const Color(0xFF0d6efd) : Colors.red,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                            Text('${producto.margenPorcentaje.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: margenPositivo ? const Color(0xFF0d6efd) : Colors.red,
                                    fontSize: 12.sp)),
                          ],
                        ),
                      ],
                    ),
                    if (tieneAdvertencia)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text('⚠️ Sin costo registrado - el margen puede no ser real',
                            style: TextStyle(color: Colors.orange, fontSize: 10.sp, fontStyle: FontStyle.italic)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsCostoBeneficio(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsCostoBeneficio(Pagination pagination) {
    final currentPage = pagination.pageNumber;
    final hasNext = pagination.hasMoreElements;
    final hasPrevious = currentPage > 1;
    final totalPages = (pagination.totalElement / pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFF363636),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: hasPrevious
                ? () {
                    final newPage = currentPage - 1;
                    ref.read(reportesProvider.notifier).loadReporteCostoBeneficio(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: 20.sp),
            label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasPrevious ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          TextButton.icon(
            onPressed: hasNext
                ? () {
                    final newPage = currentPage + 1;
                    ref.read(reportesProvider.notifier).loadReporteCostoBeneficio(
                          startDate: _startDate!.toIso8601String().split('T')[0],
                          endDate: _endDate!.toIso8601String().split('T')[0],
                          pageNumber: newPage,
                        );
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: 20.sp),
            label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
            style: TextButton.styleFrom(
              foregroundColor: hasNext ? const Color(0xFF0d6efd) : const Color(0xFF6c757d),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
              color: Colors.white.withValues(alpha: isTotal ? 1.0 : 0.7),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(
              color: valueColor ?? (isTotal ? const Color(0xFF0d6efd) : Colors.white),
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
