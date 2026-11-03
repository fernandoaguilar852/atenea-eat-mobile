import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/ventas_provider.dart';
import '../widgets/venta_detalle_modal.dart';
import '../../../../core/cajas/presentation/providers/cajas_provider.dart';
import '../../../../core/cajas/domain/entities/caja.dart';
import '../../../../core/operadores/presentation/providers/operadores_provider.dart';

class VentasScreen extends ConsumerStatefulWidget {
  const VentasScreen({super.key});

  @override
  ConsumerState<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends ConsumerState<VentasScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _operadorSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedEstado;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ventasProvider.notifier).loadVentas();
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
    _startDateController.dispose();
    _endDateController.dispose();
    _operadorSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF0d6efd),
              onPrimary: Colors.white,
              surface: const Color(0xFF1a1a1a),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1a1a1a),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isStartDate) {
        _startDateController.text = formattedDate;
      } else {
        _endDateController.text = formattedDate;
      }
    }
  }

  void _applyFilters() {
    final startDate = _startDateController.text.isEmpty ? null : _startDateController.text;
    final endDate = _endDateController.text.isEmpty ? null : _endDateController.text;
    final cajasState = ref.read(globalCajasProvider);
    final cajaId = cajasState.selectedCaja?.cajaId;
    final operadoresState = ref.read(globalOperadoresSearchProvider);
    final operadorId = operadoresState.selectedOperador?.operadorId;

    ref.read(ventasProvider.notifier).setFilters(
      startDate: startDate,
      endDate: endDate,
      estado: _selectedEstado,
      cajaId: cajaId,
      operadorId: operadorId,
    );
  }

  void _clearFilters() {
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _selectedEstado = null;
      _operadorSearchController.clear();
    });
    ref.read(globalCajasProvider.notifier).selectCaja(null);
    ref.read(globalOperadoresSearchProvider.notifier).clearSearch();
    ref.read(ventasProvider.notifier).clearFilters();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getFormaPagoColor(String formaPago) {
    switch (formaPago.toLowerCase()) {
      case 'efectivo':
        return const Color(0xFF198754);
      case 'transferencia':
        return const Color(0xFF0d6efd);
      case 'varios':
        return const Color(0xFFffc107);
      default:
        return const Color(0xFF6c757d);
    }
  }

  void _showVentaDetalle(int ventaId) async {
    await ref.read(ventasProvider.notifier).loadVentaDetalle(ventaId: ventaId);

    final state = ref.read(ventasProvider);

    if (state.ventaDetallada != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => const VentaDetalleModal(),
      ).then((_) {
        ref.read(ventasProvider.notifier).clearVentaDetalle();
      });
    } else if (state.errorDetail != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar detalle: ${state.errorDetail}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ventasProvider);
    final ventas = state.ventasResponse?.ventas ?? [];
    final pagination = state.ventasResponse?.pagination;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
            // Filtros de fecha
            Container(
                            padding: EdgeInsets.all(16.w),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a1a),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFF404040),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list,
                                      color: const Color(0xFF0d6efd),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Filtrar por fecha',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    if (state.startDate != null || state.endDate != null || state.estado != null || state.cajaId != null || state.operadorId != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0d6efd).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4.r),
                                          border: Border.all(color: const Color(0xFF0d6efd), width: 1),
                                        ),
                                        child: Text(
                                          'ACTIVO',
                                          style: TextStyle(
                                            color: const Color(0xFF0d6efd),
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _startDateController,
                                        readOnly: true,
                                        onTap: () => _selectDate(context, true),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Fecha inicial',
                                          labelStyle: TextStyle(
                                            color: const Color(0xFF808080),
                                            fontSize: 14.sp,
                                          ),
                                          hintText: 'yyyy-MM-dd',
                                          hintStyle: TextStyle(
                                            color: const Color(0xFF606060),
                                            fontSize: 12.sp,
                                          ),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: const Color(0xFF0d6efd),
                                            size: 20.sp,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF0a0a0a),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF404040),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF404040),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF0d6efd),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 12.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: TextField(
                                        controller: _endDateController,
                                        readOnly: true,
                                        onTap: () => _selectDate(context, false),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Fecha final',
                                          labelStyle: TextStyle(
                                            color: const Color(0xFF808080),
                                            fontSize: 14.sp,
                                          ),
                                          hintText: 'yyyy-MM-dd',
                                          hintStyle: TextStyle(
                                            color: const Color(0xFF606060),
                                            fontSize: 12.sp,
                                          ),
                                          suffixIcon: Icon(
                                            Icons.calendar_today,
                                            color: const Color(0xFF0d6efd),
                                            size: 20.sp,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF0a0a0a),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF404040),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF404040),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.r),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF0d6efd),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 12.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                // Dropdown de estado
                                DropdownButtonFormField<String>(
                                  value: _selectedEstado,
                                  dropdownColor: const Color(0xFF1a1a1a),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Estado',
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF808080),
                                      fontSize: 14.sp,
                                    ),
                                    hintText: 'Seleccionar estado',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF606060),
                                      fontSize: 12.sp,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.filter_alt,
                                      color: const Color(0xFF0d6efd),
                                      size: 20.sp,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF0a0a0a),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF404040),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF404040),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF0d6efd),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'Todos',
                                        style: TextStyle(
                                          color: const Color(0xFF808080),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'pagada',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Pagada',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'pendiente',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Pendiente',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'anulada',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Anulada',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedEstado = newValue;
                                    });
                                  },
                                ),
                                SizedBox(height: 12.h),
                                // Selector de caja
                                _buildCajaSelector(),
                                SizedBox(height: 12.h),
                                // Buscador de operador
                                _buildOperadorSearch(),
                                SizedBox(height: 16.h),
                                // Botones: Limpiar filtros y Consultar
                                Row(
                                  children: [
                                    // Botón limpiar filtros
                                    IconButton(
                                      onPressed: _clearFilters,
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
                                        onPressed: _applyFilters,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF198754),
                                          padding: EdgeInsets.symmetric(vertical: 12.h),
                                        ),
                                        child: Text('Consultar Ventas', style: TextStyle(fontSize: 16.sp)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Mostrar error de validación si existe
                          if (state.error != null && state.ventasResponse != null) ...[
                            Container(
                              padding: EdgeInsets.all(12.w),
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      state.error!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Área de resultados
                          if (state.isLoading && state.ventasResponse == null)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.h),
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF0d6efd),
                                ),
                              ),
                            )
                          else if (state.error != null && state.ventasResponse == null)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.h),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64.sp,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Error al cargar ventas',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      state.error!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (ventas.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.h),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 80.sp,
                                      color: const Color(0xFF808080).withValues(alpha: 0.3),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'No hay registros',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Lista de ventas
                            ...ventas.map((venta) {
                            final estadoColor = _getEstadoColor(venta.estado);
                            final formaPagoColor = _getFormaPagoColor(venta.formaPago ?? 'N/A');

                              return InkWell(
                                onTap: () => _showVentaDetalle(venta.ventaId),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Card(
                                  color: const Color(0xFF1a1a1a),
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: const Color(0xFF404040),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header: Número de factura y estado
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.receipt,
                                            color: const Color(0xFF0d6efd),
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${venta.prefijoFactura ?? ''}-${venta.numeroFactura}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: estadoColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4.r),
                                              border: Border.all(color: estadoColor, width: 1),
                                            ),
                                            child: Text(
                                              venta.estado.toUpperCase(),
                                              style: TextStyle(
                                                color: estadoColor,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),

                                      // Cliente
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16.sp,
                                            color: const Color(0xFF808080),
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              venta.consumidor?.nombreRazonSocial ?? 'Sin consumidor',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),

                                      // Forma de pago y total
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                            decoration: BoxDecoration(
                                              color: formaPagoColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.payment,
                                                  size: 14.sp,
                                                  color: formaPagoColor,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  (venta.formaPago ?? 'N/A').toUpperCase(),
                                                  style: TextStyle(
                                                    color: formaPagoColor,
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            '\$${double.parse(venta.total).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: const Color(0xFF0d6efd),
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),

                                      // Fecha
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14.sp,
                                            color: const Color(0xFF808080),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            _formatDate(venta.fechaEmision),
                                            style: TextStyle(
                                              color: const Color(0xFF808080),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                          }),

                          // Paginación
                          if (ventas.isNotEmpty && pagination != null) ...[
                            SizedBox(height: 16.h),
                            Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1a1a1a),
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFF404040),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: state.currentPage > 1
                                      ? () {
                                          final newPage = state.currentPage - 1;
                                          ref.read(ventasProvider.notifier).loadVentas(pageNumber: newPage);
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
                                  'Página ${state.currentPage} de ${(pagination.totalElement / pagination.pageSize).ceil()}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: pagination.hasMoreElements
                                      ? () {
                                          final newPage = state.currentPage + 1;
                                          ref.read(ventasProvider.notifier).loadVentas(pageNumber: newPage);
                                        }
                                      : null,
                                  label: Text('Siguiente', style: TextStyle(fontSize: 14.sp)),
                                  icon: Icon(Icons.chevron_right, size: 20.sp),
                                  style: TextButton.styleFrom(
                                    foregroundColor: pagination.hasMoreElements
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

  Widget _buildCajaSelector() {
    final cajasState = ref.watch(globalCajasProvider);
    final selectedCaja = cajasState.selectedCaja;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caja',
          style: TextStyle(
            color: const Color(0xFF808080),
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
                color: const Color(0xFF606060),
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                Icons.point_of_sale,
                color: const Color(0xFF0d6efd),
                size: 20.sp,
              ),
              filled: true,
              fillColor: const Color(0xFF0a0a0a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFF404040),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFF404040),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: const Color(0xFF0d6efd),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            dropdownColor: const Color(0xFF1a1a1a),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: [
              DropdownMenuItem<Caja>(
                value: null,
                child: Text(
                  'Todas las cajas',
                  style: TextStyle(
                    color: const Color(0xFF808080),
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
              ref.read(globalCajasProvider.notifier).selectCaja(newValue);
            },
          ),
      ],
    );
  }

  Widget _buildOperadorSearch() {
    final operadoresState = ref.watch(globalOperadoresSearchProvider);
    final selectedOperador = operadoresState.selectedOperador;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operador',
          style: TextStyle(
            color: const Color(0xFF808080),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),

        if (selectedOperador != null)
          // Mostrar operador seleccionado
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0a0a0a),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF0d6efd),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: const Color(0xFF0d6efd),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedOperador.nombre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedOperador.numeroDocumento != null)
                        Text(
                          'Doc: ${selectedOperador.numeroDocumento}',
                          style: TextStyle(
                            color: const Color(0xFF808080),
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _operadorSearchController.clear();
                    });
                    ref.read(globalOperadoresSearchProvider.notifier).clearSearch();
                  },
                  icon: const Icon(Icons.clear, color: Colors.red),
                  iconSize: 20.sp,
                ),
              ],
            ),
          )
        else
          // Campo de búsqueda
          Column(
            children: [
              TextField(
                controller: _operadorSearchController,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar operador (min. 3 caracteres)...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF606060),
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF0d6efd),
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0a0a0a),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: const Color(0xFF0d6efd),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
                onChanged: (value) {
                  ref.read(globalOperadoresSearchProvider.notifier).searchOperadores(value);
                },
              ),

              // Lista de resultados
              if (operadoresState.isLoading)
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0d6efd),
                    ),
                  ),
                )
              else if (operadoresState.error != null)
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.all(12.w),
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
              else if (operadoresState.operadores.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  constraints: BoxConstraints(maxHeight: 200.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a1a),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF404040),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: operadoresState.operadores.length,
                    separatorBuilder: (context, index) => Divider(
                      color: const Color(0xFF404040),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final operador = operadoresState.operadores[index];
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        leading: Icon(
                          Icons.person,
                          color: operador.activo ? const Color(0xFF0d6efd) : const Color(0xFF808080),
                          size: 20.sp,
                        ),
                        title: Text(
                          operador.nombre,
                          style: TextStyle(
                            color: operador.activo ? Colors.white : const Color(0xFF808080),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: operador.numeroDocumento != null
                            ? Text(
                                'Doc: ${operador.numeroDocumento}',
                                style: TextStyle(
                                  color: const Color(0xFF808080),
                                  fontSize: 12.sp,
                                ),
                              )
                            : null,
                        trailing: !operador.activo
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(color: Colors.orange, width: 1),
                                ),
                                child: Text(
                                  'INACTIVO',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _operadorSearchController.text = operador.nombre;
                          });
                          ref.read(globalOperadoresSearchProvider.notifier).selectOperador(operador);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
