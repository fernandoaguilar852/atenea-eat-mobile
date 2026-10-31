import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/estadisticas.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_estadisticas_usecase.dart';

// Provider del repositorio de dashboard
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = DashboardRemoteDatasourceImpl(dio: dio);

  return DashboardRepositoryImpl(remoteDatasource: datasource);
});

// Provider del UseCase
final getEstadisticasUseCaseProvider = Provider<GetEstadisticasUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetEstadisticasUseCase(repository);
});

// Estado de dashboard
class DashboardState {
  final Estadisticas? estadisticas;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.estadisticas,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Estadisticas? estadisticas,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      estadisticas: estadisticas ?? this.estadisticas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier de dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetEstadisticasUseCase getEstadisticasUseCase;
  final Ref ref;

  DashboardNotifier({
    required this.getEstadisticasUseCase,
    required this.ref,
  }) : super(const DashboardState());

  /// Carga las estadísticas del día actual
  Future<void> loadEstadisticas() async {
    // Obtener el clienteId del usuario autenticado
    final user = ref.read(authProvider).user;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Usuario no autenticado',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final estadisticas = await getEstadisticasUseCase.call(
        clienteId: user.clienteId,
      );

      state = DashboardState(
        estadisticas: estadisticas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Recarga las estadísticas (para pull to refresh)
  Future<void> refresh() async {
    await loadEstadisticas();
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider del notifier
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final getEstadisticasUseCase = ref.watch(getEstadisticasUseCaseProvider);

  return DashboardNotifier(
    getEstadisticasUseCase: getEstadisticasUseCase,
    ref: ref,
  );
});
