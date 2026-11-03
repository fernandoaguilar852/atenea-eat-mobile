import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/productos_provider.dart';

class ProductosSearchWidget extends ConsumerStatefulWidget {
  const ProductosSearchWidget({super.key});

  @override
  ConsumerState<ProductosSearchWidget> createState() => _ProductosSearchWidgetState();
}

class _ProductosSearchWidgetState extends ConsumerState<ProductosSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _hideOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 56.h),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8.r),
            color: const Color(0xFF1a1a1a),
            child: _buildSearchResults(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, _) {
        final searchState = ref.watch(productosSearchProvider);

        if (searchState.isLoading) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            ),
          );
        }

        if (searchState.error != null) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Text(
              searchState.error!,
              style: TextStyle(
                color: const Color(0xFFdc3545),
                fontSize: 12.sp,
              ),
            ),
          );
        }

        if (searchState.productos.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'No se encontraron productos',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.sp,
              ),
            ),
          );
        }

        return Container(
          constraints: BoxConstraints(maxHeight: 300.h),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: searchState.productos.length,
            itemBuilder: (context, index) {
              final producto = searchState.productos[index];
              return ListTile(
                dense: true,
                leading: producto.imagen != null && producto.imagen!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          producto.imagen!,
                          width: 40.w,
                          height: 40.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40.w,
                              height: 40.h,
                              color: const Color(0xFF2a2a2a),
                              child: Icon(
                                Icons.image_not_supported,
                                size: 20.sp,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.inventory_2,
                          size: 20.sp,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                title: Text(
                  producto.nombre,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                  ),
                ),
                subtitle: Text(
                  '\$${producto.precio.toStringAsFixed(2)} - Stock: ${producto.stockTotal}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11.sp,
                  ),
                ),
                onTap: () {
                  ref.read(productosSearchProvider.notifier).selectProducto(producto);
                  _searchController.clear();
                  _hideOverlay();
                  _focusNode.unfocus();

                  // Filtrar por el producto seleccionado
                  ref.read(productosListProvider.notifier).loadProductos(
                        search: producto.nombre,
                      );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productosSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar producto (mín. 3 caracteres)...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF2a2a2a),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.6),
                size: 20.sp,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productosSearchProvider.notifier).clearSearch();
                        _hideOverlay();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.length >= 3) {
                ref.read(productosSearchProvider.notifier).searchProductos(value);
                _showOverlay();
              } else {
                ref.read(productosSearchProvider.notifier).clearSearch();
                _hideOverlay();
              }
            },
          ),
        ),

        // Chip del producto seleccionado
        if (searchState.selectedProducto != null) ...[
          SizedBox(height: 12.h),
          Chip(
            backgroundColor: const Color(0xFF0d6efd).withValues(alpha: 0.2),
            deleteIconColor: const Color(0xFF0d6efd),
            side: const BorderSide(color: Color(0xFF0d6efd)),
            label: Text(
              searchState.selectedProducto!.nombre,
              style: TextStyle(
                color: const Color(0xFF0d6efd),
                fontSize: 12.sp,
              ),
            ),
            onDeleted: () {
              ref.read(productosSearchProvider.notifier).clearSearch();
              ref.read(productosListProvider.notifier).loadProductos(search: null);
            },
          ),
        ],
      ],
    );
  }
}
