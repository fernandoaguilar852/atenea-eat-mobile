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
import '../../domain/entities/producto.dart';
import '../../domain/entities/consumidor.dart';
import '../../domain/entities/tipo_producto.dart';
import '../../domain/entities/caja.dart';
import '../../domain/entities/operador.dart';

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

final searchProductosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return SearchProductosUseCase(repository);
});

final searchConsumidoresUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return SearchConsumidoresUseCase(repository);
});

final getTiposProductoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetTiposProductoUseCase(repository);
});

final getCajasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetCajasUseCase(repository);
});

final getUsuarioUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetUsuarioUseCase(repository);
});

final getOperadoresUseCaseProvider = Provider((ref) {
  final repository = ref.watch(reportesRepositoryProvider);
  return GetOperadoresUseCase(repository);
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

// Estado para búsqueda de productos
class ProductosSearchState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;
  final Producto? selectedProducto;

  ProductosSearchState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
    this.selectedProducto,
  });

  ProductosSearchState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    Producto? selectedProducto,
    bool clearSelected = false,
  }) {
    return ProductosSearchState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedProducto: clearSelected ? null : (selectedProducto ?? this.selectedProducto),
    );
  }
}

// Notifier para búsqueda de productos
class ProductosSearchNotifier extends StateNotifier<ProductosSearchState> {
  final SearchProductosUseCase searchProductosUseCase;
  final int clienteId;

  ProductosSearchNotifier({
    required this.searchProductosUseCase,
    required this.clienteId,
  }) : super(ProductosSearchState());

  Future<void> searchProductos(String query) async {
    if (query.length < 3) {
      state = ProductosSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await searchProductosUseCase(
        clienteId: clienteId,
        search: query,
      );

      state = state.copyWith(
        productos: response.products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectProducto(Producto? producto) {
    state = state.copyWith(
      selectedProducto: producto,
      clearSelected: producto == null,
    );
  }

  void clearSearch() {
    state = ProductosSearchState();
  }
}

// Provider del StateNotifier para búsqueda de productos
final productosSearchProvider = StateNotifierProvider<ProductosSearchNotifier, ProductosSearchState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return ProductosSearchNotifier(
    searchProductosUseCase: ref.watch(searchProductosUseCaseProvider),
    clienteId: clienteId,
  );
});

// Estado para búsqueda de consumidores
class ConsumidoresSearchState {
  final List<Consumidor> consumidores;
  final bool isLoading;
  final String? error;
  final Consumidor? selectedConsumidor;

  ConsumidoresSearchState({
    this.consumidores = const [],
    this.isLoading = false,
    this.error,
    this.selectedConsumidor,
  });

  ConsumidoresSearchState copyWith({
    List<Consumidor>? consumidores,
    bool? isLoading,
    String? error,
    Consumidor? selectedConsumidor,
    bool clearSelected = false,
  }) {
    return ConsumidoresSearchState(
      consumidores: consumidores ?? this.consumidores,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedConsumidor: clearSelected ? null : (selectedConsumidor ?? this.selectedConsumidor),
    );
  }
}

// Notifier para búsqueda de consumidores
class ConsumidoresSearchNotifier extends StateNotifier<ConsumidoresSearchState> {
  final SearchConsumidoresUseCase searchConsumidoresUseCase;
  final int clienteId;

  ConsumidoresSearchNotifier({
    required this.searchConsumidoresUseCase,
    required this.clienteId,
  }) : super(ConsumidoresSearchState());

  Future<void> searchConsumidores(String query) async {
    if (query.length < 3) {
      state = ConsumidoresSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await searchConsumidoresUseCase(
        clienteId: clienteId,
        search: query,
      );

      state = state.copyWith(
        consumidores: response.consumidores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectConsumidor(Consumidor? consumidor) {
    state = state.copyWith(
      selectedConsumidor: consumidor,
      clearSelected: consumidor == null,
    );
  }

  void clearSearch() {
    state = ConsumidoresSearchState();
  }
}

// Provider del StateNotifier para búsqueda de consumidores
final consumidoresSearchProvider = StateNotifierProvider<ConsumidoresSearchNotifier, ConsumidoresSearchState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return ConsumidoresSearchNotifier(
    searchConsumidoresUseCase: ref.watch(searchConsumidoresUseCaseProvider),
    clienteId: clienteId,
  );
});

// Estado para tipos de producto
class TiposProductoState {
  final List<TipoProducto> tiposProducto;
  final bool isLoading;
  final String? error;
  final TipoProducto? selectedTipo;

  TiposProductoState({
    this.tiposProducto = const [],
    this.isLoading = false,
    this.error,
    this.selectedTipo,
  });

  TiposProductoState copyWith({
    List<TipoProducto>? tiposProducto,
    bool? isLoading,
    String? error,
    TipoProducto? selectedTipo,
    bool clearSelected = false,
  }) {
    return TiposProductoState(
      tiposProducto: tiposProducto ?? this.tiposProducto,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedTipo: clearSelected ? null : (selectedTipo ?? this.selectedTipo),
    );
  }
}

// Notifier para tipos de producto
class TiposProductoNotifier extends StateNotifier<TiposProductoState> {
  final GetTiposProductoUseCase getTiposProductoUseCase;
  final int clienteId;

