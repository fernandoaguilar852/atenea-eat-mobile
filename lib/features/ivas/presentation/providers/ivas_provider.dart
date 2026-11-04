import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/ivas_remote_datasource.dart';
import '../../data/repositories/ivas_repository_impl.dart';
import '../../domain/repositories/ivas_repository.dart';
import '../../domain/usecases/get_ivas_usecase.dart';
import '../../domain/entities/ivas_response.dart';

// Provider del datasource
final ivasRemoteDatasourceProvider = Provider<IvasRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return IvasRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final ivasRepositoryProvider = Provider<IvasRepository>((ref) {
  final datasource = ref.watch(ivasRemoteDatasourceProvider);
  return IvasRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case
final getIvasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(ivasRepositoryProvider);
  return GetIvasUseCase(repository);
});

// Estado de la lista de IVAs
class IvasState {
  final IvasResponse? ivasResponse;
  final bool isLoading;
  final String? error;

  IvasState({
    this.ivasResponse,
    this.isLoading = false,
    this.error,
  });

  IvasState copyWith({
    IvasResponse? ivasResponse,
    bool? isLoading,
    String? error,
  }) {
    return IvasState(
      ivasResponse: ivasResponse ?? this.ivasResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier de la lista de IVAs
class IvasNotifier extends StateNotifier<IvasState> {
  final GetIvasUseCase getIvasUseCase;

  IvasNotifier({
    required this.getIvasUseCase,
  }) : super(IvasState());

  Future<void> loadIvas() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await getIvasUseCase(
        pageSize: 100, // Traer todos los IVAs
        pageNumber: 1,
      );

      state = state.copyWith(
        ivasResponse: response,
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

  void clearIvas() {
    state = IvasState();
  }
}

// Provider del notifier
final ivasProvider = StateNotifierProvider<IvasNotifier, IvasState>((ref) {
  final useCase = ref.watch(getIvasUseCaseProvider);
  return IvasNotifier(getIvasUseCase: useCase);
});
