import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../services/credentials_storage_service.dart';

// Provider del cliente Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiVersion}',
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Logger para debug
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  );

  // Interceptor para agregar token y headers requeridos automáticamente
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Agregar Authorization header si existe un token
        final storage = CredentialsStorageService();
        final token = await storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
        }

        // Agregar headers requeridos por el API
        options.headers[ApiConstants.headerMessageUuid] = '550e8400-e29b-41d4-a716-446655440000';
        options.headers[ApiConstants.headerRequestAppId] = ApiConstants.defaultAppId;

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Manejo de errores global
        if (error.response?.statusCode == 401) {
          // Token expirado - en el futuro implementar refresh token
          // Por ahora simplemente propagar el error
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
