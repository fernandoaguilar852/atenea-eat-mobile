import '../../../reportes/domain/entities/pagination.dart';
import 'proveedor.dart';

class ProveedoresResponse {
  final List<Proveedor> proveedores;
  final Pagination pagination;

  ProveedoresResponse({
    required this.proveedores,
    required this.pagination,
  });
}
