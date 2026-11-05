import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/movimientos_provider.dart';
import '../../../reportes/presentation/providers/reportes_provider.dart';
import '../../../reportes/domain/entities/producto.dart';
import '../../../reportes/domain/entities/insumo.dart';
import 'productos_tab_screen.dart';
import 'insumos_tab_screen.dart';
import '../widgets/movimiento_detalle_modal.dart';

class MovimientosScreen extends ConsumerStatefulWidget {
  const MovimientosScreen({super.key});

  @override
  ConsumerState<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends ConsumerState<MovimientosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          // Pestañas
          Container(
            color: const Color(0xFF1a1a1a),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF0d6efd),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              tabs: [
                Tab(
                  icon: Icon(Icons.list_alt, size: 24.sp),
                  text: 'Todos',
                ),
                Tab(
                  icon: Icon(Icons.inventory_2, size: 24.sp),
                  text: 'Productos',
                ),
                Tab(
                  icon: Icon(Icons.science, size: 24.sp),
                  text: 'Insumos',
                ),
              ],
            ),
          ),
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _TodosTab(),
                ProductosTab(),
                InsumosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de Todos los movimientos
class _TodosTab extends ConsumerStatefulWidget {
  const _TodosTab();

  @override
  ConsumerState<_TodosTab> createState() => _TodosTabState();
}

