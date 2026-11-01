import 'producto_dto.dart';
import '../../domain/entities/productos_response.dart';
import '../../../reportes/data/models/pagination_dto.dart';

class ProductosResponseDto {
  final List<ProductoDto> productos;
  final PaginationDto pagination;

  ProductosResponseDto({
    required this.productos,
    required this.pagination,
  });

  factory ProductosResponseDto.fromJson(Map<String, dynamic> json) {
    final dataList = json['data']['products'] as List;
    final productos = dataList.map((json) => ProductoDto.fromJson(json)).toList();

    final pagination = PaginationDto.fromJson(json['pagination']);

    return ProductosResponseDto(
      productos: productos,
      pagination: pagination,
    );
  }

  ProductosResponse toEntity() {
    return ProductosResponse(
      productos: productos.map((dto) => dto.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}
