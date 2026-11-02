import 'resolucion.dart';

class ResolucionesResponse {
  final List<Resolucion> resoluciones;
  final Pagination pagination;

  const ResolucionesResponse({
    required this.resoluciones,
    required this.pagination,
  });
}

class Pagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const Pagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });
}
