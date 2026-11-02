import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/reportes_provider.dart';
import '../../domain/entities/caja.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pagination.dart';

class ArqueoTab extends ConsumerStatefulWidget {
  const ArqueoTab({super.key});

  @override
  ConsumerState<ArqueoTab> createState() => ArqueoTabState();
}

class ArqueoTabState extends ConsumerState<ArqueoTab> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  String? _tipoPago;
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
    final reporte = reportesState.arqueoReporte;
    final isLoading = reportesState.isLoadingArqueo;
    final error = reportesState.errorArqueo;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text('Arqueo de Caja', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
            _buildReporteArqueo(reporte)
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 64.sp, color: Colors.white.withValues(alpha: 0.3)),
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

            // Fechas (similar a anteriores)
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

            // Tipo de pago
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payment, color: Colors.white),
              title: Text(_tipoPago ?? 'Tipo de pago (opcional)', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              onTap: () async {
                final tipo = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1a1a1a),
                    title: Text('Tipo de Pago', style: TextStyle(color: Colors.white)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: Text('Todos', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, null)),
                        ListTile(title: Text('Caja', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'CAJA')),
                        ListTile(title: Text('Banco', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context, 'BANCO')),
                      ],
                    ),
                  ),
                );
                setState(() => _tipoPago = tipo);
              },
            ),

            Divider(color: Colors.white.withValues(alpha: 0.2)),

            // Selector de caja
            _buildCajaSelector(),
          ],
        ),
      ),
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

  void _consultarReporte() {
    if (_startDate == null || _endDate == null) return;

    final cajasState = ref.read(cajasProvider);
    final cajaId = cajasState.selectedCaja?.cajaId;

    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
          startDate: _startDate!.toIso8601String().split('T')[0],
          endDate: _endDate!.toIso8601String().split('T')[0],
          tipoPago: _tipoPago,
          cajaId: cajaId,
        );
  }

  void _limpiarFiltros() {
    // Limpiar tipo de pago
    setState(() {
      _tipoPago = null;
    });

    // Limpiar filtro de cajas
    ref.read(cajasProvider.notifier).selectCaja(null);
  }

  Widget _buildReporteArqueo(reporte) {
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
                _buildRow('Total Caja', '\$${reporte.resumen.totalCaja.toStringAsFixed(2)}', valueColor: const Color(0xFF198754)),
                _buildRow('Total Banco', '\$${reporte.resumen.totalBanco.toStringAsFixed(2)}', valueColor: const Color(0xFF0d6efd)),
                _buildRow('Transacciones', '${reporte.resumen.totalTransacciones}'),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 24.h),
                _buildRow('TOTAL GENERAL', '\$${reporte.resumen.totalGeneral.toStringAsFixed(2)}', isTotal: true),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Transacciones
        Row(
          children: [
            Icon(Icons.list_alt, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Transacciones (${reporte.transacciones.length})',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8.h),

        if (reporte.transacciones.isEmpty)
          Card(
            color: const Color(0xFF1a1a1a),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(child: Text('No hay transacciones en este período',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)))),
            ),
          )
        else
          ...reporte.transacciones.map<Widget>((tx) {
            final isCaja = tx.tipoPago == 'CAJA';
            return Card(
              color: const Color(0xFF1a1a1a),
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: Icon(
                  isCaja ? Icons.account_balance_wallet : Icons.account_balance,
                  color: isCaja ? const Color(0xFF198754) : const Color(0xFF0d6efd),
                ),
                title: Text('${tx.tipoTransaccion} - ${tx.tipoPago}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.fechaTransaccion),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.sp)),
                    if (tx.metodoPago != null)
                      Text('Método: ${tx.metodoPago}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.sp)),
                  ],
                ),
                trailing: Text('\$${tx.valor.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),

        // Controles de paginación
        if (reporte.pagination.totalElement > 0) ...[
          SizedBox(height: 16.h),
          _buildPaginationControlsArqueo(reporte.pagination),
        ],
      ],
    );
  }

  Widget _buildPaginationControlsArqueo(Pagination pagination) {
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
                    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
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
                    ref.read(reportesProvider.notifier).loadReporteArqueoCaja(
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

// ============================================================================
// STOCK PRODUCTOS TAB
// ============================================================================
