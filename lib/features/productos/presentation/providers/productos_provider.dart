import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/productos_remote_datasource.dart';
import '../../data/repositories/productos_repository_impl.dart';
import '../../domain/repositories/productos_repository.dart';
import '../../domain/usecases/get_productos_usecase.dart';
import '../../domain/usecases/get_producto_detail_usecase.dart';
import '../../domain/entities/productos_response.dart';
import '../../domain/entities/producto.dart';

// Provider del datasource
final productosRemoteDatasourceProvider = Provider<ProductosRemoteDatasource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductosRemoteDatasourceImpl(dio: dio);
});

// Provider del repositorio
final productosRepositoryProvider = Provider<ProductosRepository>((ref) {
  final datasource = ref.watch(productosRemoteDatasourceProvider);
  return ProductosRepositoryImpl(remoteDatasource: datasource);
});

// Providers de los use cases
final getProductosUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productosRepositoryProvider);
  return GetProductosUseCase(repository);
});

final getProductoDetailUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productosRepositoryProvider);
  return GetProductoDetailUseCase(repository);
});

// Clase especial para valores undefined
class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();

// Estado para el listado de productos
class ProductosListState {
  final ProductosResponse? productosResponse;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String? search;
  final int? tipoProductoId;

  ProductosListState({
    this.productosResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.search,
    this.tipoProductoId,
  });

  ProductosListState copyWith({
    ProductosResponse? productosResponse,
    bool? isLoading,
    Object? error = _undefined,
    int? currentPage,
    Object? search = _undefined,
    Object? tipoProductoId = _undefined,
  }) {
    return ProductosListState(
      productosResponse: productosResponse ?? this.productosResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
      currentPage: currentPage ?? this.currentPage,
      search: search == _undefined ? this.search : search as String?,
      tipoProductoId: tipoProductoId == _undefined ? this.tipoProductoId : tipoProductoId as int?,
    );
  }
}

// Notifier para el listado de productos
class ProductosListNotifier extends StateNotifier<ProductosListState> {
  final GetProductosUseCase getProductosUseCase;
  final Ref ref;

  ProductosListNotifier({
    required this.getProductosUseCase,
    required this.ref,
  }) : super(ProductosListState());

  Future<void> loadProductos({
    int? pageNumber,
    Object? search = _undefined,
    Object? tipoProductoId = _undefined,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        search: search,
        tipoProductoId: tipoProductoId,
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

      final response = await getProductosUseCase(
        clienteId: clienteId,
        pageSize: 10,
        pageNumber: page,
        search: state.search,
        tipoProductoId: state.tipoProductoId,
      );

      state = state.copyWith(
        productosResponse: response,
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

  void clearProductos() {
    state = ProductosListState();
  }
}

// Provider del notifier para listado de productos
final productosListProvider = StateNotifierProvider<ProductosListNotifier, ProductosListState>((ref) {
  final useCase = ref.watch(getProductosUseCaseProvider);
  return ProductosListNotifier(
    getProductosUseCase: useCase,
    ref: ref,
  );
});

// Estado para el detalle de un producto
class ProductoDetailState {
  final Producto? producto;
  final bool isLoading;
  final String? error;

  ProductoDetailState({
    this.producto,
    this.isLoading = false,
    this.error,
  });

  ProductoDetailState copyWith({
    Producto? producto,
    bool? isLoading,
    String? error,
  }) {
    return ProductoDetailState(
      producto: producto ?? this.producto,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier para el detalle de producto
class ProductoDetailNotifier extends StateNotifier<ProductoDetailState> {
  final GetProductoDetailUseCase getProductoDetailUseCase;
  final Ref ref;

  ProductoDetailNotifier({
    required this.getProductoDetailUseCase,
    required this.ref,
  }) : super(ProductoDetailState());

  Future<void> loadProductoDetail({required int productoId}) async {
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

      final producto = await getProductoDetailUseCase(
        clienteId: clienteId,
        productoId: productoId,
      );

      state = state.copyWith(
        producto: producto,
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

  void clearProducto() {
    state = ProductoDetailState();
  }
}

// Provider del notifier para detalle de producto
final productoDetailProvider = StateNotifierProvider<ProductoDetailNotifier, ProductoDetailState>((ref) {
  final useCase = ref.watch(getProductoDetailUseCaseProvider);
  return ProductoDetailNotifier(
    getProductoDetailUseCase: useCase,
    ref: ref,
  );
});
