class Insumo {
  final int insumoId;
  final int clienteId;
  final String nombre;
  final String unidadBase;
  final String stockActual;
  final String stockMinimo;
  final String stockReservado;
  final String costoPromedio;
  final bool activo;
  final String creadoEn;

  Insumo({
    required this.insumoId,
    required this.clienteId,
    required this.nombre,
    required this.unidadBase,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockReservado,
    required this.costoPromedio,
    required this.activo,
    required this.creadoEn,
  });
}
