import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/categorias_remote_datasource.dart';
import '../../data/repositories/categorias_repository_impl.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../../domain/usecases/get_categorias_usecase.dart';
import '../../domain/entities/categorias_response.dart';

// Provider del datasource
final categoriasRemoteDatasourceProvider = Provider<CategoriasRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoriasRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final categoriasRepositoryProvider = Provider<CategoriasRepository>((ref) {
  final datasource = ref.watch(categoriasRemoteDatasourceProvider);
  return CategoriasRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case
final getCategoriasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(categoriasRepositoryProvider);
  return GetCategoriasUseCase(repository);
});

// Estado de categorías
class CategoriasState {
  final CategoriasResponse? categoriasResponse;
  final bool isLoading;
  final String? error;

  CategoriasState({
    this.categoriasResponse,
    this.isLoading = false,
    this.error,
  });

  CategoriasState copyWith({
    CategoriasResponse? categoriasResponse,
    bool? isLoading,
    String? error,
  }) {
    return CategoriasState(
      categoriasResponse: categoriasResponse ?? this.categoriasResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier de categorías
class CategoriasNotifier extends StateNotifier<CategoriasState> {
  final GetCategoriasUseCase getCategoriasUseCase;
  final Ref ref;

  CategoriasNotifier({
    required this.getCategoriasUseCase,
    required this.ref,
  }) : super(CategoriasState());

  Future<void> loadCategorias() async {
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

      final response = await getCategoriasUseCase(clienteId: clienteId);

      state = state.copyWith(
        categoriasResponse: response,
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
}

// Provider del notifier
final categoriasProvider = StateNotifierProvider<CategoriasNotifier, CategoriasState>((ref) {
  final useCase = ref.watch(getCategoriasUseCaseProvider);
  return CategoriasNotifier(
    getCategoriasUseCase: useCase,
    ref: ref,
  );
});
