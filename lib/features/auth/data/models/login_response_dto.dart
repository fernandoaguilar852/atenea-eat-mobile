class LoginResponseDto {
  final ResponseHeaders headers;
  final MessageResponse messageResponse;
  final LoginData data;

  const LoginResponseDto({
    required this.headers,
    required this.messageResponse,
    required this.data,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      headers: ResponseHeaders.fromJson(json['headers']),
      messageResponse: MessageResponse.fromJson(json['messageResponse']),
      data: LoginData.fromJson(json['data']),
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

class LoginData {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int refreshExpiresIn;

  const LoginData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshExpiresIn,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      refreshExpiresIn: json['refreshExpiresIn'] as int,
    );
  }
}
