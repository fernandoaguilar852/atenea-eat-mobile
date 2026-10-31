import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/reportes_remote_datasource.dart';
import '../../data/repositories/reportes_repository_impl.dart';
import '../../domain/repositories/reportes_repository.dart';
import '../../domain/usecases/get_reportes_usecases.dart';
import '../../domain/entities/ventas_reporte.dart';
import '../../domain/entities/inventario_reporte.dart';
import '../../domain/entities/arqueo_reporte.dart';
import '../../domain/entities/stock_productos_reporte.dart';
import '../../domain/entities/stock_insumos_reporte.dart';
import '../../domain/entities/costo_beneficio_reporte.dart';

// Provider del datasource
final reportesRemoteDatasourceProvider = Provider<ReportesRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportesRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final reportesRepositoryProvider = Provider<ReportesRepository>((ref) {
  final datasource = ref.watch(reportesRemoteDatasourceProvider);
  return ReportesRepositoryImpl(remoteDatasource: datasource);
});

// Providers de los use cases
final getReporteVentasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteVentasUseCase(repository);
});

final getReporteInventarioConsumidoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteInventarioConsumidoUseCase(repository);
});

final getReporteArqueoCajaUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteArqueoCajaUseCase(repository);
});

final getReporteStockProductosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteStockProductosUseCase(repository);
});

final getReporteStockInsumosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteStockInsumosUseCase(repository);
});

final getReporteCostoBeneficioUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetReporteCostoBeneficioUseCase(repository);
});

// Estado de reportes
class ReportesState {
  // Tab activo
  final int activeTab;

  // Reportes
  final VentasReporte? ventasReporte;
  final InventarioReporte? inventarioReporte;
  final ArqueoReporte? arqueoReporte;
  final StockProductosReporte? stockProductosReporte;
  final StockInsumosReporte? stockInsumosReporte;
  final CostoBeneficioReporte? costoBeneficioReporte;

  // Estados de carga
  final bool isLoadingVentas;
  final bool isLoadingInventario;
  final bool isLoadingArqueo;
  final bool isLoadingStockProductos;
  final bool isLoadingStockInsumos;
  final bool isLoadingCostoBeneficio;

  // Errores
  final String? errorVentas;
  final String? errorInventario;
  final String? errorArqueo;
  final String? errorStockProductos;
  final String? errorStockInsumos;
  final String? errorCostoBeneficio;

  ReportesState({
    this.activeTab = 0,
    this.ventasReporte,
    this.inventarioReporte,
    this.arqueoReporte,
    this.stockProductosReporte,
    this.stockInsumosReporte,
    this.costoBeneficioReporte,
    this.isLoadingVentas = false,
    this.isLoadingInventario = false,
    this.isLoadingArqueo = false,
    this.isLoadingStockProductos = false,
    this.isLoadingStockInsumos = false,
    this.isLoadingCostoBeneficio = false,
    this.errorVentas,
    this.errorInventario,
    this.errorArqueo,
    this.errorStockProductos,
    this.errorStockInsumos,
    this.errorCostoBeneficio,
  });

  ReportesState copyWith({
    int? activeTab,
    VentasReporte? ventasReporte,
    InventarioReporte? inventarioReporte,
    ArqueoReporte? arqueoReporte,
    StockProductosReporte? stockProductosReporte,
    StockInsumosReporte? stockInsumosReporte,
    CostoBeneficioReporte? costoBeneficioReporte,
    bool? isLoadingVentas,
    bool? isLoadingInventario,
    bool? isLoadingArqueo,
    bool? isLoadingStockProductos,
    bool? isLoadingStockInsumos,
    bool? isLoadingCostoBeneficio,
    String? errorVentas,
    String? errorInventario,
    String? errorArqueo,
    String? errorStockProductos,
    String? errorStockInsumos,
    String? errorCostoBeneficio,
  }) {
    return ReportesState(
      activeTab: activeTab ?? this.activeTab,
      ventasReporte: ventasReporte ?? this.ventasReporte,
      inventarioReporte: inventarioReporte ?? this.inventarioReporte,
      arqueoReporte: arqueoReporte ?? this.arqueoReporte,
      stockProductosReporte: stockProductosReporte ?? this.stockProductosReporte,
      stockInsumosReporte: stockInsumosReporte ?? this.stockInsumosReporte,
      costoBeneficioReporte: costoBeneficioReporte ?? this.costoBeneficioReporte,
      isLoadingVentas: isLoadingVentas ?? this.isLoadingVentas,
      isLoadingInventario: isLoadingInventario ?? this.isLoadingInventario,
      isLoadingArqueo: isLoadingArqueo ?? this.isLoadingArqueo,
      isLoadingStockProductos: isLoadingStockProductos ?? this.isLoadingStockProductos,
      isLoadingStockInsumos: isLoadingStockInsumos ?? this.isLoadingStockInsumos,
      isLoadingCostoBeneficio: isLoadingCostoBeneficio ?? this.isLoadingCostoBeneficio,
      errorVentas: errorVentas,
      errorInventario: errorInventario,
      errorArqueo: errorArqueo,
      errorStockProductos: errorStockProductos,
      errorStockInsumos: errorStockInsumos,
      errorCostoBeneficio: errorCostoBeneficio,
    );
  }
}

