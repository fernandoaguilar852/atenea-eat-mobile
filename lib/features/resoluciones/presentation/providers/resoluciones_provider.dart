import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/resoluciones_remote_datasource.dart';
import '../../data/repositories/resoluciones_repository_impl.dart';
import '../../domain/entities/resoluciones_response.dart';
import '../../domain/repositories/resoluciones_repository.dart';
import '../../domain/usecases/get_resoluciones_usecase.dart';
import '../../domain/usecases/create_resolucion_usecase.dart';

// Provider del repositorio
final resolucionesRepositoryProvider = Provider<ResolucionesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = ResolucionesRemoteDatasourceImpl(dio: dio);

  return ResolucionesRepositoryImpl(remoteDatasource: datasource);
});

// Provider del UseCase para obtener resoluciones
final getResolucionesUseCaseProvider = Provider<GetResolucionesUseCase>((ref) {
  final repository = ref.watch(resolucionesRepositoryProvider);
  return GetResolucionesUseCase(repository);
});

// Provider del UseCase para crear resoluciones
final createResolucionUseCaseProvider = Provider<CreateResolucionUseCase>((ref) {
  final repository = ref.watch(resolucionesRepositoryProvider);
  return CreateResolucionUseCase(repository);
});

// Clase helper para distinguir entre "no cambiar" y "establecer a null"
class _Undefined {
  const _Undefined();
}

// Estado de resoluciones
class ResolucionesState {
  final ResolucionesResponse? resolucionesResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool? filtroActivo; // null = todas, true = activas, false = inactivas
  final String? startDate; // Formato: 2026-08-30
  final String? endDate;   // Formato: 2026-08-30

  const ResolucionesState({
    this.resolucionesResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.filtroActivo,
    this.startDate,
    this.endDate,
  });

  ResolucionesState copyWith({
    Object? resolucionesResponse = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? error = const _Undefined(),
    int? currentPage,
    Object? filtroActivo = const _Undefined(),
    Object? startDate = const _Undefined(),
    Object? endDate = const _Undefined(),
  }) {
    return ResolucionesState(
      resolucionesResponse: resolucionesResponse is _Undefined
          ? this.resolucionesResponse
          : resolucionesResponse as ResolucionesResponse?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      error: error is _Undefined ? this.error : error as String?,
      currentPage: currentPage ?? this.currentPage,
      filtroActivo: filtroActivo is _Undefined ? this.filtroActivo : filtroActivo as bool?,
      startDate: startDate is _Undefined ? this.startDate : startDate as String?,
      endDate: endDate is _Undefined ? this.endDate : endDate as String?,
    );
  }
}

// Notifier de resoluciones
class ResolucionesNotifier extends StateNotifier<ResolucionesState> {
  final GetResolucionesUseCase getResolucionesUseCase;
  final CreateResolucionUseCase createResolucionUseCase;
  final Ref ref;

  ResolucionesNotifier({
    required this.getResolucionesUseCase,
    required this.createResolucionUseCase,
    required this.ref,
  }) : super(const ResolucionesState());

  /// Carga las resoluciones del servidor
  Future<void> loadResoluciones({
    int? pageNumber,
    bool? activo,
    String? startDate,
    String? endDate,
  }) async {
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
      final page = pageNumber ?? state.currentPage;
      final filtro = activo ?? state.filtroActivo;
      final fechaDesde = startDate ?? state.startDate;
      final fechaHasta = endDate ?? state.endDate;

      final response = await getResolucionesUseCase.call(
        clienteId: clienteId,
        pageSize: 20,
        pageNumber: page,
        activo: filtro,
        startDate: fechaDesde,
        endDate: fechaHasta,
      );

      state = state.copyWith(
        resolucionesResponse: response,
        isLoading: false,
        currentPage: page,
        filtroActivo: filtro,
        startDate: fechaDesde,
        endDate: fechaHasta,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Aplicar filtro de activo
  void setFiltroActivo(bool? activo) {
    state = state.copyWith(filtroActivo: activo);
    loadResoluciones(pageNumber: 1, activo: activo);
  }

  /// Aplicar filtros (incluye validación de fechas)
  String? aplicarFiltros({String? startDate, String? endDate}) {
    // Validar que endDate sea mayor o igual a startDate
    if (startDate != null && endDate != null) {
      final fechaDesde = DateTime.parse(startDate);
      final fechaHasta = DateTime.parse(endDate);

      if (fechaHasta.isBefore(fechaDesde)) {
        return 'La fecha hasta debe ser mayor o igual a la fecha desde';
      }
    }

    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    loadResoluciones(pageNumber: 1, startDate: startDate, endDate: endDate);
    return null; // Sin error
  }

  /// Limpiar filtros
  void clearFiltros() {
    state = state.copyWith(
      filtroActivo: null,
      startDate: null,
      endDate: null,
    );
    loadResoluciones(pageNumber: 1, activo: null, startDate: null, endDate: null);
  }

  /// Página siguiente
  void nextPage() {
    if (state.resolucionesResponse?.pagination.hasMoreElements ?? false) {
      loadResoluciones(pageNumber: state.currentPage + 1);
    }
  }

  /// Página anterior
  void previousPage() {
    if (state.currentPage > 1) {
      loadResoluciones(pageNumber: state.currentPage - 1);
    }
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadResoluciones(pageNumber: 1);
  }

  /// Crear resolución
  Future<String?> crearResolucion({
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required String fechaResolucion,
    required String fechaVencimiento,
    required bool activo,
  }) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await createResolucionUseCase.call(
        clienteId: clienteId,
        prefijo: prefijo,
        numeroDesde: numeroDesde,
        numeroHasta: numeroHasta,
        numeroActual: numeroActual,
        numeroResolucion: numeroResolucion,
        fechaResolucion: fechaResolucion,
        fechaVencimiento: fechaVencimiento,
        activo: activo,
      );

      // Recargar las resoluciones después de crear
      await loadResoluciones(pageNumber: 1);

      return null; // Sin error
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}

// Provider del notifier
final resolucionesProvider = StateNotifierProvider<ResolucionesNotifier, ResolucionesState>((ref) {
  final getResolucionesUseCase = ref.watch(getResolucionesUseCaseProvider);
  final createResolucionUseCase = ref.watch(createResolucionUseCaseProvider);

  return ResolucionesNotifier(
    getResolucionesUseCase: getResolucionesUseCase,
    createResolucionUseCase: createResolucionUseCase,
    ref: ref,
  );
});
