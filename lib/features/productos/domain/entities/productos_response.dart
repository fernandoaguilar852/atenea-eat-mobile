import 'producto.dart';
import '../../../reportes/domain/entities/pagination.dart';

class ProductosResponse {
  final List<Producto> productos;
  final Pagination pagination;

  ProductosResponse({
    required this.productos,
    required this.pagination,
  });
}
