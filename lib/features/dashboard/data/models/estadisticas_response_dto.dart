class EstadisticasResponseDto {
  final ResponseHeaders headers;
  final MessageResponse messageResponse;
  final EstadisticasData data;

  const EstadisticasResponseDto({
    required this.headers,
    required this.messageResponse,
    required this.data,
  });

  factory EstadisticasResponseDto.fromJson(Map<String, dynamic> json) {
    return EstadisticasResponseDto(
      headers: ResponseHeaders.fromJson(json['headers'] as Map<String, dynamic>),
      messageResponse: MessageResponse.fromJson(json['messageResponse'] as Map<String, dynamic>),
      data: EstadisticasData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ResponseHeaders {
  final int httpStatusCode;
  final String httpStatusDesc;
  final String messageUuid;
  final String requestDatetime;
  final String requestAppId;

  const ResponseHeaders({
    required this.httpStatusCode,
    required this.httpStatusDesc,
    required this.messageUuid,
    required this.requestDatetime,
    required this.requestAppId,
  });

  factory ResponseHeaders.fromJson(Map<String, dynamic> json) {
    return ResponseHeaders(
      httpStatusCode: json['httpStatusCode'] as int,
      httpStatusDesc: json['httpStatusDesc'] as String,
      messageUuid: json['messageUuid'] as String,
      requestDatetime: json['requestDatetime'] as String,
      requestAppId: json['requestAppId'] as String,
    );
  }
}

class MessageResponse {
  final String responseCode;
  final String responseMessage;
  final String responseDetails;

  const MessageResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.responseDetails,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      responseCode: json['responseCode'] as String,
      responseMessage: json['responseMessage'] as String,
      responseDetails: json['responseDetails'] as String,
    );
  }
}

class EstadisticasData {
  final int ventasDia;
  final int cantidadFacturas;
  final num totalIngresos;
  final int cantidadAlertas;
  final int totalReservas;
  final int totalReservasConfirmadas;
  final int totalOrdenesAbiertas;
  final int totalOrdenesEnProceso;
  final int totalOrdenesCerradas;
  final int totalMesas;
  final int totalMesasOcupadas;
  final int totalMesasLibres;
  final int totalComandasPendientes;
  final int totalComandasEnPreparacion;
  final int totalComandasListas;

  const EstadisticasData({
    required this.ventasDia,
    required this.cantidadFacturas,
    required this.totalIngresos,
    required this.cantidadAlertas,
    required this.totalReservas,
    required this.totalReservasConfirmadas,
    required this.totalOrdenesAbiertas,
    required this.totalOrdenesEnProceso,
    required this.totalOrdenesCerradas,
    required this.totalMesas,
    required this.totalMesasOcupadas,
    required this.totalMesasLibres,
    required this.totalComandasPendientes,
    required this.totalComandasEnPreparacion,
    required this.totalComandasListas,
  });

  factory EstadisticasData.fromJson(Map<String, dynamic> json) {
    return EstadisticasData(
      ventasDia: (json['ventasDia'] as num).toInt(),
      cantidadFacturas: (json['cantidadFacturas'] as num).toInt(),
      totalIngresos: json['totalIngresos'] as num,
      cantidadAlertas: (json['cantidadAlertas'] as num).toInt(),
      totalReservas: (json['totalReservas'] as num).toInt(),
      totalReservasConfirmadas: (json['totalReservasConfirmadas'] as num).toInt(),
      totalOrdenesAbiertas: (json['totalOrdenesAbiertas'] as num).toInt(),
      totalOrdenesEnProceso: (json['totalOrdenesEnProceso'] as num).toInt(),
      totalOrdenesCerradas: (json['totalOrdenesCerradas'] as num).toInt(),
      totalMesas: (json['totalMesas'] as num).toInt(),
      totalMesasOcupadas: (json['totalMesasOcupadas'] as num).toInt(),
      totalMesasLibres: (json['totalMesasLibres'] as num).toInt(),
      totalComandasPendientes: (json['totalComandasPendientes'] as num).toInt(),
      totalComandasEnPreparacion: (json['totalComandasEnPreparacion'] as num).toInt(),
      totalComandasListas: (json['totalComandasListas'] as num).toInt(),
    );
  }
}
