import '../../domain/entities/alertas_response.dart';
import 'alerta_dto.dart';

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

class AlertasResponseDto {
  final List<AlertaDto> alertas;
  final PaginationDto pagination;

  const AlertasResponseDto({
    required this.alertas,
    required this.pagination,
  });

  factory AlertasResponseDto.fromJson(Map<String, dynamic> json) {
    return AlertasResponseDto(
      alertas: (json['data']['alertas'] as List<dynamic>)
          .map((e) => AlertaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  AlertasResponse toEntity() {
    return AlertasResponse(
      alertas: alertas.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
