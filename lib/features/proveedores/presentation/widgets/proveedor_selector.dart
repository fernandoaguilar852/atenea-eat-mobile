import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/proveedor.dart';
import '../providers/proveedores_provider.dart';

class ProveedorSelector extends ConsumerStatefulWidget {
  const ProveedorSelector({super.key});

  @override
  ConsumerState<ProveedorSelector> createState() => _ProveedorSelectorState();
}

class _ProveedorSelectorState extends ConsumerState<ProveedorSelector> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(proveedoresProvider.notifier).searchProveedores(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedoresState = ref.watch(proveedoresProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF0d6efd), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0d6efd),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Seleccionar Proveedor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                    iconSize: 20.sp,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Campo de búsqueda
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Escribe al menos 3 caracteres para buscar...',
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
            ),

            // Lista de resultados
            Flexible(
              child: _buildResultsList(proveedoresState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(ProveedoresState state) {
    if (state.searchQuery.length < 3) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64.sp,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                'Escribe al menos 3 caracteres\npara buscar proveedores',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: const Color(0xFF0d6efd)),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'Error: ${state.error}',
            style: TextStyle(color: Colors.red, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final proveedores = state.proveedoresResponse?.proveedores ?? [];

    if (proveedores.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 64.sp,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                'No se encontraron proveedores',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: proveedores.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.white.withValues(alpha: 0.1),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final proveedor = proveedores[index];
        return ListTile(
          onTap: () => Navigator.pop(context, proveedor),
          leading: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.business,
              color: const Color(0xFF0d6efd),
              size: 20.sp,
            ),
          ),
          title: Text(
            proveedor.nombre,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: proveedor.nit.isNotEmpty
              ? Text(
                  'NIT: ${proveedor.nit}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chevron_right,
            color: const Color(0xFF0d6efd),
            size: 20.sp,
          ),
        );
      },
    );
  }
}
