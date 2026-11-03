import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/insumos_remote_datasource.dart';
import '../../data/repositories/insumos_repository_impl.dart';
import '../../domain/repositories/insumos_repository.dart';
import '../../domain/usecases/get_insumos_usecase.dart';
import '../../domain/usecases/get_insumo_detail_usecase.dart';
import '../../domain/usecases/create_insumo_usecase.dart';
import '../../domain/usecases/update_insumo_usecase.dart';
import '../../domain/usecases/delete_insumo_usecase.dart';
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

final createInsumoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insumosRepositoryProvider);
  return CreateInsumoUseCase(repository: repository);
});

final updateInsumoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insumosRepositoryProvider);
  return UpdateInsumoUseCase(repository: repository);
});

final deleteInsumoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(insumosRepositoryProvider);
  return DeleteInsumoUseCase(repository: repository);
});

// Clase especial para valores undefined
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

// Estado de la lista de insumos
class InsumosListState {
  final InsumosResponse? insumosResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String? nombre;
  final bool? activo;

  InsumosListState({
    this.insumosResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.nombre,
    this.activo = true,
  });

  InsumosListState copyWith({
    InsumosResponse? insumosResponse,
    bool? isLoading,
    Object? error = _undefined,
    int? currentPage,
    Object? nombre = _undefined,
    Object? activo = _undefined,
  }) {
    return InsumosListState(
      insumosResponse: insumosResponse ?? this.insumosResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
      currentPage: currentPage ?? this.currentPage,
      nombre: nombre == _undefined ? this.nombre : nombre as String?,
      activo: activo == _undefined ? this.activo : activo as bool?,
    );
  }
}

// Notifier de la lista de insumos
class InsumosListNotifier extends StateNotifier<InsumosListState> {
  final GetInsumosUseCase getInsumosUseCase;
  final CreateInsumoUseCase createInsumoUseCase;
  final UpdateInsumoUseCase updateInsumoUseCase;
  final DeleteInsumoUseCase deleteInsumoUseCase;
  final Ref ref;

  InsumosListNotifier({
    required this.getInsumosUseCase,
    required this.createInsumoUseCase,
    required this.updateInsumoUseCase,
    required this.deleteInsumoUseCase,
    required this.ref,
  }) : super(InsumosListState());

  Future<void> loadInsumos({
    int? pageNumber,
    Object? nombre = _undefined,
    Object? activo = _undefined,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        nombre: nombre,
        activo: activo,
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

      final page = pageNumber ?? 1;

      final response = await getInsumosUseCase(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
        activo: state.activo,
        nombre: state.nombre,
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

  Future<String?> createInsumo({
    required String nombre,
    required String unidadBase,
    required double stockActual,
    required double stockMinimo,
    required double costoPromedio,
    required bool activo,
  }) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await createInsumoUseCase(
        clienteId: clienteId,
        nombre: nombre,
        unidadBase: unidadBase,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        costoPromedio: costoPromedio,
        activo: activo,
      );

      // Recargar la lista después de crear
      await loadInsumos();

      return null; // Sin error
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> updateInsumo({
    required int insumoId,
    required String nombre,
    required String unidadBase,
    required double stockActual,
    required double stockMinimo,
    required double costoPromedio,
    required bool activo,
  }) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await updateInsumoUseCase(
        insumoId: insumoId,
        clienteId: clienteId,
        nombre: nombre,
        unidadBase: unidadBase,
        stockActual: stockActual,
        stockMinimo: stockMinimo,
        costoPromedio: costoPromedio,
        activo: activo,
      );

      // Recargar la lista después de actualizar
      await loadInsumos();

      return null; // Sin error
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> deleteInsumo({
    required int insumoId,
    required bool isActivo,
  }) async {
    // Validar que no esté activo
    if (isActivo) {
      return 'No se puede eliminar un insumo activo. Primero debe desactivarlo.';
    }

    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await deleteInsumoUseCase(
        insumoId: insumoId,
        clienteId: clienteId,
      );

      // Recargar la lista después de eliminar
      await loadInsumos();

      return null; // Sin error
    } catch (e) {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}

// Provider del notifier de lista
final insumosListProvider = StateNotifierProvider<InsumosListNotifier, InsumosListState>((ref) {
  final getInsumosUseCase = ref.watch(getInsumosUseCaseProvider);
  final createInsumoUseCase = ref.watch(createInsumoUseCaseProvider);
  final updateInsumoUseCase = ref.watch(updateInsumoUseCaseProvider);
  final deleteInsumoUseCase = ref.watch(deleteInsumoUseCaseProvider);

  return InsumosListNotifier(
    getInsumosUseCase: getInsumosUseCase,
    createInsumoUseCase: createInsumoUseCase,
    updateInsumoUseCase: updateInsumoUseCase,
    deleteInsumoUseCase: deleteInsumoUseCase,
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

// Estado para búsqueda de insumos
class InsumosSearchState {
  final List<Insumo> insumos;
  final bool isLoading;
  final String? error;
  final Insumo? selectedInsumo;

  InsumosSearchState({
    this.insumos = const [],
    this.isLoading = false,
    this.error,
    this.selectedInsumo,
  });

  InsumosSearchState copyWith({
    List<Insumo>? insumos,
    bool? isLoading,
    String? error,
    Insumo? selectedInsumo,
    bool clearSelected = false,
  }) {
    return InsumosSearchState(
      insumos: insumos ?? this.insumos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedInsumo: clearSelected ? null : (selectedInsumo ?? this.selectedInsumo),
    );
  }
}

// Notifier para búsqueda de insumos
class InsumosSearchNotifier extends StateNotifier<InsumosSearchState> {
  final GetInsumosUseCase getInsumosUseCase;
  final Ref ref;

  InsumosSearchNotifier({
    required this.getInsumosUseCase,
    required this.ref,
  }) : super(InsumosSearchState());

  Future<void> searchInsumos(String query) async {
    if (query.length < 3) {
      state = InsumosSearchState();
      return;
      }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID',
        );
        return;
      }

      final response = await getInsumosUseCase(
        clienteId: clienteId,
        pageSize: 100, // Traer más resultados para buscar en todas las páginas
        pageNumber: 1,
        activo: null, // Buscar en todos (activos e inactivos)
        nombre: query,
      );

      state = state.copyWith(
        insumos: response.insumos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectInsumo(Insumo insumo) {
    state = state.copyWith(
      selectedInsumo: insumo,
      insumos: [],
    );
  }

  void clearSearch() {
    state = InsumosSearchState();
  }
}

// Provider global del StateNotifier para búsqueda de insumos
final insumosSearchProvider = StateNotifierProvider<InsumosSearchNotifier, InsumosSearchState>((ref) {
  final getInsumosUseCase = ref.watch(getInsumosUseCaseProvider);

  return InsumosSearchNotifier(
    getInsumosUseCase: getInsumosUseCase,
    ref: ref,
  );
});
