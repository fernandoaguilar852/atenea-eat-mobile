import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/pagination.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/tipo_producto.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/operador.dart';
class VentasTab extends ConsumerStatefulWidget {
  const VentasTab({super.key});

  @override
  ConsumerState<VentasTab> createState() => VentasTabState();
}

class VentasTabState extends ConsumerState<VentasTab> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  final TextEditingController _productSearchController = TextEditingController();
  final TextEditingController _consumidorSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
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
    _productSearchController.dispose();
    _consumidorSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportesState = ref.watch(reportesProvider);
    final reporte = reportesState.ventasReporte;
    final isLoading = reportesState.isLoadingVentas;
    final error = reportesState.errorVentas;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
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
