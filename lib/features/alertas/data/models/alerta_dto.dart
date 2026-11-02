import '../../domain/entities/alerta.dart';

class AlertaDto {
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

  const AlertaDto({
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

  factory AlertaDto.fromJson(Map<String, dynamic> json) {
    return AlertaDto(
      alertaId: json['alertaId'] as int,
      productoId: json['productoId'] as int?,
      insumoId: json['insumoId'] as int?,
      clienteId: json['clienteId'] as int,
      nombre: json['nombre'] as String,
      stockActual: json['stockActual'] as int,
      stockMinimo: json['stockMinimo'] as int,
      fechaAlerta: json['fechaAlerta'] as String,
      notificado: json['notificado'] as bool,
      fechaNotificacion: json['fechaNotificacion'] as String?,
      activa: json['activa'] as bool,
      fechaResolucion: json['fechaResolucion'] as String?,
      porcentajeStock: json['porcentajeStock'] as int,
      diasEnAlerta: json['diasEnAlerta'] as int,
    );
  }

  Alerta toEntity() {
    return Alerta(
      alertaId: alertaId,
      productoId: productoId,
      insumoId: insumoId,
      clienteId: clienteId,
      nombre: nombre,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      fechaAlerta: fechaAlerta,
      notificado: notificado,
      fechaNotificacion: fechaNotificacion,
      activa: activa,
      fechaResolucion: fechaResolucion,
      porcentajeStock: porcentajeStock,
      diasEnAlerta: diasEnAlerta,
    );
  }
}
