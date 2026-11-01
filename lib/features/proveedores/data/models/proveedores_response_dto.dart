import '../../../reportes/data/models/pagination_dto.dart';
import '../../domain/entities/proveedores_response.dart';
import 'proveedor_dto.dart';

class ProveedoresResponseDto {
  final List<ProveedorDto> proveedores;
  final PaginationDto pagination;

  ProveedoresResponseDto({
    required this.proveedores,
    required this.pagination,
  });

  factory ProveedoresResponseDto.fromJson(Map<String, dynamic> json) {
    return ProveedoresResponseDto(
      proveedores: (json['data']['proveedores'] as List)
          .map((proveedor) => ProveedorDto.fromJson(proveedor))
          .toList(),
      pagination: PaginationDto.fromJson(json['pagination']),
    );
  }

  ProveedoresResponse toEntity() {
    return ProveedoresResponse(
      proveedores: proveedores.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
