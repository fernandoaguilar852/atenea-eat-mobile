class Resolucion {
  final int resolucionId;
  final int clienteId;
  final String prefijo;
  final int numeroDesde;
  final int numeroHasta;
  final int numeroActual;
  final String numeroResolucion;
  final String fechaResolucion;
  final String fechaVencimiento;
  final bool activo;
  final String createdAt;

  const Resolucion({
    required this.resolucionId,
    required this.clienteId,
    required this.prefijo,
    required this.numeroDesde,
    required this.numeroHasta,
    required this.numeroActual,
    required this.numeroResolucion,
    required this.fechaResolucion,
    required this.fechaVencimiento,
    required this.activo,
    required this.createdAt,
  });

  // Calcular resoluciones disponibles
  int get resolucionesDisponibles => numeroHasta - numeroActual + 1;

  // Calcular porcentaje utilizado
  int get porcentajeUtilizado {
    final total = numeroHasta - numeroDesde + 1;
    final utilizadas = numeroActual - numeroDesde;
    return ((utilizadas / total) * 100).round();
  }
}
