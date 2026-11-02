import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/resoluciones_provider.dart';
import '../widgets/resolucion_card.dart';
import '../widgets/crear_resolucion_modal.dart';

class ResolucionesScreen extends ConsumerStatefulWidget {
  const ResolucionesScreen({super.key});

  @override
  ConsumerState<ResolucionesScreen> createState() => _ResolucionesScreenState();
}

class _ResolucionesScreenState extends ConsumerState<ResolucionesScreen> {
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    // Cargar resoluciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resolucionesProvider.notifier).loadResoluciones();
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
    final error = ref.read(resolucionesProvider.notifier).aplicarFiltros(
      startDate: _fechaDesde != null ? _formatDate(_fechaDesde!) : null,
      endDate: _fechaHasta != null ? _formatDate(_fechaHasta!) : null,
    );

    if (error != null) {
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
            error,
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
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _fechaDesde = null;
      _fechaHasta = null;
    });
    ref.read(resolucionesProvider.notifier).clearFiltros();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resolucionesProvider);
    final resolucionesResponse = state.resolucionesResponse;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Contenido principal
          state.isLoading && resolucionesResponse == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0d6efd),
              ),
            )
          : state.error != null && resolucionesResponse == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: const Color(0xFFdc3545),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error al cargar resoluciones',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        state.error!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF808080),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(resolucionesProvider.notifier).loadResoluciones();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtros
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
                            // Filtro de Estado
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _FilterChip(
                                        label: 'Todas',
                                        isSelected: state.filtroActivo == null,
                                        onTap: () {
                                          ref.read(resolucionesProvider.notifier).setFiltroActivo(null);
                                        },
                                        color: const Color(0xFF0d6efd),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: _FilterChip(
                                        label: 'Activas',
                                        isSelected: state.filtroActivo == true,
                                        onTap: () {
                                          ref.read(resolucionesProvider.notifier).setFiltroActivo(true);
                                        },
                                        color: const Color(0xFF198754),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: _FilterChip(
                                        label: 'Inactivas',
                                        isSelected: state.filtroActivo == false,
                                        onTap: () {
                                          ref.read(resolucionesProvider.notifier).setFiltroActivo(false);
                                        },
                                        color: const Color(0xFF6c757d),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // Filtros de fecha
                            Text(
                              'Rango de Fechas',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fecha Desde',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 11.sp,
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
                                          color: Colors.white.withValues(alpha: 0.6),
                                          fontSize: 11.sp,
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

                            // Botones de acción
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
                                      'Consultar Resoluciones',
                                      style: TextStyle(fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      Text(
                        'Resoluciones de Facturación (${resolucionesResponse?.pagination.totalElement ?? 0})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Lista de resoluciones
                      if (resolucionesResponse != null &&
                          resolucionesResponse.resoluciones.isNotEmpty)
                        ...resolucionesResponse.resoluciones.map((resolucion) {
                          return ResolucionCard(resolucion: resolucion);
                        })
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64.sp,
                                  color: Colors.white24,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No hay resoluciones registradas',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Paginación
                      if (resolucionesResponse != null &&
                          resolucionesResponse.pagination.totalElement > 0) ...[
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
                                onPressed: state.currentPage > 1
                                    ? () {
                                        ref.read(resolucionesProvider.notifier).previousPage();
                                      }
                                    : null,
                                icon: Icon(Icons.chevron_left, size: 20.sp),
                                label: Text('Anterior', style: TextStyle(fontSize: 14.sp)),
                                style: TextButton.styleFrom(
                                  foregroundColor: state.currentPage > 1
                                      ? const Color(0xFF0d6efd)
                                      : const Color(0xFF6c757d),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                ),
                              ),
                              Text(
                                'Página ${state.currentPage} de ${(resolucionesResponse.pagination.totalElement / 20).ceil()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: resolucionesResponse.pagination.hasMoreElements
                                    ? () {
                                        ref.read(resolucionesProvider.notifier).nextPage();
                                      }
                                    : null,
                                label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                                icon: Icon(Icons.chevron_right, size: 20.sp),
                                style: TextButton.styleFrom(
                                  foregroundColor: resolucionesResponse.pagination.hasMoreElements
                                      ? const Color(0xFF0d6efd)
                                      : const Color(0xFF6c757d),
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

          // Botón flotante para crear resolución
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
                    builder: (context) => const CrearResolucionModal(),
                  );

                  if (result == true && mounted) {
                    // Mostrar mensaje de éxito
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text('Resolución creada exitosamente'),
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF404040),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
