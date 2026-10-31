import 'package:equatable/equatable.dart';
import 'encabezado.dart';
import 'pagination.dart';

/// Transacción de arqueo de caja
class ArqueoTransaccion extends Equatable {
  final int transaccionId;
  final String tipoTransaccion;
  final String tipoPago;
  final DateTime fechaTransaccion;
  final int? pagoId;
  final String? metodoPago;
  final num valor;

  const ArqueoTransaccion({
    required this.transaccionId,
    required this.tipoTransaccion,
    required this.tipoPago,
    required this.fechaTransaccion,
    this.pagoId,
    this.metodoPago,
    required this.valor,
  });

  @override
  List<Object?> get props => [
        transaccionId,
        tipoTransaccion,
        tipoPago,
        fechaTransaccion,
        pagoId,
        metodoPago,
        valor,
      ];
}

/// Resumen de arqueo
class ArqueoResumen extends Equatable {
  final num totalGeneral;
  final num totalCaja;
  final num totalBanco;
  final int totalTransacciones;
  final DateTime rangoDesde;
  final DateTime rangoHasta;

  const ArqueoResumen({
    required this.totalGeneral,
    required this.totalCaja,
    required this.totalBanco,
    required this.totalTransacciones,
    required this.rangoDesde,
    required this.rangoHasta,
  });

  @override
  List<Object?> get props => [
        totalGeneral,
        totalCaja,
        totalBanco,
        totalTransacciones,
        rangoDesde,
        rangoHasta,
      ];
}

/// Reporte completo de arqueo de caja
class ArqueoReporte extends Equatable {
  final Encabezado encabezado;
  final List<ArqueoTransaccion> transacciones;
  final ArqueoResumen resumen;
  final Pagination pagination;

  const ArqueoReporte({
    required this.encabezado,
    required this.transacciones,
    required this.resumen,
    required this.pagination,
  });

  @override
  List<Object?> get props => [
        encabezado,
        transacciones,
        resumen,
        pagination,
      ];
}
