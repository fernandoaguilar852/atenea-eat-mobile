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

  VentasState({
    this.ventasResponse,
    this.ventaDetallada,
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.error,
    this.errorDetail,
    this.currentPage = 1,
  });

  VentasState copyWith({
    Object? ventasResponse = const _Undefined(),
    Object? ventaDetallada = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? isLoadingDetail = const _Undefined(),
    Object? error = const _Undefined(),
    Object? errorDetail = const _Undefined(),
    Object? currentPage = const _Undefined(),
  }) {
    return VentasState(
      ventasResponse: ventasResponse is _Undefined ? this.ventasResponse : ventasResponse as VentasResponse?,
      ventaDetallada: ventaDetallada is _Undefined ? this.ventaDetallada : ventaDetallada as VentaDetallada?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      isLoadingDetail: isLoadingDetail is _Undefined ? this.isLoadingDetail : isLoadingDetail as bool,
      error: error is _Undefined ? this.error : error as String?,
      errorDetail: errorDetail is _Undefined ? this.errorDetail : errorDetail as String?,
      currentPage: currentPage is _Undefined ? this.currentPage : currentPage as int,
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

  Future<void> loadVentas({int? pageNumber}) async {
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

      final page = pageNumber ?? state.currentPage;

      final response = await getVentasUseCase(
        clienteId: clienteId,
        pageSize: 20, // 20 items por página según requerimiento
        pageNumber: page,
      );

      state = state.copyWith(
        ventasResponse: response,
        isLoading: false,
        error: null,
        currentPage: page,
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

      // Cargar métodos de pago en paralelo
      final datasource = ref.read(ventasRemoteDatasourceProvider);
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
            // Si falla, devolver el pago sin método
            return pago;
          }
        }).toList(),
      );

      // Crear nueva venta detallada con los pagos actualizados
      final detalleConMetodos = VentaDetallada(
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

      state = state.copyWith(
        ventaDetallada: detalleConMetodos,
        isLoadingDetail: false,
        errorDetail: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        errorDetail: e.toString(),
      );
    }
  }

  void clearVentaDetalle() {
    state = state.copyWith(
      ventaDetallada: null,
      errorDetail: null,
    );
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
