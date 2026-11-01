import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/movimientos_remote_datasource.dart';
import '../../data/repositories/movimientos_repository_impl.dart';
import '../../domain/repositories/movimientos_repository.dart';
import '../../domain/usecases/get_movimientos_usecase.dart';
import '../../domain/usecases/registrar_movimiento_usecase.dart';
import '../../domain/usecases/get_movimiento_detalle_usecase.dart';
import '../../domain/usecases/actualizar_movimiento_usecase.dart';
import '../../domain/usecases/eliminar_movimiento_usecase.dart';
import '../../domain/entities/movimientos_response.dart';
import '../../domain/entities/movimiento.dart';

// Provider del datasource
final movimientosRemoteDatasourceProvider = Provider<MovimientosRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return MovimientosRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final movimientosRepositoryProvider = Provider<MovimientosRepository>((ref) {
  final datasource = ref.watch(movimientosRemoteDatasourceProvider);
  return MovimientosRepositoryImpl(remoteDatasource: datasource);
});

// Providers de use cases
final getMovimientosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return GetMovimientosUseCase(repository);
});

final registrarMovimientoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return RegistrarMovimientoUseCase(repository);
});

final getMovimientoDetalleUseCaseProvider = Provider((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return GetMovimientoDetalleUseCase(repository);
});

final actualizarMovimientoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return ActualizarMovimientoUseCase(repository);
});

final eliminarMovimientoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(movimientosRepositoryProvider);
  return EliminarMovimientoUseCase(repository);
});

// Estado de movimientos
class MovimientosState {
  final MovimientosResponse? movimientosResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String? fechaDesde;
  final String? fechaHasta;
  final int? productoId;
  final String? productoNombre;
  final int? insumoId;
  final String? insumoNombre;

  MovimientosState({
    this.movimientosResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.fechaDesde,
    this.fechaHasta,
    this.productoId,
    this.productoNombre,
    this.insumoId,
    this.insumoNombre,
  });

  MovimientosState copyWith({
    MovimientosResponse? movimientosResponse,
    bool? isLoading,
    String? error,
    int? currentPage,
    Object? fechaDesde = const _Undefined(),
    Object? fechaHasta = const _Undefined(),
    Object? productoId = const _Undefined(),
    Object? productoNombre = const _Undefined(),
    Object? insumoId = const _Undefined(),
    Object? insumoNombre = const _Undefined(),
  }) {
    return MovimientosState(
      movimientosResponse: movimientosResponse ?? this.movimientosResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      fechaDesde: fechaDesde is _Undefined ? this.fechaDesde : fechaDesde as String?,
      fechaHasta: fechaHasta is _Undefined ? this.fechaHasta : fechaHasta as String?,
      productoId: productoId is _Undefined ? this.productoId : productoId as int?,
      productoNombre: productoNombre is _Undefined ? this.productoNombre : productoNombre as String?,
      insumoId: insumoId is _Undefined ? this.insumoId : insumoId as int?,
      insumoNombre: insumoNombre is _Undefined ? this.insumoNombre : insumoNombre as String?,
    );
  }
}

// Clase helper para distinguir entre "no cambiar" y "establecer a null"
class _Undefined {
  const _Undefined();
}

// Notifier de movimientos
class MovimientosNotifier extends StateNotifier<MovimientosState> {
  final GetMovimientosUseCase getMovimientosUseCase;
  final Ref ref;

  MovimientosNotifier({
    required this.getMovimientosUseCase,
    required this.ref,
  }) : super(MovimientosState());

  Future<void> loadMovimientos({
    int? pageNumber,
    Object? fechaDesde = const _Undefined(),
    Object? fechaHasta = const _Undefined(),
    Object? productoId = const _Undefined(),
    Object? insumoId = const _Undefined(),
  }) async {
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
      final desde = fechaDesde is _Undefined ? state.fechaDesde : fechaDesde as String?;
      final hasta = fechaHasta is _Undefined ? state.fechaHasta : fechaHasta as String?;
      final prodId = productoId is _Undefined ? state.productoId : productoId as int?;
      final insId = insumoId is _Undefined ? state.insumoId : insumoId as int?;

      final response = await getMovimientosUseCase(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
        fechaDesde: desde,
        fechaHasta: hasta,
        productoId: prodId,
        insumoId: insId,
      );

      state = state.copyWith(
        movimientosResponse: response,
        isLoading: false,
        error: null,
        currentPage: page,
        fechaDesde: desde,
        fechaHasta: hasta,
        productoId: prodId,
        insumoId: insId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setProducto(int id, String nombre) {
    state = state.copyWith(
      productoId: id,
      productoNombre: nombre,
      insumoId: null,
      insumoNombre: null,
    );
  }

  void setInsumo(int id, String nombre) {
    state = state.copyWith(
      insumoId: id,
      insumoNombre: nombre,
      productoId: null,
      productoNombre: null,
    );
  }

  void clearProducto() {
    state = state.copyWith(
      productoId: null,
      productoNombre: null,
    );
  }

  void clearInsumo() {
    state = state.copyWith(
      insumoId: null,
      insumoNombre: null,
    );
  }
}

// Provider del notifier
final movimientosProvider = StateNotifierProvider<MovimientosNotifier, MovimientosState>((ref) {
  final useCase = ref.watch(getMovimientosUseCaseProvider);
  return MovimientosNotifier(
    getMovimientosUseCase: useCase,
    ref: ref,
  );
});

// Estado para registrar movimiento
class RegistrarMovimientoState {
  final bool isLoading;
  final String? error;
  final Movimiento? movimientoCreado;

  RegistrarMovimientoState({
    this.isLoading = false,
    this.error,
    this.movimientoCreado,
  });

  RegistrarMovimientoState copyWith({
    bool? isLoading,
    String? error,
    Movimiento? movimientoCreado,
  }) {
    return RegistrarMovimientoState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      movimientoCreado: movimientoCreado ?? this.movimientoCreado,
    );
  }
}

// Notifier para registrar movimiento
class RegistrarMovimientoNotifier extends StateNotifier<RegistrarMovimientoState> {
  final RegistrarMovimientoUseCase registrarMovimientoUseCase;
  final Ref ref;

  RegistrarMovimientoNotifier({
    required this.registrarMovimientoUseCase,
    required this.ref,
  }) : super(RegistrarMovimientoState());

  Future<bool> registrarMovimiento({
    int? productoId,
    int? insumoId,
    int? proveedorId,
    required String tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required int cantidad,
    required String observacion,
    required String fecha,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authState = ref.read(authProvider);
      final clienteId = authState.user?.clienteId;
      final usuarioId = authState.user?.usuarioId;

      if (clienteId == null || usuarioId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se encontró el cliente ID o usuario ID',
        );
        return false;
      }

      final movimiento = await registrarMovimientoUseCase(
        productoId: productoId,
        insumoId: insumoId,
        usuarioId: usuarioId,
        clienteId: clienteId,
        proveedorId: proveedorId,
        tipo: tipo,
        costo: costo,
        impuesto: impuesto,
        descuentoUnidad: descuentoUnidad,
        cantidad: cantidad,
        observacion: observacion,
        fecha: fecha,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        movimientoCreado: movimiento,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = RegistrarMovimientoState();
  }
}

// Provider del notifier para registrar movimiento
final registrarMovimientoProvider = StateNotifierProvider<RegistrarMovimientoNotifier, RegistrarMovimientoState>((ref) {
  final useCase = ref.watch(registrarMovimientoUseCaseProvider);
  return RegistrarMovimientoNotifier(
    registrarMovimientoUseCase: useCase,
    ref: ref,
  );
});
