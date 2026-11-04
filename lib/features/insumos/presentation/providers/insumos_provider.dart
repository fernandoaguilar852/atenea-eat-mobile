import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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

  // CACHÉ: Almacena las últimas páginas visitadas para navegación rápida
  final Map<String, InsumosResponse> _cache = {};

  InsumosListNotifier({
    required this.getInsumosUseCase,
    required this.createInsumoUseCase,
    required this.updateInsumoUseCase,
    required this.deleteInsumoUseCase,
    required this.ref,
  }) : super(InsumosListState());

  // Genera una clave única para el caché basada en los filtros
  String _getCacheKey({
    required int page,
    String? nombre,
    bool? activo,
  }) {
    return 'page_${page}_nombre_${nombre ?? 'null'}_activo_${activo ?? 'null'}';
  }

  // Limpia todo el caché (se llama al crear/editar/eliminar)
  void _clearCache() {
    _cache.clear();
  }

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

      // Generar clave del caché
      final cacheKey = _getCacheKey(
        page: page,
        nombre: state.nombre,
        activo: state.activo,
      );

      // VERIFICAR CACHÉ: Si existe, usar datos cacheados
      if (_cache.containsKey(cacheKey)) {
        final cachedResponse = _cache[cacheKey]!;

        state = state.copyWith(
          insumosResponse: cachedResponse,
          isLoading: false,
          error: null,
          currentPage: page,
        );
        return;
      }

      // CACHE MISS: Llamar al servidor
      final response = await getInsumosUseCase(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
        activo: state.activo,
        nombre: state.nombre,
      );

      // GUARDAR EN CACHÉ
      _cache[cacheKey] = response;

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

      // LIMPIAR CACHÉ: Los datos cambiaron
      _clearCache();

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

    // Guardar la lista original por si hay que revertir
    final originalInsumosResponse = state.insumosResponse;

    try {
      // ACTUALIZACIÓN OPTIMISTA: Actualizar en la lista INMEDIATAMENTE
      if (state.insumosResponse != null) {
        final nuevaLista = state.insumosResponse!.insumos.map((insumo) {
          if (insumo.insumoId == insumoId) {
            // Crear una copia del insumo con los nuevos valores
            return Insumo(
              insumoId: insumo.insumoId,
              clienteId: insumo.clienteId,
              nombre: nombre,
              unidadBase: unidadBase,
              stockActual: stockActual,
              stockMinimo: stockMinimo,
              stockReservado: insumo.stockReservado, // Mantener valor original
              costoPromedio: costoPromedio,
              activo: activo,
              creadoEn: insumo.creadoEn, // Mantener valor original
            );
          }
          return insumo;
        }).toList();

        state = state.copyWith(
          insumosResponse: InsumosResponse(
            insumos: nuevaLista,
            pagination: state.insumosResponse!.pagination,
          ),
        );
      }

      // Llamar al servidor en background
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

      // LIMPIAR CACHÉ: Los datos cambiaron (solo si el update fue exitoso)
      _clearCache();

      return null; // Sin error
    } on DioException catch (e) {
      // REVERTIR: Restaurar la lista original si hay error
      if (originalInsumosResponse != null) {
        state = state.copyWith(insumosResponse: originalInsumosResponse);
      }

      // Capturar error de Dio con mensaje del servidor
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        } else if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return 'Error del servidor: ${e.response?.statusCode ?? 'desconocido'}';
      }
      return e.message ?? 'Error de conexión';
    } catch (e) {
      // REVERTIR: Restaurar la lista original si hay error
      if (originalInsumosResponse != null) {
        state = state.copyWith(insumosResponse: originalInsumosResponse);
      }
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

    // Guardar la lista original por si hay que revertir
    final originalInsumosResponse = state.insumosResponse;

    try {
      // ACTUALIZACIÓN OPTIMISTA: Eliminar de la lista INMEDIATAMENTE
      if (state.insumosResponse != null) {
        final nuevaLista = state.insumosResponse!.insumos
            .where((i) => i.insumoId != insumoId)
            .toList();

        state = state.copyWith(
          insumosResponse: InsumosResponse(
            insumos: nuevaLista,
            pagination: state.insumosResponse!.pagination,
          ),
        );
      }

      // Llamar al servidor en background
      await deleteInsumoUseCase(
        insumoId: insumoId,
        clienteId: clienteId,
      );

      // LIMPIAR CACHÉ: Los datos cambiaron (solo si el delete fue exitoso)
      _clearCache();

      return null; // Sin error
    } on DioException catch (e) {
      // REVERTIR: Restaurar la lista original si hay error
      if (originalInsumosResponse != null) {
        state = state.copyWith(insumosResponse: originalInsumosResponse);
      }

      // Capturar error de Dio con mensaje del servidor
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        } else if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return 'Error del servidor: ${e.response?.statusCode ?? 'desconocido'}';
      }
      return e.message ?? 'Error de conexión';
    } catch (e) {
      // REVERTIR: Restaurar la lista original si hay error
      if (originalInsumosResponse != null) {
        state = state.copyWith(insumosResponse: originalInsumosResponse);
      }
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
