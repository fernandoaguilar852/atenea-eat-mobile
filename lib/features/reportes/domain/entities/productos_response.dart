import 'producto.dart';
import 'pagination.dart';

class ProductosResponse {
  final List<Producto> products;
  final Pagination pagination;

  ProductosResponse({
    required this.products,
    required this.pagination,
  });
}
