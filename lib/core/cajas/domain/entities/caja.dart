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

  Caja copyWith({
    int? cajaId,
    int? clienteId,
    int? usuarioId,
    String? estado,
    String? fecha,
    String? saldoInicial,
    String? openedAt,
    String? closedAt,
    String? nombreUsuario,
  }) {
    return Caja(
      cajaId: cajaId ?? this.cajaId,
      clienteId: clienteId ?? this.clienteId,
      usuarioId: usuarioId ?? this.usuarioId,
      estado: estado ?? this.estado,
      fecha: fecha ?? this.fecha,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
    );
  }
}
