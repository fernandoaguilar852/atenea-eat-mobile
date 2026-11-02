class ChatQueryResponseDto {
  final ResponseHeaders headers;
  final MessageResponse messageResponse;
  final ChatData data;

  const ChatQueryResponseDto({
    required this.headers,
    required this.messageResponse,
    required this.data,
  });

  factory ChatQueryResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatQueryResponseDto(
      headers: ResponseHeaders.fromJson(json['headers'] as Map<String, dynamic>),
      messageResponse: MessageResponse.fromJson(json['messageResponse'] as Map<String, dynamic>),
      data: ChatData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ResponseHeaders {
  final int httpStatusCode;
  final String messageUuid;
  final String requestAppId;

  const ResponseHeaders({
    required this.httpStatusCode,
    required this.messageUuid,
    required this.requestAppId,
  });

  factory ResponseHeaders.fromJson(Map<String, dynamic> json) {
    return ResponseHeaders(
      httpStatusCode: json['httpStatusCode'] as int,
      messageUuid: json['messageUuid'] as String,
      requestAppId: json['requestAppId'] as String,
    );
  }
}

class MessageResponse {
  final String responseCode;
  final String responseMessage;

  const MessageResponse({
    required this.responseCode,
    required this.responseMessage,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      responseCode: json['responseCode'] as String,
      responseMessage: json['responseMessage'] as String,
    );
  }
}

class ChatData {
  final String answer;
  final List<Map<String, dynamic>>? data;
  final String? querySource;
  final String? explanation;
  final String? templateUsed;

  const ChatData({
    required this.answer,
    this.data,
    this.querySource,
    this.explanation,
    this.templateUsed,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      answer: json['answer'] as String,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList()
          : null,
      querySource: json['querySource'] as String?,
      explanation: json['explanation'] as String?,
      templateUsed: json['templateUsed'] as String?,
    );
  }
}
