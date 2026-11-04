import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/producto.dart';
import '../providers/productos_provider.dart';
import '../widgets/producto_card.dart';
import '../widgets/productos_search_widget.dart';
import '../widgets/crear_producto_modal.dart';
import '../widgets/editar_producto_modal.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../categorias/domain/entities/categoria.dart';

class ProductosScreen extends ConsumerStatefulWidget {
  const ProductosScreen({super.key});

  @override
  ConsumerState<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  Categoria? _selectedCategoria;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriasProvider.notifier).loadCategorias();
      ref.read(productosListProvider.notifier).loadProductos();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _mostrarFiltroActivo() async {
    final state = ref.read(productosListProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Filtrar por Estado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.check_circle,
                color: state.activo == true ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Solo activos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(activo: true);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cancel,
                color: state.activo == false ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Solo inactivos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(activo: false);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.all_inclusive,
                color: state.activo == null ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Todos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(activo: null);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarFiltroCategoria() async {
    final categoriasState = ref.read(categoriasProvider);
    final categorias = categoriasState.categoriasResponse?.categorias ?? [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Filtrar por Categoría',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: Icon(
                  Icons.all_inclusive,
                  color: _selectedCategoria == null ? const Color(0xFF0d6efd) : Colors.white,
                ),
                title: const Text('Todas las categorías', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _selectedCategoria = null);
                  Navigator.pop(context);
                  ref.read(productosListProvider.notifier).loadProductos(tipoProductoId: null);
                },
              ),
              ...categorias.map((categoria) {
                return ListTile(
                  leading: Icon(
                    Icons.category,
                    color: _selectedCategoria?.tipoProductoId == categoria.tipoProductoId
                        ? const Color(0xFF0d6efd)
                        : Colors.white,
                  ),
                  title: Text(
                    categoria.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() => _selectedCategoria = categoria);
                    Navigator.pop(context);
                    ref.read(productosListProvider.notifier).loadProductos(
                          tipoProductoId: categoria.tipoProductoId,
                        );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFiltroReceta() async {
    final state = ref.read(productosListProvider);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Filtrar por Receta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.all_inclusive,
                color: state.usaReceta == null ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Todos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(usaReceta: null);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.restaurant_menu,
                color: state.usaReceta == true ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Con receta', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(usaReceta: true);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.do_not_disturb_alt,
                color: state.usaReceta == false ? const Color(0xFF0d6efd) : Colors.white,
              ),
              title: const Text('Sin receta', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(productosListProvider.notifier).loadProductos(usaReceta: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _selectedCategoria = null;
    });
    ref.read(productosSearchProvider.notifier).clearSearch();
    ref.read(productosListProvider.notifier).loadProductos(
          activo: true,
          tipoProductoId: null,
          usaReceta: null,
          search: null,
        );
  }

  Future<void> _confirmarEliminar(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFffc107),
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Confirmar Eliminación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar el producto "${producto.nombre}"?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFdc3545),
            ),
            child: Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      final error = await ref.read(productosListProvider.notifier).deleteProducto(
        productoId: producto.productoId,
      );

      if (mounted) {
        if (error == null) {
          // Eliminación exitosa
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: const Color(0xFF28a745),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Éxito',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Producto "${producto.nombre}" eliminado exitosamente',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28a745),
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Error al eliminar
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1a1a1a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: const Color(0xFFdc3545),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              content: Text(
                error,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d6efd),
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _mostrarEditarProducto(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => EditarProductoModal(producto: producto),
    );
  }

  void _mostrarCrearProducto() {
    showDialog(
      context: context,
      builder: (context) => const CrearProductoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productosListProvider);

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Gestión de Productos',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Administra el catálogo de productos',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 24.h),

                // Widget de búsqueda
                const ProductosSearchWidget(),
                SizedBox(height: 16.h),

                // Botones de filtros
                Row(
                  children: [
                    // Filtro de estado
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _mostrarFiltroActivo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.filter_list, size: 16.sp),
                        label: Text(
                          state.activo == null
                              ? 'Todos'
                              : state.activo == true
                                  ? 'Activos'
                                  : 'Inactivos',
                          style: TextStyle(fontSize: 11.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Filtro de categoría
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _mostrarFiltroCategoria,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.category, size: 16.sp),
                        label: Text(
                          _selectedCategoria?.nombre ?? 'Categoría',
                          style: TextStyle(fontSize: 11.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Filtro de receta
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _mostrarFiltroReceta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d6efd),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.restaurant_menu, size: 16.sp),
                        label: Text(
                          state.usaReceta == null
                              ? 'Receta'
                              : state.usaReceta == true
                                  ? 'Con'
                                  : 'Sin',
                          style: TextStyle(fontSize: 11.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Botón limpiar filtros
                    IconButton(
                      onPressed: _limpiarFiltros,
                      icon: const Icon(Icons.clear_all),
                      color: Colors.orange,
                      iconSize: 28.sp,
                      tooltip: 'Limpiar filtros',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        padding: EdgeInsets.all(10.w),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Loading indicator
                if (state.isLoading && state.productosResponse == null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: CircularProgressIndicator(
                        color: const Color(0xFF0d6efd),
                      ),
                    ),
                  )

                // Error message
                else if (state.error != null && state.productosResponse == null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: const Color(0xFFdc3545),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.error!,
                            style: TextStyle(
                              color: const Color(0xFFdc3545),
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )

                // Lista de productos
                else if (state.productosResponse != null && state.productosResponse!.productos.isNotEmpty)
                  ...state.productosResponse!.productos.map((producto) {
                    return ProductoCard(
                      producto: producto,
                      onEdit: () => _mostrarEditarProducto(producto),
                      onDelete: () => _confirmarEliminar(producto),
                    );
                  })
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.sp,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No hay productos',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 16.h),

                // Paginación
                if (state.productosResponse != null && state.productosResponse!.productos.isNotEmpty)
                  _buildPaginacion(state.productosResponse!),
              ],
            ),
          ),

          // Botón crear producto (superior derecha)
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Material(
              color: const Color(0xFF0d6efd),
              borderRadius: BorderRadius.circular(22.r),
              elevation: 4,
              child: InkWell(
                onTap: _mostrarCrearProducto,
                borderRadius: BorderRadius.circular(22.r),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),

          // Botón scroll to top
          if (_showScrollToTop)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Material(
                color: const Color(0xFF0d6efd),
                borderRadius: BorderRadius.circular(22.r),
                elevation: 4,
                child: InkWell(
                  onTap: _scrollToTop,
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
      ),
    );
  }

  Widget _buildPaginacion(productosResponse) {
    final state = ref.watch(productosListProvider);
    final totalPages = (productosResponse.pagination.totalElement /
                        productosResponse.pagination.pageSize).ceil();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF363636)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.currentPage > 1
                  ? () => ref.read(productosListProvider.notifier)
                          .loadProductos(pageNumber: state.currentPage - 1)
                  : null,
              icon: Icon(Icons.chevron_left, size: 18.sp),
              label: Text('Anterior', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a2a2a),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF1a1a1a),
                disabledForegroundColor: Colors.white38,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Indicador de página
          Column(
            children: [
              Text(
                'Pag. ${state.currentPage} de $totalPages',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${productosResponse.pagination.totalElement} productos',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Botón siguiente
          Expanded(
            child: ElevatedButton.icon(
              onPressed: productosResponse.pagination.hasMoreElements
                  ? () => ref.read(productosListProvider.notifier)
                          .loadProductos(pageNumber: state.currentPage + 1)
                  : null,
              icon: Icon(Icons.chevron_right, size: 18.sp),
              label: Text('Siguiente', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a2a2a),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF1a1a1a),
                disabledForegroundColor: Colors.white38,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
