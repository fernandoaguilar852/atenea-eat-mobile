import '../../domain/entities/ivas_response.dart';
import 'iva_dto.dart';

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

class IvasResponseDto {
  final List<IvaDto> ivas;
  final PaginationDto pagination;

  IvasResponseDto({
    required this.ivas,
    required this.pagination,
  });

  factory IvasResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final ivasList = (data['ivas'] as List)
        .map((iva) => IvaDto.fromJson(iva as Map<String, dynamic>))
        .toList();

    final paginationData = json['pagination'] as Map<String, dynamic>;

    return IvasResponseDto(
      ivas: ivasList,
      pagination: PaginationDto.fromJson(paginationData),
    );
  }

  IvasResponse toEntity() {
    return IvasResponse(
      ivas: ivas.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
