import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/insumos_provider.dart';
import '../widgets/insumo_card.dart';
import '../widgets/crear_insumo_modal.dart';
import '../widgets/editar_insumo_modal.dart';
import '../../domain/entities/insumo.dart';

class InsumosScreen extends ConsumerStatefulWidget {
  const InsumosScreen({super.key});

  @override
  ConsumerState<InsumosScreen> createState() => _InsumosScreenState();
}

class _InsumosScreenState extends ConsumerState<InsumosScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool? _filtroActivo = true; // null = todos, true = activos, false = inactivos
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();

    // LAZY LOADING: No cargar insumos automáticamente
    // Los datos se cargarán cuando el widget sea visible

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

  Future<void> _confirmarEliminar(Insumo insumo) async {
    // Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFdc3545),
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Confirmar Eliminación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar este insumo?',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insumo: ${insumo.nombre}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Unidad: ${insumo.unidadBase}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: const Color(0xFFdc3545),
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: const Color(0xFF6c757d),
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
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      // Llamar al método de eliminar
      final error = await ref.read(insumosListProvider.notifier).deleteInsumo(
        insumoId: insumo.insumoId,
        isActivo: insumo.activo,
      );

      if (mounted) {
        // Mostrar resultado en un diálogo
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a1a),
            title: Row(
              children: [
                Icon(
                  error == null ? Icons.check_circle : Icons.error,
                  color: error == null ? const Color(0xFF198754) : const Color(0xFFdc3545),
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  error == null ? 'Éxito' : 'Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              error ?? 'Insumo eliminado exitosamente',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14.sp,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: error == null ? const Color(0xFF198754) : const Color(0xFF0d6efd),
                ),
                child: Text(
                  'Aceptar',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _editarInsumo(Insumo insumo) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditarInsumoModal(insumo: insumo),
    );

    if (result == true && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Insumo actualizado exitosamente'),
          backgroundColor: const Color(0xFF198754),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insumosListProvider);
    final insumosResponse = state.insumosResponse;

    // LAZY LOADING: Cargar datos solo la primera vez que el widget es visible
    if (!_hasLoadedData && insumosResponse == null && !state.isLoading) {
      _hasLoadedData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarInsumos();
      });
    }

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
                  'Gestión de Insumos',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Administra el inventario de insumos',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 24.h),

                // Widget de búsqueda
                _buildInsumoSearch(),
                SizedBox(height: 16.h),

                // Filtro de activo/inactivo y botón limpiar
                Row(
                  children: [
                    Expanded(child: _buildFiltroActivo()),
                    SizedBox(width: 12.w),
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
                  ],
                ),
                SizedBox(height: 16.h),

                // Loading indicator
                if (state.isLoading && insumosResponse == null)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: CircularProgressIndicator(
                        color: const Color(0xFF0d6efd),
                      ),
                    ),
                  )

                // Error message
                else if (state.error != null && insumosResponse == null)
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

                // Lista de insumos
                else if (insumosResponse != null && insumosResponse.insumos.isNotEmpty)
                  ...insumosResponse.insumos.map((insumo) {
                    return InsumoCard(
                      insumo: insumo,
                      onEdit: () => _editarInsumo(insumo),
                      onDelete: () => _confirmarEliminar(insumo),
                    );
                  })
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.h),
                      child: Column(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            size: 64.sp,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No hay insumos',
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
                if (insumosResponse != null && insumosResponse.insumos.isNotEmpty)
                  Container(
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
                                ? () => ref.read(insumosListProvider.notifier).previousPage()
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
                              'Pag. ${state.currentPage} de ${(insumosResponse.pagination.totalElement / insumosResponse.pagination.pageSize).ceil()}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${insumosResponse.pagination.totalElement} insumos',
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
                            onPressed: insumosResponse.pagination.hasMoreElements
                                ? () => ref.read(insumosListProvider.notifier).nextPage()
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
                  ),
              ],
            ),
          ),
          // Botón flotante para crear insumo
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Material(
              color: const Color(0xFF0d6efd),
              borderRadius: BorderRadius.circular(22.r),
              elevation: 4,
              child: InkWell(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => const CrearInsumoModal(),
                  );

                  if (result == true && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Insumo creado exitosamente'),
                        backgroundColor: const Color(0xFF198754),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
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
      ),
    );
  }

  void _cargarInsumos({String? nombreFiltro}) {
    final nombre = nombreFiltro ??
        ref.read(insumosSearchProvider).selectedInsumo?.nombre;

    ref.read(insumosListProvider.notifier).loadInsumos(
      nombre: nombre,
      activo: _filtroActivo,
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroActivo = true;
    });
    ref.read(insumosSearchProvider.notifier).clearSearch();
    _cargarInsumos();
  }

  Widget _buildFiltroActivo() {
    String getFiltroText() {
      if (_filtroActivo == null) return 'Todos los insumos';
      if (_filtroActivo == true) return 'Solo activos';
      return 'Solo inactivos';
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF363636)),
      ),
      child: InkWell(
        onTap: () async {
          final filtro = await showDialog<bool?>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1a1a1a),
              title: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Filtrar Insumos',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Todos', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                    leading: Icon(
                      Icons.list,
                      color: _filtroActivo == null ? const Color(0xFF0d6efd) : Colors.white54,
                    ),
                    onTap: () => Navigator.pop(context, null),
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                  ListTile(
                    title: Text('Solo activos', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                    leading: Icon(
                      Icons.check_circle,
                      color: _filtroActivo == true ? const Color(0xFF198754) : Colors.white54,
                    ),
                    onTap: () => Navigator.pop(context, true),
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                  ListTile(
                    title: Text('Solo inactivos', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                    leading: Icon(
                      Icons.block,
                      color: _filtroActivo == false ? const Color(0xFFdc3545) : Colors.white54,
                    ),
                    onTap: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
          );

          if (filtro != null || filtro == null) {
            setState(() => _filtroActivo = filtro);
            _cargarInsumos();
          }
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Icon(Icons.filter_list, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                getFiltroText(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsumoSearch() {
    final insumosSearchState = ref.watch(insumosSearchProvider);
    final selectedInsumo = insumosSearchState.selectedInsumo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Si hay insumo seleccionado, mostrar chip
        if (selectedInsumo != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF0d6efd).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFF0d6efd), width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  color: const Color(0xFF0d6efd),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedInsumo.nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock: ${selectedInsumo.stockActual} ${selectedInsumo.unidadBase}',
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
                    ref.read(insumosSearchProvider.notifier).clearSearch();
                    // Recargar lista completa
                    _cargarInsumos();
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
              ref.read(insumosSearchProvider.notifier).searchInsumos(value);
            },
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Buscar insumo (min. 3 caracteres)...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
              suffixIcon: insumosSearchState.isLoading
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
        if (insumosSearchState.insumos.isNotEmpty && selectedInsumo == null) ...[
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
              itemCount: insumosSearchState.insumos.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.1),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final insumo = insumosSearchState.insumos[index];
                return ListTile(
                  onTap: () {
                    ref.read(insumosSearchProvider.notifier).selectInsumo(insumo);
                    // Filtrar lista por nombre del insumo seleccionado
                    _cargarInsumos(nombreFiltro: insumo.nombre);
                  },
                  title: Text(
                    insumo.nombre,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock: ${insumo.stockActual} ${insumo.unidadBase}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        'Costo: \$${insumo.costoPromedio}',
                        style: TextStyle(
                          color: const Color(0xFF0d6efd),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 16.sp,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