  TiposProductoNotifier({
    required this.getTiposProductoUseCase,
    required this.clienteId,
  }) : super(TiposProductoState()) {
    // Cargar tipos de producto al iniciar
    loadTiposProducto();
  }

  Future<void> loadTiposProducto() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tiposProducto = await getTiposProductoUseCase(
        clienteId: clienteId,
        activo: true,
      );

      state = state.copyWith(
        tiposProducto: tiposProducto,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectTipo(TipoProducto? tipo) {
    state = state.copyWith(
      selectedTipo: tipo,
      clearSelected: tipo == null,
    );
  }
}

// Provider del StateNotifier para tipos de producto
final tiposProductoProvider = StateNotifierProvider<TiposProductoNotifier, TiposProductoState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return TiposProductoNotifier(
    getTiposProductoUseCase: ref.watch(getTiposProductoUseCaseProvider),
    clienteId: clienteId,
  );
});

// Estado para cajas
class CajasState {
  final List<Caja> cajas;
  final bool isLoading;
  final String? error;
  final Caja? selectedCaja;

  CajasState({
    this.cajas = const [],
    this.isLoading = false,
    this.error,
    this.selectedCaja,
  });

  CajasState copyWith({
    List<Caja>? cajas,
    bool? isLoading,
    String? error,
    Caja? selectedCaja,
    bool clearSelected = false,
  }) {
    return CajasState(
      cajas: cajas ?? this.cajas,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCaja: clearSelected ? null : (selectedCaja ?? this.selectedCaja),
    );
  }
}

// Notifier para cajas
class CajasNotifier extends StateNotifier<CajasState> {
  final GetCajasUseCase getCajasUseCase;
  final GetUsuarioUseCase getUsuarioUseCase;
  final int clienteId;

  CajasNotifier({
    required this.getCajasUseCase,
    required this.getUsuarioUseCase,
    required this.clienteId,
  }) : super(CajasState()) {
    // Cargar cajas al iniciar
    loadCajas();
  }

  Future<void> loadCajas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cajas = await getCajasUseCase(
        clienteId: clienteId,
      );

      // Para cada caja, obtener el nombre del usuario
      for (var caja in cajas) {
        try {
          final usuario = await getUsuarioUseCase(
            usuarioId: caja.usuarioId,
            clienteId: clienteId,
          );
          caja.nombreUsuario = usuario.nombre;
        } catch (e) {
          // Si falla obtener el usuario, dejarlo como null
          caja.nombreUsuario = null;
        }
      }

      state = state.copyWith(
        cajas: cajas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCaja(Caja? caja) {
    state = state.copyWith(
      selectedCaja: caja,
      clearSelected: caja == null,
    );
  }
}

// Provider del StateNotifier para cajas
final cajasProvider = StateNotifierProvider<CajasNotifier, CajasState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return CajasNotifier(
    getCajasUseCase: ref.watch(getCajasUseCaseProvider),
    getUsuarioUseCase: ref.watch(getUsuarioUseCaseProvider),
    clienteId: clienteId,
  );
});

// Estado para operadores
class OperadoresState {
  final List<Operador> operadores;
  final bool isLoading;
  final String? error;
  final Operador? selectedOperador;

  OperadoresState({
    this.operadores = const [],
    this.isLoading = false,
    this.error,
    this.selectedOperador,
  });

  OperadoresState copyWith({
    List<Operador>? operadores,
    bool? isLoading,
    String? error,
    Operador? selectedOperador,
    bool clearSelected = false,
  }) {
    return OperadoresState(
      operadores: operadores ?? this.operadores,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedOperador: clearSelected ? null : (selectedOperador ?? this.selectedOperador),
    );
  }
}

// Notifier para operadores
class OperadoresNotifier extends StateNotifier<OperadoresState> {
  final GetOperadoresUseCase getOperadoresUseCase;
  final int clienteId;

  OperadoresNotifier({
    required this.getOperadoresUseCase,
    required this.clienteId,
  }) : super(OperadoresState()) {
    // Cargar operadores al iniciar
    loadOperadores();
  }

  Future<void> loadOperadores() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final operadores = await getOperadoresUseCase(
        clienteId: clienteId,
      );

      state = state.copyWith(
        operadores: operadores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectOperador(Operador? operador) {
    state = state.copyWith(
      selectedOperador: operador,
      clearSelected: operador == null,
    );
  }
}

// Provider del StateNotifier para operadores
final operadoresProvider = StateNotifierProvider<OperadoresNotifier, OperadoresState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return OperadoresNotifier(
    getOperadoresUseCase: ref.watch(getOperadoresUseCaseProvider),
    clienteId: clienteId,
  );
});
