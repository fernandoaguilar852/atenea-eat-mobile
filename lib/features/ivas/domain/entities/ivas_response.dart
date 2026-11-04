import 'iva.dart';

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

class IvasResponse {
  final List<Iva> ivas;
  final Pagination pagination;

  IvasResponse({
    required this.ivas,
    required this.pagination,
  });
}
