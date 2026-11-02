import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';

import '../../domain/entities/pagination.dart';
class StockProductosTab extends ConsumerStatefulWidget {
  const StockProductosTab({super.key});

  @override
  ConsumerState<StockProductosTab> createState() => StockProductosTabState();
}

class StockProductosTabState extends ConsumerState<StockProductosTab> {
  String? _filtroStockBajo;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Cargar reporte al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportesProvider.notifier).loadReporteStockProductos();
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.stockProductosReporte;
    final isLoading = reportesState.isLoadingStockProductos;
    final error = reportesState.errorStockProductos;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Stock de Productos', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

          _buildFilters(),
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
                  onPressed: () => _consultarReporte(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF198754),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
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

            // Búsqueda de productos
            _buildProductSearch(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

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

  Widget _buildProductSearch() {
    final productosState = ref.watch(productosSearchProvider);
    final selectedProducto = productosState.selectedProducto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Producto',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        // Si hay producto seleccionado, mostrar chip
        if (selectedProducto != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFF0d6efd), width: 1),
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
                  onPressed: () {
                    ref.read(productosSearchProvider.notifier).clearSearch();
                  },
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF0d6efd),
                  iconSize: 20.sp,
                ),
              ],
            ),
          )
        else
          // Campo de búsqueda
          TextField(
            onChanged: (value) {
              ref.read(productosSearchProvider.notifier).searchProductos(value);
            },
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Buscar producto (min. 3 caracteres)...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
              suffixIcon: productosState.isLoading
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFF0d6efd),
                        ),
                      ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),

        // Mostrar resultados de búsqueda
        if (productosState.productos.isNotEmpty && selectedProducto == null) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF0d6efd).withValues(alpha: 0.3),
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
                  onTap: () {
                    ref.read(productosSearchProvider.notifier).selectProducto(producto);
                  },
                  title: Text(
                    producto.nombre,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Código: ${producto.codExterno}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        'Precio: \$${producto.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: const Color(0xFF0d6efd),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  dense: true,
                );
              },
            ),
          ),
        ],

        // Mostrar error si existe
        if (productosState.error != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              productosState.error!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  void _consultarReporte() {
    final productosState = ref.read(productosSearchProvider);
    final nombreProducto = productosState.selectedProducto?.nombre;

    ref.read(reportesProvider.notifier).loadReporteStockProductos(
          nombreProducto: nombreProducto,
          stockBajo: _filtroStockBajo,
        );
  }

  void _limpiarFiltros() {
    // Limpiar búsqueda de productos
    ref.read(productosSearchProvider.notifier).clearSearch();

    // Limpiar filtro de stock bajo
    setState(() {
      _filtroStockBajo = null;
    });
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
