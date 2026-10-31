import 'package:equatable/equatable.dart';

class Notificacion extends Equatable {
  final int notificacionId;
  final int clienteId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String prioridad;
  final String estado;
  final int? resolucionId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? leidaAt;
  final DateTime? archivadaAt;

  const Notificacion({
    required this.notificacionId,
    required this.clienteId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.prioridad,
    required this.estado,
    this.resolucionId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.leidaAt,
    this.archivadaAt,
  });

  @override
  List<Object?> get props => [
        notificacionId,
        clienteId,
        tipo,
        titulo,
        mensaje,
        prioridad,
        estado,
        resolucionId,
        metadata,
        createdAt,
        updatedAt,
        leidaAt,
        archivadaAt,
      ];
}
