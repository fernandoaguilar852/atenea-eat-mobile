class Categoria {
  final int tipoProductoId;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Categoria({
    required this.tipoProductoId,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });
}
