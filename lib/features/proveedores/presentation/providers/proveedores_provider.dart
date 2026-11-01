import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/proveedores_remote_datasource.dart';
import '../../data/repositories/proveedores_repository_impl.dart';
import '../../domain/repositories/proveedores_repository.dart';
import '../../domain/usecases/get_proveedores_usecase.dart';
import '../../domain/entities/proveedores_response.dart';

// Provider del datasource
final proveedoresRemoteDatasourceProvider = Provider<ProveedoresRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProveedoresRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final proveedoresRepositoryProvider = Provider<ProveedoresRepository>((ref) {
  final datasource = ref.watch(proveedoresRemoteDatasourceProvider);
  return ProveedoresRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case
final getProveedoresUseCaseProvider = Provider((ref) {
  final repository = ref.watch(proveedoresRepositoryProvider);
  return GetProveedoresUseCase(repository);
});

// Estado de proveedores
class ProveedoresState {
  final ProveedoresResponse? proveedoresResponse;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  ProveedoresState({
    this.proveedoresResponse,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ProveedoresState copyWith({
    ProveedoresResponse? proveedoresResponse,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ProveedoresState(
      proveedoresResponse: proveedoresResponse ?? this.proveedoresResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifier de proveedores
class ProveedoresNotifier extends StateNotifier<ProveedoresState> {
  final GetProveedoresUseCase getProveedoresUseCase;
  final Ref ref;

  ProveedoresNotifier({
    required this.getProveedoresUseCase,
    required this.ref,
  }) : super(ProveedoresState());

  Future<void> searchProveedores(String query) async {
    // Solo buscar si tiene 3 o más caracteres
    if (query.length < 3) {
      state = state.copyWith(
        proveedoresResponse: null,
        searchQuery: query,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null, searchQuery: query);

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;

      if (clienteId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID',
        );
        return;
      }

      final response = await getProveedoresUseCase(
        clienteId: clienteId,
        pageNumber: 1,
        pageSize: 50, // Suficiente para mostrar resultados filtrados
        search: query,
      );

      state = state.copyWith(
        proveedoresResponse: response,
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

  void clearSearch() {
    state = ProveedoresState();
  }
}

// Provider del notifier
final proveedoresProvider = StateNotifierProvider<ProveedoresNotifier, ProveedoresState>((ref) {
  final useCase = ref.watch(getProveedoresUseCaseProvider);
  return ProveedoresNotifier(
    getProveedoresUseCase: useCase,
    ref: ref,
  );
});
