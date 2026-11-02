import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dio_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/operadores_remote_datasource.dart';
import '../../data/repositories/operadores_repository_impl.dart';
import '../../domain/repositories/operadores_repository.dart';
import '../../domain/usecases/search_operadores_usecase.dart';
import '../../domain/entities/operador.dart';

// Provider del datasource
final operadoresRemoteDatasourceProvider = Provider<OperadoresRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return OperadoresRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final operadoresRepositoryProvider = Provider<OperadoresRepository>((ref) {
  final datasource = ref.watch(operadoresRemoteDatasourceProvider);
  return OperadoresRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case
final searchOperadoresUseCaseProvider = Provider((ref) {
  final repository = ref.watch(operadoresRepositoryProvider);
  return SearchOperadoresUseCase(repository);
});

// Estado para búsqueda de operadores
class OperadoresSearchState {
  final List<Operador> operadores;
  final bool isLoading;
  final String? error;
  final Operador? selectedOperador;

  OperadoresSearchState({
    this.operadores = const [],
    this.isLoading = false,
    this.error,
    this.selectedOperador,
  });

  OperadoresSearchState copyWith({
    List<Operador>? operadores,
    bool? isLoading,
    String? error,
    Operador? selectedOperador,
    bool clearSelected = false,
  }) {
    return OperadoresSearchState(
      operadores: operadores ?? this.operadores,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedOperador: clearSelected ? null : (selectedOperador ?? this.selectedOperador),
    );
  }
}

// Notifier para búsqueda de operadores
class OperadoresSearchNotifier extends StateNotifier<OperadoresSearchState> {
  final SearchOperadoresUseCase searchOperadoresUseCase;
  final int clienteId;

  OperadoresSearchNotifier({
    required this.searchOperadoresUseCase,
    required this.clienteId,
  }) : super(OperadoresSearchState());

  Future<void> searchOperadores(String query) async {
    if (query.length < 3) {
      state = OperadoresSearchState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final operadores = await searchOperadoresUseCase(
        clienteId: clienteId,
        search: query,
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

  void clearSearch() {
    state = OperadoresSearchState();
  }
}

// Provider del StateNotifier para búsqueda de operadores - GLOBAL
final globalOperadoresSearchProvider = StateNotifierProvider<OperadoresSearchNotifier, OperadoresSearchState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return OperadoresSearchNotifier(
    searchOperadoresUseCase: ref.watch(searchOperadoresUseCaseProvider),
    clienteId: clienteId,
  );
});
