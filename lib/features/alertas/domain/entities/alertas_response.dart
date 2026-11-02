import 'alerta.dart';

class AlertasResponse {
  final List<Alerta> alertas;
  final Pagination pagination;

  const AlertasResponse({
    required this.alertas,
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
