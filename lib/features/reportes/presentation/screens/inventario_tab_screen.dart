import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/pagination.dart';
class InventarioTab extends ConsumerStatefulWidget {
  const InventarioTab({super.key});

  @override
  ConsumerState<InventarioTab> createState() => InventarioTabState();
}

class InventarioTabState extends ConsumerState<InventarioTab> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  String? _tipoMovimiento;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
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
    final reporte = reportesState.inventarioReporte;
    final isLoading = reportesState.isLoadingInventario;
    final error = reportesState.errorInventario;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
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
                  child: Text('Consultar Reporte', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
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

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Búsqueda de producto
            _buildProductSearch(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Búsqueda de insumo
            _buildInsumoSearch(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearch() {
    final productosState = ref.watch(productosSearchProvider);
    final selectedProducto = productosState.selectedProducto;

    if (selectedProducto != null) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0d6efd).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF0d6efd)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF0d6efd), size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedProducto.nombre,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Text(
                    'Código: ${selectedProducto.codExterno}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
              onPressed: () => ref.read(productosSearchProvider.notifier).clearSearch(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Buscar producto (opcional)...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
            suffixIcon: productosState.isLoading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(color: Color(0xFF0d6efd), strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF2d2d2d),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
          ),
          onChanged: (value) {
            if (value.length >= 3) {
              ref.read(productosSearchProvider.notifier).searchProductos(value);
            } else if (value.isEmpty) {
              ref.read(productosSearchProvider.notifier).clearSearch();
            }
          },
        ),
        if (productosState.productos.isNotEmpty && selectedProducto == null) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: productosState.productos.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              itemBuilder: (context, index) {
                final producto = productosState.productos[index];
                return ListTile(
                  title: Text(producto.nombre, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  subtitle: Text(
                    'Código: ${producto.codExterno} - \$${producto.precio}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.sp),
                  ),
                  onTap: () => ref.read(productosSearchProvider.notifier).selectProducto(producto),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsumoSearch() {
    final insumosState = ref.watch(insumosSearchProvider);
    final selectedInsumo = insumosState.selectedInsumo;

    if (selectedInsumo != null) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0d6efd).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF0d6efd)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF0d6efd), size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedInsumo.nombre,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  Text(
                    'Stock: ${selectedInsumo.stockActual} ${selectedInsumo.unidadBase}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
              onPressed: () => ref.read(insumosSearchProvider.notifier).clearSearch(),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Buscar insumo (opcional)...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(Icons.science, color: Colors.white.withValues(alpha: 0.7)),
            suffixIcon: insumosState.isLoading
                ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(color: Color(0xFF0d6efd), strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF2d2d2d),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
          ),
          onChanged: (value) {
            if (value.length >= 3) {
              ref.read(insumosSearchProvider.notifier).searchInsumos(value);
            } else if (value.isEmpty) {
              ref.read(insumosSearchProvider.notifier).clearSearch();
            }
          },
        ),
        if (insumosState.insumos.isNotEmpty && selectedInsumo == null) ...[
          SizedBox(height: 8.h),
          Container(
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2d2d2d),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: insumosState.insumos.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              itemBuilder: (context, index) {
                final insumo = insumosState.insumos[index];
                return ListTile(
                  title: Text(insumo.nombre, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  subtitle: Text(
                    'Stock: ${insumo.stockActual} ${insumo.unidadBase}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12.sp),
                  ),
                  onTap: () => ref.read(insumosSearchProvider.notifier).selectInsumo(insumo),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    final productosState = ref.read(productosSearchProvider);
    final productoId = productosState.selectedProducto?.productoId;
    final insumosState = ref.read(insumosSearchProvider);
    final insumoId = insumosState.selectedInsumo?.insumoId;

    ref.read(reportesProvider.notifier).loadReporteInventarioConsumido(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
          tipoMovimiento: _tipoMovimiento,
          productoId: productoId,
          insumoId: insumoId,
        );
  }

  void _limpiarFiltros() {
    // Limpiar filtro de productos
    ref.read(productosSearchProvider.notifier).clearSearch();

    // Limpiar filtro de insumos
    ref.read(insumosSearchProvider.notifier).clearSearch();

    // Limpiar tipo de movimiento
    setState(() {
      _tipoMovimiento = null;
    });
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
