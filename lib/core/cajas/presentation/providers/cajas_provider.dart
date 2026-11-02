import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dio_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/cajas_remote_datasource.dart';
import '../../data/repositories/cajas_repository_impl.dart';
import '../../domain/repositories/cajas_repository.dart';
import '../../domain/usecases/get_cajas_usecase.dart';
import '../../domain/usecases/get_usuario_usecase.dart';
import '../../domain/entities/caja.dart';

// Provider del datasource
final cajasRemoteDatasourceProvider = Provider<CajasRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return CajasRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final cajasRepositoryProvider = Provider<CajasRepository>((ref) {
  final datasource = ref.watch(cajasRemoteDatasourceProvider);
  return CajasRepositoryImpl(remoteDatasource: datasource);
});

// Provider del use case para obtener cajas
final getCajasUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cajasRepositoryProvider);
  return GetCajasUseCase(repository);
});

// Provider del use case para obtener usuario
final getUsuarioUseCaseProvider = Provider((ref) {
  final repository = ref.watch(cajasRepositoryProvider);
  return GetUsuarioUseCase(repository);
});

// Estado para cajas
class CajasState {
  final List<Caja> cajas;
  final bool isLoading;
  final String? error;
  final Caja? selectedCaja;

  CajasState({
    this.cajas = const [],
    this.isLoading = false,
    this.error,
    this.selectedCaja,
  });

  CajasState copyWith({
    List<Caja>? cajas,
    bool? isLoading,
    String? error,
    Caja? selectedCaja,
    bool clearSelected = false,
  }) {
    return CajasState(
      cajas: cajas ?? this.cajas,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCaja: clearSelected ? null : (selectedCaja ?? this.selectedCaja),
    );
  }
}

// Notifier para cajas
class CajasNotifier extends StateNotifier<CajasState> {
  final GetCajasUseCase getCajasUseCase;
  final GetUsuarioUseCase getUsuarioUseCase;
  final int clienteId;

  CajasNotifier({
    required this.getCajasUseCase,
    required this.getUsuarioUseCase,
    required this.clienteId,
  }) : super(CajasState()) {
    // Cargar cajas al iniciar
    loadCajas();
  }

  Future<void> loadCajas() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final cajas = await getCajasUseCase(
        clienteId: clienteId,
      );

      // Para cada caja, obtener el nombre del usuario
      for (var caja in cajas) {
        try {
          final usuario = await getUsuarioUseCase(
            usuarioId: caja.usuarioId,
            clienteId: clienteId,
          );
          caja.nombreUsuario = usuario.nombre;
        } catch (e) {
          // Si falla obtener el usuario, dejarlo como null
          caja.nombreUsuario = null;
        }
      }

      state = state.copyWith(
        cajas: cajas,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCaja(Caja? caja) {
    state = state.copyWith(
      selectedCaja: caja,
      clearSelected: caja == null,
    );
  }

  // Método para refrescar las cajas manualmente
  Future<void> refreshCajas() async {
    await loadCajas();
  }
}

// Provider del StateNotifier para cajas - GLOBAL
final globalCajasProvider = StateNotifierProvider<CajasNotifier, CajasState>((ref) {
  final authState = ref.watch(authProvider);
  final clienteId = authState.user?.clienteId ?? 0;

  return CajasNotifier(
    getCajasUseCase: ref.watch(getCajasUseCaseProvider),
    getUsuarioUseCase: ref.watch(getUsuarioUseCaseProvider),
    clienteId: clienteId,
  );
});