// Notifier para gestionar el estado de reportes
class ReportesNotifier extends StateNotifier<ReportesState> {
  final GetReporteVentasUseCase getReporteVentasUseCase;
  final GetReporteInventarioConsumidoUseCase getReporteInventarioConsumidoUseCase;
  final GetReporteArqueoCajaUseCase getReporteArqueoCajaUseCase;
  final GetReporteStockProductosUseCase getReporteStockProductosUseCase;
  final GetReporteStockInsumosUseCase getReporteStockInsumosUseCase;
  final GetReporteCostoBeneficioUseCase getReporteCostoBeneficioUseCase;
  final int clienteId;

  ReportesNotifier({
    required this.getReporteVentasUseCase,
    required this.getReporteInventarioConsumidoUseCase,
    required this.getReporteArqueoCajaUseCase,
    required this.getReporteStockProductosUseCase,
    required this.getReporteStockInsumosUseCase,
    required this.getReporteCostoBeneficioUseCase,
    required this.clienteId,
  }) : super(ReportesState());

  void changeTab(int tabIndex) {
    state = state.copyWith(activeTab: tabIndex);
  }

  Future<void> loadReporteVentas({
    required String startDate,
    required String endDate,
    int? productoId,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    int? operadorId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingVentas: true, errorVentas: null);

    try {
      final reporte = await getReporteVentasUseCase(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        consumidorId: consumidorId,
        categoriaId: categoriaId,
        cajaId: cajaId,
        operadorId: operadorId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        ventasReporte: reporte,
        isLoadingVentas: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingVentas: false,
        errorVentas: e.toString(),
      );
    }
  }

  Future<void> loadReporteInventarioConsumido({
    required String startDate,
    required String endDate,
    String? tipoMovimiento,
    int? productoId,
    int? insumoId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingInventario: true, errorInventario: null);

    try {
      final reporte = await getReporteInventarioConsumidoUseCase(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        tipoMovimiento: tipoMovimiento,
        productoId: productoId,
        insumoId: insumoId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        inventarioReporte: reporte,
        isLoadingInventario: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInventario: false,
        errorInventario: e.toString(),
      );
    }
  }

  Future<void> loadReporteArqueoCaja({
    required String startDate,
    required String endDate,
    String? tipoPago,
    int? cajaId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingArqueo: true, errorArqueo: null);

    try {
      final reporte = await getReporteArqueoCajaUseCase(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        tipoPago: tipoPago,
        cajaId: cajaId,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        arqueoReporte: reporte,
        isLoadingArqueo: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingArqueo: false,
        errorArqueo: e.toString(),
      );
    }
  }

  Future<void> loadReporteStockProductos({
    String? nombreProducto,
    int? tipoProductoId,
    String? activo,
    String? stockBajo,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingStockProductos: true, errorStockProductos: null);

    try {
      final reporte = await getReporteStockProductosUseCase(
        clienteId: clienteId,
        nombreProducto: nombreProducto,
        tipoProductoId: tipoProductoId,
        activo: activo,
        stockBajo: stockBajo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        stockProductosReporte: reporte,
        isLoadingStockProductos: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStockProductos: false,
        errorStockProductos: e.toString(),
      );
    }
  }

  Future<void> loadReporteStockInsumos({
    String? nombreInsumo,
    String? activo,
    String? stockBajo,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingStockInsumos: true, errorStockInsumos: null);

    try {
      final reporte = await getReporteStockInsumosUseCase(
        clienteId: clienteId,
        nombreInsumo: nombreInsumo,
        activo: activo,
        stockBajo: stockBajo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        stockInsumosReporte: reporte,
        isLoadingStockInsumos: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStockInsumos: false,
        errorStockInsumos: e.toString(),
      );
    }
  }

  Future<void> loadReporteCostoBeneficio({
    required String startDate,
    required String endDate,
    int? productoId,
    int? tipoProductoId,
    String? activo,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    state = state.copyWith(isLoadingCostoBeneficio: true, errorCostoBeneficio: null);

    try {
      final reporte = await getReporteCostoBeneficioUseCase(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        tipoProductoId: tipoProductoId,
        activo: activo,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      state = state.copyWith(
        costoBeneficioReporte: reporte,
        isLoadingCostoBeneficio: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCostoBeneficio: false,
        errorCostoBeneficio: e.toString(),
      );
    }
  }
}

// Provider del StateNotifier de Reportes
final reportesProvider = StateNotifierProvider<ReportesNotifier, ReportesState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return ReportesNotifier(
    getReporteVentasUseCase: ref.watch(getReporteVentasUseCaseProvider),
    getReporteInventarioConsumidoUseCase: ref.watch(getReporteInventarioConsumidoUseCaseProvider),
    getReporteArqueoCajaUseCase: ref.watch(getReporteArqueoCajaUseCaseProvider),
    getReporteStockProductosUseCase: ref.watch(getReporteStockProductosUseCaseProvider),
    getReporteStockInsumosUseCase: ref.watch(getReporteStockInsumosUseCaseProvider),
    getReporteCostoBeneficioUseCase: ref.watch(getReporteCostoBeneficioUseCaseProvider),
    clienteId: clienteId,
  );
});
