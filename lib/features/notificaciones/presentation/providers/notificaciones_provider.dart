import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../core/services/credentials_storage_service.dart';
import '../../data/datasources/notificaciones_remote_datasource.dart';
import '../../data/repositories/notificaciones_repository_impl.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/notificaciones_repository.dart';
import '../../domain/usecases/get_notificaciones_usecase.dart';
import '../../domain/usecases/marcar_notificacion_leida_usecase.dart';
import '../../domain/usecases/eliminar_notificacion_usecase.dart';

// Provider del repositorio
final notificacionesRepositoryProvider = Provider<NotificacionesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final datasource = NotificacionesRemoteDatasourceImpl(dio: dio);

  return NotificacionesRepositoryImpl(
    remoteDatasource: datasource,
  );
});

// Providers de los UseCases
final getNotificacionesUseCaseProvider = Provider<GetNotificacionesUseCase>((ref) {
  final repository = ref.watch(notificacionesRepositoryProvider);
  return GetNotificacionesUseCase(repository);
});

final marcarNotificacionLeidaUseCaseProvider = Provider<MarcarNotificacionLeidaUseCase>((ref) {
  final repository = ref.watch(notificacionesRepositoryProvider);
  return MarcarNotificacionLeidaUseCase(repository);
});

final eliminarNotificacionUseCaseProvider = Provider<EliminarNotificacionUseCase>((ref) {
  final repository = ref.watch(notificacionesRepositoryProvider);
  return EliminarNotificacionUseCase(repository);
});

// Estado de notificaciones
class NotificacionesState {
  final List<Notificacion> notificaciones;
  final Pagination? pagination;
  final bool isLoading;
  final String? error;
  final String estadoFiltro; // PENDIENTE o LEIDA

  const NotificacionesState({
    this.notificaciones = const [],
    this.pagination,
    this.isLoading = false,
    this.error,
    this.estadoFiltro = 'PENDIENTE',
  });

  NotificacionesState copyWith({
    List<Notificacion>? notificaciones,
    Pagination? pagination,
    bool? isLoading,
    String? error,
    String? estadoFiltro,
  }) {
    return NotificacionesState(
      notificaciones: notificaciones ?? this.notificaciones,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      estadoFiltro: estadoFiltro ?? this.estadoFiltro,
    );
  }

  int get totalPendientes => notificaciones.where((n) => n.estado == 'PENDIENTE').length;
}

// Notifier
class NotificacionesNotifier extends StateNotifier<NotificacionesState> {
  final GetNotificacionesUseCase getNotificacionesUseCase;
  final MarcarNotificacionLeidaUseCase marcarNotificacionLeidaUseCase;
  final EliminarNotificacionUseCase eliminarNotificacionUseCase;

  NotificacionesNotifier({
    required this.getNotificacionesUseCase,
    required this.marcarNotificacionLeidaUseCase,
    required this.eliminarNotificacionUseCase,
  }) : super(const NotificacionesState());

  Future<void> loadNotificaciones({String? estado}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Obtener clienteId del JWT
      final storage = CredentialsStorageService();
      final token = await storage.getAccessToken();

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No hay token de acceso',
        );
        return;
      }

      final payload = Jwt.parseJwt(token);
      final clienteId = payload['clienteId'] as int;

      final estadoActual = estado ?? state.estadoFiltro;

      final (notificaciones, pagination) = await getNotificacionesUseCase.call(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: 1,
        estado: estadoActual,
      );

      state = NotificacionesState(
        notificaciones: notificaciones,
        pagination: pagination,
        isLoading: false,
        estadoFiltro: estadoActual,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> cambiarFiltro(String nuevoEstado) async {
    await loadNotificaciones(estado: nuevoEstado);
  }

  Future<void> refresh() async {
    await loadNotificaciones();
  }

  Future<void> goToPage(int pageNumber) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Obtener clienteId del JWT
      final storage = CredentialsStorageService();
      final token = await storage.getAccessToken();

      if (token == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No hay token de acceso',
        );
        return;
      }

      final payload = Jwt.parseJwt(token);
      final clienteId = payload['clienteId'] as int;

      final (notificaciones, pagination) = await getNotificacionesUseCase.call(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: pageNumber,
        estado: state.estadoFiltro,
      );

      state = state.copyWith(
        notificaciones: notificaciones,
        pagination: pagination,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> nextPage() async {
    if (state.pagination == null || !state.pagination!.hasMoreElements) return;

    final nextPageNumber = state.pagination!.pageNumber + 1;
    await goToPage(nextPageNumber);
  }

  Future<void> previousPage() async {
    if (state.pagination == null || state.pagination!.pageNumber <= 1) return;

    final previousPageNumber = state.pagination!.pageNumber - 1;
    await goToPage(previousPageNumber);
  }

  Future<bool> marcarComoLeida(int notificacionId) async {
    try {
      // Obtener clienteId del JWT
      final storage = CredentialsStorageService();
      final token = await storage.getAccessToken();

      if (token == null) {
        return false;
      }

      final payload = Jwt.parseJwt(token);
      final clienteId = payload['clienteId'] as int;

      await marcarNotificacionLeidaUseCase.call(
        notificacionId: notificacionId,
        clienteId: clienteId,
      );

      // Recargar notificaciones
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> eliminarNotificacion(int notificacionId) async {
    try {
      // Obtener clienteId del JWT
      final storage = CredentialsStorageService();
      final token = await storage.getAccessToken();

      if (token == null) {
        return false;
      }

      final payload = Jwt.parseJwt(token);
      final clienteId = payload['clienteId'] as int;

      await eliminarNotificacionUseCase.call(
        notificacionId: notificacionId,
        clienteId: clienteId,
      );

      // Recargar notificaciones
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }
}

// Provider del notifier
final notificacionesProvider = StateNotifierProvider<NotificacionesNotifier, NotificacionesState>((ref) {
  final getNotificacionesUseCase = ref.watch(getNotificacionesUseCaseProvider);
  final marcarNotificacionLeidaUseCase = ref.watch(marcarNotificacionLeidaUseCaseProvider);
  final eliminarNotificacionUseCase = ref.watch(eliminarNotificacionUseCaseProvider);

  return NotificacionesNotifier(
    getNotificacionesUseCase: getNotificacionesUseCase,
    marcarNotificacionLeidaUseCase: marcarNotificacionLeidaUseCase,
    eliminarNotificacionUseCase: eliminarNotificacionUseCase,
  );
});
