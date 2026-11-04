import '../../domain/entities/iva.dart';

class IvaDto {
  final int ivaId;
  final String descripcion;
  final String valor;
  final bool activo;

  IvaDto({
    required this.ivaId,
    required this.descripcion,
    required this.valor,
    required this.activo,
  });

  factory IvaDto.fromJson(Map<String, dynamic> json) {
    return IvaDto(
      ivaId: json['ivaId'] as int,
      descripcion: json['descripcion'] as String,
      valor: json['valor'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ivaId': ivaId,
      'descripcion': descripcion,
      'valor': valor,
      'activo': activo,
    };
  }

  Iva toEntity() {
    return Iva(
      ivaId: ivaId,
      descripcion: descripcion,
      valor: valor,
      activo: activo,
    );
  }
}
