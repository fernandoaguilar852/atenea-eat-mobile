class Alerta {
  final int alertaId;
  final int? productoId;
  final int? insumoId;
  final int clienteId;
  final String nombre;
  final int stockActual;
  final int stockMinimo;
  final String fechaAlerta;
  final bool notificado;
  final String? fechaNotificacion;
  final bool activa;
  final String? fechaResolucion;
  final int porcentajeStock;
  final int diasEnAlerta;

  const Alerta({
    required this.alertaId,
    this.productoId,
    this.insumoId,
    required this.clienteId,
    required this.nombre,
    required this.stockActual,
    required this.stockMinimo,
    required this.fechaAlerta,
    required this.notificado,
    this.fechaNotificacion,
    required this.activa,
    this.fechaResolucion,
    required this.porcentajeStock,
    required this.diasEnAlerta,
  });
}
