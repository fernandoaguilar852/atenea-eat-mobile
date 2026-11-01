import '../../domain/entities/categorias_response.dart';
import 'categoria_dto.dart';

class CategoriasResponseDto {
  final List<CategoriaDto> categorias;

  CategoriasResponseDto({
    required this.categorias,
  });

  factory CategoriasResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final categorias = data
        .map((item) => CategoriaDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return CategoriasResponseDto(
      categorias: categorias,
    );
  }

  CategoriasResponse toEntity() {
    return CategoriasResponse(
      categorias: categorias.map((dto) => dto.toEntity()).toList(),
    );
  }
}
