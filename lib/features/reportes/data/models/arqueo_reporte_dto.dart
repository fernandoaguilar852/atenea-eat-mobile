import '../../domain/entities/arqueo_reporte.dart';
import 'encabezado_dto.dart';
import 'pagination_dto.dart';

class ArqueoTransaccionDto {
  final int transaccionId;
  final String tipoTransaccion;
  final String tipoPago;
  final String fechaTransaccion;
  final int? pagoId;
  final String? metodoPago;
  final num valor;

  ArqueoTransaccionDto({
    required this.transaccionId,
    required this.tipoTransaccion,
    required this.tipoPago,
    required this.fechaTransaccion,
    this.pagoId,
    this.metodoPago,
    required this.valor,
  });

  factory ArqueoTransaccionDto.fromJson(Map<String, dynamic> json) {
    return ArqueoTransaccionDto(
      transaccionId: json['transaccionId'] as int,
      tipoTransaccion: json['tipoTransaccion'] as String,
      tipoPago: json['tipoPago'] as String,
      fechaTransaccion: json['fechaTransaccion'] as String,
      pagoId: json['pagoId'] as int?,
      metodoPago: json['metodoPago'] as String?,
      valor: json['valor'] as num,
    );
  }

  ArqueoTransaccion toEntity() => ArqueoTransaccion(
        transaccionId: transaccionId,
        tipoTransaccion: tipoTransaccion,
        tipoPago: tipoPago,
        fechaTransaccion: DateTime.parse(fechaTransaccion),
        pagoId: pagoId,
        metodoPago: metodoPago,
        valor: valor,
      );
}

class ArqueoResumenDto {
  final num totalGeneral;
  final num totalCaja;
  final num totalBanco;
  final int totalTransacciones;
  final Map<String, String> rangoFechas;

  ArqueoResumenDto({
    required this.totalGeneral,
    required this.totalCaja,
    required this.totalBanco,
    required this.totalTransacciones,
    required this.rangoFechas,
  });

  factory ArqueoResumenDto.fromJson(Map<String, dynamic> json) {
    return ArqueoResumenDto(
      totalGeneral: json['totalGeneral'] as num,
      totalCaja: json['totalCaja'] as num,
      totalBanco: json['totalBanco'] as num,
      totalTransacciones: json['totalTransacciones'] as int,
      rangoFechas: (json['rangoFechas'] as Map<String, dynamic>).cast<String, String>(),
    );
  }

  ArqueoResumen toEntity() => ArqueoResumen(
        totalGeneral: totalGeneral,
        totalCaja: totalCaja,
        totalBanco: totalBanco,
        totalTransacciones: totalTransacciones,
        rangoDesde: DateTime.parse(rangoFechas['desde']!),
        rangoHasta: DateTime.parse(rangoFechas['hasta']!),
      );
}

class ArqueoReporteResponseDto {
  final EncabezadoDto encabezado;
  final Map<String, dynamic> reporteArqueo;
  final ArqueoResumenDto resumen;
  final PaginationDto pagination;

  ArqueoReporteResponseDto({
    required this.encabezado,
    required this.reporteArqueo,
    required this.resumen,
    required this.pagination,
  });

  factory ArqueoReporteResponseDto.fromJson(Map<String, dynamic> json) {
    return ArqueoReporteResponseDto(
      encabezado: EncabezadoDto.fromJson(json['encabezado'] as Map<String, dynamic>),
      reporteArqueo: json['reporteArqueo'] as Map<String, dynamic>,
      resumen: ArqueoResumenDto.fromJson(json['resumen'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  ArqueoReporte toEntity() {
    final transacciones = (reporteArqueo['transacciones'] as List? ?? [])
        .where((e) => e != null)
        .map((e) => ArqueoTransaccionDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();

    return ArqueoReporte(
      encabezado: encabezado.toEntity(),
      transacciones: transacciones,
      resumen: resumen.toEntity(),
      pagination: pagination.toEntity(),
    );
  }
}
