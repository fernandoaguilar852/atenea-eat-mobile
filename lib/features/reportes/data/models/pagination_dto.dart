import '../../domain/entities/pagination.dart';

class PaginationDto {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  PaginationDto({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      totalElement: json['totalElement'] as int,
      pageSize: json['pageSize'] as int,
      pageNumber: json['pageNumber'] as int,
      hasMoreElements: json['hasMoreElements'] as bool,
    );
  }

  Pagination toEntity() {
    return Pagination(
      totalElement: totalElement,
      pageSize: pageSize,
      pageNumber: pageNumber,
      hasMoreElements: hasMoreElements,
    );
  }
}
