import 'package:equatable/equatable.dart';

class Pagination extends Equatable {
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

  @override
  List<Object?> get props => [
        totalElement,
        pageSize,
        pageNumber,
        hasMoreElements,
      ];
}
