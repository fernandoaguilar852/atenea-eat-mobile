import '../../domain/entities/ventas_response.dart';
import 'venta_dto.dart';

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

class VentasResponseDto {
  final List<VentaDto> ventas;
  final PaginationDto pagination;

  VentasResponseDto({
    required this.ventas,
    required this.pagination,
  });

  factory VentasResponseDto.fromJson(Map<String, dynamic> json) {
    return VentasResponseDto(
      ventas: (json['data']['ventas'] as List<dynamic>)
          .map((e) => VentaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  VentasResponse toEntity() {
    return VentasResponse(
      ventas: ventas.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
