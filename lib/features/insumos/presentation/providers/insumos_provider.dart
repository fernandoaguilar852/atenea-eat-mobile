import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/insumos_remote_datasource.dart';
import '../../data/repositories/insumos_repository_impl.dart';
import '../../domain/repositories/insumos_repository.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/get_insumo_detail_usecase.dart';
import '../../domain/entities/insumos_response.dart';
import '../../domain/entities/insumo.dart';

// Provider del datasource
final insumosRemoteDatasourceProvider = Provider<InsumosRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return InsumosRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final insumosRepositoryProvider = Provider<InsumosRepository>((ref) {
  final datasource = ref.watch(insumosRemoteDatasourceProvider);
  return InsumosRepositoryImpl(remoteDatasource: datasource);
});

// Providers de use cases
final getInsumosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insumosRepositoryProvider);
  return GetInsumosUseCase(repository);
});

final getInsumoDetailUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insumosRepositoryProvider);
  return GetInsumoDetailUseCase(repository);
});

// Estado de la lista de insumos
class InsumosListState {
  final InsumosResponse? insumosResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;

  InsumosListState({
    this.insumosResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
  });

  InsumosListState copyWith({
    InsumosResponse? insumosResponse,
    bool? isLoading,
    String? error,
    int? currentPage,
  }) {
    return InsumosListState(
      insumosResponse: insumosResponse ?? this.insumosResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Notifier de la lista de insumos
class InsumosListNotifier extends StateNotifier<InsumosListState> {
  final GetInsumosUseCase getInsumosUseCase;
  final Ref ref;

  InsumosListNotifier({
    required this.getInsumosUseCase,
    required this.ref,
  }) : super(InsumosListState());

  Future<void> loadInsumos({int? pageNumber}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

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

      final response = await getInsumosUseCase(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
        activo: true,
      );

      state = state.copyWith(
        insumosResponse: response,
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
    if (state.insumosResponse?.pagination.hasMoreElements == true) {
      loadInsumos(pageNumber: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      loadInsumos(pageNumber: state.currentPage - 1);
    }
  }
}

// Provider del notifier de lista
final insumosListProvider = StateNotifierProvider<InsumosListNotifier, InsumosListState>((ref) {
  final useCase = ref.watch(getInsumosUseCaseProvider);
  return InsumosListNotifier(
    getInsumosUseCase: useCase,
    ref: ref,
  );
});

// Estado del detalle del insumo
class InsumoDetailState {
  final Insumo? insumo;
  final bool isLoading;
  final String? error;

  InsumoDetailState({
    this.insumo,
    this.isLoading = false,
    this.error,
  });

  InsumoDetailState copyWith({
    Insumo? insumo,
    bool? isLoading,
    String? error,
  }) {
    return InsumoDetailState(
      insumo: insumo ?? this.insumo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier del detalle del insumo
class InsumoDetailNotifier extends StateNotifier<InsumoDetailState> {
  final GetInsumoDetailUseCase getInsumoDetailUseCase;
  final Ref ref;

  InsumoDetailNotifier({
    required this.getInsumoDetailUseCase,
    required this.ref,
  }) : super(InsumoDetailState());

  Future<void> loadInsumoDetail(int insumoId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID',
        );
        return;
      }

      final insumo = await getInsumoDetailUseCase(
        insumoId: insumoId,
        clienteId: clienteId,
      );

      state = state.copyWith(
        insumo: insumo,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = InsumoDetailState();
  }
}

// Provider del notifier de detalle
final insumoDetailProvider = StateNotifierProvider<InsumoDetailNotifier, InsumoDetailState>((ref) {
  final useCase = ref.watch(getInsumoDetailUseCaseProvider);
  return InsumoDetailNotifier(
    getInsumoDetailUseCase: useCase,
    ref: ref,
  );
});
