import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/productos_remote_datasource.dart';
import '../../data/repositories/productos_repository_impl.dart';
import '../../domain/repositories/productos_repository.dart';
import '../../domain/usecases/get_productos_usecase.dart';
import '../../domain/usecases/get_producto_detail_usecase.dart';
import '../../domain/usecases/create_producto_usecase.dart';
import '../../domain/usecases/update_producto_usecase.dart';
import '../../domain/usecases/delete_producto_usecase.dart';
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

final createProductoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productosRepositoryProvider);
  return CreateProductoUseCase(repository: repository);
});

final updateProductoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productosRepositoryProvider);
  return UpdateProductoUseCase(repository: repository);
});

final deleteProductoUseCaseProvider = Provider((ref) {
  final repository = ref.watch(productosRepositoryProvider);
  return DeleteProductoUseCase(repository: repository);
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
  final bool? activo;
  final bool? usaReceta;

  ProductosListState({
    this.productosResponse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.search,
    this.tipoProductoId,
    this.activo = true,
    this.usaReceta,
  });

  ProductosListState copyWith({
    ProductosResponse? productosResponse,
    bool? isLoading,
    Object? error = _undefined,
    int? currentPage,
    Object? search = _undefined,
    Object? tipoProductoId = _undefined,
    Object? activo = _undefined,
    Object? usaReceta = _undefined,
  }) {
    return ProductosListState(
      productosResponse: productosResponse ?? this.productosResponse,
      isLoading: isLoading ?? this.isLoading,
      error: error == _undefined ? this.error : error as String?,
      currentPage: currentPage ?? this.currentPage,
      search: search == _undefined ? this.search : search as String?,
      tipoProductoId: tipoProductoId == _undefined ? this.tipoProductoId : tipoProductoId as int?,
      activo: activo == _undefined ? this.activo : activo as bool?,
      usaReceta: usaReceta == _undefined ? this.usaReceta : usaReceta as bool?,
    );
  }
}

// Notifier para el listado de productos
class ProductosListNotifier extends StateNotifier<ProductosListState> {
  final GetProductosUseCase getProductosUseCase;
  final CreateProductoUseCase createProductoUseCase;
  final UpdateProductoUseCase updateProductoUseCase;
  final DeleteProductoUseCase deleteProductoUseCase;
  final Ref ref;

  ProductosListNotifier({
    required this.getProductosUseCase,
    required this.createProductoUseCase,
    required this.updateProductoUseCase,
    required this.deleteProductoUseCase,
    required this.ref,
  }) : super(ProductosListState());

  Future<void> loadProductos({
    int? pageNumber,
    Object? search = _undefined,
    Object? tipoProductoId = _undefined,
    Object? activo = _undefined,
    Object? usaReceta = _undefined,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        search: search,
        tipoProductoId: tipoProductoId,
        activo: activo,
        usaReceta: usaReceta,
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
        activo: state.activo,
        usaReceta: state.usaReceta,
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

  Future<String?> createProducto({
    required int tipoProductoId,
    required String nombre,
    required String codExterno,
    required String codBarras,
    required double precio,
    required String unidadMedida,
    required int stockTotal,
    required int stockMinimo,
    required bool manejaStock,
    required bool usaReceta,
    required int ivaId,
    String? imagenBase64,
    String? imagenTipo,
  }) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    print('🔵 Provider - createProducto');
    print('🔵 clienteId: $clienteId');
    print('🔵 tipoProductoId: $tipoProductoId');
    print('🔵 nombre: $nombre');
    print('🔵 codExterno: $codExterno');
    print('🔵 codBarras: $codBarras');
    print('🔵 precio: $precio');
    print('🔵 unidadMedida: $unidadMedida');
    print('🔵 stockTotal: $stockTotal');
    print('🔵 stockMinimo: $stockMinimo');
    print('🔵 manejaStock: $manejaStock');
    print('🔵 usaReceta: $usaReceta');
    print('🔵 ivaId: $ivaId');
    print('🔵 Tiene imagen: ${imagenBase64 != null && imagenBase64.isNotEmpty}');

    try {
      await createProductoUseCase(
        clienteId: clienteId,
        tipoProductoId: tipoProductoId,
        nombre: nombre,
        codExterno: codExterno,
        codBarras: codBarras,
        precio: precio,
        unidadMedida: unidadMedida,
        stockTotal: stockTotal,
        stockMinimo: stockMinimo,
        manejaStock: manejaStock,
        usaReceta: usaReceta,
        ivaId: ivaId,
        imagenBase64: imagenBase64,
        imagenTipo: imagenTipo,
      );

      // Recargar la lista después de crear
      await loadProductos();

      return null; // Sin error
    } on DioException catch (e) {
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
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> updateProducto({
    required int productoId,
    required int tipoProductoId,
    required String nombre,
    required String codExterno,
    required String codBarras,
    required double precio,
    required String unidadMedida,
    required int stockTotal,
    required int stockMinimo,
    required bool manejaStock,
    required bool usaReceta,
    String? imagenBase64,
    String? imagenTipo,
  }) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await updateProductoUseCase(
        productoId: productoId,
        clienteId: clienteId,
        tipoProductoId: tipoProductoId,
        nombre: nombre,
        codExterno: codExterno,
        codBarras: codBarras,
        precio: precio,
        unidadMedida: unidadMedida,
        stockTotal: stockTotal,
        stockMinimo: stockMinimo,
        manejaStock: manejaStock,
        usaReceta: usaReceta,
        imagenBase64: imagenBase64,
        imagenTipo: imagenTipo,
      );

      // Recargar la lista después de actualizar
      await loadProductos();

      return null; // Sin error
    } on DioException catch (e) {
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
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> deleteProducto({required int productoId}) async {
    final authState = ref.read(authProvider);
    final clienteId = authState.user?.clienteId;

    if (clienteId == null) {
      return 'No se encontró el cliente';
    }

    try {
      await deleteProductoUseCase(
        productoId: productoId,
        clienteId: clienteId,
      );

      // Recargar la lista después de eliminar
      await loadProductos();

      return null; // Sin error
    } on DioException catch (e) {
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
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  void clearProductos() {
    state = ProductosListState();
  }
}

// Provider del notifier para listado de productos
final productosListProvider = StateNotifierProvider<ProductosListNotifier, ProductosListState>((ref) {
  final getProductosUseCase = ref.watch(getProductosUseCaseProvider);
  final createProductoUseCase = ref.watch(createProductoUseCaseProvider);
  final updateProductoUseCase = ref.watch(updateProductoUseCaseProvider);
  final deleteProductoUseCase = ref.watch(deleteProductoUseCaseProvider);

  return ProductosListNotifier(
    getProductosUseCase: getProductosUseCase,
    createProductoUseCase: createProductoUseCase,
    updateProductoUseCase: updateProductoUseCase,
    deleteProductoUseCase: deleteProductoUseCase,
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

// Estado para búsqueda de productos
class ProductosSearchState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;
  final Producto? selectedProducto;

  ProductosSearchState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
    this.selectedProducto,
  });

  ProductosSearchState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    Producto? selectedProducto,
    bool clearSelected = false,
  }) {
    return ProductosSearchState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedProducto: clearSelected ? null : (selectedProducto ?? this.selectedProducto),
    );
  }
}

// Notifier para búsqueda de productos
class ProductosSearchNotifier extends StateNotifier<ProductosSearchState> {
  final GetProductosUseCase getProductosUseCase;
  final Ref ref;

  ProductosSearchNotifier({
    required this.getProductosUseCase,
    required this.ref,
  }) : super(ProductosSearchState());

  Future<void> searchProductos(String query) async {
    if (query.length < 3) {
      state = ProductosSearchState();
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

      final response = await getProductosUseCase(
        clienteId: clienteId,
        pageSize: 100, // Traer más resultados para buscar en todas las páginas
        pageNumber: 1,
        activo: null, // Buscar en todos (activos e inactivos)
        search: query,
      );

      state = state.copyWith(
        productos: response.productos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectProducto(Producto producto) {
    state = state.copyWith(
      selectedProducto: producto,
      productos: [],
    );
  }

  void clearSearch() {
    state = ProductosSearchState();
  }
}

// Provider global del StateNotifier para búsqueda de productos
final productosSearchProvider = StateNotifierProvider<ProductosSearchNotifier, ProductosSearchState>((ref) {
  final getProductosUseCase = ref.watch(getProductosUseCaseProvider);

  return ProductosSearchNotifier(
    getProductosUseCase: getProductosUseCase,
    ref: ref,
  );
});
