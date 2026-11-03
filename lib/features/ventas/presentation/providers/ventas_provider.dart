import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ventas_remote_datasource.dart';
import '../../data/repositories/ventas_repository_impl.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../../domain/usecases/get_ventas_usecase.dart';
import '../../domain/usecases/get_venta_detalle_usecase.dart';
import '../../domain/entities/ventas_response.dart';
import '../../domain/entities/venta_detallada.dart';
import '../../domain/entities/venta_pago.dart';

// Provider del datasource
final ventasRemoteDatasourceProvider = Provider<VentasRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return VentasRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final ventasRepositoryProvider = Provider<VentasRepository>((ref) {
  final datasource = ref.watch(ventasRemoteDatasourceProvider);
  return VentasRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case
final getVentasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ventasRepositoryProvider);
  return GetVentasUseCase(repository);
});

// Provider del use case para detalle
final getVentaDetalleUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ventasRepositoryProvider);
  return GetVentaDetalleUseCase(repository: repository);
});

// Clase helper para distinguir entre "no cambiar" y "establecer a null"
class _Undefined {
  const _Undefined();
}

// Estado de ventas
class VentasState {
  final VentasResponse? ventasResponse;
  final VentaDetallada? ventaDetallada;
  final bool isLoading;
  final bool isLoadingDetail;
  final String? error;
  final String? errorDetail;
  final int currentPage;
  final String? startDate; // Formato: yyyy-MM-dd
  final String? endDate;   // Formato: yyyy-MM-dd
  final String? estado;    // Valores: 'pagada', 'anulada', 'pendiente'
  final int? cajaId;       // Filtro de caja
  final int? operadorId;   // Filtro de operador

  VentasState({
    this.ventasResponse,
    this.ventaDetallada,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.error,
    this.errorDetail,
    this.currentPage = 1,
    this.startDate,
    this.endDate,
    this.estado,
    this.cajaId,
    this.operadorId,
  });

  VentasState copyWith({
    Object? ventasResponse = const _Undefined(),
    Object? ventaDetallada = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? isLoadingDetail = const _Undefined(),
    Object? error = const _Undefined(),
    Object? errorDetail = const _Undefined(),
    Object? currentPage = const _Undefined(),
    Object? startDate = const _Undefined(),
    Object? endDate = const _Undefined(),
    Object? estado = const _Undefined(),
    Object? cajaId = const _Undefined(),
    Object? operadorId = const _Undefined(),
  }) {
    return VentasState(
      ventasResponse: ventasResponse is _Undefined ? this.ventasResponse : ventasResponse as VentasResponse?,
      ventaDetallada: ventaDetallada is _Undefined ? this.ventaDetallada : ventaDetallada as VentaDetallada?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      isLoadingDetail: isLoadingDetail is _Undefined ? this.isLoadingDetail : isLoadingDetail as bool,
      error: error is _Undefined ? this.error : error as String?,
      errorDetail: errorDetail is _Undefined ? this.errorDetail : errorDetail as String?,
      currentPage: currentPage is _Undefined ? this.currentPage : currentPage as int,
      startDate: startDate is _Undefined ? this.startDate : startDate as String?,
      endDate: endDate is _Undefined ? this.endDate : endDate as String?,
      estado: estado is _Undefined ? this.estado : estado as String?,
      cajaId: cajaId is _Undefined ? this.cajaId : cajaId as int?,
      operadorId: operadorId is _Undefined ? this.operadorId : operadorId as int?,
    );
  }
}

// Notifier de ventas
class VentasNotifier extends StateNotifier<VentasState> {
  final GetVentasUseCase getVentasUseCase;
  final GetVentaDetalleUseCase getVentaDetalleUseCase;
  final Ref ref;

  VentasNotifier({
    required this.getVentasUseCase,
    required this.getVentaDetalleUseCase,
    required this.ref,
  }) : super(VentasState());

