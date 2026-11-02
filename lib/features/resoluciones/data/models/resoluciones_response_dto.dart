import '../../domain/entities/resoluciones_response.dart';
import 'resolucion_dto.dart';

class PaginationDto {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const PaginationDto({
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

class ResolucionesResponseDto {
  final List<ResolucionDto> resoluciones;
  final PaginationDto pagination;

  const ResolucionesResponseDto({
    required this.resoluciones,
    required this.pagination,
  });

  factory ResolucionesResponseDto.fromJson(Map<String, dynamic> json) {
    return ResolucionesResponseDto(
      resoluciones: (json['data']['resoluciones'] as List)
          .map((e) => ResolucionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  ResolucionesResponse toEntity() {
    return ResolucionesResponse(
      resoluciones: resoluciones.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
