import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/resoluciones_remote_datasource.dart';
import '../../data/repositories/resoluciones_repository_impl.dart';
import '../../domain/entities/resoluciones_response.dart';
import '../../domain/repositories/resoluciones_repository.dart';
import '../../domain/usecases/get_resoluciones_usecase.dart';

// Provider del repositorio
final resolucionesRepositoryProvider = Provider<ResolucionesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = ResolucionesRemoteDatasourceImpl(dio: dio);

  return ResolucionesRepositoryImpl(remoteDatasource: datasource);
});

// Provider del UseCase
final getResolucionesUseCaseProvider = Provider<GetResolucionesUseCase>((ref) {
  final repository = ref.watch(resolucionesRepositoryProvider);
  return GetResolucionesUseCase(repository);
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

  const ResolucionesState({
    this.resolucionesResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
  });

  ResolucionesState copyWith({
    Object? resolucionesResponse = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? error = const _Undefined(),
    int? currentPage,
  }) {
    return ResolucionesState(
      resolucionesResponse: resolucionesResponse is _Undefined
          ? this.resolucionesResponse
          : resolucionesResponse as ResolucionesResponse?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      error: error is _Undefined ? this.error : error as String?,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Notifier de resoluciones
class ResolucionesNotifier extends StateNotifier<ResolucionesState> {
  final GetResolucionesUseCase getResolucionesUseCase;
  final Ref ref;

  ResolucionesNotifier({
    required this.getResolucionesUseCase,
    required this.ref,
  }) : super(const ResolucionesState());

  /// Carga las resoluciones del servidor
  Future<void> loadResoluciones({int? pageNumber}) async {
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
      final response = await getResolucionesUseCase.call(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
      );

      state = state.copyWith(
        resolucionesResponse: response,
        isLoading: false,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
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
}

// Provider del notifier
final resolucionesProvider = StateNotifierProvider<ResolucionesNotifier, ResolucionesState>((ref) {
  final getResolucionesUseCase = ref.watch(getResolucionesUseCaseProvider);

  return ResolucionesNotifier(
    getResolucionesUseCase: getResolucionesUseCase,
    ref: ref,
  );
});
