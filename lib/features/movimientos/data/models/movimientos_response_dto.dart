import '../../../reportes/data/models/pagination_dto.dart';
import '../../domain/entities/movimientos_response.dart';
import 'movimiento_dto.dart';

class MovimientosResponseDto {
  final List<MovimientoDto> movimientos;
  final PaginationDto pagination;

  MovimientosResponseDto({
    required this.movimientos,
    required this.pagination,
  });

  factory MovimientosResponseDto.fromJson(Map<String, dynamic> json) {
    final movimientosJson = (json['data']['movimientos'] as List<dynamic>);
    final movimientos = movimientosJson.map((item) => MovimientoDto.fromJson(item as Map<String, dynamic>)).toList();

    final paginationJson = json['pagination'] as Map<String, dynamic>;
    final pagination = PaginationDto.fromJson(paginationJson);

    return MovimientosResponseDto(
      movimientos: movimientos,
      pagination: pagination,
    );
  }

  MovimientosResponse toEntity() {
    return MovimientosResponse(
      movimientos: movimientos.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
