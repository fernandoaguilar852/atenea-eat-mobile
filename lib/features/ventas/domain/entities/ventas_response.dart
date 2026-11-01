import 'venta.dart';

class Pagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  Pagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });
}

class VentasResponse {
  final List<Venta> ventas;
  final Pagination pagination;

  VentasResponse({
    required this.ventas,
    required this.pagination,
  });
}
