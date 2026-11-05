import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../productos/presentation/providers/productos_provider.dart';
import '../../../productos/domain/entities/producto.dart';
import '../../../categorias/presentation/providers/categorias_provider.dart';
import '../../../categorias/domain/entities/categoria.dart';
// import '../../../reportes/domain/entities/producto.dart' as reportes_producto; // TODO: Para funcionalidad futura
import 'producto_detail_screen.dart';

class ProductosTab extends ConsumerStatefulWidget {
  const ProductosTab({super.key});

  @override
  ConsumerState<ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends ConsumerState<ProductosTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  Categoria? _selectedCategoria;
  bool _showScrollToTop = false;
  // reportes_producto.Producto? _selectedProducto; // TODO: Implementar selección de producto

  @override
  void initState() {
    super.initState();
    // Cargar productos y categorías al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productosListProvider.notifier).loadProductos();
      ref.read(categoriasProvider.notifier).loadCategorias();
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
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(productosListProvider.notifier).loadProductos(
        search: query.isEmpty ? null : query,
      );
    });
  }

  void _onCategoriaChanged(Categoria? categoria) {
    setState(() {
      _selectedCategoria = categoria;
    });

    ref.read(productosListProvider.notifier).loadProductos(
      tipoProductoId: categoria?.tipoProductoId,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoria = null;
      _searchController.clear();
    });

    ref.read(productosListProvider.notifier).loadProductos(
      search: null,
      tipoProductoId: null,
    );
  }

  Future<void> _showProductoDetail(Producto producto) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductoDetailScreen(producto: producto),
    );

    // Si se registró un movimiento, recargar la lista de productos
    if (result == true && mounted) {
      ref.read(productosListProvider.notifier).loadProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosState = ref.watch(productosListProvider);
    final categoriasState = ref.watch(categoriasProvider);
    final isLoading = productosState.isLoading;
    final error = productosState.error;
    final productosResponse = productosState.productosResponse;

    // Filtrar solo productos que NO usan receta (usaReceta = false)
    final productosFiltrados = productosResponse?.productos
        .where((producto) => producto.usaReceta == false)
        .toList() ?? [];

    return Stack(
      children: [
        Column(
          children: [
        // Filtros
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            border: Border(
              bottom: BorderSide(color: const Color(0xFF363636), width: 1),
            ),
          ),
          child: Column(
            children: [
              // Campo de búsqueda
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13.sp,
                  ),
                  prefixIcon: Icon(Icons.search, color: const Color(0xFF0d6efd)),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF404040)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF404040)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF0d6efd)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
              ),
              SizedBox(height: 12.h),

              // Selector de categoría
              DropdownButtonFormField<Categoria>(
                value: _selectedCategoria,
                onChanged: _onCategoriaChanged,
                dropdownColor: const Color(0xFF2a2a2a),
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  labelStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2a2a2a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF404040)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF404040)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: const Color(0xFF0d6efd)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
                hint: Text(
                  'Todas las categorías',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                ),
                items: [
                  DropdownMenuItem<Categoria>(
                    value: null,
                    child: Text('Todas las categorías'),
                  ),
                  ...?categoriasState.categoriasResponse?.categorias.map((categoria) {
                    return DropdownMenuItem<Categoria>(
                      value: categoria,
                      child: Text(categoria.nombre),
                    );
                  }),
                ],
              ),

              // Botón limpiar filtros
              if (_selectedCategoria != null || _searchController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: Icon(Icons.clear_all, size: 18.sp),
                      label: Text('Limpiar filtros', style: TextStyle(fontSize: 14.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Lista de productos o estados
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: const Color(0xFF0d6efd)),
                )
              : error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          'Error: $error',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : productosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64.sp,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No se encontraron productos',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            itemCount: productosFiltrados.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final producto = productosFiltrados[index];
              final stockDisponible = producto.stockTotal - producto.stockReservado;
              final stockBajo = stockDisponible <= producto.stockMinimo;

              return Card(
                color: const Color(0xFF1a1a1a),
                child: InkWell(
                  onTap: () => _showProductoDetail(producto),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        // Imagen del producto
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: const Color(0xFF404040),
                            ),
                          ),
                          child: producto.imagen != null && producto.imagen!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    producto.imagen!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.inventory_2,
                                      color: const Color(0xFF0d6efd),
                                      size: 30.sp,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.inventory_2,
                                  color: const Color(0xFF0d6efd),
                                  size: 30.sp,
                                ),
                        ),
                        SizedBox(width: 12.w),

                        // Información del producto
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                producto.nombre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Código: ${producto.codExterno}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 14.sp,
                                    color: stockBajo ? Colors.orange : Colors.green,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Stock: $stockDisponible ${producto.sigla}',
                                    style: TextStyle(
                                      color: stockBajo ? Colors.orange : Colors.green,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Icono de flecha
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Controles de paginación
        if ((productosResponse?.pagination.totalElement ?? 0) > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFF363636),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: productosState.currentPage > 1
                      ? () {
                          ref.read(productosListProvider.notifier).loadProductos(
                                pageNumber: productosState.currentPage - 1,
                              );
                        }
                      : null,
                  icon: Icon(Icons.chevron_left, size: 20.sp),
                  label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                  style: TextButton.styleFrom(
                    foregroundColor: productosState.currentPage > 1
                        ? const Color(0xFF0d6efd)
                        : const Color(0xFF6c757d),
                  ),
                ),
                Text(
                  'Página ${productosState.currentPage} de ${((productosResponse?.pagination.totalElement ?? 0) / 10).ceil()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                TextButton.icon(
                  onPressed: (productosResponse?.pagination.hasMoreElements ?? false)
                      ? () {
                          ref.read(productosListProvider.notifier).loadProductos(
                                pageNumber: productosState.currentPage + 1,
                              );
                        }
                      : null,
                  label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                  icon: Icon(Icons.chevron_right, size: 20.sp),
                  style: TextButton.styleFrom(
                    foregroundColor: (productosResponse?.pagination.hasMoreElements ?? false)
                        ? const Color(0xFF0d6efd)
                        : const Color(0xFF6c757d),
                  ),
                ),
              ],
            ),
          ),
          ],
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
