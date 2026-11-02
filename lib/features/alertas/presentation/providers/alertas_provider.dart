import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/alertas_remote_datasource.dart';
import '../../data/repositories/alertas_repository_impl.dart';
import '../../domain/entities/alertas_response.dart';
import '../../domain/repositories/alertas_repository.dart';
import '../../domain/usecases/get_alertas_usecase.dart';

// Provider del repositorio de alertas
final alertasRepositoryProvider = Provider<AlertasRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = AlertasRemoteDatasourceImpl(dio: dio);

  return AlertasRepositoryImpl(remoteDatasource: datasource);
});

// Provider del UseCase
final getAlertasUseCaseProvider = Provider<GetAlertasUseCase>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return GetAlertasUseCase(repository);
});

// Clase helper para distinguir entre "no cambiar" y "establecer a null"
class _Undefined {
  const _Undefined();
}

// Estado de alertas
class AlertasState {
  final AlertasResponse? alertasResponse;
  final bool isLoading;
  final String? error;
  final int productosPage;
  final int insumosPage;
  final int activeTab; // 0 = Productos, 1 = Insumos

  const AlertasState({
    this.alertasResponse,
    this.isLoading = false,
    this.error,
    this.productosPage = 1,
    this.insumosPage = 1,
    this.activeTab = 0,
  });

  AlertasState copyWith({
    Object? alertasResponse = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? error = const _Undefined(),
    int? productosPage,
    int? insumosPage,
    int? activeTab,
  }) {
    return AlertasState(
      alertasResponse: alertasResponse is _Undefined
          ? this.alertasResponse
          : alertasResponse as AlertasResponse?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      error: error is _Undefined ? this.error : error as String?,
      productosPage: productosPage ?? this.productosPage,
      insumosPage: insumosPage ?? this.insumosPage,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

// Notifier de alertas
class AlertasNotifier extends StateNotifier<AlertasState> {
  final GetAlertasUseCase getAlertasUseCase;
  final Ref ref;

  AlertasNotifier({
    required this.getAlertasUseCase,
    required this.ref,
  }) : super(const AlertasState());

  /// Carga las alertas del servidor
  Future<void> loadAlertas({int? pageNumber}) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se encontró el cliente',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      final response = await getAlertasUseCase.call(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: pageNumber ?? (state.activeTab == 0 ? state.productosPage : state.insumosPage),
      );

      state = state.copyWith(
        alertasResponse: response,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Cambia el tab activo
  void changeTab(int tabIndex) {
    state = state.copyWith(activeTab: tabIndex);
    // Cargar datos del tab si es necesario
    loadAlertas();
  }

  /// Página siguiente para productos
  void nextPageProductos() {
    final newPage = state.productosPage + 1;
    state = state.copyWith(productosPage: newPage);
    loadAlertas(pageNumber: newPage);
  }

  /// Página anterior para productos
  void previousPageProductos() {
    if (state.productosPage > 1) {
      final newPage = state.productosPage - 1;
      state = state.copyWith(productosPage: newPage);
      loadAlertas(pageNumber: newPage);
    }
  }

  /// Página siguiente para insumos
  void nextPageInsumos() {
    final newPage = state.insumosPage + 1;
    state = state.copyWith(insumosPage: newPage);
    loadAlertas(pageNumber: newPage);
  }

  /// Página anterior para insumos
  void previousPageInsumos() {
    if (state.insumosPage > 1) {
      final newPage = state.insumosPage - 1;
      state = state.copyWith(insumosPage: newPage);
      loadAlertas(pageNumber: newPage);
    }
  }
}

// Provider del notifier
final alertasProvider = StateNotifierProvider<AlertasNotifier, AlertasState>((ref) {
  final getAlertasUseCase = ref.watch(getAlertasUseCaseProvider);

  return AlertasNotifier(
    getAlertasUseCase: getAlertasUseCase,
    ref: ref,
  );
});
