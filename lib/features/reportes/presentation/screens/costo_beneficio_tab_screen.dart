import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/tipo_producto.dart';
import '../../domain/entities/pagination.dart';
class CostoBeneficioTab extends ConsumerStatefulWidget {
  const CostoBeneficioTab({super.key});

  @override
  ConsumerState<CostoBeneficioTab> createState() => CostoBeneficioTabState();
}

class CostoBeneficioTabState extends ConsumerState<CostoBeneficioTab> {
  DateTime? _startDate;
  DateTime? _endDate;
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
    final reporte = reportesState.costoBeneficioReporte;
    final isLoading = reportesState.isLoadingCostoBeneficio;
    final error = reportesState.errorCostoBeneficio;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Análisis Costo-Beneficio', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),

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
                  onPressed: _startDate != null && _endDate != null ? () => _consultarReporte() : null,
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

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Búsqueda de productos
            _buildProductSearch(),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Selector de tipo de producto
            _buildTipoProductoSelector(),
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

  Widget _buildTipoProductoSelector() {
    final tiposProductoState = ref.watch(tiposProductoProvider);
    final selectedTipo = tiposProductoState.selectedTipo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Producto',
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
              hintText: 'Seleccionar tipo...',
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
                  'Todos los tipos',
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

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    final productosState = ref.read(productosSearchProvider);
    final tiposProductoState = ref.read(tiposProductoProvider);

    final productoId = productosState.selectedProducto?.productoId;
    final tipoProductoId = tiposProductoState.selectedTipo?.tipoProductoId;

    ref.read(reportesProvider.notifier).loadReporteCostoBeneficio(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
          productoId: productoId,
          tipoProductoId: tipoProductoId,
        );
  }

  void _limpiarFiltros() {
    // Limpiar búsqueda de productos
    ref.read(productosSearchProvider.notifier).clearSearch();

    // Limpiar tipo de producto
    ref.read(tiposProductoProvider.notifier).selectTipo(null);
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
