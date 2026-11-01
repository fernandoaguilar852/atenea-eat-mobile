import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/ventas_remote_datasource.dart';
import '../../data/repositories/ventas_repository_impl.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../../domain/usecases/get_ventas_usecase.dart';
import '../../domain/entities/ventas_response.dart';

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

// Clase helper para distinguir entre "no cambiar" y "establecer a null"
class _Undefined {
  const _Undefined();
}

// Estado de ventas
class VentasState {
  final VentasResponse? ventasResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;

  VentasState({
    this.ventasResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
  });

  VentasState copyWith({
    Object? ventasResponse = const _Undefined(),
    Object? isLoading = const _Undefined(),
    Object? error = const _Undefined(),
    Object? currentPage = const _Undefined(),
  }) {
    return VentasState(
      ventasResponse: ventasResponse is _Undefined ? this.ventasResponse : ventasResponse as VentasResponse?,
      isLoading: isLoading is _Undefined ? this.isLoading : isLoading as bool,
      error: error is _Undefined ? this.error : error as String?,
      currentPage: currentPage is _Undefined ? this.currentPage : currentPage as int,
    );
  }
}

// Notifier de ventas
class VentasNotifier extends StateNotifier<VentasState> {
  final GetVentasUseCase getVentasUseCase;
  final Ref ref;

  VentasNotifier({
    required this.getVentasUseCase,
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
}

// Provider del notifier
final ventasProvider = StateNotifierProvider<VentasNotifier, VentasState>((ref) {
  final useCase = ref.watch(getVentasUseCaseProvider);
  return VentasNotifier(
    getVentasUseCase: useCase,
    ref: ref,
  );
});