  Future<void> loadVentas({
    int? pageNumber,
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  }) async {
    try {
      // Validar fechas si ambas están presentes
      if (startDate != null && endDate != null) {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);

        if (end.isBefore(start)) {
          state = state.copyWith(
            error: 'La fecha final debe ser mayor o igual a la fecha inicial',
            isLoading: false,
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID',
        );
        return;
      }

      final page = pageNumber ?? state.currentPage;
      final filterStartDate = startDate ?? state.startDate;
      final filterEndDate = endDate ?? state.endDate;
      final filterEstado = estado ?? state.estado;
      final filterCajaId = cajaId ?? state.cajaId;
      final filterOperadorId = operadorId ?? state.operadorId;

      final response = await getVentasUseCase(
        clienteId: clienteId,
        pageSize: 20, // 20 items por página según requerimiento
        pageNumber: page,
        startDate: filterStartDate,
        endDate: filterEndDate,
        estado: filterEstado,
        cajaId: filterCajaId,
        operadorId: filterOperadorId,
      );

      state = state.copyWith(
        ventasResponse: response,
        isLoading: false,
        error: null,
        currentPage: page,
        startDate: filterStartDate,
        endDate: filterEndDate,
        estado: filterEstado,
        cajaId: filterCajaId,
        operadorId: filterOperadorId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void nextPage() {
    final pagination = state.ventasResponse?.pagination;
    if (pagination != null) {
      final totalPages = (pagination.totalElement / pagination.pageSize).ceil();
      final hasNextPage = state.currentPage < totalPages;

      if (hasNextPage) {
        loadVentas(pageNumber: state.currentPage + 1);
      }
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      loadVentas(pageNumber: state.currentPage - 1);
    }
  }

  Future<void> loadVentaDetalle({
    required int ventaId,
  }) async {
    try {
      state = state.copyWith(
        isLoadingDetail: true,
        errorDetail: null,
        ventaDetallada: null,
      );

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoadingDetail: false,
          errorDetail: 'No se encontró el cliente ID',
        );
        return;
      }

      final detalle = await getVentaDetalleUseCase(
        ventaId: ventaId,
        clienteId: clienteId,
      );

      // Mostrar el detalle inmediatamente sin métodos de pago
      final detalleInicial = VentaDetallada(
        ventaId: detalle.ventaId,
        clienteId: detalle.clienteId,
        ordenId: detalle.ordenId,
        operadorId: detalle.operadorId,
        consumidorId: detalle.consumidorId,
        cajaId: detalle.cajaId,
        formaPago: detalle.formaPago,
        fechaVencimiento: detalle.fechaVencimiento,
        codigoVoucher: detalle.codigoVoucher,
        subtotalSinImpuestos: detalle.subtotalSinImpuestos,
        totalDescuentos: detalle.totalDescuentos,
        totalImpuestos: detalle.totalImpuestos,
        totalIva: detalle.totalIva,
        totalInc: detalle.totalInc,
        totalIca: detalle.totalIca,
        total: detalle.total,
        porcentajePropina: detalle.porcentajePropina,
        valorPropina: detalle.valorPropina,
        estado: detalle.estado,
        observacion: detalle.observacion,
        tipoDocumento: detalle.tipoDocumento,
        prefijoFactura: detalle.prefijoFactura,
        numeroFactura: detalle.numeroFactura,
        fechaEmision: detalle.fechaEmision,
        cufe: detalle.cufe,
        qrCode: detalle.qrCode,
        estadoDian: detalle.estadoDian,
        dianTrackId: detalle.dianTrackId,
        createdAt: detalle.createdAt,
        pagos: detalle.pagos,
        detalles: detalle.detalles,
      );

      state = state.copyWith(
        ventaDetallada: detalleInicial,
        isLoadingDetail: false,
        errorDetail: null,
      );

      // Cargar métodos de pago de forma asíncrona (sin bloquear)
      _loadMetodosPagoAsync(detalle);
    } catch (e) {
      String errorMessage = 'Error al cargar el detalle de la venta';

      // Mejorar mensaje de error según el tipo
      if (e.toString().contains('timeout')) {
        errorMessage = 'El servidor está tardando mucho en responder. Por favor, intente nuevamente.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Sin conexión a internet. Verifique su conexión.';
      } else if (e.toString().contains('Status: 404')) {
        errorMessage = 'Venta no encontrada';
      } else if (e.toString().contains('Status: 500')) {
        errorMessage = 'Error en el servidor. Intente más tarde.';
      }

      state = state.copyWith(
        isLoadingDetail: false,
        errorDetail: errorMessage,
      );
    }
  }

  void clearVentaDetalle() {
    state = state.copyWith(
      ventaDetallada: null,
      errorDetail: null,
    );
  }

  // Cargar métodos de pago de forma asíncrona (no bloquea la UI)
  Future<void> _loadMetodosPagoAsync(VentaDetallada detalle) async {
    try {
      final datasource = ref.read(ventasRemoteDatasourceProvider);

      // Cargar métodos de pago en paralelo
      final pagosConMetodo = await Future.wait(
        detalle.pagos.map((pago) async {
          try {
            final metodo = await datasource.getMetodoPago(pagoId: pago.pagoId);
            return VentaPago(
              ventaPagoId: pago.ventaPagoId,
              ventaId: pago.ventaId,
              pagoId: pago.pagoId,
              valor: pago.valor,
              numeroComprobante: pago.numeroComprobante,
              bancoId: pago.bancoId,
              createdAt: pago.createdAt,
              metodo: metodo,
            );
          } catch (e) {
            // Si falla, devolver el pago con método "Desconocido"
            return VentaPago(
              ventaPagoId: pago.ventaPagoId,
              ventaId: pago.ventaId,
              pagoId: pago.pagoId,
              valor: pago.valor,
              numeroComprobante: pago.numeroComprobante,
              bancoId: pago.bancoId,
              createdAt: pago.createdAt,
              metodo: 'Desconocido',
            );
          }
        }).toList(),
      );

      // Actualizar estado solo si todavía tenemos la venta cargada
      if (state.ventaDetallada?.ventaId == detalle.ventaId) {
        final detalleActualizado = VentaDetallada(
          ventaId: detalle.ventaId,
          clienteId: detalle.clienteId,
          ordenId: detalle.ordenId,
          operadorId: detalle.operadorId,
          consumidorId: detalle.consumidorId,
          cajaId: detalle.cajaId,
          formaPago: detalle.formaPago,
          fechaVencimiento: detalle.fechaVencimiento,
          codigoVoucher: detalle.codigoVoucher,
          subtotalSinImpuestos: detalle.subtotalSinImpuestos,
          totalDescuentos: detalle.totalDescuentos,
          totalImpuestos: detalle.totalImpuestos,
          totalIva: detalle.totalIva,
          totalInc: detalle.totalInc,
          totalIca: detalle.totalIca,
          total: detalle.total,
          porcentajePropina: detalle.porcentajePropina,
          valorPropina: detalle.valorPropina,
          estado: detalle.estado,
          observacion: detalle.observacion,
          tipoDocumento: detalle.tipoDocumento,
          prefijoFactura: detalle.prefijoFactura,
          numeroFactura: detalle.numeroFactura,
          fechaEmision: detalle.fechaEmision,
          cufe: detalle.cufe,
          qrCode: detalle.qrCode,
          estadoDian: detalle.estadoDian,
          dianTrackId: detalle.dianTrackId,
          createdAt: detalle.createdAt,
          pagos: pagosConMetodo,
          detalles: detalle.detalles,
        );

        state = state.copyWith(ventaDetallada: detalleActualizado);
      }
    } catch (e) {
      // Si falla la carga de métodos de pago, no mostramos error
      // ya que el detalle principal ya está cargado
    }
  }

  Future<void> setFilters({
    String? startDate,
    String? endDate,
    String? estado,
    int? cajaId,
    int? operadorId,
  }) async {
    // Validar fechas si ambas están presentes
    if (startDate != null && endDate != null) {
      try {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);

        if (end.isBefore(start)) {
          state = state.copyWith(
            error: 'La fecha final debe ser mayor o igual a la fecha inicial',
          );
          return;
        }
      } catch (e) {
        state = state.copyWith(
          error: 'Formato de fecha inválido. Use el formato yyyy-MM-dd',
        );
        return;
      }
    }

    // Aplicar filtros y recargar desde la página 1
    await loadVentas(
      pageNumber: 1,
      startDate: startDate,
      endDate: endDate,
      estado: estado,
      cajaId: cajaId,
      operadorId: operadorId,
    );
  }

  Future<void> clearFilters() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
      );

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID',
        );
        return;
      }

      final response = await getVentasUseCase(
        clienteId: clienteId,
        pageSize: 20,
        pageNumber: 1,
        startDate: null,
        endDate: null,
        estado: null,
        cajaId: null,
        operadorId: null,
      );

      state = state.copyWith(
        ventasResponse: response,
        isLoading: false,
        error: null,
        currentPage: 1,
        startDate: null,
        endDate: null,
        estado: null,
        cajaId: null,
        operadorId: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider del notifier
final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  final useCase = ref.watch(getVentasUseCaseProvider);
  final detalleUseCase = ref.watch(getVentaDetalleUseCaseProvider);
  return VentasNotifier(
    getVentasUseCase: useCase,
    getVentaDetalleUseCase: detalleUseCase,
    ref: ref,
  );
});
