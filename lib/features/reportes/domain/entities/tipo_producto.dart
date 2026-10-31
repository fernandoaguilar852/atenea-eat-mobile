class TipoProducto {
  final int tipoProductoId;
  final int clienteId;
  final String nombre;
  final String descripcion;
  final bool activo;
  final String createdAt;

  TipoProducto({
    required this.tipoProductoId,
    required this.clienteId,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.createdAt,
  });
}