class _TodosTabState extends ConsumerState<_TodosTab> {
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  Producto? _selectedProducto;
  Insumo? _selectedInsumo;
  final TextEditingController _productoController = TextEditingController();
  final TextEditingController _insumoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Cargar movimientos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movimientosProvider.notifier).loadMovimientos();
    });

    // Listener para mostrar/ocultar botón de scroll to top
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 200 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _productoController.dispose();
    _insumoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectFechaDesde() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0d6efd),
              surface: Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaDesde) {
      setState(() {
        _fechaDesde = picked;
      });
    }
  }

  Future<void> _selectFechaHasta() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0d6efd),
              surface: Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaHasta) {
      setState(() {
        _fechaHasta = picked;
      });
    }
  }

  void _aplicarFiltros() {
    // Validar que fecha hasta sea mayor o igual a fecha desde
    if (_fechaDesde != null && _fechaHasta != null) {
      if (_fechaHasta!.isBefore(_fechaDesde!)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a1a),
            title: Text(
              'Error de validación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'La fecha hasta debe ser mayor o igual a la fecha desde',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14.sp,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Entendido',
                  style: TextStyle(
                    color: const Color(0xFF0d6efd),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }
    }

    ref.read(movimientosProvider.notifier).loadMovimientos(
      pageNumber: 1,
      fechaDesde: _fechaDesde != null ? _formatDate(_fechaDesde!) : null,
      fechaHasta: _fechaHasta != null ? _formatDate(_fechaHasta!) : null,
      productoId: _selectedProducto?.productoId,
      insumoId: _selectedInsumo?.insumoId,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
      _selectedProducto = null;
      _selectedInsumo = null;
      _productoController.clear();
      _insumoController.clear();
    });
    ref.read(productosSearchProvider.notifier).clearSearch();
    ref.read(insumosSearchProvider.notifier).clearSearch();
    ref.read(movimientosProvider.notifier).loadMovimientos(
      pageNumber: 1,
      fechaDesde: null,
      fechaHasta: null,
      productoId: null,
      insumoId: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final movimientosState = ref.watch(movimientosProvider);
    final isLoading = movimientosState.isLoading;
    final error = movimientosState.error;
    final movimientosResponse = movimientosState.movimientosResponse;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Filtros de fecha
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF363636),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha Desde',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          InkWell(
                            onTap: _selectFechaDesde,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2a2a),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFF404040),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fechaDesde != null
                                        ? _formatDate(_fechaDesde!)
                                        : 'Seleccionar',
                                    style: TextStyle(
                                      color: _fechaDesde != null
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: const Color(0xFF0d6efd),
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha Hasta',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          InkWell(
                            onTap: _selectFechaHasta,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2a2a2a),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: const Color(0xFF404040),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fechaHasta != null
                                        ? _formatDate(_fechaHasta!)
                                        : 'Seleccionar',
                                    style: TextStyle(
                                      color: _fechaHasta != null
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: const Color(0xFF0d6efd),
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Filtro de Producto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextFormField(
                      controller: _productoController,
                      enabled: _selectedInsumo == null,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: _selectedInsumo != null
                            ? 'Desbloquear limpiando insumo'
                            : 'Buscar producto...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                        ),
                        filled: true,
                        fillColor: _selectedInsumo != null
                            ? const Color(0xFF1a1a1a)
                            : const Color(0xFF2a2a2a),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF404040),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF404040),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF0d6efd),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        suffixIcon: _selectedProducto != null
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18.sp),
                                color: Colors.white.withValues(alpha: 0.7),
                                onPressed: () {
                                  setState(() {
                                    _selectedProducto = null;
                                    _productoController.clear();
                                  });
                                  ref.read(productosSearchProvider.notifier).clearSearch();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        if (_selectedInsumo == null) {
                          if (value.length >= 3) {
                            ref.read(productosSearchProvider.notifier).searchProductos(value);
                          } else {
                            ref.read(productosSearchProvider.notifier).clearSearch();
                          }
                        }
                      },
                    ),
                    // Resultados de búsqueda de productos
                    Consumer(
                      builder: (context, ref, child) {
                        final productosState = ref.watch(productosSearchProvider);
                        if (productosState.productos.isNotEmpty && _selectedProducto == null) {
                          return Container(
                            margin: EdgeInsets.only(top: 8.h),
                            constraints: BoxConstraints(maxHeight: 150.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2d2d2d),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: productosState.productos.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final producto = productosState.productos[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    producto.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Código: ${producto.codExterno}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedProducto = producto;
                                      _productoController.text = producto.nombre;
                                    });
                                    ref.read(productosSearchProvider.notifier).clearSearch();
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Filtro de Insumo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insumo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    TextFormField(
                      controller: _insumoController,
                      enabled: _selectedProducto == null,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: _selectedProducto != null
                            ? 'Desbloquear limpiando producto'
                            : 'Buscar insumo...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                        ),
                        filled: true,
                        fillColor: _selectedProducto != null
                            ? const Color(0xFF1a1a1a)
                            : const Color(0xFF2a2a2a),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF404040),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF404040),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.r),
                          borderSide: BorderSide(
                            color: const Color(0xFF0d6efd),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        suffixIcon: _selectedInsumo != null
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 18.sp),
                                color: Colors.white.withValues(alpha: 0.7),
                                onPressed: () {
                                  setState(() {
                                    _selectedInsumo = null;
                                    _insumoController.clear();
                                  });
                                  ref.read(insumosSearchProvider.notifier).clearSearch();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        if (_selectedProducto == null) {
                          if (value.length >= 3) {
                            ref.read(insumosSearchProvider.notifier).searchInsumos(value);
                          } else {
                            ref.read(insumosSearchProvider.notifier).clearSearch();
                          }
                        }
                      },
                    ),
                    // Resultados de búsqueda de insumos
                    Consumer(
                      builder: (context, ref, child) {
                        final insumosState = ref.watch(insumosSearchProvider);
                        if (insumosState.insumos.isNotEmpty && _selectedInsumo == null) {
                          return Container(
                            margin: EdgeInsets.only(top: 8.h),
                            constraints: BoxConstraints(maxHeight: 150.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2d2d2d),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: insumosState.insumos.length,
                              separatorBuilder: (_, __) => Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final insumo = insumosState.insumos[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    insumo.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Unidad: ${insumo.unidadBase}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedInsumo = insumo;
                                      _insumoController.text = insumo.nombre;
                                    });
                                    ref.read(insumosSearchProvider.notifier).clearSearch();
                                  },
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
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
                        onPressed: _aplicarFiltros,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF198754),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          'Consultar Movimientos',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: CircularProgressIndicator(color: const Color(0xFF0d6efd)),
              ),
            )
          else if (error != null)
            Center(
              child: Text(
                'Error: $error',
                style: TextStyle(color: Colors.red, fontSize: 14.sp),
              ),
            )
          else if (movimientosResponse != null) ...[
            Text(
              'Todos los Movimientos (${movimientosResponse.pagination.totalElement})',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),

            // Lista de movimientos
            ...movimientosResponse.movimientos.map((movimiento) {
              final tipoLower = movimiento.tipo.toLowerCase();
              final isNegativo = tipoLower == 'salida' || tipoLower == 'venta';
              final iconData = movimiento.productoId != null ? Icons.inventory_2 : Icons.science;

              return InkWell(
                onTap: () {
                  // Validar si es tipo venta
                  if (movimiento.tipo.toLowerCase() == 'venta') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1a1a1a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: const Color(0xFFffc107), width: 2),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.block, color: const Color(0xFFffc107), size: 28.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Acción no permitida',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Los movimientos de tipo VENTA no se pueden visualizar, editar ni eliminar.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14.sp,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFffc107),
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            ),
                            child: Text(
                              'Entendido',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (context) => MovimientoDetalleModal(
                      movimientoId: movimiento.movimientoId,
                    ),
                  );
                },
                child: Card(
                  color: const Color(0xFF1a1a1a),
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              iconData,
                              color: isNegativo ? Colors.red : Colors.green,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movimiento.nombre,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    movimiento.tipo.toUpperCase(),
                                    style: TextStyle(
                                      color: const Color(0xFF0d6efd),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isNegativo ? '-' : '+'}${movimiento.cantidad.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isNegativo ? Colors.red : Colors.green,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          movimiento.observacion,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Fecha: ${DateTime.parse(movimiento.fecha).toLocal().toString().split('.')[0]}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Controles de paginación
            if (movimientosResponse.pagination.totalElement > 0) ...[
              SizedBox(height: 16.h),
              Container(
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
                      onPressed: movimientosState.currentPage > 1
                          ? () {
                              final newPage = movimientosState.currentPage - 1;
                              ref.read(movimientosProvider.notifier).loadMovimientos(pageNumber: newPage);
                            }
                          : null,
                      icon: Icon(Icons.chevron_left, size: 20.sp),
                      label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: movimientosState.currentPage > 1
                            ? const Color(0xFF0d6efd)
                            : const Color(0xFF6c757d),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                    Text(
                      'Página ${movimientosState.currentPage} de ${(movimientosResponse.pagination.totalElement / 10).ceil()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: movimientosResponse.pagination.hasMoreElements
                          ? () {
                              final newPage = movimientosState.currentPage + 1;
                              ref.read(movimientosProvider.notifier).loadMovimientos(pageNumber: newPage);
                            }
                          : null,
                      label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                      icon: Icon(Icons.chevron_right, size: 20.sp),
                      style: TextButton.styleFrom(
                        foregroundColor: movimientosResponse.pagination.hasMoreElements
                            ? const Color(0xFF0d6efd)
                            : const Color(0xFF6c757d),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Text(
                  'No hay movimientos para mostrar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
        ],
          ),
        ),

        // Botón de scroll to top
        if (_showScrollToTop)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Material(
              color: const Color(0xFF0d6efd),
              borderRadius: BorderRadius.circular(22.r),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(22.r),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

