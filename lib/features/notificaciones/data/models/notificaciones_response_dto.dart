class NotificacionesResponseDto {
  final ResponseHeaders headers;
  final MessageResponse messageResponse;
  final NotificacionesData data;
  final PaginationDto pagination;

  const NotificacionesResponseDto({
    required this.headers,
    required this.messageResponse,
    required this.data,
    required this.pagination,
  });

  factory NotificacionesResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificacionesResponseDto(
      headers: ResponseHeaders.fromJson(json['headers'] as Map<String, dynamic>),
      messageResponse: MessageResponse.fromJson(json['messageResponse'] as Map<String, dynamic>),
      data: NotificacionesData.fromJson(json['data'] as Map<String, dynamic>),
      pagination: PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
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

class NotificacionesData {
  final List<NotificacionDto> notificaciones;

  const NotificacionesData({
    required this.notificaciones,
  });

  factory NotificacionesData.fromJson(Map<String, dynamic> json) {
    return NotificacionesData(
      notificaciones: (json['notificaciones'] as List)
          .map((n) => NotificacionDto.fromJson(n as Map<String, dynamic>))
          .toList(),
    );
  }
}

class NotificacionDto {
  final int notificacionId;
  final int clienteId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String prioridad;
  final String estado;
  final int? resolucionId;
  final Map<String, dynamic>? metadata;
  final String createdAt;
  final String updatedAt;
  final String? leidaAt;
  final String? archivadaAt;

  const NotificacionDto({
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

  factory NotificacionDto.fromJson(Map<String, dynamic> json) {
    return NotificacionDto(
      notificacionId: json['notificacionId'] as int,
      clienteId: json['clienteId'] as int,
      tipo: json['tipo'] as String,
      titulo: json['titulo'] as String,
      mensaje: json['mensaje'] as String,
      prioridad: json['prioridad'] as String,
      estado: json['estado'] as String,
      resolucionId: json['resolucionId'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      leidaAt: json['leidaAt'] as String?,
      archivadaAt: json['archivadaAt'] as String?,
    );
  }
}

class PaginationDto {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const PaginationDto({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      totalElement: json['totalElement'] as int,
      pageSize: json['pageSize'] as int,
      pageNumber: json['pageNumber'] as int,
      hasMoreElements: json['hasMoreElements'] as bool,
    );
  }
}
