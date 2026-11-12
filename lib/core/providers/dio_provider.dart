import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../services/credentials_storage_service.dart';
import '../services/navigation_service.dart';

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

  // Logger solo en debug: en release expondría tokens y contraseñas en el log del sistema
  if (kDebugMode) {
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
  }

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
          // Token expirado - limpiar sesión y redirigir al login
          try {
            // Limpiar tokens y cache de datos del usuario
            final storage = CredentialsStorageService();
            await storage.clearTokens();
            await storage.clearUserData();

            // Redirigir al login (el estado de auth se limpiará automáticamente)
            NavigationService().navigateToLogin();
          } catch (e) {
            // Si hay error al limpiar, igual redirigir al login
            NavigationService().navigateToLogin();
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
