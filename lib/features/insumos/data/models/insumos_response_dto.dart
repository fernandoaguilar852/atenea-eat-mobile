import '../../../reportes/data/models/pagination_dto.dart';
import '../../../reportes/domain/entities/pagination.dart';
import '../../domain/entities/insumos_response.dart';
import 'insumo_dto.dart';

class InsumosResponseDto {
  final List<InsumoDto> data;
  final PaginationDto pagination;

  InsumosResponseDto({
    required this.data,
    required this.pagination,
  });

  factory InsumosResponseDto.fromJson(Map<String, dynamic> json) {
    return InsumosResponseDto(
      data: (json['data'] as List)
          .map((insumo) => InsumoDto.fromJson(insumo))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination']),
    );
  }

  InsumosResponse toEntity() {
    return InsumosResponse(
      insumos: data.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
