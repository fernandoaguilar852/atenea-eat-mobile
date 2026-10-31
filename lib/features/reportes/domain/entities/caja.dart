class Caja {
  final int cajaId;
  final int clienteId;
  final int usuarioId;
  final String estado;
  final String fecha;
  final String saldoInicial;
  final String openedAt;
  final String? closedAt;
  String? nombreUsuario; // Se llenará después de consultar el usuario

  Caja({
    required this.cajaId,
    required this.clienteId,
    required this.usuarioId,
    required this.estado,
    required this.fecha,
    required this.saldoInicial,
    required this.openedAt,
    this.closedAt,
    this.nombreUsuario,
  });

  bool get isAbierta => estado.toLowerCase() == 'abierta';
}
